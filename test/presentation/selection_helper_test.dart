import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:runa/domain/domain.dart';
import 'package:runa/presentation/editor/selection_helper.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Stroke _stroke(String id, List<Offset> points) => Stroke(
      id: id,
      tool: StrokeTool.pen,
      color: '#000000FF',
      width: 2.0,
      points: points
          .map((o) =>
              StrokePoint(x: o.dx, y: o.dy, pressure: 0.5, timestamp: 0))
          .toList(),
    );

TextElement _text(String id, double x, double y) => TextElement(
      id: id,
      content: 'Hi',
      x: x,
      y: y,
      fontSize: 16.0,
      color: '#000000FF',
    );

ShapeElement _shape(String id, double x1, double y1, double x2, double y2) =>
    ShapeElement(
      id: id,
      type: ShapeType.rect,
      x1: x1,
      y1: y1,
      x2: x2,
      y2: y2,
      color: '#000000FF',
      strokeWidth: 2.0,
      filled: false,
    );

InkBlock _block({
  List<Stroke>? strokes,
  List<TextElement>? textElements,
  List<ShapeElement>? shapes,
}) =>
    InkBlock(
      id: 'b1',
      height: 400.0,
      strokes: strokes ?? [],
      textElements: textElements ?? [],
      shapes: shapes ?? [],
    );

const _size = Size(800, 400);

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('SelectionHelper.hitTestRect', () {
    test('selects stroke whose point falls inside rect', () {
      final block = _block(
        strokes: [_stroke('s1', [const Offset(100, 100)])],
      );
      final ids = SelectionHelper.hitTestRect(
          block, const Rect.fromLTWH(50, 50, 100, 100), _size);
      expect(ids, {'s1'});
    });

    test('does not select stroke outside rect', () {
      final block = _block(
        strokes: [_stroke('s1', [const Offset(300, 300)])],
      );
      final ids = SelectionHelper.hitTestRect(
          block, const Rect.fromLTWH(0, 0, 50, 50), _size);
      expect(ids, isEmpty);
    });

    test('selects text element overlapping rect', () {
      // TextElement at normalised (0.5, 0.5) → pixel (400, 200).
      final block = _block(textElements: [_text('t1', 0.5, 0.5)]);
      final ids = SelectionHelper.hitTestRect(
          block, const Rect.fromLTWH(390, 190, 30, 30), _size);
      expect(ids, {'t1'});
    });

    test('selects shape overlapping rect', () {
      // Shape from normalised (0.1,0.1)→(0.3,0.3) → pixel (80,40)→(240,120).
      final block = _block(shapes: [_shape('sh1', 0.1, 0.1, 0.3, 0.3)]);
      final ids = SelectionHelper.hitTestRect(
          block, const Rect.fromLTWH(70, 30, 50, 50), _size);
      expect(ids, {'sh1'});
    });

    test('selects mixed elements', () {
      final block = _block(
        strokes: [_stroke('s1', [const Offset(50, 50)])],
        textElements: [_text('t1', 0.5, 0.5)],
      );
      // Rect only covers the stroke.
      final ids = SelectionHelper.hitTestRect(
          block, const Rect.fromLTWH(0, 0, 100, 100), _size);
      expect(ids, {'s1'});
    });
  });

  group('SelectionHelper.hitTestLasso', () {
    // Square lasso: (0,0)→(200,0)→(200,200)→(0,200)
    const lasso = [
      Offset(0, 0),
      Offset(200, 0),
      Offset(200, 200),
      Offset(0, 200),
    ];

    test('selects stroke inside lasso', () {
      final block = _block(
        strokes: [_stroke('s1', [const Offset(100, 100)])],
      );
      final ids = SelectionHelper.hitTestLasso(block, lasso, _size);
      expect(ids, {'s1'});
    });

    test('does not select stroke outside lasso', () {
      final block = _block(
        strokes: [_stroke('s1', [const Offset(300, 300)])],
      );
      final ids = SelectionHelper.hitTestLasso(block, lasso, _size);
      expect(ids, isEmpty);
    });

    test('returns empty when polygon has fewer than 3 points', () {
      final block = _block(
        strokes: [_stroke('s1', [const Offset(10, 10)])],
      );
      final ids = SelectionHelper.hitTestLasso(
          block, const [Offset(0, 0), Offset(100, 100)], _size);
      expect(ids, isEmpty);
    });
  });

  group('SelectionHelper.moveSelection', () {
    test('moves a single stroke by delta', () {
      final block = _block(
        strokes: [_stroke('s1', [const Offset(100, 100)])],
      );
      final moved = SelectionHelper.moveSelection(
          block, {'s1'}, const Offset(10, 20), _size);
      expect(moved.strokes.first.points.first.x, closeTo(110, 0.001));
      expect(moved.strokes.first.points.first.y, closeTo(120, 0.001));
    });

    test('does not move stroke not in selection', () {
      final block = _block(
        strokes: [
          _stroke('s1', [const Offset(100, 100)]),
          _stroke('s2', [const Offset(200, 200)]),
        ],
      );
      final moved = SelectionHelper.moveSelection(
          block, {'s1'}, const Offset(50, 0), _size);
      expect(moved.strokes[1].points.first.x, closeTo(200, 0.001));
    });

    test('moves text element in normalised space', () {
      final block = _block(textElements: [_text('t1', 0.5, 0.5)]);
      // delta 80px on 800-wide canvas → +0.1 in normalised x
      final moved = SelectionHelper.moveSelection(
          block, {'t1'}, const Offset(80, 40), _size);
      expect(moved.textElements.first.x, closeTo(0.6, 0.001));
      expect(moved.textElements.first.y, closeTo(0.6, 0.001));
    });

    test('clamps stroke to canvas bounds', () {
      final block = _block(
        strokes: [_stroke('s1', [const Offset(790, 390)])],
      );
      final moved = SelectionHelper.moveSelection(
          block, {'s1'}, const Offset(100, 100), _size);
      expect(moved.strokes.first.points.first.x, closeTo(800, 0.001));
      expect(moved.strokes.first.points.first.y, closeTo(400, 0.001));
    });

    test('clamps text element to [0,1]', () {
      final block = _block(textElements: [_text('t1', 0.95, 0.95)]);
      final moved = SelectionHelper.moveSelection(
          block, {'t1'}, const Offset(800, 400), _size);
      expect(moved.textElements.first.x, closeTo(1.0, 0.001));
      expect(moved.textElements.first.y, closeTo(1.0, 0.001));
    });

    test('returns same block when ids is empty', () {
      final block = _block(
        strokes: [_stroke('s1', [const Offset(100, 100)])],
      );
      final result =
          SelectionHelper.moveSelection(block, {}, const Offset(10, 10), _size);
      expect(result, same(block));
    });
  });

  group('SelectionHelper.deleteSelection', () {
    test('removes selected stroke', () {
      final block = _block(
        strokes: [
          _stroke('s1', [const Offset(0, 0)]),
          _stroke('s2', [const Offset(10, 10)]),
        ],
      );
      final result = SelectionHelper.deleteSelection(block, {'s1'});
      expect(result.strokes.map((s) => s.id), ['s2']);
    });

    test('removes selected text element', () {
      final block = _block(textElements: [_text('t1', 0.1, 0.1)]);
      final result = SelectionHelper.deleteSelection(block, {'t1'});
      expect(result.textElements, isEmpty);
    });

    test('removes selected shape', () {
      final block = _block(shapes: [_shape('sh1', 0.1, 0.1, 0.3, 0.3)]);
      final result = SelectionHelper.deleteSelection(block, {'sh1'});
      expect(result.shapes, isEmpty);
    });

    test('returns same block when ids is empty', () {
      final block = _block(
        strokes: [_stroke('s1', [const Offset(0, 0)])],
      );
      expect(SelectionHelper.deleteSelection(block, {}), same(block));
    });
  });

  group('SelectionHelper.computeBounds', () {
    test('returns null when ids is empty', () {
      final block = _block(
        strokes: [_stroke('s1', [const Offset(100, 100)])],
      );
      expect(SelectionHelper.computeBounds(block, {}, _size), isNull);
    });

    test('computes bounds for a single stroke', () {
      final block = _block(
        strokes: [
          _stroke('s1', [const Offset(50, 60), const Offset(150, 120)])
        ],
      );
      final bounds = SelectionHelper.computeBounds(block, {'s1'}, _size);
      expect(bounds, isNotNull);
      expect(bounds!.left, closeTo(50, 0.001));
      expect(bounds.top, closeTo(60, 0.001));
      expect(bounds.right, closeTo(150, 0.001));
      expect(bounds.bottom, closeTo(120, 0.001));
    });

    test('computes bounds for a shape', () {
      // Shape normalised (0.1,0.2)→(0.3,0.4) → pixel (80,80)→(240,160).
      final block = _block(shapes: [_shape('sh1', 0.1, 0.2, 0.3, 0.4)]);
      final bounds = SelectionHelper.computeBounds(block, {'sh1'}, _size);
      expect(bounds, isNotNull);
      expect(bounds!.left, closeTo(80, 0.001));
      expect(bounds.top, closeTo(80, 0.001));
    });
  });
}
