import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:runa/presentation/editor/markdown_preview_widget.dart';

Widget _wrap(Widget child) =>
    MaterialApp(home: Scaffold(body: SingleChildScrollView(child: child)));

const _simpleTable = '''
| A | B | C |
|---|---|---|
| 1 | 2 | 3 |
| 4 | 5 | 6 |
''';

const _alignTable = '''
| Left | Center | Right |
|:-----|:------:|------:|
| L    |   C    |     R |
''';

const _inlineTable = '''
| Name | Value |
|------|-------|
| **Bold** | *italic* |
''';

void main() {
  group('TableBuilder', () {
    testWidgets('3-column table renders without error', (tester) async {
      await tester.pumpWidget(_wrap(const MarkdownPreviewWidget(content: _simpleTable)));
      await tester.pumpAndSettle();
      expect(find.text('A'), findsOneWidget);
      expect(find.text('1'), findsOneWidget);
      expect(find.text('6'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('column alignment renders without crash', (tester) async {
      await tester.pumpWidget(_wrap(const MarkdownPreviewWidget(content: _alignTable)));
      await tester.pumpAndSettle();
      expect(find.text('Left'), findsOneWidget);
      expect(find.text('Center'), findsOneWidget);
      expect(find.text('Right'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('table with inline content renders without crash', (tester) async {
      await tester.pumpWidget(_wrap(const MarkdownPreviewWidget(content: _inlineTable)));
      await tester.pumpAndSettle();
      expect(find.text('Name'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
