import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:runa/domain/domain.dart';
import 'package:uuid/uuid.dart';

import 'ink_background_painter.dart';

// ---------------------------------------------------------------------------
// InkCanvasWidget
// ---------------------------------------------------------------------------

/// Drawing canvas for an [InkBlock].
///
/// Captures raw pointer events and emits completed [Stroke]s via [onUpdate].
/// Renders committed strokes (smoothed) and the in-progress stroke (raw)
/// through [InkPainter].
class InkCanvasWidget extends StatefulWidget {
  const InkCanvasWidget({
    super.key,
    required this.block,
    required this.height,
    required this.activeTool,
    required this.activeColor,
    required this.activeWidth,
    this.onUpdate,
  });

  final InkBlock block;
  final double height;
  final StrokeTool activeTool;

  /// Active color in `#RRGGBBAA` format.
  final String activeColor;

  /// Base stroke width in logical pixels.
  final double activeWidth;

  /// Called when a stroke is committed or a stroke is erased.
  final ValueChanged<InkBlock>? onUpdate;

  @override
  State<InkCanvasWidget> createState() => _InkCanvasWidgetState();
}

class _InkCanvasWidgetState extends State<InkCanvasWidget> {
  static const _uuid = Uuid();
  static const _eraserRadius = 20.0;

  List<StrokePoint> _currentPoints = [];

  StrokePoint _makePoint(PointerEvent e) => StrokePoint(
        x: e.localPosition.dx,
        y: e.localPosition.dy,
        // If the device doesn't report pressure, e.pressure == 0; fallback 1.0.
        pressure: e.pressure > 0.0 ? e.pressure : 1.0,
        timestamp: DateTime.now().millisecondsSinceEpoch,
      );

  void _onPointerDown(PointerDownEvent e) {
    setState(() => _currentPoints = [_makePoint(e)]);
  }

  void _onPointerMove(PointerMoveEvent e) {
    setState(() => _currentPoints = [..._currentPoints, _makePoint(e)]);
  }

  void _onPointerUp(PointerUpEvent e) {
    final allPoints = [..._currentPoints, _makePoint(e)];
    _currentPoints = [];

    if (widget.activeTool == StrokeTool.eraser) {
      _handleErase(allPoints);
    } else {
      _commitStroke(allPoints);
    }
  }

  void _commitStroke(List<StrokePoint> points) {
    if (points.isEmpty) return;
    final stroke = Stroke(
      id: _uuid.v4(),
      color: widget.activeColor,
      width: widget.activeWidth,
      tool: widget.activeTool,
      points: points,
    );
    widget.onUpdate?.call(
      widget.block.copyWith(strokes: [...widget.block.strokes, stroke]),
    );
  }

  void _handleErase(List<StrokePoint> eraserPoints) {
    final remaining = widget.block.strokes
        .where((s) => !_intersectsEraser(s, eraserPoints))
        .toList();
    if (remaining.length != widget.block.strokes.length) {
      widget.onUpdate?.call(widget.block.copyWith(strokes: remaining));
    }
  }

  /// Returns `true` when any eraser point is within [_eraserRadius] of any
  /// point belonging to [stroke].
  static bool _intersectsEraser(Stroke stroke, List<StrokePoint> eraser) {
    const r2 = _eraserRadius * _eraserRadius;
    for (final ep in eraser) {
      for (final sp in stroke.points) {
        final dx = sp.x - ep.x;
        final dy = sp.y - ep.y;
        if (dx * dx + dy * dy <= r2) return true;
      }
    }
    return false;
  }

  static Color? _parseColorHex(String? hex) {
    if (hex == null) return null;
    final h = hex.replaceFirst('#', '');
    final r = int.parse(h.substring(0, 2), radix: 16);
    final g = int.parse(h.substring(2, 4), radix: 16);
    final b = int.parse(h.substring(4, 6), radix: 16);
    final a = int.parse(h.substring(6, 8), radix: 16);
    return Color.fromARGB(a, r, g, b);
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: _onPointerDown,
      onPointerMove: _onPointerMove,
      onPointerUp: _onPointerUp,
      child: SizedBox(
        height: widget.height,
        child: ClipRect(
          child: CustomPaint(
            painter: InkBackgroundPainter(
              background: widget.block.background,
              spacing: widget.block.backgroundSpacing,
              lineColor: _parseColorHex(widget.block.backgroundLineColor),
              defaultColor: Theme.of(context).colorScheme.outlineVariant,
            ),
            foregroundPainter: InkPainter(
              strokes: widget.block.strokes,
              currentPoints: _currentPoints,
              activeTool: widget.activeTool,
            ),
            size: Size.infinite,
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// InkPainter
// ---------------------------------------------------------------------------

/// [CustomPainter] that renders committed [Stroke]s and the in-progress
/// stroke from [currentPoints].
class InkPainter extends CustomPainter {
  const InkPainter({
    required this.strokes,
    required this.currentPoints,
    required this.activeTool,
    StrokeSmoother? smoother,
  }) : smoother = smoother ?? const StrokeSmoother();

  final List<Stroke> strokes;
  final List<StrokePoint> currentPoints;
  final StrokeTool activeTool;
  final StrokeSmoother smoother;

  @override
  void paint(Canvas canvas, Size size) {
    // Draw committed strokes (smoothed).
    for (final stroke in strokes) {
      if (stroke.tool == StrokeTool.eraser) continue;
      final smoothed = smoother.smooth(stroke.points);
      if (smoothed.length < 2) continue;
      canvas.drawPath(_buildPath(smoothed), _makePaint(stroke));
    }

    // Draw in-progress stroke (raw, no smoothing yet).
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
        // Eraser strokes are never rendered; they remove other strokes.
        break;
    }
    return paint;
  }

  /// Parses `#RRGGBBAA` into a Flutter [Color].
  static Color _parseColor(String hex) {
    final h = hex.replaceFirst('#', '');
    final r = int.parse(h.substring(0, 2), radix: 16);
    final g = int.parse(h.substring(2, 4), radix: 16);
    final b = int.parse(h.substring(4, 6), radix: 16);
    final a = int.parse(h.substring(6, 8), radix: 16);
    return Color.fromARGB(a, r, g, b);
  }

  @override
  bool shouldRepaint(InkPainter old) =>
      old.strokes != strokes || old.currentPoints != currentPoints;
}
