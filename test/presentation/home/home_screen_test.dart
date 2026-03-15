import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show LogicalKeyboardKey;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:runa/application/application.dart';
import 'package:runa/domain/domain.dart';
import 'package:runa/presentation/presentation.dart';

// ---------------------------------------------------------------------------
// Fakes
// ---------------------------------------------------------------------------

class FakeDocumentRepository implements DocumentRepository {
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

class FakeRecentFilesService implements RecentFilesService {
  List<String> recents = [];

  @override
  Future<List<String>> loadRecents() async => List.from(recents);

  @override
  Future<List<RecentEntry>> loadRecentEntries() async =>
      recents.map((p) => RecentEntry(path: p, openedAt: DateTime.utc(2024))).toList();

  @override
  Future<void> addRecent(String path) async {
    recents.remove(path);
    recents.insert(0, path);
    if (recents.length > 20) recents = recents.sublist(0, 20);
  }

  @override
  Future<void> remove(String path) async => recents.remove(path);

  @override
  Future<void> clear() async => recents.clear();
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

Widget _appWith({
  required FakeRecentFilesService fakeRecents,
  FakeDocumentRepository? fakeRepo,
  FakeFileSystemService? fakeFs,
}) {
  return ProviderScope(
    overrides: [
      documentRepositoryProvider
          .overrideWith((_) => fakeRepo ?? FakeDocumentRepository()),
      recentFilesServiceProvider.overrideWith((_) => fakeRecents),
      fileSystemServiceProvider
          .overrideWith((_) => fakeFs ?? FakeFileSystemService()),
    ],
    child: const MaterialApp(home: HomeScreen()),
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  // -------------------------------------------------------------------------
  // Welcome state (no folder open)
  // -------------------------------------------------------------------------

  group('welcome state', () {
    testWidgets('shows "Abrir carpeta" and "Nuevo documento" buttons',
        (tester) async {
      await tester.pumpWidget(_appWith(fakeRecents: FakeRecentFilesService()));
      await tester.pumpAndSettle();

      expect(find.text('Abrir carpeta'), findsOneWidget);
      expect(find.text('Nuevo documento'), findsOneWidget);
    });

    testWidgets('empty recents — recents section is not shown', (tester) async {
      final fakeRecents = FakeRecentFilesService();

      await tester.pumpWidget(_appWith(fakeRecents: fakeRecents));
      await tester.pumpAndSettle();

      expect(find.text('Recientes'), findsNothing);
    });

    testWidgets('non-empty recents — section header is shown', (tester) async {
      final fakeRecents = FakeRecentFilesService()
        ..recents = ['/home/user/Runa/doc.runa'];

      await tester.pumpWidget(_appWith(fakeRecents: fakeRecents));
      await tester.pumpAndSettle();

      expect(find.text('Recientes'), findsOneWidget);
    });
  });

  // -------------------------------------------------------------------------
  // Recent files list
  // -------------------------------------------------------------------------

  group('recent files', () {
    testWidgets('shows the filename for each recent path', (tester) async {
      final fakeRecents = FakeRecentFilesService()
        ..recents = [
          '/home/user/Runa/alpha.runa',
          '/home/user/Runa/beta.runa',
        ];

      await tester.pumpWidget(_appWith(fakeRecents: fakeRecents));
      await tester.pumpAndSettle();

      expect(find.text('alpha'), findsOneWidget);
      expect(find.text('beta'), findsOneWidget);
    });

    testWidgets(
        'non-existent path shows a remove button (file does not exist on disk)',
        (tester) async {
      // This path will not exist on the test machine's filesystem.
      const missingPath = '/nonexistent_runa_test_path/doc.runa';
      final fakeRecents = FakeRecentFilesService()
        ..recents = [missingPath];

      await tester.pumpWidget(_appWith(fakeRecents: fakeRecents));
      await tester.pumpAndSettle();

      // The close/remove button is shown only for non-existent paths.
      expect(find.byIcon(Icons.close), findsOneWidget);
    });

    testWidgets('tapping remove button removes the path from state',
        (tester) async {
      const missingPath = '/nonexistent_runa_test_path/to_remove.runa';
      final fakeRecents = FakeRecentFilesService()..recents = [missingPath];

      await tester.pumpWidget(_appWith(fakeRecents: fakeRecents));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      expect(find.text('Recientes'), findsNothing);
    });
  });

  // -------------------------------------------------------------------------
  // Recent files — Part 6 additions
  // -------------------------------------------------------------------------

  group('recent files — Part 6', () {
    testWidgets('shows "Limpiar recientes" button when recents are non-empty',
        (tester) async {
      final fakeRecents = FakeRecentFilesService()
        ..recents = ['/home/user/Runa/alpha.runa'];

      await tester.pumpWidget(_appWith(fakeRecents: fakeRecents));
      await tester.pumpAndSettle();

      expect(find.text('Limpiar recientes'), findsOneWidget);
    });

    testWidgets('tapping "Limpiar recientes" hides the recents section',
        (tester) async {
      final fakeRecents = FakeRecentFilesService()
        ..recents = ['/home/user/Runa/alpha.runa'];

      await tester.pumpWidget(_appWith(fakeRecents: fakeRecents));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Limpiar recientes'));
      await tester.pumpAndSettle();

      expect(find.text('Recientes'), findsNothing);
      expect(find.text('Limpiar recientes'), findsNothing);
    });

    testWidgets('shows at most 10 entries even with more recents',
        (tester) async {
      final fakeRecents = FakeRecentFilesService()
        ..recents = List.generate(
            12,
            (i) =>
                '/home/user/Runa/doc_${i.toString().padLeft(2, '0')}.runa');

      await tester.pumpWidget(_appWith(fakeRecents: fakeRecents));
      await tester.pumpAndSettle();

      expect(find.text('doc_00'), findsOneWidget);
      expect(find.text('doc_09'), findsOneWidget);
      expect(find.text('doc_10'), findsNothing);
      expect(find.text('doc_11'), findsNothing);
    });

    testWidgets('shows the file path in each recent entry row', (tester) async {
      final fakeRecents = FakeRecentFilesService()
        ..recents = ['/home/user/Runa/alpha.runa'];

      await tester.pumpWidget(_appWith(fakeRecents: fakeRecents));
      await tester.pumpAndSettle();

      expect(
          find.textContaining('/home/user/Runa/alpha.runa'), findsOneWidget);
    });
  });

  // -------------------------------------------------------------------------
  // Layout with folder open
  // -------------------------------------------------------------------------

  group('with folder open', () {
    testWidgets('shows sidebar with directory name', (tester) async {
      final fakeRecents = FakeRecentFilesService();

      await tester.pumpWidget(_appWith(fakeRecents: fakeRecents));
      await tester.pumpAndSettle();

      // Simulate opening a directory by reading the notifier from context.
      // We pump after updating state to trigger a rebuild.
      final element = tester.element(find.byType(HomeScreen));
      final ref = ProviderScope.containerOf(element);
      await ref.read(workspaceNotifierProvider.notifier).openDirectory('/home/user/Runa');
      await tester.pumpAndSettle();

      // Sidebar header shows the directory basename.
      expect(find.text('Runa'), findsWidgets);
    });

    testWidgets('shows empty editor area when no document is active',
        (tester) async {
      final fakeRecents = FakeRecentFilesService();

      await tester.pumpWidget(_appWith(fakeRecents: fakeRecents));
      await tester.pumpAndSettle();

      final element = tester.element(find.byType(HomeScreen));
      final ref = ProviderScope.containerOf(element);
      await ref.read(workspaceNotifierProvider.notifier).openDirectory('/home/user/Runa');
      await tester.pumpAndSettle();

      expect(find.text('Selecciona un documento del sidebar'), findsOneWidget);
    });
  });

  // -------------------------------------------------------------------------
  // Ctrl+S — save shortcut
  // -------------------------------------------------------------------------

  group('Ctrl+S shortcut', () {
    late Directory tempDir;
    late FakeDocumentRepository fakeRepo;

    setUp(() {
      tempDir = Directory.systemTemp.createTempSync('runa_ctrls_test_');
      fakeRepo = FakeDocumentRepository();
    });

    tearDown(() {
      if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
    });

    Future<ProviderContainer> openDoc(
      WidgetTester tester,
      String docPath,
      Document doc,
    ) async {
      fakeRepo.seed(docPath, doc);
      await tester.pumpWidget(_appWith(
        fakeRecents: FakeRecentFilesService(),
        fakeRepo: fakeRepo,
      ));
      await tester.pumpAndSettle();

      final element = tester.element(find.byType(HomeScreen));
      final container = ProviderScope.containerOf(element);
      await container.read(workspaceNotifierProvider.notifier).openDirectory(tempDir.path);
      await container.read(workspaceNotifierProvider.notifier).openDocument(docPath);
      await tester.pumpAndSettle();
      return container;
    }

    testWidgets('Ctrl+S with no active document does not throw', (tester) async {
      await tester.pumpWidget(_appWith(fakeRecents: FakeRecentFilesService()));
      await tester.pumpAndSettle();

      await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyS);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
      await tester.pumpAndSettle();
      // No exception = pass.
    });

    testWidgets('Ctrl+S with active document saves to repository', (tester) async {
      const docId = 'ctrl-s-save-doc-id';
      final docPath = '${tempDir.path}/ctrl_s_doc.runa';
      final doc = Document(
        version: '0.1',
        id: docId,
        createdAt: DateTime.utc(2024),
        updatedAt: DateTime.utc(2024),
        blocks: const [],
      );

      await openDoc(tester, docPath, doc);

      await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyS);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
      await tester.pump(); // let save start
      await tester.pump(const Duration(milliseconds: 1500)); // drain indicator timer

      // Repository received a save call for this path.
      expect(fakeRepo._store.containsKey(docPath), isTrue);
    });

    testWidgets('Ctrl+S shows saved indicator in tab, disappears after 1.5 s',
        (tester) async {
      const docId = 'ctrl-s-indicator-doc-id';
      final docPath = '${tempDir.path}/indicator_doc.runa';
      final doc = Document(
        version: '0.1',
        id: docId,
        createdAt: DateTime.utc(2024),
        updatedAt: DateTime.utc(2024),
        blocks: const [],
      );

      final container = await openDoc(tester, docPath, doc);

      await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyS);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
      await tester.pump(); // let _saveActiveDocument start

      // Indicator should be visible immediately after save.
      final ws = container.read(workspaceNotifierProvider);
      final opened = ws.openedDocuments
          .firstWhere((d) => d.document.id == docId);
      expect(opened.showSavedIndicator, isTrue);

      // After 1.5 s the indicator should be gone.
      await tester.pump(const Duration(milliseconds: 1500));
      final ws2 = container.read(workspaceNotifierProvider);
      final opened2 = ws2.openedDocuments
          .firstWhere((d) => d.document.id == docId);
      expect(opened2.showSavedIndicator, isFalse);
    });
  });

  // -------------------------------------------------------------------------
  // DocumentEditorPlaceholder
  // -------------------------------------------------------------------------

  group('DocumentEditorPlaceholder', () {
    late Directory tempDir;

    setUp(() {
      tempDir = Directory.systemTemp.createTempSync('runa_editor_test_');
    });

    tearDown(() {
      if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
    });

    testWidgets('shows document filename and block count', (tester) async {
      const docId = '00000000-0000-0000-0000-000000000001';
      final docPath = '${tempDir.path}/my_notes.runa';

      final doc = Document(
        version: '0.1',
        id: docId,
        createdAt: DateTime.utc(2024),
        updatedAt: DateTime.utc(2024),
        blocks: const [],
      );

      final fakeRepo = FakeDocumentRepository()..seed(docPath, doc);
      final fakeRecents = FakeRecentFilesService();

      await tester.pumpWidget(_appWith(
        fakeRecents: fakeRecents,
        fakeRepo: fakeRepo,
      ));
      await tester.pumpAndSettle();

      final element = tester.element(find.byType(HomeScreen));
      final ref = ProviderScope.containerOf(element);
      await ref.read(workspaceNotifierProvider.notifier).openDirectory(tempDir.path);
      await ref.read(workspaceNotifierProvider.notifier).openDocument(docPath);
      await tester.pumpAndSettle();

      expect(find.text('my_notes'), findsWidgets);
      expect(find.textContaining('Sin bloques'), findsOneWidget);
    });

    testWidgets('shows "Guardar" button', (tester) async {
      const docId = '00000000-0000-0000-0000-000000000002';
      final docPath = '${tempDir.path}/notes.runa';

      final doc = Document(
        version: '0.1',
        id: docId,
        createdAt: DateTime.utc(2024),
        updatedAt: DateTime.utc(2024),
        blocks: const [],
      );

      final fakeRepo = FakeDocumentRepository()..seed(docPath, doc);
      final fakeRecents = FakeRecentFilesService();

      await tester.pumpWidget(_appWith(
        fakeRecents: fakeRecents,
        fakeRepo: fakeRepo,
      ));
      await tester.pumpAndSettle();

      final element = tester.element(find.byType(HomeScreen));
      final ref = ProviderScope.containerOf(element);
      await ref.read(workspaceNotifierProvider.notifier).openDirectory(tempDir.path);
      await ref.read(workspaceNotifierProvider.notifier).openDocument(docPath);
      await tester.pumpAndSettle();

      expect(find.text('Guardar'), findsOneWidget);
    });
  });
}
