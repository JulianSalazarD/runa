import 'package:flutter/material.dart';
import 'package:runa/domain/domain.dart';

/// Pure static helpers for the ink canvas selection tool.
///
/// All methods are side-effect free so they can be unit tested in isolation.
class SelectionHelper {
  SelectionHelper._();

  // ---------------------------------------------------------------------------
  // Hit-testing
  // ---------------------------------------------------------------------------

  /// Returns the IDs of all elements inside [rect] (pixel space).
  static Set<String> hitTestRect(InkBlock block, Rect rect, Size canvasSize) {
    final ids = <String>{};
    for (final s in block.strokes) {
      if (_strokeInRect(s, rect)) ids.add(s.id);
    }
    for (final el in block.textElements) {
      if (_textInRect(el, rect, canvasSize)) ids.add(el.id);
    }
    for (final shape in block.shapes) {
      if (_shapeInRect(shape, rect, canvasSize)) ids.add(shape.id);
    }
    return ids;
  }

  /// Returns the IDs of all elements inside [polygon] (pixel space, closed).
  static Set<String> hitTestLasso(
      InkBlock block, List<Offset> polygon, Size canvasSize) {
    if (polygon.length < 3) return {};
    final ids = <String>{};
    for (final s in block.strokes) {
      if (_strokeInLasso(s, polygon)) ids.add(s.id);
    }
    for (final el in block.textElements) {
      if (_textInLasso(el, polygon, canvasSize)) ids.add(el.id);
    }
    for (final shape in block.shapes) {
      if (_shapeInLasso(shape, polygon, canvasSize)) ids.add(shape.id);
    }
    return ids;
  }

  // ---------------------------------------------------------------------------
  // Move
  // ---------------------------------------------------------------------------

  /// Applies [delta] (in canvas pixels) to all elements whose IDs are in [ids].
  ///
  /// Stroke points are clamped to `[0, canvasSize.width] × [0, canvasSize.height]`.
  /// TextElement and ShapeElement normalised coords are clamped to `[0.0, 1.0]`.
  static InkBlock moveSelection(
    InkBlock block,
    Set<String> ids,
    Offset delta,
    Size canvasSize,
  ) {
    if (ids.isEmpty || delta == Offset.zero) return block;

    final dxNorm = delta.dx / canvasSize.width;
    final dyNorm = delta.dy / canvasSize.height;

    final strokes = block.strokes.map((s) {
      if (!ids.contains(s.id)) return s;
      return s.copyWith(
        points: s.points
            .map((p) => p.copyWith(
                  x: (p.x + delta.dx).clamp(0.0, canvasSize.width),
                  y: (p.y + delta.dy).clamp(0.0, canvasSize.height),
                ))
            .toList(),
      );
    }).toList();

    final textElements = block.textElements.map((el) {
      if (!ids.contains(el.id)) return el;
      return el.copyWith(
        x: (el.x + dxNorm).clamp(0.0, 1.0),
        y: (el.y + dyNorm).clamp(0.0, 1.0),
      );
    }).toList();

    final shapes = block.shapes.map((shape) {
      if (!ids.contains(shape.id)) return shape;
      return shape.copyWith(
        x1: (shape.x1 + dxNorm).clamp(0.0, 1.0),
        y1: (shape.y1 + dyNorm).clamp(0.0, 1.0),
        x2: (shape.x2 + dxNorm).clamp(0.0, 1.0),
        y2: (shape.y2 + dyNorm).clamp(0.0, 1.0),
      );
    }).toList();

    return block.copyWith(
      strokes: strokes,
      textElements: textElements,
      shapes: shapes,
    );
  }

  // ---------------------------------------------------------------------------
  // Delete
  // ---------------------------------------------------------------------------

  /// Removes all elements whose IDs are in [ids] from [block].
  static InkBlock deleteSelection(InkBlock block, Set<String> ids) {
    if (ids.isEmpty) return block;
    return block.copyWith(
      strokes: block.strokes.where((s) => !ids.contains(s.id)).toList(),
      textElements:
          block.textElements.where((el) => !ids.contains(el.id)).toList(),
      shapes: block.shapes.where((s) => !ids.contains(s.id)).toList(),
    );
  }

  // ---------------------------------------------------------------------------
  // Bounding box
  // ---------------------------------------------------------------------------

  /// Computes the pixel-space bounding box of the elements in [ids].
  /// Returns null if no matching elements are found.
  static Rect? computeBounds(
      InkBlock block, Set<String> ids, Size canvasSize) {
    if (ids.isEmpty) return null;

    double minX = double.infinity,
        minY = double.infinity,
        maxX = double.negativeInfinity,
        maxY = double.negativeInfinity;

    void extend(double x, double y) {
      if (x < minX) minX = x;
      if (y < minY) minY = y;
      if (x > maxX) maxX = x;
      if (y > maxY) maxY = y;
    }

    for (final s in block.strokes) {
      if (!ids.contains(s.id)) continue;
      for (final p in s.points) {
        extend(p.x, p.y);
      }
    }
    for (final el in block.textElements) {
      if (!ids.contains(el.id)) continue;
      final x = el.x * canvasSize.width;
      final y = el.y * canvasSize.height;
      final w = el.content.length * el.fontSize * 0.6;
      final h = el.fontSize * 1.4;
      extend(x, y);
      extend(x + w, y + h);
    }
    for (final shape in block.shapes) {
      if (!ids.contains(shape.id)) continue;
      extend(shape.x1 * canvasSize.width, shape.y1 * canvasSize.height);
      extend(shape.x2 * canvasSize.width, shape.y2 * canvasSize.height);
    }

    if (minX == double.infinity) return null;
    return Rect.fromLTRB(minX, minY, maxX, maxY);
  }

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  static bool _strokeInRect(Stroke stroke, Rect rect) =>
      stroke.points.any((p) => rect.contains(Offset(p.x, p.y)));

  static bool _textInRect(TextElement el, Rect rect, Size size) {
    final x = el.x * size.width;
    final y = el.y * size.height;
    final w = el.content.length * el.fontSize * 0.6;
    final h = el.fontSize * 1.4;
    return rect.overlaps(Rect.fromLTWH(x, y, w, h));
  }

  static bool _shapeInRect(ShapeElement shape, Rect rect, Size size) {
    final shapeBounds = Rect.fromPoints(
      Offset(shape.x1 * size.width, shape.y1 * size.height),
      Offset(shape.x2 * size.width, shape.y2 * size.height),
    );
    return rect.overlaps(shapeBounds);
  }

  static bool _strokeInLasso(Stroke stroke, List<Offset> polygon) =>
      stroke.points.any((p) => _pointInPolygon(Offset(p.x, p.y), polygon));

  static bool _textInLasso(
      TextElement el, List<Offset> polygon, Size size) =>
      _pointInPolygon(Offset(el.x * size.width, el.y * size.height), polygon);

  static bool _shapeInLasso(
      ShapeElement shape, List<Offset> polygon, Size size) {
    final x1 = shape.x1 * size.width;
    final y1 = shape.y1 * size.height;
    final x2 = shape.x2 * size.width;
    final y2 = shape.y2 * size.height;
    return _pointInPolygon(Offset(x1, y1), polygon) ||
        _pointInPolygon(Offset(x2, y2), polygon) ||
        _pointInPolygon(Offset((x1 + x2) / 2, (y1 + y2) / 2), polygon);
  }

  /// Ray-casting point-in-polygon test.
  static bool _pointInPolygon(Offset point, List<Offset> polygon) {
    if (polygon.length < 3) return false;
    int crossings = 0;
    for (int i = 0; i < polygon.length; i++) {
      final a = polygon[i];
      final b = polygon[(i + 1) % polygon.length];
      if ((a.dy <= point.dy && b.dy > point.dy) ||
          (b.dy <= point.dy && a.dy > point.dy)) {
        final t = (point.dy - a.dy) / (b.dy - a.dy);
        if (point.dx < a.dx + t * (b.dx - a.dx)) crossings++;
      }
    }
    return crossings.isOdd;
  }
}
