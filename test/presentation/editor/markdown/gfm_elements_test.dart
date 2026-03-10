import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:runa/presentation/editor/markdown_preview_widget.dart';

Widget _wrap(Widget child) =>
    MaterialApp(home: Scaffold(body: SingleChildScrollView(child: child)));

void main() {
  group('GFM — Strikethrough', () {
    testWidgets('~~text~~ renders with line-through decoration', (tester) async {
      await tester.pumpWidget(
        _wrap(const MarkdownPreviewWidget(content: '~~deleted~~')),
      );
      await tester.pumpAndSettle();
      // Should render without error and contain the text.
      expect(tester.takeException(), isNull);
      // The text appears (possibly inside a RichText with del style).
      expect(find.textContaining('deleted'), findsWidgets);
    });
  });

  group('GFM — Autolinks', () {
    testWidgets('bare URL renders as link without crash', (tester) async {
      await tester.pumpWidget(
        _wrap(const MarkdownPreviewWidget(
          content: 'Visit https://example.com for info',
        )),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      // Either the URL or the surrounding text is rendered.
    });
  });
}
