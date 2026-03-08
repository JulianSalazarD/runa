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
  final List<String> createdDirectories = [];
  final List<String> deletedFiles = [];

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
  Future<void> createDirectory(String path) async =>
      createdDirectories.add(path);

  @override
  Future<void> renameEntry(String oldPath, String newPath) async {}

  @override
  Future<void> deleteFile(String path) async => deletedFiles.add(path);

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

Document _doc(String id) => Document(
      version: '0.1',
      id: id,
      createdAt: DateTime.utc(2024),
      updatedAt: DateTime.utc(2024),
      blocks: const [],
    );

Widget _pumpSidebar({
  required FakeFileSystemService fakeFs,
  FakeDocumentRepository? fakeRepo,
  String directoryPath = rootDir,
}) {
  return ProviderScope(
    overrides: [
      documentRepositoryProvider
          .overrideWith((_) => fakeRepo ?? FakeDocumentRepository()),
      recentFilesServiceProvider
          .overrideWith((_) => FakeRecentFilesService()),
      fileSystemServiceProvider.overrideWith((_) => fakeFs),
    ],
    child: MaterialApp(
      home: Scaffold(
        body: SizedBox(
          width: 250,
          child: FileSidebarWidget(directoryPath: directoryPath),
        ),
      ),
    ),
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  // -------------------------------------------------------------------------
  // Listing files
  // -------------------------------------------------------------------------

  group('file listing', () {
    testWidgets('shows filenames for .runa files in directory', (tester) async {
      final fakeFs = FakeFileSystemService()
        ..seedDirectory(rootDir, [
          const DirectoryItem(path: pathA, isDirectory: false),
          const DirectoryItem(path: pathB, isDirectory: false),
        ]);

      await tester.pumpWidget(_pumpSidebar(fakeFs: fakeFs));
      await tester.pumpAndSettle();

      expect(find.text('alpha'), findsOneWidget);
      expect(find.text('beta'), findsOneWidget);
    });

    testWidgets('shows folder name for subdirectory entries', (tester) async {
      final fakeFs = FakeFileSystemService()
        ..seedDirectory(rootDir, [
          const DirectoryItem(path: '$rootDir/chapter_1', isDirectory: true),
        ]);

      await tester.pumpWidget(_pumpSidebar(fakeFs: fakeFs));
      await tester.pumpAndSettle();

      expect(find.text('chapter_1'), findsOneWidget);
      expect(find.byIcon(Icons.folder), findsOneWidget);
    });

    testWidgets('shows folder icon for directories and file icon for files',
        (tester) async {
      final fakeFs = FakeFileSystemService()
        ..seedDirectory(rootDir, [
          const DirectoryItem(path: '$rootDir/notes', isDirectory: true),
          const DirectoryItem(path: pathA, isDirectory: false),
        ]);

      await tester.pumpWidget(_pumpSidebar(fakeFs: fakeFs));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.folder), findsOneWidget);
      expect(find.byIcon(Icons.description_outlined), findsOneWidget);
    });

    testWidgets('shows "Sin documentos" for empty directory', (tester) async {
      final fakeFs = FakeFileSystemService()
        ..seedDirectory(rootDir, const []);

      await tester.pumpWidget(_pumpSidebar(fakeFs: fakeFs));
      await tester.pumpAndSettle();

      expect(find.text('Sin documentos'), findsOneWidget);
    });

    testWidgets('shows directory name in header', (tester) async {
      final fakeFs = FakeFileSystemService()
        ..seedDirectory(rootDir, const []);

      await tester.pumpWidget(_pumpSidebar(fakeFs: fakeFs));
      await tester.pumpAndSettle();

      expect(find.text('Runa'), findsOneWidget);
    });
  });

  // -------------------------------------------------------------------------
  // Tapping items
  // -------------------------------------------------------------------------

  group('tapping items', () {
    testWidgets('tapping a file calls openDocument', (tester) async {
      final fakeRepo = FakeDocumentRepository()..seed(pathA, _doc(idA));
      final fakeFs = FakeFileSystemService()
        ..seedDirectory(rootDir, [
          const DirectoryItem(path: pathA, isDirectory: false),
        ]);

      await tester.pumpWidget(_pumpSidebar(fakeFs: fakeFs, fakeRepo: fakeRepo));
      await tester.pumpAndSettle();

      await tester.tap(find.text('alpha'));
      await tester.pumpAndSettle();

      // After opening, the document should be in the workspace state.
      final element = tester.element(find.byType(FileSidebarWidget));
      final ref = ProviderScope.containerOf(element);
      final workspace = ref.read(workspaceNotifierProvider);
      expect(workspace.openedDocuments.length, 1);
      expect(workspace.openedDocuments.first.path, pathA);
    });

    testWidgets('tapping a folder toggles expand — shows open folder icon',
        (tester) async {
      const folderPath = '$rootDir/chapter_1';
      final fakeFs = FakeFileSystemService()
        ..seedDirectory(rootDir, [
          const DirectoryItem(path: folderPath, isDirectory: true),
        ])
        ..seedDirectory(folderPath, []);

      await tester.pumpWidget(_pumpSidebar(fakeFs: fakeFs));
      await tester.pumpAndSettle();

      // Initially: closed folder icon.
      expect(find.byIcon(Icons.folder), findsOneWidget);
      expect(find.byIcon(Icons.folder_open), findsNothing);

      await tester.tap(find.text('chapter_1'));
      await tester.pumpAndSettle();

      // After tap: open folder icon.
      expect(find.byIcon(Icons.folder_open), findsOneWidget);
    });

    testWidgets('tapping expanded folder collapses it', (tester) async {
      const folderPath = '$rootDir/chapter_1';
      final fakeFs = FakeFileSystemService()
        ..seedDirectory(rootDir, [
          const DirectoryItem(path: folderPath, isDirectory: true),
        ])
        ..seedDirectory(folderPath, [
          const DirectoryItem(path: '$folderPath/doc.runa', isDirectory: false),
        ]);

      await tester.pumpWidget(_pumpSidebar(fakeFs: fakeFs));
      await tester.pumpAndSettle();

      await tester.tap(find.text('chapter_1'));
      await tester.pumpAndSettle();
      expect(find.text('doc'), findsOneWidget);

      await tester.tap(find.text('chapter_1'));
      await tester.pumpAndSettle();
      expect(find.text('doc'), findsNothing);
    });
  });

  // -------------------------------------------------------------------------
  // Active file highlighting
  // -------------------------------------------------------------------------

  group('active file highlighting', () {
    testWidgets('active document tile is selected', (tester) async {
      final fakeRepo = FakeDocumentRepository()..seed(pathA, _doc(idA));
      final fakeFs = FakeFileSystemService()
        ..seedDirectory(rootDir, [
          const DirectoryItem(path: pathA, isDirectory: false),
        ]);

      await tester.pumpWidget(_pumpSidebar(fakeFs: fakeFs, fakeRepo: fakeRepo));
      await tester.pumpAndSettle();

      // Open the document to make it active.
      final element = tester.element(find.byType(FileSidebarWidget));
      final ref = ProviderScope.containerOf(element);
      await ref.read(workspaceNotifierProvider.notifier).openDocument(pathA);
      await tester.pumpAndSettle();

      final tile = tester.widget<ListTile>(
        find.ancestor(
          of: find.text('alpha'),
          matching: find.byType(ListTile),
        ),
      );
      expect(tile.selected, isTrue);
    });

    testWidgets('non-active document tile is not selected', (tester) async {
      final fakeRepo = FakeDocumentRepository()..seed(pathA, _doc(idA));
      final fakeFs = FakeFileSystemService()
        ..seedDirectory(rootDir, [
          const DirectoryItem(path: pathA, isDirectory: false),
          const DirectoryItem(path: pathB, isDirectory: false),
        ]);

      await tester.pumpWidget(_pumpSidebar(fakeFs: fakeFs, fakeRepo: fakeRepo));
      await tester.pumpAndSettle();

      // No document is active.
      final tile = tester.widget<ListTile>(
        find.ancestor(
          of: find.text('alpha'),
          matching: find.byType(ListTile),
        ),
      );
      expect(tile.selected, isFalse);
    });
  });

  // -------------------------------------------------------------------------
  // Nested tree (depth indentation)
  // -------------------------------------------------------------------------

  group('nested tree', () {
    testWidgets('children of expanded folder are shown with deeper indent',
        (tester) async {
      const folderPath = '$rootDir/notes';
      const childPath = '$folderPath/child.runa';
      final fakeFs = FakeFileSystemService()
        ..seedDirectory(rootDir, [
          const DirectoryItem(path: folderPath, isDirectory: true),
        ])
        ..seedDirectory(folderPath, [
          const DirectoryItem(path: childPath, isDirectory: false),
        ]);

      await tester.pumpWidget(_pumpSidebar(fakeFs: fakeFs));
      await tester.pumpAndSettle();

      await tester.tap(find.text('notes'));
      await tester.pumpAndSettle();

      expect(find.text('child'), findsOneWidget);

      // The child tile should have a larger left padding than the folder tile.
      final folderTile = tester.widget<ListTile>(
        find.ancestor(
            of: find.text('notes'), matching: find.byType(ListTile)).first,
      );
      final childTile = tester.widget<ListTile>(
        find.ancestor(
            of: find.text('child'), matching: find.byType(ListTile)).first,
      );
      final folderPadding =
          (folderTile.contentPadding as EdgeInsets).left;
      final childPadding =
          (childTile.contentPadding as EdgeInsets).left;
      expect(childPadding, greaterThan(folderPadding));
    });
  });
}
