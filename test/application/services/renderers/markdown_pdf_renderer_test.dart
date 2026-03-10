import 'package:pdf/widgets.dart' as pw;
import 'package:runa/application/services/renderers/markdown_pdf_renderer.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late MarkdownPdfRenderer renderer;

  setUp(() => renderer = MarkdownPdfRenderer());

  group('MarkdownPdfRenderer', () {
    test('empty string returns empty list', () {
      expect(renderer.render(''), isEmpty);
      expect(renderer.render('   '), isEmpty);
    });

    test('heading returns a non-empty widget list', () {
      final widgets = renderer.render('# Hello');
      expect(widgets, isNotEmpty);
    });

    test('paragraph returns a non-empty widget list', () {
      final widgets = renderer.render('Simple paragraph.');
      expect(widgets, isNotEmpty);
    });

    test('code block returns a non-empty widget list', () {
      final widgets = renderer.render('```dart\nvoid main() {}\n```');
      expect(widgets, isNotEmpty);
    });

    test('bold text in paragraph is rendered', () {
      final widgets = renderer.render('Text with **bold** word.');
      expect(widgets, isNotEmpty);
    });

    test('unordered list returns widgets', () {
      final widgets = renderer.render('- Item A\n- Item B\n- Item C');
      expect(widgets, isNotEmpty);
    });

    test('ordered list returns widgets', () {
      final widgets = renderer.render('1. First\n2. Second');
      expect(widgets, isNotEmpty);
    });

    test('table returns widgets', () {
      const md = '| A | B |\n|---|---|\n| 1 | 2 |';
      final widgets = renderer.render(md);
      expect(widgets, isNotEmpty);
    });

    test('horizontal rule returns widgets', () {
      final widgets = renderer.render('---');
      expect(widgets, isNotEmpty);
    });

    test('rendered widgets can be assembled into a PDF without error', () async {
      const content = '''
# Title

A paragraph with **bold** and *italic* text.

- Item 1
- Item 2

```dart
void main() {}
```
''';
      final doc = pw.Document();
      final widgets = renderer.render(content);
      doc.addPage(
        pw.Page(build: (ctx) => pw.Column(children: widgets)),
      );
      final bytes = await doc.save();
      expect(bytes, isNotEmpty);
    });
  });
}
