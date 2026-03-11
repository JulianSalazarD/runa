import 'package:flutter_test/flutter_test.dart';
import 'package:runa/domain/domain.dart';
import 'package:runa/presentation/editor/text_element_painter.dart';

void main() {
  group('TextElementPainter.shouldRepaint', () {
    const el = TextElement(id: 'e1', x: 0.5, y: 0.5, content: 'Hello');

    test('returns false when elements are identical', () {
      const a = TextElementPainter(elements: [el]);
      const b = TextElementPainter(elements: [el]);
      expect(a.shouldRepaint(b), isFalse);
    });

    test('returns true when elements change', () {
      const el2 = TextElement(id: 'e2', x: 0.5, y: 0.5, content: 'World');
      const a = TextElementPainter(elements: [el]);
      const b = TextElementPainter(elements: [el2]);
      expect(a.shouldRepaint(b), isTrue);
    });

    test('returns true when list changes length', () {
      const a = TextElementPainter(elements: [el]);
      const b = TextElementPainter(elements: []);
      expect(a.shouldRepaint(b), isTrue);
    });
  });
}
