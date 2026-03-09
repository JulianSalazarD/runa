import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:runa/application/application.dart';
import 'package:runa/domain/domain.dart';
import 'package:runa/presentation/editor/document_editor.dart';

// ---------------------------------------------------------------------------
// Fakes
// ---------------------------------------------------------------------------

class FakeDocumentRepository implements DocumentRepository {
  final Map<String, Document> _store = {};
  final List<({Document doc, String path})> saves = [];

  void seed(String path, Document doc) => _store[path] = doc;

  @override
  Future<Document> load(String path) async {
    final doc = _store[path];
    if (doc == null) throw DocumentNotFoundException(path: path);
    return doc;
  }

  @override
  Future<void> save(Document doc, String path) async {
    saves.add((doc: doc, path: path));
    _store[path] = doc;
  }

  @override
  Future<List<String>> listDocuments(String directory) async =>
      _store.keys.where((k) => k.startsWith(directory)).toList();
}

class FakeRecentFilesService implements RecentFilesService {
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

class FakeFileSystemService implements FileSystemService {
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

const _docId = '00000000-0000-0000-0000-000000000001';
const _docPath = '/tmp/runa_editor_test/doc.runa';

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

/// Pumps a [DocumentEditor] inside a [ProviderScope] with fake providers.
/// Returns the [ProviderContainer] so tests can inspect state directly.
Future<ProviderContainer> pumpEditor(
  WidgetTester tester, {
  required OpenedDocument opened,
  FakeDocumentRepository? repo,
}) async {
  final fakeRepo = repo ?? FakeDocumentRepository();

  late ProviderContainer container;

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        documentRepositoryProvider.overrideWith((_) => fakeRepo),
        recentFilesServiceProvider
            .overrideWith((_) => FakeRecentFilesService()),
        fileSystemServiceProvider.overrideWith((_) => FakeFileSystemService()),
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

  // Wait for initFromDocument (addPostFrameCallback).
  await tester.pumpAndSettle();
  return container;
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  // -------------------------------------------------------------------------
  // Block list rendering
  // -------------------------------------------------------------------------

  group('block list', () {
    testWidgets('renders all blocks from document', (tester) async {
      final blocks = [
        const Block.markdown(id: 'b1', content: 'Hola mundo'),
        const Block.markdown(id: 'b2', content: 'Segunda línea'),
      ];
      await pumpEditor(tester, opened: _makeOpened(blocks: blocks));

      expect(find.text('Hola mundo'), findsOneWidget);
      expect(find.text('Segunda línea'), findsOneWidget);
    });

    testWidgets('shows empty-state message when document has no blocks',
        (tester) async {
      await pumpEditor(tester, opened: _makeOpened());

      expect(find.textContaining('Sin bloques'), findsOneWidget);
    });

    testWidgets('shows editor for empty markdown content (edit mode)',
        (tester) async {
      final blocks = [const Block.markdown(id: 'b1', content: '')];
      await pumpEditor(tester, opened: _makeOpened(blocks: blocks));

      // Empty blocks start in edit mode — a TextField is rendered.
      expect(find.byType(TextField), findsOneWidget);
    });
  });

  // -------------------------------------------------------------------------
  // Toolbar
  // -------------------------------------------------------------------------

  group('toolbar', () {
    testWidgets('shows document name without extension', (tester) async {
      await pumpEditor(tester, opened: _makeOpened());

      expect(find.text('doc'), findsOneWidget);
    });

    testWidgets('shows ● when isDirty', (tester) async {
      final container =
          await pumpEditor(tester, opened: _makeOpened());

      // Make the editor dirty by adding a block.
      container
          .read(editorNotifierProvider(_docId).notifier)
          .addBlock(const Block.markdown(id: 'new', content: ''));
      await tester.pump();

      expect(find.text('●'), findsOneWidget);
    });

    testWidgets('does not show ● when clean', (tester) async {
      await pumpEditor(tester, opened: _makeOpened());

      expect(find.text('●'), findsNothing);
    });

    testWidgets('tapping "+" toolbar button shows block-type popup',
        (tester) async {
      final blocks = [const Block.markdown(id: 'b1', content: 'primero')];
      await pumpEditor(tester, opened: _makeOpened(blocks: blocks));

      await tester.tap(find.byTooltip('Nuevo bloque al final'));
      await tester.pumpAndSettle();

      expect(find.text('Texto (Markdown)'), findsOneWidget);
      expect(find.text('Escritura a mano (Ink)'), findsOneWidget);
    });

    testWidgets('selecting "Texto (Markdown)" from toolbar inserts block at end',
        (tester) async {
      final blocks = [const Block.markdown(id: 'b1', content: 'primero')];
      final container =
          await pumpEditor(tester, opened: _makeOpened(blocks: blocks));

      await tester.tap(find.byTooltip('Nuevo bloque al final'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Texto (Markdown)'));
      await tester.pumpAndSettle();

      final editorState = container.read(editorNotifierProvider(_docId));
      expect(editorState.blocks, hasLength(2));
      expect(editorState.blocks.last, isA<MarkdownBlock>());
    });

    testWidgets('tapping "Guardar" saves the document', (tester) async {
      final fakeRepo = FakeDocumentRepository();
      final blocks = [const Block.markdown(id: 'b1', content: 'texto')];
      final container = await pumpEditor(
        tester,
        opened: _makeOpened(blocks: blocks),
        repo: fakeRepo,
      );

      // Make it dirty first.
      container
          .read(editorNotifierProvider(_docId).notifier)
          .addBlock(const Block.markdown(id: 'b2', content: ''));
      await tester.pump();

      await tester.tap(find.text('Guardar'));
      await tester.pumpAndSettle();

      expect(fakeRepo.saves, isNotEmpty);
      final editorState = container.read(editorNotifierProvider(_docId));
      expect(editorState.isDirty, isFalse);
    });
  });

  // -------------------------------------------------------------------------
  // Block interactions
  // -------------------------------------------------------------------------

  group('block interactions', () {
    testWidgets('tapping a block selects it', (tester) async {
      final blocks = [
        const Block.markdown(id: 'b1', content: 'primero'),
        const Block.markdown(id: 'b2', content: 'segundo'),
      ];
      final container =
          await pumpEditor(tester, opened: _makeOpened(blocks: blocks));

      await tester.tap(find.text('primero'));
      await tester.pump();

      expect(
        container.read(editorNotifierProvider(_docId)).selectedBlockId,
        'b1',
      );
    });

    testWidgets('pressing × on an empty block removes it without dialog',
        (tester) async {
      final blocks = [
        const Block.markdown(id: 'b1', content: ''),
        const Block.markdown(id: 'b2', content: 'segundo'),
      ];
      final container =
          await pumpEditor(tester, opened: _makeOpened(blocks: blocks));

      // Select the first block to make controls visible.
      container
          .read(editorNotifierProvider(_docId).notifier)
          .setSelectedBlock('b1');
      await tester.pumpAndSettle();

      // Tap the delete icon (Icons.close) — no dialog since block is empty.
      await tester.tap(find.byIcon(Icons.close).first);
      await tester.pump();

      expect(
        container.read(editorNotifierProvider(_docId)).blocks,
        hasLength(1),
      );
      expect(
        container.read(editorNotifierProvider(_docId)).blocks.first.id,
        'b2',
      );
    });
  });

  // -------------------------------------------------------------------------
  // Block delete with confirmation
  // -------------------------------------------------------------------------

  group('block delete', () {
    testWidgets('× on block with content shows confirmation dialog',
        (tester) async {
      final blocks = [
        const Block.markdown(id: 'b1', content: 'texto importante'),
      ];
      final container =
          await pumpEditor(tester, opened: _makeOpened(blocks: blocks));

      container
          .read(editorNotifierProvider(_docId).notifier)
          .setSelectedBlock('b1');
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.close).first);
      await tester.pumpAndSettle();

      // Dialog must appear.
      expect(find.text('¿Eliminar este bloque?'), findsOneWidget);

      // Block is NOT yet removed.
      expect(
        container.read(editorNotifierProvider(_docId)).blocks,
        hasLength(1),
      );
    });

    testWidgets('confirming dialog removes block and marks dirty',
        (tester) async {
      final blocks = [
        const Block.markdown(id: 'b1', content: 'texto'),
        const Block.markdown(id: 'b2', content: 'otro'),
      ];
      final container =
          await pumpEditor(tester, opened: _makeOpened(blocks: blocks));

      container
          .read(editorNotifierProvider(_docId).notifier)
          .setSelectedBlock('b1');
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.close).first);
      await tester.pumpAndSettle();

      // Confirm deletion.
      await tester.tap(find.text('Eliminar'));
      await tester.pumpAndSettle();

      final state = container.read(editorNotifierProvider(_docId));
      expect(state.blocks, hasLength(1));
      expect(state.blocks.first.id, 'b2');
      expect(state.isDirty, isTrue);
    });

    testWidgets('cancelling dialog leaves block intact', (tester) async {
      final blocks = [
        const Block.markdown(id: 'b1', content: 'texto importante'),
      ];
      final container =
          await pumpEditor(tester, opened: _makeOpened(blocks: blocks));

      container
          .read(editorNotifierProvider(_docId).notifier)
          .setSelectedBlock('b1');
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.close).first);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Cancelar'));
      await tester.pumpAndSettle();

      expect(
        container.read(editorNotifierProvider(_docId)).blocks,
        hasLength(1),
      );
    });

    testWidgets('Delete key on empty selected block removes without dialog',
        (tester) async {
      final blocks = [
        const Block.markdown(id: 'b1', content: ''),
        const Block.markdown(id: 'b2', content: 'segundo'),
      ];
      final container =
          await pumpEditor(tester, opened: _makeOpened(blocks: blocks));

      // Select via notifier — editor Focus node has autofocus so it keeps focus.
      container
          .read(editorNotifierProvider(_docId).notifier)
          .setSelectedBlock('b1');
      await tester.pump();

      await tester.sendKeyEvent(LogicalKeyboardKey.delete);
      await tester.pump();

      // No dialog; block removed immediately.
      expect(find.text('¿Eliminar este bloque?'), findsNothing);
      final state = container.read(editorNotifierProvider(_docId));
      expect(state.blocks, hasLength(1));
      expect(state.blocks.first.id, 'b2');
    });

    testWidgets('Delete key on block with content shows confirmation dialog',
        (tester) async {
      final blocks = [
        const Block.markdown(id: 'b1', content: 'texto importante'),
      ];
      final container =
          await pumpEditor(tester, opened: _makeOpened(blocks: blocks));

      container
          .read(editorNotifierProvider(_docId).notifier)
          .setSelectedBlock('b1');
      await tester.pump();

      await tester.sendKeyEvent(LogicalKeyboardKey.delete);
      await tester.pumpAndSettle();

      expect(find.text('¿Eliminar este bloque?'), findsOneWidget);
      // Block still present while dialog is open.
      expect(
        container.read(editorNotifierProvider(_docId)).blocks,
        hasLength(1),
      );
    });
  });

  // -------------------------------------------------------------------------
  // Block reorder (drag & drop)
  // -------------------------------------------------------------------------

  group('block reorder', () {
    testWidgets(
        'drag handle uses ReorderableDragStartListener when 2+ blocks',
        (tester) async {
      final blocks = [
        const Block.markdown(id: 'b1', content: 'primero'),
        const Block.markdown(id: 'b2', content: 'segundo'),
      ];
      await pumpEditor(tester, opened: _makeOpened(blocks: blocks));

      expect(find.byType(ReorderableDragStartListener), findsWidgets);
    });

    testWidgets('drag handle has no ReorderableDragStartListener with 1 block',
        (tester) async {
      final blocks = [const Block.markdown(id: 'b1', content: 'único')];
      await pumpEditor(tester, opened: _makeOpened(blocks: blocks));

      expect(find.byType(ReorderableDragStartListener), findsNothing);
    });

    testWidgets('dragging block 0 to end moves it to last position',
        (tester) async {
      final blocks = [
        const Block.markdown(id: 'b0', content: 'primero'),
        const Block.markdown(id: 'b1', content: 'segundo'),
        const Block.markdown(id: 'b2', content: 'tercero'),
      ];
      final container =
          await pumpEditor(tester, opened: _makeOpened(blocks: blocks));

      // Select block 0 so its drag handle becomes visible (opacity → 1.0).
      container
          .read(editorNotifierProvider(_docId).notifier)
          .setSelectedBlock('b0');
      await tester.pumpAndSettle();

      // Drag the first handle far enough to pass all blocks below.
      await tester.drag(
        find.byType(ReorderableDragStartListener).first,
        const Offset(0, 400),
      );
      await tester.pumpAndSettle();

      final state = container.read(editorNotifierProvider(_docId));
      expect(state.blocks.last.id, 'b0');
    });

    testWidgets('reordering marks document as dirty', (tester) async {
      final blocks = [
        const Block.markdown(id: 'b0', content: 'primero'),
        const Block.markdown(id: 'b1', content: 'segundo'),
      ];
      final container =
          await pumpEditor(tester, opened: _makeOpened(blocks: blocks));

      container
          .read(editorNotifierProvider(_docId).notifier)
          .setSelectedBlock('b0');
      await tester.pumpAndSettle();

      await tester.drag(
        find.byType(ReorderableDragStartListener).first,
        const Offset(0, 200),
      );
      await tester.pumpAndSettle();

      expect(
        container.read(editorNotifierProvider(_docId)).isDirty,
        isTrue,
      );
    });
  });

  // -------------------------------------------------------------------------
  // Tab switch (didUpdateWidget)
  // -------------------------------------------------------------------------

  group('tab switch', () {
    late Directory tempDir;

    setUp(() {
      tempDir = Directory.systemTemp.createTempSync('runa_editor_switch_');
    });

    tearDown(() {
      if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
    });

    testWidgets('switching opened document updates rendered content',
        (tester) async {
      final docA = Document(
        version: '0.1',
        id: 'id-a',
        createdAt: DateTime.utc(2024),
        updatedAt: DateTime.utc(2024),
        blocks: const [Block.markdown(id: 'ba', content: 'Alpha content')],
      );
      final docB = Document(
        version: '0.1',
        id: 'id-b',
        createdAt: DateTime.utc(2024),
        updatedAt: DateTime.utc(2024),
        blocks: const [Block.markdown(id: 'bb', content: 'Beta content')],
      );
      final openedA = OpenedDocument(
          document: docA, path: '${tempDir.path}/alpha.runa');
      final openedB = OpenedDocument(
          document: docB, path: '${tempDir.path}/beta.runa');

      // Pump with doc A.
      final notifier = ValueNotifier<OpenedDocument>(openedA);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            documentRepositoryProvider
                .overrideWith((_) => FakeDocumentRepository()),
            recentFilesServiceProvider
                .overrideWith((_) => FakeRecentFilesService()),
            fileSystemServiceProvider
                .overrideWith((_) => FakeFileSystemService()),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: ValueListenableBuilder(
                valueListenable: notifier,
                builder: (_, opened, _) => DocumentEditor(opened: opened),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Alpha content'), findsOneWidget);
      expect(find.text('Beta content'), findsNothing);

      // Switch to doc B.
      notifier.value = openedB;
      await tester.pumpAndSettle();

      expect(find.text('Alpha content'), findsNothing);
      expect(find.text('Beta content'), findsOneWidget);
    });
  });
}
