import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:runa/application/application.dart';
import 'package:runa/domain/domain.dart';

// ---------------------------------------------------------------------------
// Fakes (same pattern as editor_notifier_test.dart)
// ---------------------------------------------------------------------------

class _FakeDocumentRepository implements DocumentRepository {
  final Map<String, Document> _store = {};
  int saveCount = 0;

  void seed(String path, Document doc) => _store[path] = doc;

  @override
  Future<Document> load(String path) async {
    final doc = _store[path];
    if (doc == null) throw DocumentNotFoundException(path: path);
    return doc;
  }

  @override
  Future<void> save(Document doc, String path) async {
    saveCount++;
    _store[path] = doc;
  }

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

const _docId = '00000000-0000-0000-0000-000000000088';
const _path = '/tmp/runa_autosave_test/doc.runa';

Document _makeDoc() => Document(
      version: '0.1',
      id: _docId,
      createdAt: DateTime.utc(2024),
      updatedAt: DateTime.utc(2024),
      blocks: const [],
    );

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  late _FakeDocumentRepository fakeRepo;
  late ProviderContainer container;
  late EditorNotifier notifier;

  EditorState state() => container.read(editorProvider(_docId));

  setUp(() {
    fakeRepo = _FakeDocumentRepository();
    fakeRepo.seed(_path, _makeDoc());

    container = ProviderContainer(
      overrides: [
        documentRepositoryProvider.overrideWith((_) => fakeRepo),
        recentFilesServiceProvider
            .overrideWith((_) => _FakeRecentFilesService()),
        fileSystemServiceProvider
            .overrideWith((_) => _FakeFileSystemService()),
      ],
    );

    notifier = container.read(editorProvider(_docId).notifier);
    notifier.initFromDocument(_makeDoc(), _path);
  });

  tearDown(() => container.dispose());

  group('autosave', () {
    test('isDirty → triggerAutosave saves document and clears isDirty',
        () async {
      // Make dirty by adding a block.
      notifier.addBlock(const Block.markdown(id: 'b1', content: 'hola'));
      expect(state().isDirty, isTrue);

      await notifier.triggerAutosave();

      expect(state().isDirty, isFalse);
      expect(fakeRepo.saveCount, 1);
    });

    test('not isDirty → triggerAutosave does not call repository', () async {
      expect(state().isDirty, isFalse);

      await notifier.triggerAutosave();

      expect(fakeRepo.saveCount, 0);
    });

    test('isDirty → triggerAutosave sets autosaveMessage to true', () async {
      notifier.addBlock(const Block.markdown(id: 'b1', content: 'hola'));

      await notifier.triggerAutosave();

      expect(state().autosaveMessage, isTrue);
    });

    test('not isDirty → triggerAutosave leaves autosaveMessage false',
        () async {
      await notifier.triggerAutosave();

      expect(state().autosaveMessage, isFalse);
    });
  });
}
