import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:runa/application/application.dart';
import 'package:runa/domain/domain.dart';

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
  List<String> recents = [];

  @override
  Future<List<String>> loadRecents() async => List.from(recents);

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
  final List<String> createdDirectories = [];

  @override
  Future<List<String>> listRunaFiles(String directory) async => const [];

  @override
  Stream<FileSystemEvent> watchDirectory(String directory) =>
      const Stream.empty();

  @override
  Future<void> createDirectory(String path) async =>
      createdDirectories.add(path);
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Document _doc(String id) => Document(
      version: '0.1',
      id: id,
      createdAt: DateTime.utc(2024, 1, 1),
      updatedAt: DateTime.utc(2024, 1, 1),
      blocks: const [],
    );

const _pathA = '/home/user/Runa/alpha.runa';
const _pathB = '/home/user/Runa/beta.runa';
const _idA = '00000000-0000-0000-0000-000000000001';
const _idB = '00000000-0000-0000-0000-000000000002';

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  late FakeDocumentRepository fakeRepo;
  late FakeRecentFilesService fakeRecents;
  late FakeFileSystemService fakeFs;
  late ProviderContainer container;
  late WorkspaceNotifier notifier;

  setUp(() {
    fakeRepo = FakeDocumentRepository();
    fakeRecents = FakeRecentFilesService();
    fakeFs = FakeFileSystemService();

    container = ProviderContainer(
      overrides: [
        documentRepositoryProvider.overrideWith((_) => fakeRepo),
        recentFilesServiceProvider.overrideWith((_) => fakeRecents),
        fileSystemServiceProvider.overrideWith((_) => fakeFs),
      ],
    );
    addTearDown(container.dispose);

    notifier = container.read(workspaceNotifierProvider.notifier);
  });

  WorkspaceState state() => container.read(workspaceNotifierProvider);

  // -------------------------------------------------------------------------
  // Initial state
  // -------------------------------------------------------------------------

  group('initial state', () {
    test('starts empty', () {
      expect(state().openedDirectoryPath, isNull);
      expect(state().openedDocuments, isEmpty);
      expect(state().activeDocumentId, isNull);
      expect(state().recentPaths, isEmpty);
    });
  });

  // -------------------------------------------------------------------------
  // initialize
  // -------------------------------------------------------------------------

  group('initialize', () {
    test('loads recents from service into state', () async {
      fakeRecents.recents = [_pathA, _pathB];
      await notifier.initialize();
      expect(state().recentPaths, [_pathA, _pathB]);
    });

    test('empty recents service → empty recentPaths', () async {
      await notifier.initialize();
      expect(state().recentPaths, isEmpty);
    });
  });

  // -------------------------------------------------------------------------
  // openDirectory
  // -------------------------------------------------------------------------

  group('openDirectory', () {
    test('sets openedDirectoryPath', () async {
      await notifier.openDirectory('/home/user/Runa');
      expect(state().openedDirectoryPath, '/home/user/Runa');
    });

    test('replaces a previously opened directory', () async {
      await notifier.openDirectory('/home/user/Runa');
      await notifier.openDirectory('/home/user/Notes');
      expect(state().openedDirectoryPath, '/home/user/Notes');
    });

    test('does not open any documents', () async {
      await notifier.openDirectory('/home/user/Runa');
      expect(state().openedDocuments, isEmpty);
    });
  });

  // -------------------------------------------------------------------------
  // openDocument
  // -------------------------------------------------------------------------

  group('openDocument', () {
    setUp(() => fakeRepo.seed(_pathA, _doc(_idA)));

    test('adds a new tab', () async {
      await notifier.openDocument(_pathA);
      expect(state().openedDocuments.length, 1);
      expect(state().openedDocuments.first.path, _pathA);
    });

    test('sets activeDocumentId to the opened document', () async {
      await notifier.openDocument(_pathA);
      expect(state().activeDocumentId, _idA);
    });

    test('adds the path to recents', () async {
      await notifier.openDocument(_pathA);
      expect(state().recentPaths, contains(_pathA));
    });

    test('opening an already-open document switches focus without duplicating',
        () async {
      fakeRepo.seed(_pathB, _doc(_idB));
      await notifier.openDocument(_pathA);
      await notifier.openDocument(_pathB);
      await notifier.openDocument(_pathA); // re-open A

      expect(state().openedDocuments.length, 2);
      expect(state().activeDocumentId, _idA);
    });

    test('multiple documents open as separate tabs', () async {
      fakeRepo.seed(_pathB, _doc(_idB));
      await notifier.openDocument(_pathA);
      await notifier.openDocument(_pathB);
      expect(state().openedDocuments.length, 2);
    });

    test('throws DocumentNotFoundException for a missing file', () async {
      await expectLater(
        () => notifier.openDocument('/missing.runa'),
        throwsA(isA<DocumentNotFoundException>()),
      );
    });
  });

  // -------------------------------------------------------------------------
  // closeDocument
  // -------------------------------------------------------------------------

  group('closeDocument', () {
    setUp(() async {
      fakeRepo
        ..seed(_pathA, _doc(_idA))
        ..seed(_pathB, _doc(_idB));
      await notifier.openDocument(_pathA);
      await notifier.openDocument(_pathB);
    });

    test('removes the tab', () {
      notifier.closeDocument(_idB);
      expect(state().openedDocuments.length, 1);
      expect(state().openedDocuments.first.document.id, _idA);
    });

    test('closing the active tab activates the adjacent one', () {
      // B is active (last opened)
      expect(state().activeDocumentId, _idB);
      notifier.closeDocument(_idB);
      expect(state().activeDocumentId, _idA);
    });

    test('closing a non-active tab keeps the current active tab', () {
      // B is active; close A
      notifier.closeDocument(_idA);
      expect(state().activeDocumentId, _idB);
    });

    test('closing the only tab sets activeDocumentId to null', () async {
      notifier.closeDocument(_idB);
      notifier.closeDocument(_idA);
      expect(state().openedDocuments, isEmpty);
      expect(state().activeDocumentId, isNull);
    });

    test('no-op for an unknown id', () {
      notifier.closeDocument('unknown-id');
      expect(state().openedDocuments.length, 2);
    });
  });

  // -------------------------------------------------------------------------
  // setActiveDocument
  // -------------------------------------------------------------------------

  group('setActiveDocument', () {
    setUp(() async {
      fakeRepo
        ..seed(_pathA, _doc(_idA))
        ..seed(_pathB, _doc(_idB));
      await notifier.openDocument(_pathA);
      await notifier.openDocument(_pathB);
    });

    test('switches active document', () {
      notifier.setActiveDocument(_idA);
      expect(state().activeDocumentId, _idA);
    });
  });

  // -------------------------------------------------------------------------
  // createDocument
  // -------------------------------------------------------------------------

  group('createDocument', () {
    test('saves a new document to disk', () async {
      await notifier.createDocument('/home/user/Runa', 'my_notes');
      expect(fakeRepo.saves.length, 1);
      expect(fakeRepo.saves.first.path, '/home/user/Runa/my_notes.runa');
    });

    test('opens the new document in a tab', () async {
      await notifier.createDocument('/home/user/Runa', 'my_notes');
      expect(state().openedDocuments.length, 1);
    });

    test('created document has no blocks', () async {
      await notifier.createDocument('/home/user/Runa', 'my_notes');
      expect(state().openedDocuments.first.document.blocks, isEmpty);
    });

    test('created document becomes the active tab', () async {
      await notifier.createDocument('/home/user/Runa', 'my_notes');
      expect(state().activeDocumentId, isNotNull);
      expect(
        state().activeDocumentId,
        state().openedDocuments.first.document.id,
      );
    });
  });

  // -------------------------------------------------------------------------
  // createSubdirectory
  // -------------------------------------------------------------------------

  group('createSubdirectory', () {
    test('calls FileSystemService.createDirectory with the correct path',
        () async {
      await notifier.createSubdirectory('/home/user/Runa', 'chapter_1');
      expect(fakeFs.createdDirectories, ['/home/user/Runa/chapter_1']);
    });
  });
}
