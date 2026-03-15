import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:runa/application/application.dart';
import 'package:runa/domain/domain.dart';
import 'package:runa/presentation/editor/document_editor.dart';

// ---------------------------------------------------------------------------
// Fakes (same as document_editor_test.dart)
// ---------------------------------------------------------------------------

class _FakeDocumentRepository implements DocumentRepository {
  final Map<String, Document> _store = {};

  void seed(String path, Document doc) => _store[path] = doc;

  @override
  Future<Document> load(String path) async {
    final doc = _store[path];
    if (doc == null) throw DocumentNotFoundException(path: path);
    return doc;
  }

  @override
  Future<void> save(Document doc, String path) async => _store[path] = doc;

  @override
  Future<List<String>> listDocuments(String directory) async =>
      _store.keys.where((k) => k.startsWith(directory)).toList();
}

class _FakeRecentFilesService implements RecentFilesService {
  @override
  Future<List<String>> loadRecents() async => const [];

  @override
  Future<List<RecentEntry>> loadRecentEntries() async => const [];

  @override
  Future<void> addRecent(String path) async {}

  @override
  Future<void> remove(String path) async {}

  @override
  Future<void> clear() async {}
}

class _FakeFileSystemService implements FileSystemService {
  @override
  Future<List<String>> listRunaFiles(String directory) async => const [];

  @override
  Future<List<DirectoryItem>> listDirectory(String path) async => const [];

  @override
  Stream<FileSystemEvent> watchDirectory(String directory) =>
      const Stream.empty();

  @override
  Future<void> createDirectory(String path) async {}

  @override
  Future<void> renameEntry(String oldPath, String newPath) async {}

  @override
  Future<void> deleteFile(String path) async {}

  @override
  Future<void> deleteDirectory(String path) async {}
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

const _docId = '00000000-0000-0000-0000-000000000099';
const _docPath = '/tmp/runa_insert_test/doc.runa';

Document _makeDoc({List<Block> blocks = const []}) => Document(
      version: '0.1',
      id: _docId,
      createdAt: DateTime.utc(2024),
      updatedAt: DateTime.utc(2024),
      blocks: blocks,
    );

OpenedDocument _makeOpened({List<Block> blocks = const []}) => OpenedDocument(
      document: _makeDoc(blocks: blocks),
      path: _docPath,
    );

Future<ProviderContainer> pumpEditor(
  WidgetTester tester, {
  required OpenedDocument opened,
}) async {
  late ProviderContainer container;

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        documentRepositoryProvider
            .overrideWith((_) => _FakeDocumentRepository()),
        recentFilesServiceProvider
            .overrideWith((_) => _FakeRecentFilesService()),
        fileSystemServiceProvider
            .overrideWith((_) => _FakeFileSystemService()),
      ],
      child: MaterialApp(
        home: Scaffold(
          body: Consumer(
            builder: (context, ref, _) {
              container = ProviderScope.containerOf(context);
              return DocumentEditor(opened: opened);
            },
          ),
        ),
      ),
    ),
  );

  await tester.pumpAndSettle();
  return container;
}

EditorState editorState(ProviderContainer c) =>
    c.read(editorProvider(_docId));

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  // -------------------------------------------------------------------------
  // Gap popup menu
  // -------------------------------------------------------------------------

  group('gap insert menu', () {
    testWidgets('tapping gap "+" shows block type options', (tester) async {
      final blocks = [const Block.markdown(id: 'b1', content: 'Hola')];
      await pumpEditor(tester, opened: _makeOpened(blocks: blocks));

      await tester.tap(find.byTooltip('Insertar bloque').first);
      await tester.pumpAndSettle();

      expect(find.text('Texto (Markdown)'), findsOneWidget);
      expect(find.text('Escritura a mano (Ink)'), findsOneWidget);
    });

    testWidgets('selecting "Texto (Markdown)" inserts MarkdownBlock after b1',
        (tester) async {
      final blocks = [
        const Block.markdown(id: 'b1', content: 'primero'),
        const Block.markdown(id: 'b2', content: 'segundo'),
      ];
      final container =
          await pumpEditor(tester, opened: _makeOpened(blocks: blocks));

      // Tap the first gap (after b1).
      await tester.tap(find.byTooltip('Insertar bloque').first);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Texto (Markdown)'));
      await tester.pumpAndSettle();

      final state = editorState(container);
      expect(state.blocks, hasLength(3));
      expect(state.blocks[0].id, 'b1');
      expect(state.blocks[1], isA<MarkdownBlock>());
      expect(state.blocks[2].id, 'b2');
    });

    testWidgets('selecting "Escritura a mano (Ink)" inserts InkBlock after b1',
        (tester) async {
      final blocks = [const Block.markdown(id: 'b1', content: 'primero')];
      final container =
          await pumpEditor(tester, opened: _makeOpened(blocks: blocks));

      await tester.tap(find.byTooltip('Insertar bloque').first);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Escritura a mano (Ink)'));
      await tester.pumpAndSettle();

      final state = editorState(container);
      expect(state.blocks, hasLength(2));
      expect(state.blocks[0].id, 'b1');
      expect(state.blocks[1], isA<InkBlock>());
    });

    testWidgets('new block is selected after gap insertion', (tester) async {
      final blocks = [const Block.markdown(id: 'b1', content: 'Hola')];
      final container =
          await pumpEditor(tester, opened: _makeOpened(blocks: blocks));

      await tester.tap(find.byTooltip('Insertar bloque').first);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Texto (Markdown)'));
      await tester.pumpAndSettle();

      final state = editorState(container);
      expect(state.selectedBlockId, isNotNull);
      expect(state.selectedBlockId, state.blocks[1].id);
    });

    testWidgets('inserting at last gap appends block at the end',
        (tester) async {
      final blocks = [
        const Block.markdown(id: 'b1', content: 'primero'),
        const Block.markdown(id: 'b2', content: 'segundo'),
      ];
      final container =
          await pumpEditor(tester, opened: _makeOpened(blocks: blocks));

      // The second gap is after b2 (the last block).
      await tester.tap(find.byTooltip('Insertar bloque').last);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Texto (Markdown)'));
      await tester.pumpAndSettle();

      final state = editorState(container);
      expect(state.blocks, hasLength(3));
      expect(state.blocks[2], isA<MarkdownBlock>());
    });
  });

  // -------------------------------------------------------------------------
  // Enter at end of MarkdownBlock
  // -------------------------------------------------------------------------

  group('Enter at end of MarkdownBlock', () {
    testWidgets('Enter on empty block creates new MarkdownBlock below',
        (tester) async {
      final blocks = [const Block.markdown(id: 'b1', content: '')];
      final container =
          await pumpEditor(tester, opened: _makeOpened(blocks: blocks));

      // Tap the TextField to focus it (empty block starts in edit mode).
      await tester.tap(find.byType(TextField));
      await tester.pump();

      await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
      await tester.pump();

      final state = editorState(container);
      expect(state.blocks, hasLength(2));
      expect(state.blocks[0].id, 'b1');
      expect(state.blocks[1], isA<MarkdownBlock>());
    });

    testWidgets('Enter on block whose last line is empty creates new block',
        (tester) async {
      final blocks = [const Block.markdown(id: 'b1', content: 'hola')];
      final container =
          await pumpEditor(tester, opened: _makeOpened(blocks: blocks));

      // Switch to edit mode.
      await tester.tap(find.text('Editar'));
      await tester.pump();

      // Set text ending with newline, then press Ctrl+Enter.
      await tester.enterText(find.byType(TextField), 'hola\n');
      await tester.pump();

      await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
      await tester.pump();

      final state = editorState(container);
      expect(state.blocks, hasLength(2));
      expect(state.blocks[0].id, 'b1');
      expect(state.blocks[1], isA<MarkdownBlock>());
    });

    testWidgets('new block from Enter is inserted after the source block',
        (tester) async {
      final blocks = [
        const Block.markdown(id: 'b1', content: ''),
        const Block.markdown(id: 'b2', content: 'existente'),
      ];
      final container =
          await pumpEditor(tester, opened: _makeOpened(blocks: blocks));

      // Focus the first TextField (b1, which is empty and in edit mode).
      await tester.tap(find.byType(TextField).first);
      await tester.pump();

      await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
      await tester.pump();

      final state = editorState(container);
      expect(state.blocks, hasLength(3));
      expect(state.blocks[0].id, 'b1');
      expect(state.blocks[1], isA<MarkdownBlock>());
      expect(state.blocks[2].id, 'b2');
    });

    testWidgets('new block from Enter is selected', (tester) async {
      final blocks = [const Block.markdown(id: 'b1', content: '')];
      final container =
          await pumpEditor(tester, opened: _makeOpened(blocks: blocks));

      await tester.tap(find.byType(TextField));
      await tester.pump();

      await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
      await tester.pump();

      final state = editorState(container);
      expect(state.selectedBlockId, isNotNull);
      expect(state.selectedBlockId, isNot('b1'));
      expect(state.selectedBlockId, state.blocks[1].id);
    });
  });
}
