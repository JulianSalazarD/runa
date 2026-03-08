import 'dart:io';

import 'package:flutter/material.dart';
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
  @override
  Future<List<String>> loadRecents() async => const [];
  @override
  Future<void> addRecent(String path) async {}
  @override
  Future<void> remove(String path) async {}
  @override
  Future<void> clear() async {}
}

class FakeFileSystemService implements FileSystemService {
  final Map<String, List<DirectoryItem>> _dirs = {};

  void seedDirectory(String path, List<DirectoryItem> items) =>
      _dirs[path] = items;

  @override
  Future<List<String>> listRunaFiles(String directory) async => const [];

  @override
  Future<List<DirectoryItem>> listDirectory(String path) async =>
      _dirs[path] ?? const [];

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

const rootDir = '/home/user/Runa';
const pathA = '$rootDir/alpha.runa';
const pathB = '$rootDir/beta.runa';
const idA = '00000000-0000-0000-0000-000000000001';
const idB = '00000000-0000-0000-0000-000000000002';

Document _doc(String id) => Document(
      version: '0.1',
      id: id,
      createdAt: DateTime.utc(2024),
      updatedAt: DateTime.utc(2024),
      blocks: const [],
    );

Widget _pumpTabBar({required FakeDocumentRepository fakeRepo}) {
  return ProviderScope(
    overrides: [
      documentRepositoryProvider.overrideWith((_) => fakeRepo),
      recentFilesServiceProvider.overrideWith((_) => FakeRecentFilesService()),
      fileSystemServiceProvider.overrideWith((_) => FakeFileSystemService()),
    ],
    child: const MaterialApp(
      home: Scaffold(
        body: SizedBox(
          width: 600,
          child: DocumentTabBar(),
        ),
      ),
    ),
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('DocumentTabBar', () {
    testWidgets('renders SizedBox when no documents are open', (tester) async {
      final fakeRepo = FakeDocumentRepository();
      await tester.pumpWidget(_pumpTabBar(fakeRepo: fakeRepo));
      await tester.pumpAndSettle();

      // No tab labels visible — tab bar collapses to SizedBox.shrink()
      expect(find.text('alpha'), findsNothing);
      expect(find.text('beta'), findsNothing);
    });

    testWidgets('shows one tab per open document', (tester) async {
      final fakeRepo = FakeDocumentRepository()
        ..seed(pathA, _doc(idA))
        ..seed(pathB, _doc(idB));

      await tester.pumpWidget(_pumpTabBar(fakeRepo: fakeRepo));
      await tester.pumpAndSettle();

      final container =
          ProviderScope.containerOf(tester.element(find.byType(DocumentTabBar)));
      final notifier = container.read(workspaceNotifierProvider.notifier);
      await notifier.openDocument(pathA);
      await notifier.openDocument(pathB);
      await tester.pumpAndSettle();

      expect(find.text('alpha'), findsOneWidget);
      expect(find.text('beta'), findsOneWidget);
    });

    testWidgets('active tab text is bold', (tester) async {
      final fakeRepo = FakeDocumentRepository()
        ..seed(pathA, _doc(idA))
        ..seed(pathB, _doc(idB));

      await tester.pumpWidget(_pumpTabBar(fakeRepo: fakeRepo));
      await tester.pumpAndSettle();

      final container =
          ProviderScope.containerOf(tester.element(find.byType(DocumentTabBar)));
      final notifier = container.read(workspaceNotifierProvider.notifier);
      await notifier.openDocument(pathA);
      await notifier.openDocument(pathB);
      // pathB is now active (last opened)
      await tester.pumpAndSettle();

      // beta is active → bold
      final betaText = tester.widget<Text>(find.text('beta'));
      expect(betaText.style?.fontWeight, FontWeight.w600);

      // alpha is not active → normal weight
      final alphaText = tester.widget<Text>(find.text('alpha'));
      expect(alphaText.style?.fontWeight, FontWeight.normal);
    });

    testWidgets('tapping a non-active tab changes activeDocumentId',
        (tester) async {
      final fakeRepo = FakeDocumentRepository()
        ..seed(pathA, _doc(idA))
        ..seed(pathB, _doc(idB));

      await tester.pumpWidget(_pumpTabBar(fakeRepo: fakeRepo));
      await tester.pumpAndSettle();

      final container =
          ProviderScope.containerOf(tester.element(find.byType(DocumentTabBar)));
      final notifier = container.read(workspaceNotifierProvider.notifier);
      await notifier.openDocument(pathA);
      await notifier.openDocument(pathB);
      // pathB is active now
      await tester.pumpAndSettle();

      // Tap alpha tab to switch
      await tester.tap(find.text('alpha'));
      await tester.pumpAndSettle();

      final workspace = container.read(workspaceNotifierProvider);
      expect(workspace.activeDocumentId, idA);
    });

    testWidgets('tapping × closes tab without dialog when no unsaved changes',
        (tester) async {
      final fakeRepo = FakeDocumentRepository()..seed(pathA, _doc(idA));

      await tester.pumpWidget(_pumpTabBar(fakeRepo: fakeRepo));
      await tester.pumpAndSettle();

      final container =
          ProviderScope.containerOf(tester.element(find.byType(DocumentTabBar)));
      final notifier = container.read(workspaceNotifierProvider.notifier);
      await notifier.openDocument(pathA);
      await tester.pumpAndSettle();

      expect(find.text('alpha'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.close).first);
      await tester.pumpAndSettle();

      final workspace = container.read(workspaceNotifierProvider);
      expect(workspace.openedDocuments, isEmpty);
      // No dialog should appear
      expect(find.text('Cambios sin guardar'), findsNothing);
    });

    testWidgets(
        'tapping × shows unsaved-changes dialog when hasUnsavedChanges is true',
        (tester) async {
      final fakeRepo = FakeDocumentRepository()..seed(pathA, _doc(idA));

      await tester.pumpWidget(_pumpTabBar(fakeRepo: fakeRepo));
      await tester.pumpAndSettle();

      final container =
          ProviderScope.containerOf(tester.element(find.byType(DocumentTabBar)));
      final notifier = container.read(workspaceNotifierProvider.notifier);
      await notifier.openDocument(pathA);
      await tester.pumpAndSettle();

      notifier.markHasUnsavedChanges(idA);
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.close).first);
      await tester.pumpAndSettle();

      expect(find.text('Cambios sin guardar'), findsOneWidget);
    });

    testWidgets('choosing Descartar in dialog closes tab', (tester) async {
      final fakeRepo = FakeDocumentRepository()..seed(pathA, _doc(idA));

      await tester.pumpWidget(_pumpTabBar(fakeRepo: fakeRepo));
      await tester.pumpAndSettle();

      final container =
          ProviderScope.containerOf(tester.element(find.byType(DocumentTabBar)));
      final notifier = container.read(workspaceNotifierProvider.notifier);
      await notifier.openDocument(pathA);
      await tester.pumpAndSettle();

      notifier.markHasUnsavedChanges(idA);
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.close).first);
      await tester.pumpAndSettle();

      expect(find.text('Cambios sin guardar'), findsOneWidget);

      await tester.tap(find.text('Descartar'));
      await tester.pumpAndSettle();

      final workspace = container.read(workspaceNotifierProvider);
      expect(workspace.openedDocuments, isEmpty);
    });

    testWidgets('choosing Cancelar in dialog keeps tab open', (tester) async {
      final fakeRepo = FakeDocumentRepository()..seed(pathA, _doc(idA));

      await tester.pumpWidget(_pumpTabBar(fakeRepo: fakeRepo));
      await tester.pumpAndSettle();

      final container =
          ProviderScope.containerOf(tester.element(find.byType(DocumentTabBar)));
      final notifier = container.read(workspaceNotifierProvider.notifier);
      await notifier.openDocument(pathA);
      await tester.pumpAndSettle();

      notifier.markHasUnsavedChanges(idA);
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.close).first);
      await tester.pumpAndSettle();

      expect(find.text('Cambios sin guardar'), findsOneWidget);

      await tester.tap(find.text('Cancelar'));
      await tester.pumpAndSettle();

      final workspace = container.read(workspaceNotifierProvider);
      expect(workspace.openedDocuments.length, 1);
    });

    testWidgets('tab shows ● indicator when hasUnsavedChanges is true',
        (tester) async {
      final fakeRepo = FakeDocumentRepository()..seed(pathA, _doc(idA));

      await tester.pumpWidget(_pumpTabBar(fakeRepo: fakeRepo));
      await tester.pumpAndSettle();

      final container =
          ProviderScope.containerOf(tester.element(find.byType(DocumentTabBar)));
      final notifier = container.read(workspaceNotifierProvider.notifier);
      await notifier.openDocument(pathA);
      await tester.pumpAndSettle();

      // Initially no ● indicator
      expect(find.text('●'), findsNothing);

      notifier.markHasUnsavedChanges(idA);
      await tester.pumpAndSettle();

      expect(find.text('●'), findsOneWidget);
    });
  });
}
