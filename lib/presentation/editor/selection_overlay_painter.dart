import 'package:flutter/material.dart';

/// [CustomPainter] that renders the selection UI on the ink canvas:
///
/// - A translucent rect or lasso path **while dragging** to define the region.
/// - A dashed bounding box with corner handles **after selection is finalised**.
/// - The bounding box shifts by [moveDelta] while the user drags to move.
class SelectionOverlayPainter extends CustomPainter {
  const SelectionOverlayPainter({
    this.selectionRect,
    this.lassoPoints = const [],
    this.selectedBounds,
    this.moveDelta = Offset.zero,
  });

  /// Rect preview drawn while the user drags a rectangular selection.
  final Rect? selectionRect;

  /// Lasso path drawn while the user draws a freehand selection.
  final List<Offset> lassoPoints;

  /// Pixel-space bounding box of the currently selected elements.
  final Rect? selectedBounds;

  /// Offset (in canvas pixels) applied to [selectedBounds] during a move drag.
  final Offset moveDelta;

  static const _blue = Color(0xFF2196F3);
  static const _fill = Color(0x332196F3);

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Rect selection preview.
    if (selectionRect != null &&
        (selectionRect!.width > 1 || selectionRect!.height > 1)) {
      canvas.drawRect(
          selectionRect!, Paint()..color = _fill..style = PaintingStyle.fill);
      _drawDashedRect(canvas, selectionRect!);
    }

    // 2. Lasso preview.
    if (lassoPoints.length >= 2) {
      final path = Path()
        ..moveTo(lassoPoints.first.dx, lassoPoints.first.dy);
      for (final p in lassoPoints.skip(1)) {
        path.lineTo(p.dx, p.dy);
      }
      path.close();
      canvas.drawPath(
          path, Paint()..color = _fill..style = PaintingStyle.fill);
      canvas.drawPath(
          path,
          Paint()
            ..color = _blue
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.5);
    }

    // 3. Selection bounding box (+ move offset).
    if (selectedBounds != null) {
      final r = selectedBounds!.shift(moveDelta).inflate(4);
      _drawDashedRect(canvas, r);
      _drawHandle(canvas, r.topLeft);
      _drawHandle(canvas, r.topRight);
      _drawHandle(canvas, r.bottomLeft);
      _drawHandle(canvas, r.bottomRight);
    }
  }

  void _drawDashedRect(Canvas canvas, Rect rect) {
    final path = Path()
      ..moveTo(rect.left, rect.top)
      ..lineTo(rect.right, rect.top)
      ..lineTo(rect.right, rect.bottom)
      ..lineTo(rect.left, rect.bottom)
      ..close();
    _drawDashedPath(
      canvas,
      path,
      Paint()
        ..color = _blue
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
  }

  void _drawHandle(Canvas canvas, Offset center) {
    final r = Rect.fromCenter(center: center, width: 8, height: 8);
    canvas.drawRect(
        r, Paint()..color = Colors.white..style = PaintingStyle.fill);
    canvas.drawRect(
        r,
        Paint()
          ..color = _blue
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5);
  }

  void _drawDashedPath(Canvas canvas, Path path, Paint paint) {
    const dashLen = 6.0;
    const gapLen = 4.0;
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      var drawing = true;
      while (distance < metric.length) {
        final segLen = drawing ? dashLen : gapLen;
        if (drawing) {
          final extracted = metric.extractPath(distance, distance + segLen);
          canvas.drawPath(extracted, paint);
        }
        distance += segLen;
        drawing = !drawing;
      }
    }
  }

  @override
  bool shouldRepaint(SelectionOverlayPainter old) =>
      old.selectionRect != selectionRect ||
      old.lassoPoints != lassoPoints ||
      old.selectedBounds != selectedBounds ||
      old.moveDelta != moveDelta;
}
