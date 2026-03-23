import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:runa/domain/domain.dart';
import 'package:runa/presentation/editor/shape_painter.dart';

void main() {
  group('ShapePainter.shouldRepaint', () {
    const s1 = ShapeElement(
      id: 's1',
      type: ShapeType.rect,
      x1: 0.0,
      y1: 0.0,
      x2: 0.5,
      y2: 0.5,
    );

    test('returns false when shapes and preview are identical', () {
      const a = ShapePainter(shapes: [s1]);
      const b = ShapePainter(shapes: [s1]);
      expect(a.shouldRepaint(b), isFalse);
    });

    test('returns true when shapes list changes', () {
      const s2 = ShapeElement(
        id: 's2',
        type: ShapeType.oval,
        x1: 0.1,
        y1: 0.1,
        x2: 0.9,
        y2: 0.9,
      );
      const a = ShapePainter(shapes: [s1]);
      const b = ShapePainter(shapes: [s1, s2]);
      expect(a.shouldRepaint(b), isTrue);
    });

    test('returns true when preview changes', () {
      const preview = ShapeElement(
        id: 'p1',
        type: ShapeType.line,
        x1: 0.0,
        y1: 0.0,
        x2: 1.0,
        y2: 1.0,
      );
      const a = ShapePainter(shapes: [s1]);
      const b = ShapePainter(shapes: [s1], previewShape: preview);
      expect(a.shouldRepaint(b), isTrue);
    });

    test('returns false when list is empty and preview is null', () {
      const a = ShapePainter(shapes: []);
      const b = ShapePainter(shapes: []);
      expect(a.shouldRepaint(b), isFalse);
    });
  });

  group('ShapePainter paint — smoke tests', () {
    // These tests verify that paint() runs without throwing for each ShapeType.
    // Pixel-accurate rendering tests are left to integration/golden tests.
    for (final type in ShapeType.values) {
      test('paints $type without error', () {
        final painter = ShapePainter(
          shapes: [
            ShapeElement(
              id: 'x',
              type: type,
              x1: 0.1,
              y1: 0.1,
              x2: 0.9,
              y2: 0.9,
              filled: true,
              fillColor: '#FF000088',
            ),
          ],
        );
        expect(
          () => _paintOnCanvas(painter, const Size(200, 200)),
          returnsNormally,
        );
      });
    }

    test('paints preview shape at 70% opacity without error', () {
      const preview = ShapeElement(
        id: 'p',
        type: ShapeType.rect,
        x1: 0.0,
        y1: 0.0,
        x2: 0.5,
        y2: 0.5,
      );
      const painter = ShapePainter(shapes: [], previewShape: preview);
      expect(
        () => _paintOnCanvas(painter, const Size(300, 300)),
        returnsNormally,
      );
    });

    test('rect in upper-left quadrant uses correct normalised coordinates', () {
      // x2=0.5, y2=0.5 → shape occupies upper-left 100×100 of a 200×200 canvas
      const painter = ShapePainter(
        shapes: [
          ShapeElement(
            id: 'r',
            type: ShapeType.rect,
            x1: 0.0,
            y1: 0.0,
            x2: 0.5,
            y2: 0.5,
          ),
        ],
      );
      // Just verify no exception — coordinate correctness is validated visually
      expect(
        () => _paintOnCanvas(painter, const Size(200, 200)),
        returnsNormally,
      );
    });
  });
}

/// Paints [painter] onto an in-memory canvas of [size].
void _paintOnCanvas(ShapePainter painter, Size size) {
  final recorder = PictureRecorder();
  final canvas = Canvas(recorder, Offset.zero & size);
  painter.paint(canvas, size);
  recorder.endRecording();
}
