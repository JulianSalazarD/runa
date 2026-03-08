import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:runa/domain/domain.dart';
import 'package:runa/presentation/editor/block_widget.dart';
import 'package:runa/presentation/editor/markdown_editor_widget.dart';
import 'package:runa/presentation/editor/markdown_preview_widget.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Widget _wrap(Widget child) =>
    MaterialApp(home: Scaffold(body: SingleChildScrollView(child: child)));

// ---------------------------------------------------------------------------
// 3.1 — MarkdownEditorWidget
// ---------------------------------------------------------------------------

void main() {
  group('MarkdownEditorWidget', () {
    testWidgets('renders TextField with initial content', (tester) async {
      await tester.pumpWidget(_wrap(
        MarkdownEditorWidget(
          initialContent: 'Hola mundo',
          onChanged: (_) {},
        ),
      ));

      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Hola mundo'), findsOneWidget);
    });

    testWidgets('changing text calls onChanged after 300 ms debounce',
        (tester) async {
      String? captured;
      await tester.pumpWidget(_wrap(
        MarkdownEditorWidget(
          initialContent: '',
          onChanged: (v) => captured = v,
        ),
      ));

      await tester.enterText(find.byType(TextField), 'nuevo texto');
      // Before debounce fires, callback not called yet.
      expect(captured, isNull);

      // Advance time past the debounce delay.
      await tester.pump(const Duration(milliseconds: 300));
      expect(captured, 'nuevo texto');
    });

    testWidgets('rapid keystrokes fire onChanged only once', (tester) async {
      int callCount = 0;
      await tester.pumpWidget(_wrap(
        MarkdownEditorWidget(
          initialContent: '',
          onChanged: (_) => callCount++,
        ),
      ));

      final field = find.byType(TextField);
      await tester.enterText(field, 'a');
      await tester.pump(const Duration(milliseconds: 100));
      await tester.enterText(field, 'ab');
      await tester.pump(const Duration(milliseconds: 100));
      await tester.enterText(field, 'abc');
      // Only 100 ms elapsed since last keystroke — callback not fired yet.
      expect(callCount, 0);

      // Fire the debounce.
      await tester.pump(const Duration(milliseconds: 300));
      expect(callCount, 1);
    });

    testWidgets('losing focus flushes debounce immediately', (tester) async {
      String? captured;
      final otherFocus = FocusNode();

      await tester.pumpWidget(_wrap(
        Column(
          children: [
            MarkdownEditorWidget(
              initialContent: '',
              onChanged: (v) => captured = v,
            ),
            Focus(focusNode: otherFocus, child: const SizedBox()),
          ],
        ),
      ));

      await tester.enterText(find.byType(TextField), 'texto');
      // Debounce not fired yet.
      expect(captured, isNull);

      // Move focus away → flush should happen immediately.
      otherFocus.requestFocus();
      await tester.pump();
      expect(captured, 'texto');
    });
  });

  // -------------------------------------------------------------------------
  // 3.2 — MarkdownPreviewWidget
  // -------------------------------------------------------------------------

  group('MarkdownPreviewWidget', () {
    testWidgets('shows placeholder when content is empty', (tester) async {
      await tester.pumpWidget(
          _wrap(const MarkdownPreviewWidget(content: '')));

      expect(find.text('Escribe aquí…'), findsOneWidget);
    });

    testWidgets('renders plain text content', (tester) async {
      await tester
          .pumpWidget(_wrap(const MarkdownPreviewWidget(content: 'Hola mundo')));

      expect(find.textContaining('Hola mundo'), findsOneWidget);
    });

    testWidgets('renders heading from markdown', (tester) async {
      await tester.pumpWidget(
          _wrap(const MarkdownPreviewWidget(content: '# Título principal')));
      await tester.pumpAndSettle();

      expect(find.textContaining('Título principal'), findsOneWidget);
    });

    testWidgets('renders bold text', (tester) async {
      await tester.pumpWidget(
          _wrap(const MarkdownPreviewWidget(content: '**negrita**')));
      await tester.pumpAndSettle();

      expect(find.textContaining('negrita'), findsOneWidget);
    });

    testWidgets('renders without error for complex markdown', (tester) async {
      const md = '''
# Heading

Some **bold** and *italic* text.

- Item 1
- Item 2

`inline code`

```
code block
```
''';
      await tester
          .pumpWidget(_wrap(const MarkdownPreviewWidget(content: md)));
      await tester.pumpAndSettle();
      // No exceptions and at least some text rendered.
      expect(find.textContaining('Heading'), findsOneWidget);
    });
  });

  // -------------------------------------------------------------------------
  // 3.3 — BlockWidget toggle (raw ↔ preview)
  // -------------------------------------------------------------------------

  group('BlockWidget toggle raw ↔ preview', () {
    const emptyBlock = Block.markdown(id: 'b1', content: '');
    const contentBlock = Block.markdown(id: 'b2', content: '## Sección');

    testWidgets('empty block starts in edit mode (TextField visible)',
        (tester) async {
      await tester.pumpWidget(_wrap(const BlockWidget(block: emptyBlock)));

      expect(find.byType(TextField), findsOneWidget);
      expect(find.byType(MarkdownPreviewWidget), findsNothing);
    });

    testWidgets('block with content starts in preview mode', (tester) async {
      await tester.pumpWidget(_wrap(const BlockWidget(block: contentBlock)));
      await tester.pumpAndSettle();

      expect(find.byType(MarkdownPreviewWidget), findsOneWidget);
      expect(find.byType(TextField), findsNothing);
    });

    testWidgets('toggle button in edit mode shows "Vista previa"',
        (tester) async {
      await tester.pumpWidget(_wrap(const BlockWidget(block: emptyBlock)));

      expect(find.text('Vista previa'), findsOneWidget);
    });

    testWidgets('toggle button in preview mode shows "Editar"',
        (tester) async {
      await tester.pumpWidget(_wrap(const BlockWidget(block: contentBlock)));
      await tester.pumpAndSettle();

      expect(find.text('Editar'), findsOneWidget);
    });

    testWidgets('tapping toggle from edit switches to preview', (tester) async {
      await tester.pumpWidget(_wrap(const BlockWidget(block: emptyBlock)));

      expect(find.byType(TextField), findsOneWidget);
      await tester.tap(find.text('Vista previa'));
      await tester.pump();

      expect(find.byType(MarkdownPreviewWidget), findsOneWidget);
      expect(find.byType(TextField), findsNothing);
    });

    testWidgets('tapping toggle from preview switches to edit', (tester) async {
      await tester.pumpWidget(_wrap(const BlockWidget(block: contentBlock)));
      await tester.pumpAndSettle();

      expect(find.byType(MarkdownPreviewWidget), findsOneWidget);
      await tester.tap(find.text('Editar'));
      await tester.pump();

      expect(find.byType(TextField), findsOneWidget);
      expect(find.byType(MarkdownPreviewWidget), findsNothing);
    });

    testWidgets('tapping "Editar" toggle in preview switches to edit',
        (tester) async {
      await tester.pumpWidget(_wrap(const BlockWidget(block: contentBlock)));
      await tester.pumpAndSettle();

      // Toggle button shows "Editar" in preview mode.
      await tester.tap(find.text('Editar'));
      await tester.pump();

      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('editing block calls onUpdate with updated content',
        (tester) async {
      Block? updated;
      await tester.pumpWidget(_wrap(BlockWidget(
        block: emptyBlock,
        onUpdate: (b) => updated = b,
      )));

      await tester.enterText(find.byType(TextField), 'nuevo contenido');
      await tester.pump(const Duration(milliseconds: 300));

      expect(updated, isNotNull);
      expect((updated as MarkdownBlock).content, 'nuevo contenido');
    });
  });
}
