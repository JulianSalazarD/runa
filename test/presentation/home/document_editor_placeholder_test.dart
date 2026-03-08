import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:runa/application/application.dart';
import 'package:runa/domain/domain.dart';
import 'package:runa/presentation/home/document_editor_placeholder.dart';

// ---------------------------------------------------------------------------
// Fakes
// ---------------------------------------------------------------------------

class FakeDocumentRepository implements DocumentRepository {
  final Map<String, Document> _store = {};
  final List<(Document, String)> saveCalls = [];

  void seed(String path, Document doc) => _store[path] = doc;

  @override
  Future<Document> load(String path) async {
    final doc = _store[path];
    if (doc == null) throw DocumentNotFoundException(path: path);
    return doc;
  }

  @override
  Future<void> save(Document doc, String path) async {
    saveCalls.add((doc, path));
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

Document _makeDoc({
  required String id,
  List<Block> blocks = const [],
}) =>
    Document(
      version: '0.1',
      id: id,
      createdAt: DateTime.utc(2024),
      updatedAt: DateTime.utc(2024),
      blocks: blocks,
    );

/// Builds a widget that seeds the WorkspaceNotifier with [opened] as the
/// active document and wraps the placeholder inside a ProviderScope.
Future<void> pumpWithOpenedDoc(
  WidgetTester tester, {
  required FakeDocumentRepository fakeRepo,
  required OpenedDocument opened,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        documentRepositoryProvider.overrideWith((_) => fakeRepo),
        recentFilesServiceProvider
            .overrideWith((_) => FakeRecentFilesService()),
        fileSystemServiceProvider
            .overrideWith((_) => FakeFileSystemService()),
      ],
      child: MaterialApp(
        home: Scaffold(
          body: DocumentEditorPlaceholder(opened: opened),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  // -------------------------------------------------------------------------
  // Block count label
  // -------------------------------------------------------------------------

  group('block count label', () {
    testWidgets('0 blocks → "Sin bloques"', (tester) async {
      final doc = _makeDoc(id: '1');
      final opened =
          OpenedDocument(document: doc, path: '/tmp/doc.runa');

      await pumpWithOpenedDoc(tester,
          fakeRepo: FakeDocumentRepository()..seed('/tmp/doc.runa', doc),
          opened: opened);

      expect(find.text('Sin bloques'), findsOneWidget);
    });

    testWidgets('1 block → "1 bloque"', (tester) async {
      const block = Block.markdown(id: 'b1', content: '# Hola');
      final doc = _makeDoc(id: '2', blocks: [block]);
      final opened =
          OpenedDocument(document: doc, path: '/tmp/doc.runa');

      await pumpWithOpenedDoc(tester,
          fakeRepo: FakeDocumentRepository()..seed('/tmp/doc.runa', doc),
          opened: opened);

      expect(find.text('1 bloque'), findsOneWidget);
    });

    testWidgets('N blocks → "N bloques"', (tester) async {
      final blocks = List.generate(
        3,
        (i) => Block.markdown(id: 'b$i', content: 'block $i'),
      );
      final doc = _makeDoc(id: '3', blocks: blocks);
      final opened =
          OpenedDocument(document: doc, path: '/tmp/doc.runa');

      await pumpWithOpenedDoc(tester,
          fakeRepo: FakeDocumentRepository()..seed('/tmp/doc.runa', doc),
          opened: opened);

      expect(find.text('3 bloques'), findsOneWidget);
    });
  });

  // -------------------------------------------------------------------------
  // Toolbar — document name
  // -------------------------------------------------------------------------

  group('toolbar', () {
    testWidgets('shows document basename without extension', (tester) async {
      final doc = _makeDoc(id: 'n1');
      final opened = OpenedDocument(
          document: doc, path: '/home/user/Runa/mis_notas.runa');

      await pumpWithOpenedDoc(tester,
          fakeRepo: FakeDocumentRepository()
            ..seed('/home/user/Runa/mis_notas.runa', doc),
          opened: opened);

      // Name appears at least once (toolbar + center body).
      expect(find.text('mis_notas'), findsWidgets);
    });

    testWidgets('● indicator visible when hasUnsavedChanges is true',
        (tester) async {
      final doc = _makeDoc(id: 'u1');
      final opened = OpenedDocument(
        document: doc,
        path: '/tmp/doc.runa',
        hasUnsavedChanges: true,
      );

      await pumpWithOpenedDoc(tester,
          fakeRepo: FakeDocumentRepository()..seed('/tmp/doc.runa', doc),
          opened: opened);

      expect(find.text('●'), findsOneWidget);
    });

    testWidgets('● indicator absent when hasUnsavedChanges is false',
        (tester) async {
      final doc = _makeDoc(id: 'u2');
      final opened = OpenedDocument(
        document: doc,
        path: '/tmp/doc.runa',
      );

      await pumpWithOpenedDoc(tester,
          fakeRepo: FakeDocumentRepository()..seed('/tmp/doc.runa', doc),
          opened: opened);

      expect(find.text('●'), findsNothing);
    });
  });

  // -------------------------------------------------------------------------
  // Save button
  // -------------------------------------------------------------------------

  group('save', () {
    testWidgets('tapping "Guardar" calls DocumentRepository.save()',
        (tester) async {
      final doc = _makeDoc(id: 's1');
      const path = '/tmp/save_test.runa';
      final fakeRepo = FakeDocumentRepository()..seed(path, doc);
      final opened = OpenedDocument(document: doc, path: path);

      await pumpWithOpenedDoc(tester,
          fakeRepo: fakeRepo, opened: opened);

      await tester.tap(find.text('Guardar'));
      await tester.pumpAndSettle();

      expect(fakeRepo.saveCalls, hasLength(1));
      expect(fakeRepo.saveCalls.first.$1, doc);
      expect(fakeRepo.saveCalls.first.$2, path);
    });

    testWidgets(
        'tapping "Guardar" clears the unsaved indicator via WorkspaceNotifier',
        (tester) async {
      final doc = _makeDoc(id: 's2');
      const path = '/tmp/unsaved_test.runa';
      final fakeRepo = FakeDocumentRepository()..seed(path, doc);

      // Use a wrapper that drives state through the WorkspaceNotifier so that
      // the placeholder reads the live state from the provider.
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            documentRepositoryProvider.overrideWith((_) => fakeRepo),
            recentFilesServiceProvider
                .overrideWith((_) => FakeRecentFilesService()),
            fileSystemServiceProvider
                .overrideWith((_) => FakeFileSystemService()),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: Consumer(
                builder: (context, ref, _) {
                  final ws = ref.watch(workspaceNotifierProvider);
                  final active = ws.openedDocuments
                      .where((d) => d.document.id == ws.activeDocumentId)
                      .firstOrNull;
                  if (active == null) return const SizedBox.shrink();
                  return DocumentEditorPlaceholder(opened: active);
                },
              ),
            ),
          ),
        ),
      );

      // Seed state: open the document and mark it as unsaved.
      final element = tester.element(find.byType(Consumer));
      final ref = ProviderScope.containerOf(element);
      final notifier = ref.read(workspaceNotifierProvider.notifier);
      await notifier.openDirectory('/tmp');
      await notifier.openDocument(path);
      notifier.markHasUnsavedChanges(doc.id);
      await tester.pumpAndSettle();

      // The ● indicator should be visible.
      expect(find.text('●'), findsOneWidget);

      // Tap Guardar.
      await tester.tap(find.text('Guardar'));
      await tester.pumpAndSettle();

      // The ● indicator should be gone.
      expect(find.text('●'), findsNothing);
    });
  });

  // -------------------------------------------------------------------------
  // Navigation correctness
  // -------------------------------------------------------------------------

  group('navigation correctness', () {
    late Directory tempDir;

    setUp(() {
      tempDir = Directory.systemTemp.createTempSync('runa_nav_test_');
    });

    tearDown(() {
      if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
    });

    testWidgets('switching active document updates the editor content',
        (tester) async {
      final docA = _makeDoc(id: 'nav-a');
      final docB = _makeDoc(
        id: 'nav-b',
        blocks: [const Block.markdown(id: 'bx', content: '# B')],
      );
      final pathA = '${tempDir.path}/alpha.runa';
      final pathB = '${tempDir.path}/beta.runa';

      final fakeRepo = FakeDocumentRepository()
        ..seed(pathA, docA)
        ..seed(pathB, docB);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            documentRepositoryProvider.overrideWith((_) => fakeRepo),
            recentFilesServiceProvider
                .overrideWith((_) => FakeRecentFilesService()),
            fileSystemServiceProvider
                .overrideWith((_) => FakeFileSystemService()),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: Consumer(
                builder: (context, ref, _) {
                  final ws = ref.watch(workspaceNotifierProvider);
                  final active = ws.openedDocuments
                      .where((d) => d.document.id == ws.activeDocumentId)
                      .firstOrNull;
                  if (active == null) return const SizedBox.shrink();
                  return DocumentEditorPlaceholder(opened: active);
                },
              ),
            ),
          ),
        ),
      );

      final element = tester.element(find.byType(Consumer));
      final ref = ProviderScope.containerOf(element);
      final notifier = ref.read(workspaceNotifierProvider.notifier);

      await notifier.openDirectory(tempDir.path);
      await notifier.openDocument(pathA);
      await tester.pumpAndSettle();

      // alpha is active: 0 blocks.
      expect(find.text('alpha'), findsWidgets);
      expect(find.text('Sin bloques'), findsOneWidget);

      // Switch to beta.
      await notifier.openDocument(pathB);
      await tester.pumpAndSettle();

      expect(find.text('beta'), findsWidgets);
      expect(find.text('1 bloque'), findsOneWidget);

      // Switch back to alpha.
      notifier.setActiveDocument(docA.id);
      await tester.pumpAndSettle();

      expect(find.text('alpha'), findsWidgets);
      expect(find.text('Sin bloques'), findsOneWidget);
    });
  });
}
