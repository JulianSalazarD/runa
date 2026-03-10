import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:runa/presentation/editor/markdown/math_markdown_extension.dart';
import 'package:runa/presentation/editor/markdown_editor_widget.dart';
import 'package:runa/presentation/editor/markdown_preview_widget.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Widget _wrap(Widget child) =>
    MaterialApp(home: Scaffold(body: SingleChildScrollView(child: child)));

// ---------------------------------------------------------------------------
// 4.1 — Math markdown extension
// ---------------------------------------------------------------------------

void main() {
  group('MathMarkdownExtension — inline math', () {
    testWidgets(r'renders $E=mc^2$ as a Math widget', (tester) async {
      await tester.pumpWidget(
        _wrap(const MarkdownPreviewWidget(content: r'$E = mc^2$')),
      );
      await tester.pumpAndSettle();

      expect(find.byType(Math), findsOneWidget);
    });

    testWidgets(r'renders $\frac{1}{2}$ without crashing', (tester) async {
      await tester.pumpWidget(
        _wrap(const MarkdownPreviewWidget(
            content: r'La fracción $\frac{1}{2}$')),
      );
      await tester.pumpAndSettle();

      // The Math widget must be present and the overall tree must not throw.
      expect(find.byType(Math), findsOneWidget);
    });

    testWidgets(
        r'\$100 escaped dollar renders as literal text, not Math',
        (tester) async {
      await tester.pumpWidget(
        _wrap(const MarkdownPreviewWidget(content: r'\$100')),
      );
      await tester.pumpAndSettle();

      // No Math widget must appear.
      expect(find.byType(Math), findsNothing);
      // The digits should appear as plain text somewhere in the rendered output.
      expect(find.textContaining('100'), findsOneWidget);
    });

    testWidgets('invalid inline expression shows fallback text without crash',
        (tester) async {
      // r'\invalida' is not a valid TeX command — the parser will reject it.
      await tester.pumpWidget(
        _wrap(const MarkdownPreviewWidget(content: r'$\invalida{$')),
      );
      await tester.pumpAndSettle();

      // No Math widget; the fallback raw text with the expression is shown.
      expect(find.byType(Math), findsNothing);
      expect(tester.takeException(), isNull);
    });
  });

  group('MathMarkdownExtension — block math', () {
    testWidgets(r'renders $$\sum_{i=0}^{n} i$$ as a display Math widget',
        (tester) async {
      // Two-line block: opening $$, expression, closing $$
      const content = '\$\$\n'
          r'\sum_{i=0}^{n} i'
          '\n\$\$';

      await tester.pumpWidget(_wrap(const MarkdownPreviewWidget(content: content)));
      await tester.pumpAndSettle();

      expect(find.byType(Math), findsOneWidget);
    });
  });

  group('MathMarkdownExtension — raw editor mode', () {
    testWidgets('dollar signs in the editor are not rendered as Math',
        (tester) async {
      await tester.pumpWidget(
        _wrap(MarkdownEditorWidget(
          initialContent: r'$E = mc^2$',
          onChanged: (_) {},
        )),
      );
      await tester.pumpAndSettle();

      // The editor is a plain TextField — no Math widget present.
      expect(find.byType(Math), findsNothing);
      expect(find.byType(TextField), findsOneWidget);
    });
  });

  group('InlineMathSyntax — unit', () {
    test(r'matches $...$ expressions', () {
      final syntax = InlineMathSyntax();
      final match = syntax.pattern.firstMatch(r'$E = mc^2$');
      expect(match, isNotNull);
      expect(match![1], 'E = mc^2');
    });

    test(r'does not match \$ escaped dollar', () {
      final syntax = InlineMathSyntax();
      // The negative lookbehind prevents matching when preceded by a backslash.
      // Verify that no group-1 match starts right after the backslash (pos 1).
      final match = syntax.pattern.firstMatch(r'\$100\$');
      if (match != null) {
        expect(match.start, isNot(1));
      }
    });

    test(r'matches \(...\) expressions', () {
      final syntax = InlineMathSyntax();
      final match = syntax.pattern.firstMatch(r'\(E = mc^2\)');
      expect(match, isNotNull);
      // Group 2 captures the \(...\) content.
      expect(match![2], 'E = mc^2');
    });
  });

  group('BlockMathSyntax — unit', () {
    test(r'pattern matches $$ opening line', () {
      const syntax = BlockMathSyntax();
      expect(syntax.pattern.hasMatch(r'$$'), isTrue);
    });

    test(r'pattern matches \[ opening line', () {
      const syntax = BlockMathSyntax();
      expect(syntax.pattern.hasMatch(r'\['), isTrue);
    });

    test(r'pattern does not match inline content with $$', () {
      const syntax = BlockMathSyntax();
      expect(syntax.pattern.hasMatch(r'some text $$'), isFalse);
    });
  });
}
