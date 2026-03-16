import 'dart:ui' as ui;

import 'package:flutter/gestures.dart' show PointerDeviceKind;
import 'package:flutter/material.dart';
import 'package:runa/domain/domain.dart';
import 'package:uuid/uuid.dart';

// ---------------------------------------------------------------------------
// InkAnnotationLayer
// ---------------------------------------------------------------------------

/// A transparent ink canvas that overlays annotated strokes on top of a
/// sibling widget (typically an [Image]).
///
/// Stroke coordinates are stored as **normalised values in [0.0, 1.0]**
/// relative to the widget's render size.  Raw pointer events are normalised
/// before committing; stored strokes are un-normalised before painting.
///
/// When [readOnly] is `true` the layer renders stored strokes but ignores all
/// pointer input — useful when the block is not selected.
class InkAnnotationLayer extends StatefulWidget {
  const InkAnnotationLayer({
    super.key,
    required this.strokes,
    required this.onStrokesChanged,
    required this.activeTool,
    required this.activeColor,
    required this.activeWidth,
    this.readOnly = false,
    this.stylusOnly = false,
  });

  /// Committed strokes with normalised coordinates [0.0, 1.0].
  final List<Stroke> strokes;

  /// Called with the updated stroke list after each commit or erase.
  final ValueChanged<List<Stroke>> onStrokesChanged;

  final StrokeTool activeTool;

  /// Active colour in `#RRGGBBAA` format.
  final String activeColor;

  /// Base stroke width in logical pixels.
  final double activeWidth;

  /// When `true`, pointer events are ignored (block not selected).
  final bool readOnly;

  /// When `true`, only stylus/pen/mouse input draws; touch events are ignored.
  final bool stylusOnly;

  @override
  State<InkAnnotationLayer> createState() => _InkAnnotationLayerState();
}

class _InkAnnotationLayerState extends State<InkAnnotationLayer> {
  static const _uuid = Uuid();
  static const _eraserRadius = 20.0;

  /// In-progress stroke points in **pixel** space.
  List<StrokePoint> _currentPoints = [];

  /// Render size captured from [LayoutBuilder].
  Size _size = Size.zero;

  // Holds the parent scroll position while a pointer is active on the layer.
  ScrollHoldController? _scrollHold;

  void _holdScroll() {
    _scrollHold = Scrollable.maybeOf(context)?.position.hold(() {});
  }

  void _releaseScrollHold() {
    _scrollHold?.cancel();
    _scrollHold = null;
  }

  StrokePoint _makePoint(PointerEvent e) => StrokePoint(
        x: e.localPosition.dx,
        y: e.localPosition.dy,
        pressure: e.pressure > 0.0 ? e.pressure : 1.0,
        timestamp: DateTime.now().millisecondsSinceEpoch,
      );

  bool _isBlockedTouch(PointerEvent e) =>
      widget.stylusOnly && e.kind == PointerDeviceKind.touch;

  void _onPointerDown(PointerDownEvent e) {
    if (_isBlockedTouch(e)) return;
    _holdScroll();
    setState(() => _currentPoints = [_makePoint(e)]);
  }

  void _onPointerMove(PointerMoveEvent e) {
    if (_isBlockedTouch(e)) return;
    setState(() => _currentPoints = [..._currentPoints, _makePoint(e)]);
  }

  void _onPointerUp(PointerUpEvent e) {
    if (_isBlockedTouch(e)) return;
    _releaseScrollHold();
    final allPoints = [..._currentPoints, _makePoint(e)];
    setState(() => _currentPoints = []);

    if (widget.activeTool == StrokeTool.eraser) {
      _handleErase(allPoints);
    } else {
      _commitStroke(allPoints);
    }
  }

  /// Normalises [pixelPoints] by dividing by render size and commits to
  /// [widget.strokes] via [widget.onStrokesChanged].
  void _commitStroke(List<StrokePoint> pixelPoints) {
    if (pixelPoints.isEmpty || _size == Size.zero) return;
    final normalised = pixelPoints
        .map(
          (p) => p.copyWith(
            x: (_size.width > 0) ? p.x / _size.width : 0.0,
            y: (_size.height > 0) ? p.y / _size.height : 0.0,
          ),
        )
        .toList();

    final stroke = Stroke(
      id: _uuid.v4(),
      color: widget.activeColor,
      width: widget.activeWidth,
      tool: widget.activeTool,
      points: normalised,
    );
    widget.onStrokesChanged([...widget.strokes, stroke]);
  }

  /// Erases any stroke whose normalised points (un-normalised to pixel space)
  /// fall within [_eraserRadius] of any eraser point.
  void _handleErase(List<StrokePoint> eraserPixelPoints) {
    if (_size == Size.zero) return;
    final remaining = widget.strokes
        .where((s) => !_intersectsEraser(s, eraserPixelPoints))
        .toList();
    if (remaining.length != widget.strokes.length) {
      widget.onStrokesChanged(remaining);
    }
  }

  bool _intersectsEraser(Stroke stroke, List<StrokePoint> eraser) {
    const r2 = _eraserRadius * _eraserRadius;
    for (final ep in eraser) {
      for (final sp in stroke.points) {
        // Un-normalise stored stroke point to pixel space.
        final px = sp.x * _size.width;
        final py = sp.y * _size.height;
        final dx = px - ep.x;
        final dy = py - ep.y;
        if (dx * dx + dy * dy <= r2) return true;
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final newSize = Size(constraints.maxWidth, constraints.maxHeight);
        if (_size != newSize) {
          // Schedule after frame to avoid calling setState during build.
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) setState(() => _size = newSize);
          });
        }
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          supportedDevices: (widget.readOnly || !widget.stylusOnly)
              ? null
              : {
                  PointerDeviceKind.stylus,
                  PointerDeviceKind.invertedStylus,
                  PointerDeviceKind.mouse,
                },
          onVerticalDragStart: widget.readOnly ? null : (_) {},
          onVerticalDragUpdate: widget.readOnly ? null : (_) {},
          onVerticalDragEnd: widget.readOnly ? null : (_) {},
          child: Listener(
          onPointerDown: widget.readOnly ? null : _onPointerDown,
          onPointerMove: widget.readOnly ? null : _onPointerMove,
          onPointerUp: widget.readOnly ? null : _onPointerUp,
          onPointerCancel: widget.readOnly ? null : (_) => _releaseScrollHold(),
          child: CustomPaint(
            painter: _AnnotationPainter(
              strokes: widget.strokes,
              currentPoints: _currentPoints,
              activeTool: widget.activeTool,
              renderSize: _size,
            ),
            size: Size.infinite,
          ),
          ),  // Listener
        );    // GestureDetector
      },
    );
  }
}

// ---------------------------------------------------------------------------
// _AnnotationPainter
// ---------------------------------------------------------------------------

class _AnnotationPainter extends CustomPainter {
  const _AnnotationPainter({
    required this.strokes,
    required this.currentPoints,
    required this.activeTool,
    required this.renderSize,
    StrokeSmoother? smoother,
  }) : smoother = smoother ?? const StrokeSmoother();

  /// Committed strokes with **normalised** coordinates.
  final List<Stroke> strokes;

  /// In-progress points in **pixel** space.
  final List<StrokePoint> currentPoints;
  final StrokeTool activeTool;

  /// Current render size used to un-normalise stored strokes.
  final Size renderSize;
  final StrokeSmoother smoother;

  @override
  void paint(Canvas canvas, Size size) {
    final w = renderSize.width > 0 ? renderSize.width : size.width;
    final h = renderSize.height > 0 ? renderSize.height : size.height;

    // Draw committed strokes (un-normalise to pixel coords for painting).
    for (final stroke in strokes) {
      if (stroke.tool == StrokeTool.eraser) continue;
      final pixelPoints = stroke.points
          .map((p) => p.copyWith(x: p.x * w, y: p.y * h))
          .toList();
      final smoothed = smoother.smooth(pixelPoints);
      if (smoothed.length < 2) continue;
      canvas.drawPath(_buildPath(smoothed), _makePaint(stroke));
    }

    // Draw in-progress stroke (raw pixel coords, no smoothing yet).
    if (currentPoints.length >= 2 && activeTool != StrokeTool.eraser) {
      final rawOffsets =
          currentPoints.map((p) => ui.Offset(p.x, p.y)).toList();
      final preview = Paint()
        ..color = const Color(0xFF888888)
        ..strokeWidth = 1.5
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke;
      canvas.drawPath(_buildPath(rawOffsets), preview);
    }
  }

  Path _buildPath(List<ui.Offset> offsets) {
    final path = Path()..moveTo(offsets.first.dx, offsets.first.dy);
    for (final o in offsets.skip(1)) {
      path.lineTo(o.dx, o.dy);
    }
    return path;
  }

  Paint _makePaint(Stroke stroke) {
    final color = _parseColor(stroke.color);
    final paint = Paint()
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    switch (stroke.tool) {
      case StrokeTool.pen:
        paint.color = color;
        paint.strokeWidth = stroke.width;
      case StrokeTool.pencil:
        paint.color = color.withValues(alpha: color.a * 0.6);
        paint.strokeWidth = stroke.width * 0.8;
      case StrokeTool.marker:
        paint.color = color.withValues(alpha: color.a * 0.4);
        paint.strokeWidth = stroke.width * 3;
      case StrokeTool.eraser:
        break;
      case StrokeTool.text:
        break;
    }
    return paint;
  }

  static Color _parseColor(String hex) {
    final h = hex.replaceFirst('#', '');
    final r = int.parse(h.substring(0, 2), radix: 16);
    final g = int.parse(h.substring(2, 4), radix: 16);
    final b = int.parse(h.substring(4, 6), radix: 16);
    final a = int.parse(h.substring(6, 8), radix: 16);
    return Color.fromARGB(a, r, g, b);
  }

  @override
  bool shouldRepaint(_AnnotationPainter old) =>
      old.strokes != strokes ||
      old.currentPoints != currentPoints ||
      old.renderSize != renderSize;
}
