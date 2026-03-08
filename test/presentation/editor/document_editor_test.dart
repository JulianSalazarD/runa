import 'dart:io';

import 'package:flutter/material.dart';
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

    testWidgets('shows placeholder text for empty markdown content',
        (tester) async {
      final blocks = [const Block.markdown(id: 'b1', content: '')];
      await pumpEditor(tester, opened: _makeOpened(blocks: blocks));

      expect(find.text('Escribe aquí…'), findsOneWidget);
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

    testWidgets('tapping "+" toolbar button inserts a block at the end',
        (tester) async {
      final blocks = [const Block.markdown(id: 'b1', content: 'primero')];
      final container =
          await pumpEditor(tester, opened: _makeOpened(blocks: blocks));

      await tester.tap(find.widgetWithIcon(IconButton, Icons.add));
      await tester.pump();

      final editorState = container.read(editorNotifierProvider(_docId));
      expect(editorState.blocks, hasLength(2));
      expect(editorState.blocks.first.id, 'b1');
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

    testWidgets('pressing × on a selected block removes it', (tester) async {
      final blocks = [
        const Block.markdown(id: 'b1', content: 'primero'),
        const Block.markdown(id: 'b2', content: 'segundo'),
      ];
      final container =
          await pumpEditor(tester, opened: _makeOpened(blocks: blocks));

      // Select the first block to make controls visible.
      container
          .read(editorNotifierProvider(_docId).notifier)
          .setSelectedBlock('b1');
      await tester.pump();

      // Tap the delete icon (Icons.close).
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
