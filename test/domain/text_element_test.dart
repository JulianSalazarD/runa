import 'package:flutter_test/flutter_test.dart';
import 'package:runa/domain/domain.dart';

void main() {
  group('TextElement JSON round-trip', () {
    test('full element round-trips', () {
      const el = TextElement(
        id: 'el1',
        x: 0.25,
        y: 0.5,
        content: 'Hello',
        fontSize: 20.0,
        color: '#FF0000FF',
        bold: true,
      );
      final json = el.toJson();
      final restored = TextElement.fromJson(json);
      expect(restored, el);
    });

    test('default values', () {
      const el = TextElement(id: 'el2', x: 0.1, y: 0.2, content: 'Hi');
      expect(el.fontSize, 16.0);
      expect(el.color, '#000000FF');
      expect(el.bold, isFalse);
      expect(el.italic, isFalse);
      expect(el.fontFamily, isNull);
    });

    test('textElements in InkBlock round-trips', () {
      const block = Block.ink(
        id: 'b1',
        height: 200,
        textElements: [
          TextElement(id: 'e1', x: 0.5, y: 0.5, content: 'Test'),
        ],
      );
      final restored = Block.fromJson(block.toJson()) as InkBlock;
      expect(restored.textElements.length, 1);
      expect(restored.textElements.first.content, 'Test');
    });

    test('textElements empty by default', () {
      const block = Block.ink(id: 'b1', height: 200) as InkBlock;
      expect(block.textElements, isEmpty);
    });
  });
}
