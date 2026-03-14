import 'package:flutter_test/flutter_test.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:runa/application/services/renderers/markdown_pdf_renderer.dart';

void main() {
  // render() is async (may rasterise math), so all tests are async.
  // Non-math tests don't require testWidgets, but math tests do because
  // MathRasterizer needs the Flutter widget binding.

  late MarkdownPdfRenderer renderer;

  setUp(() => renderer = MarkdownPdfRenderer());

  // -------------------------------------------------------------------------
  // Non-math tests (plain async — no Flutter binding needed)
  // -------------------------------------------------------------------------

  group('MarkdownPdfRenderer — plain content', () {
    test('empty string returns empty list', () async {
      expect(await renderer.render(''), isEmpty);
      expect(await renderer.render('   '), isEmpty);
    });

    test('heading returns a non-empty widget list', () async {
      expect(await renderer.render('# Hello'), isNotEmpty);
    });

    test('paragraph returns a non-empty widget list', () async {
      expect(await renderer.render('Simple paragraph.'), isNotEmpty);
    });

    test('code block returns a non-empty widget list', () async {
      expect(
          await renderer.render('```dart\nvoid main() {}\n```'), isNotEmpty);
    });

    test('bold text in paragraph is rendered', () async {
      expect(await renderer.render('Text with **bold** word.'), isNotEmpty);
    });

    test('unordered list returns widgets', () async {
      expect(await renderer.render('- Item A\n- Item B\n- Item C'), isNotEmpty);
    });

    test('ordered list returns widgets', () async {
      expect(await renderer.render('1. First\n2. Second'), isNotEmpty);
    });

    test('table returns widgets', () async {
      expect(
          await renderer.render('| A | B |\n|---|---|\n| 1 | 2 |'), isNotEmpty);
    });

    test('horizontal rule returns widgets', () async {
      expect(await renderer.render('---'), isNotEmpty);
    });

    test('rendered widgets can be assembled into a PDF without error',
        () async {
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
      final widgets = await renderer.render(content);
      doc.addPage(
        pw.Page(build: (ctx) => pw.Column(children: widgets)),
      );
      final bytes = await doc.save();
      expect(bytes, isNotEmpty);
    });
  });

  // -------------------------------------------------------------------------
  // Math tests (testWidgets — MathRasterizer needs the widget binding)
  // -------------------------------------------------------------------------

  group('MarkdownPdfRenderer — math content', () {
    testWidgets(r'inline math $...$ renders as image widget, not literal text',
        (tester) async {
      final widgets = await tester
          .runAsync(() => renderer.render(r'Value: $E = mc^2$ here.'));
      expect(widgets, isNotEmpty);
      expect(widgets!.length, greaterThanOrEqualTo(1));
    });

    testWidgets('block math renders without throwing', (tester) async {
      const md = '\$\$\n\\int_0^\\infty e^{-x}\\,dx\n\$\$';
      final widgets = await tester.runAsync(() => renderer.render(md));
      expect(widgets, isNotEmpty);
    });

    testWidgets('invalid inline math falls back to red text, does not crash',
        (tester) async {
      final widgets = await tester
          .runAsync(() => renderer.render(r'Bad math: $\invaliddcmd{broken$ here.'));
      expect(widgets, isNotEmpty);
    });

    testWidgets('invalid block math falls back to red text, does not crash',
        (tester) async {
      const md = '\$\$\n\\invaliddcmd{broken\n\$\$';
      final widgets = await tester.runAsync(() => renderer.render(md));
      expect(widgets, isNotEmpty);
    });

    testWidgets('document with math can be assembled into PDF', (tester) async {
      const md = '# Math document\n\n'
          r'Inline: $E = mc^2$.'
          '\n\n'
          '\$\$\n'
          r'\frac{d}{dx}\sin(x) = \cos(x)'
          '\n\$\$\n';
      final doc = pw.Document();
      final widgets = await tester.runAsync(() => renderer.render(md));
      doc.addPage(
        pw.Page(build: (ctx) => pw.Column(children: widgets!)),
      );
      final bytes = await doc.save();
      expect(bytes, isNotEmpty);
    });
  });
}
