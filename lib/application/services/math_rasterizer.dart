import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_math_fork/flutter_math.dart';

/// Thrown by [MathRasterizer.rasterize] when [tex] fails to parse.
class MathRasterizeError extends Error {
  MathRasterizeError(this.message);

  final String message;

  @override
  String toString() => 'MathRasterizeError: $message';
}

/// Rasterizes TeX expressions to PNG bytes using [flutter_math_fork].
///
/// Results are cached in memory: the same combination of [tex], [style],
/// [fontSize], and [color] always returns the **same** [Uint8List] instance
/// (identity equality), making it safe to compare with [identical].
///
/// Must be called after `WidgetsFlutterBinding.ensureInitialized()` (which is
/// always the case in a running Flutter app or a `testWidgets` test).
class MathRasterizer {
  final Map<String, Uint8List> _cache = {};

  /// Renders [tex] to a PNG-encoded image and returns the raw bytes.
  ///
  /// - [style]: [MathStyle.text] (inline) or [MathStyle.display] (block).
  /// - [fontSize]: logical font size; the image is rasterized at 2× for clarity.
  /// - [color]: foreground colour of the rendered glyphs.
  ///
  /// Throws [MathRasterizeError] if [tex] is invalid TeX.
  Future<Uint8List> rasterize(
    String tex, {
    MathStyle style = MathStyle.text,
    double fontSize = 16.0,
    Color color = Colors.black,
  }) async {
    // Validate synchronously before any async work.
    final probe = Math.tex(
      tex,
      mathStyle: style,
      textStyle: TextStyle(fontSize: fontSize),
    );
    if (probe.parseError != null) {
      throw MathRasterizeError(probe.parseError!.message);
    }

    final cacheKey = '$tex\x00${style.index}\x00$fontSize\x00${color.toARGB32()}';
    if (_cache.containsKey(cacheKey)) return _cache[cacheKey]!;

    final widget = Math.tex(
      tex,
      mathStyle: style,
      // Render at 2× the requested fontSize; the PictureRecorder also uses
      // pixelRatio = 2.0, so the effective resolution is 4× screen pixels.
      textStyle: TextStyle(fontSize: fontSize * 2, color: color),
    );

    final bytes = await _captureWidget(widget);
    _cache[cacheKey] = bytes;
    return bytes;
  }

  // ---------------------------------------------------------------------------
  // Off-screen rendering pipeline
  // ---------------------------------------------------------------------------

  /// Pumps [widget] through a minimal Flutter rendering pipeline and returns
  /// the painted area as a 2× PNG image.
  static Future<Uint8List> _captureWidget(
    Widget widget, {
    double pixelRatio = 2.0,
  }) async {
    const logicalWidth = 1600.0;
    const logicalHeight = 400.0;

    final repaintBoundary = RenderRepaintBoundary();
    final pipelineOwner = PipelineOwner(onNeedVisualUpdate: () {});

    // We need a FlutterView to create a RenderView. In a running app or a
    // testWidgets test, the binding always has at least one view.
    final flutterView =
        WidgetsBinding.instance.platformDispatcher.views.first;

    final renderView = RenderView(
      view: flutterView,
      configuration: ViewConfiguration(
        physicalConstraints: BoxConstraints.tight(
          const Size(logicalWidth, logicalHeight) * pixelRatio,
        ),
        logicalConstraints: BoxConstraints.tight(
          const Size(logicalWidth, logicalHeight),
        ),
        devicePixelRatio: pixelRatio,
      ),
      child: RenderPositionedBox(
        alignment: Alignment.topLeft,
        child: repaintBoundary,
      ),
    );

    pipelineOwner.rootNode = renderView;
    renderView.prepareInitialFrame();

    final buildOwner = BuildOwner(focusManager: FocusManager());
    final rootElement = RenderObjectToWidgetAdapter<RenderBox>(
      container: repaintBoundary,
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: widget,
      ),
    ).attachToRenderTree(buildOwner);

    buildOwner.buildScope(rootElement);
    buildOwner.finalizeTree();

    pipelineOwner.flushLayout();
    pipelineOwner.flushCompositingBits();
    pipelineOwner.flushPaint();

    // toImageSync avoids the async GPU round-trip that hangs in headless
    // environments (test or otherwise).
    final image = repaintBoundary.toImageSync(pixelRatio: pixelRatio);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();
    return byteData!.buffer.asUint8List();
  }
}
