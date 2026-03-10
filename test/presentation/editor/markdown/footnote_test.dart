import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:runa/presentation/editor/markdown/footnote_extension.dart';
import 'package:runa/presentation/editor/markdown_preview_widget.dart';

Widget _wrap(Widget child) =>
    MaterialApp(home: Scaffold(body: SingleChildScrollView(child: child)));

void main() {
  group('Footnotes — rendering', () {
    testWidgets('single footnote: ref + definition rendered', (tester) async {
      const src = 'Text[^1] here\n\n[^1]: The definition';
      await tester.pumpWidget(_wrap(const MarkdownPreviewWidget(content: src)));
      await tester.pumpAndSettle();
      expect(find.textContaining('The definition'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('two footnotes: both definitions rendered', (tester) async {
      const src = 'First[^a] and second[^b]\n\n[^a]: Def A\n\n[^b]: Def B';
      await tester.pumpWidget(_wrap(const MarkdownPreviewWidget(content: src)));
      await tester.pumpAndSettle();
      expect(find.textContaining('Def A'), findsOneWidget);
      expect(find.textContaining('Def B'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('footnote without definition renders without crash',
        (tester) async {
      const src = 'Text[^missing] here';
      await tester.pumpWidget(_wrap(const MarkdownPreviewWidget(content: src)));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  });

  group('FootnoteInlineSyntax — unit', () {
    test('pattern matches [^id]', () {
      final syntax = FootnoteInlineSyntax();
      expect(syntax.pattern.hasMatch('[^1]'), isTrue);
      expect(syntax.pattern.hasMatch('[^note]'), isTrue);
    });

    test('pattern does not match regular links', () {
      final syntax = FootnoteInlineSyntax();
      expect(syntax.pattern.hasMatch('[link](url)'), isFalse);
    });
  });

  group('FootnoteBlockSyntax — unit', () {
    test('pattern matches [^id]: text', () {
      const syntax = FootnoteBlockSyntax();
      expect(syntax.pattern.hasMatch('[^1]: definition'), isTrue);
    });

    test('pattern does not match regular text', () {
      const syntax = FootnoteBlockSyntax();
      expect(syntax.pattern.hasMatch('regular text'), isFalse);
    });
  });
}
