import 'package:flutter_test/flutter_test.dart';
import 'package:runa/domain/domain.dart';

void main() {
  group('ShapeElement JSON round-trip', () {
    test('line round-trips with all fields', () {
      const shape = ShapeElement(
        id: 's1',
        type: ShapeType.line,
        x1: 0.1,
        y1: 0.2,
        x2: 0.8,
        y2: 0.9,
        color: '#FF0000FF',
        strokeWidth: 3.0,
      );
      final restored = ShapeElement.fromJson(shape.toJson());
      expect(restored, shape);
    });

    test('rect with fill round-trips', () {
      const shape = ShapeElement(
        id: 's2',
        type: ShapeType.rect,
        x1: 0.0,
        y1: 0.0,
        x2: 0.5,
        y2: 0.5,
        filled: true,
        fillColor: '#0000FFFF',
      );
      final restored = ShapeElement.fromJson(shape.toJson());
      expect(restored.filled, isTrue);
      expect(restored.fillColor, '#0000FFFF');
      expect(restored.type, ShapeType.rect);
    });

    test('oval round-trips', () {
      const shape = ShapeElement(
        id: 's3',
        type: ShapeType.oval,
        x1: 0.2,
        y1: 0.2,
        x2: 0.8,
        y2: 0.8,
      );
      expect(ShapeElement.fromJson(shape.toJson()), shape);
    });

    test('triangle round-trips', () {
      const shape = ShapeElement(
        id: 's4',
        type: ShapeType.triangle,
        x1: 0.0,
        y1: 1.0,
        x2: 1.0,
        y2: 0.0,
      );
      expect(ShapeElement.fromJson(shape.toJson()), shape);
    });

    test('arrow round-trips', () {
      const shape = ShapeElement(
        id: 's5',
        type: ShapeType.arrow,
        x1: 0.0,
        y1: 0.5,
        x2: 1.0,
        y2: 0.5,
        strokeWidth: 4.0,
        color: '#00FF00FF',
      );
      expect(ShapeElement.fromJson(shape.toJson()), shape);
    });

    test('default values', () {
      const shape = ShapeElement(
        id: 's6',
        type: ShapeType.line,
        x1: 0,
        y1: 0,
        x2: 1,
        y2: 1,
      );
      expect(shape.color, '#000000FF');
      expect(shape.strokeWidth, 2.0);
      expect(shape.filled, isFalse);
      expect(shape.fillColor, isNull);
    });

    test('shapes list in InkBlock round-trips', () {
      const block = Block.ink(
        id: 'b1',
        height: 200,
        shapes: [
          ShapeElement(
            id: 's1',
            type: ShapeType.rect,
            x1: 0.0,
            y1: 0.0,
            x2: 0.5,
            y2: 0.5,
          ),
        ],
      );
      final restored = Block.fromJson(block.toJson()) as InkBlock;
      expect(restored.shapes.length, 1);
      expect(restored.shapes.first.type, ShapeType.rect);
      expect(restored.shapes.first.x2, 0.5);
    });

    test('shapes empty by default', () {
      const block = Block.ink(id: 'b1', height: 200) as InkBlock;
      expect(block.shapes, isEmpty);
    });
  });
}
