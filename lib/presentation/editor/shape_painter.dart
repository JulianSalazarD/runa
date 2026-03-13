import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:runa/domain/domain.dart';

/// [CustomPainter] that renders committed [ShapeElement]s and an optional
/// in-progress shape preview.
class ShapePainter extends CustomPainter {
  const ShapePainter({
    required this.shapes,
    this.previewShape,
  });

  final List<ShapeElement> shapes;

  /// Shape currently being drawn (not yet committed). Rendered at 70% opacity.
  final ShapeElement? previewShape;

  @override
  void paint(Canvas canvas, Size size) {
    for (final shape in shapes) {
      _paintShape(canvas, size, shape, 1.0);
    }
    if (previewShape != null) {
      _paintShape(canvas, size, previewShape!, 0.7);
    }
  }

  void _paintShape(Canvas canvas, Size size, ShapeElement shape, double opacity) {
    final color = _parseColor(shape.color).withValues(alpha: opacity);
    final strokePaint = Paint()
      ..color = color
      ..strokeWidth = shape.strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final x1 = shape.x1 * size.width;
    final y1 = shape.y1 * size.height;
    final x2 = shape.x2 * size.width;
    final y2 = shape.y2 * size.height;

    switch (shape.type) {
      case ShapeType.line:
        canvas.drawLine(Offset(x1, y1), Offset(x2, y2), strokePaint);
      case ShapeType.rect:
        final rect = Rect.fromPoints(Offset(x1, y1), Offset(x2, y2));
        if (shape.filled && shape.fillColor != null) {
          final fillPaint = Paint()
            ..color = _parseColor(shape.fillColor!).withValues(alpha: opacity)
            ..style = PaintingStyle.fill;
          canvas.drawRect(rect, fillPaint);
        }
        canvas.drawRect(rect, strokePaint);
      case ShapeType.oval:
        final rect = Rect.fromPoints(Offset(x1, y1), Offset(x2, y2));
        if (shape.filled && shape.fillColor != null) {
          final fillPaint = Paint()
            ..color = _parseColor(shape.fillColor!).withValues(alpha: opacity)
            ..style = PaintingStyle.fill;
          canvas.drawOval(rect, fillPaint);
        }
        canvas.drawOval(rect, strokePaint);
      case ShapeType.triangle:
        final path = Path()
          ..moveTo((x1 + x2) / 2, y1)
          ..lineTo(x2, y2)
          ..lineTo(x1, y2)
          ..close();
        if (shape.filled && shape.fillColor != null) {
          final fillPaint = Paint()
            ..color = _parseColor(shape.fillColor!).withValues(alpha: opacity)
            ..style = PaintingStyle.fill;
          canvas.drawPath(path, fillPaint);
        }
        canvas.drawPath(path, strokePaint);
      case ShapeType.arrow:
        _drawArrow(canvas, Offset(x1, y1), Offset(x2, y2), strokePaint);
    }
  }

  void _drawArrow(Canvas canvas, Offset start, Offset end, Paint paint) {
    canvas.drawLine(start, end, paint);
    final angle = math.atan2(end.dy - start.dy, end.dx - start.dx);
    const headLen = 12.0;
    const headAngle = math.pi / 7;
    final path = Path()
      ..moveTo(
        end.dx - headLen * math.cos(angle - headAngle),
        end.dy - headLen * math.sin(angle - headAngle),
      )
      ..lineTo(end.dx, end.dy)
      ..lineTo(
        end.dx - headLen * math.cos(angle + headAngle),
        end.dy - headLen * math.sin(angle + headAngle),
      );
    canvas.drawPath(path, paint);
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
  bool shouldRepaint(ShapePainter old) =>
      old.shapes != shapes || old.previewShape != previewShape;
}
