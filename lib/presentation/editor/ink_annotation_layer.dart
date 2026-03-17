import 'dart:math' as math;
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

  /// True when the current touch was identified as a palm on pointer-down.
  bool _palmRejected = false;

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
    _palmRejected = e.kind == PointerDeviceKind.touch && e.radiusMajor > 15.0;
    if (_palmRejected) return;
    _holdScroll();
    setState(() => _currentPoints = [_makePoint(e)]);
  }

  void _onPointerMove(PointerMoveEvent e) {
    if (_isBlockedTouch(e) || _palmRejected) return;
    if (_currentPoints.isNotEmpty) {
      final last = _currentPoints.last;
      final dx = e.localPosition.dx - last.x;
      final dy = e.localPosition.dy - last.y;
      if (dx * dx + dy * dy < 1.0) return;
    }
    setState(() => _currentPoints = [..._currentPoints, _makePoint(e)]);
  }

  void _onPointerUp(PointerUpEvent e) {
    if (_isBlockedTouch(e)) return;
    if (_palmRejected) {
      _palmRejected = false;
      _releaseScrollHold();
      return;
    }
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
    final simplified = _douglasPeucker(pixelPoints, 0.5);
    final normalised = simplified
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

  static List<StrokePoint> _douglasPeucker(
      List<StrokePoint> pts, double epsilon) {
    if (pts.length < 3) return pts;
    double maxDist = 0;
    int maxIdx = 0;
    final first = pts.first;
    final last = pts.last;
    for (int i = 1; i < pts.length - 1; i++) {
      final d = _perpDist(pts[i], first, last);
      if (d > maxDist) {
        maxDist = d;
        maxIdx = i;
      }
    }
    if (maxDist > epsilon) {
      final left = _douglasPeucker(pts.sublist(0, maxIdx + 1), epsilon);
      final right = _douglasPeucker(pts.sublist(maxIdx), epsilon);
      return [...left.sublist(0, left.length - 1), ...right];
    }
    return [first, last];
  }

  static double _perpDist(StrokePoint p, StrokePoint a, StrokePoint b) {
    final dx = b.x - a.x;
    final dy = b.y - a.y;
    final len2 = dx * dx + dy * dy;
    if (len2 < 1e-10) {
      final ex = p.x - a.x;
      final ey = p.y - a.y;
      return math.sqrt(ex * ex + ey * ey);
    }
    final t = ((p.x - a.x) * dx + (p.y - a.y) * dy) / len2;
    final px = a.x + t * dx;
    final py = a.y + t * dy;
    final ex = p.x - px;
    final ey = p.y - py;
    return math.sqrt(ex * ex + ey * ey);
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

    // Pass 1: highlighters render below all other strokes.
    for (final stroke in strokes) {
      if (stroke.tool != StrokeTool.highlighter) continue;
      final pixelPoints = stroke.points
          .map((p) => p.copyWith(x: p.x * w, y: p.y * h))
          .toList();
      final smoothed = smoother.smoothWithPressure(pixelPoints);
      if (smoothed.length < 2) continue;
      final color = _parseColor(stroke.color);
      _drawSegments(canvas, smoothed,
          color.withValues(alpha: color.a * 0.30), stroke.width * 5.0,
          taper: false, pressureSensitive: false);
    }

    // Pass 2: all other strokes.
    for (final stroke in strokes) {
      if (stroke.tool == StrokeTool.eraser ||
          stroke.tool == StrokeTool.highlighter) {
        continue;
      }
      final pixelPoints = stroke.points
          .map((p) => p.copyWith(x: p.x * w, y: p.y * h))
          .toList();
      final smoothed = smoother.smoothWithPressure(pixelPoints);
      if (smoothed.length < 2) continue;
      _drawStroke(canvas, smoothed, stroke);
    }

    if (currentPoints.length >= 2 && activeTool != StrokeTool.eraser) {
      final smoothed = smoother.smoothWithPressure(currentPoints);
      if (smoothed.length >= 2) {
        _drawSegments(canvas, smoothed, const Color(0xFF888888), 1.5,
            taper: false, pressureSensitive: false);
      }
    }
  }

  void _drawStroke(Canvas canvas, List<SmoothedPoint> pts, Stroke stroke) {
    final color = _parseColor(stroke.color);
    switch (stroke.tool) {
      case StrokeTool.pen:
        _drawRibbon(canvas, pts, color, stroke.width,
            taper: true, pressureSensitive: true, velocitySensitive: true);
      case StrokeTool.pencil:
        _drawSegments(canvas, pts,
            color.withValues(alpha: color.a * 0.65), stroke.width * 0.8,
            taper: true, pressureSensitive: true, velocitySensitive: true,
            grainSeed: stroke.id.hashCode);
      case StrokeTool.marker:
        _drawSegments(canvas, pts,
            color.withValues(alpha: color.a * 0.25), stroke.width * 4.2,
            taper: false, pressureSensitive: false);
        _drawSegments(canvas, pts,
            color.withValues(alpha: color.a * 0.4), stroke.width * 3,
            taper: false, pressureSensitive: false);
      case StrokeTool.fountainPen:
        _drawFountainPen(canvas, pts, color, stroke.width, taper: true);
      case StrokeTool.highlighter:
      case StrokeTool.eraser:
      case StrokeTool.text:
        break;
    }
  }

  // ---------------------------------------------------------------------------
  // Ribbon polygon — filled outline for pen/pencil variable-width strokes
  // ---------------------------------------------------------------------------

  void _drawRibbon(
    Canvas canvas,
    List<SmoothedPoint> pts,
    Color color,
    double baseWidth, {
    required bool taper,
    required bool pressureSensitive,
    bool velocitySensitive = false,
  }) {
    final n = pts.length;
    if (n < 1) return;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final taperN = taper ? (n / 4).floor().clamp(1, 10) : 0;

    final hw = List<double>.filled(n, 0);
    final normals = List<ui.Offset>.filled(n, ui.Offset.zero);

    for (int i = 0; i < n; i++) {
      double tFactor = 1.0;
      if (taperN > 0) {
        final entry = i < taperN ? i / taperN : 1.0;
        final exit = (n - 1 - i) < taperN ? (n - 1 - i) / taperN : 1.0;
        tFactor = math.min(entry, exit);
      }
      final pFactor = pressureSensitive
          ? 0.3 + 0.7 * math.pow(pts[i].pressure, 0.6)
          : 1.0;
      final vFactor =
          velocitySensitive ? (1.0 - pts[i].velocity * 0.35) : 1.0;
      hw[i] = (baseWidth * pFactor * vFactor * tFactor)
              .clamp(0.3, baseWidth * 2.0) /
          2;

      final ui.Offset tangent;
      if (i == 0) {
        tangent = pts[1].offset - pts[0].offset;
      } else if (i == n - 1) {
        tangent = pts[n - 1].offset - pts[n - 2].offset;
      } else {
        tangent = pts[i + 1].offset - pts[i - 1].offset;
      }
      final tLen =
          math.sqrt(tangent.dx * tangent.dx + tangent.dy * tangent.dy);
      if (tLen < 1e-6) {
        normals[i] = i > 0 ? normals[i - 1] : const ui.Offset(0, 1);
      } else {
        normals[i] = ui.Offset(-tangent.dy / tLen, tangent.dx / tLen);
      }
    }

    if (n == 1) {
      canvas.drawCircle(pts[0].offset, hw[0], paint);
      return;
    }

    final left = List<ui.Offset>.generate(
        n, (i) => pts[i].offset + normals[i] * hw[i]);
    final right = List<ui.Offset>.generate(
        n, (i) => pts[i].offset - normals[i] * hw[i]);

    final path = Path()..moveTo(left[0].dx, left[0].dy);
    for (int i = 1; i < n; i++) {
      path.lineTo(left[i].dx, left[i].dy);
    }
    for (int i = n - 1; i >= 0; i--) {
      path.lineTo(right[i].dx, right[i].dy);
    }
    path.close();

    canvas.drawPath(path, paint);
    canvas.drawCircle(pts[0].offset, hw[0], paint);
    canvas.drawCircle(pts[n - 1].offset, hw[n - 1], paint);
  }

  void _drawSegments(
    Canvas canvas,
    List<SmoothedPoint> pts,
    Color color,
    double baseWidth, {
    required bool taper,
    required bool pressureSensitive,
    bool velocitySensitive = false,
    int? grainSeed,
  }) {
    final n = pts.length;
    final taperN = taper ? (n / 4).floor().clamp(1, 10) : 0;
    final rng = grainSeed != null ? math.Random(grainSeed) : null;

    final paint = Paint()
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < n - 1; i++) {
      final p = pts[i];

      double tFactor = 1.0;
      if (taperN > 0) {
        final entry = i < taperN ? i / taperN : 1.0;
        final exit  = (n - 2 - i) < taperN ? (n - 2 - i) / taperN : 1.0;
        tFactor = math.min(entry, exit);
      }

      final pFactor = pressureSensitive
          ? 0.3 + 0.7 * math.pow(p.pressure, 0.6)
          : 1.0;
      final vFactor = velocitySensitive ? (1.0 - p.velocity * 0.35) : 1.0;
      final gFactor = rng != null ? 0.85 + rng.nextDouble() * 0.15 : 1.0;

      paint.color = color.withValues(alpha: color.a * gFactor);
      paint.strokeWidth =
          (baseWidth * pFactor * vFactor * tFactor).clamp(0.3, baseWidth * 2.0);
      canvas.drawLine(p.offset, pts[i + 1].offset, paint);
    }
  }

  // ---------------------------------------------------------------------------
  // Fountain pen — angle-aware calligraphy width
  // ---------------------------------------------------------------------------

  static const _kNibAngle = math.pi / 4;
  static const _kNibMinWidthFraction = 0.12;

  void _drawFountainPen(
    Canvas canvas,
    List<SmoothedPoint> pts,
    Color color,
    double baseWidth, {
    required bool taper,
  }) {
    final n = pts.length;
    if (n < 1) return;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final taperN = taper ? (n / 4).floor().clamp(1, 10) : 0;
    final hw = List<double>.filled(n, 0);
    final normals = List<ui.Offset>.filled(n, ui.Offset.zero);

    for (int i = 0; i < n; i++) {
      double tFactor = 1.0;
      if (taperN > 0) {
        final entry = i < taperN ? i / taperN : 1.0;
        final exit = (n - 1 - i) < taperN ? (n - 1 - i) / taperN : 1.0;
        tFactor = math.min(entry, exit);
      }

      final ui.Offset tangent;
      if (i == 0) {
        tangent = pts[1].offset - pts[0].offset;
      } else if (i == n - 1) {
        tangent = pts[n - 1].offset - pts[n - 2].offset;
      } else {
        tangent = pts[i + 1].offset - pts[i - 1].offset;
      }
      final tLen =
          math.sqrt(tangent.dx * tangent.dx + tangent.dy * tangent.dy);

      double aFactor = _kNibMinWidthFraction;
      if (tLen > 1e-6) {
        final strokeAngle = math.atan2(tangent.dy, tangent.dx);
        aFactor = _kNibMinWidthFraction +
            (1.0 - _kNibMinWidthFraction) *
                math.sin(strokeAngle - _kNibAngle).abs();
      }

      hw[i] =
          (baseWidth * aFactor * tFactor).clamp(0.3, baseWidth * 2.0) / 2;

      if (tLen < 1e-6) {
        normals[i] = i > 0 ? normals[i - 1] : const ui.Offset(0, 1);
      } else {
        normals[i] = ui.Offset(-tangent.dy / tLen, tangent.dx / tLen);
      }
    }

    if (n == 1) {
      canvas.drawCircle(pts[0].offset, hw[0], paint);
      return;
    }

    final left = List<ui.Offset>.generate(
        n, (i) => pts[i].offset + normals[i] * hw[i]);
    final right = List<ui.Offset>.generate(
        n, (i) => pts[i].offset - normals[i] * hw[i]);

    final path = Path()..moveTo(left[0].dx, left[0].dy);
    for (int i = 1; i < n; i++) {
      path.lineTo(left[i].dx, left[i].dy);
    }
    for (int i = n - 1; i >= 0; i--) {
      path.lineTo(right[i].dx, right[i].dy);
    }
    path.close();

    canvas.drawPath(path, paint);
    canvas.drawCircle(pts[0].offset, hw[0], paint);
    canvas.drawCircle(pts[n - 1].offset, hw[n - 1], paint);
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
