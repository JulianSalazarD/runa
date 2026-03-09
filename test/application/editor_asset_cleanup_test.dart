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
  Future<List<String>> listDocuments(String directory) async => const [];
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

class FakeAssetManager implements AssetManager {
  /// Tracks paths passed to [deleteAsset].
  final List<String> deletedAssets = [];

  /// If non-null, [copyAsset] and [readImageSize] throw this exception.
  Object? errorToThrow;

  /// Controls the size returned by [readImageSize].
  (double, double) imageSize = (1920.0, 1080.0);

  /// Records calls: sourcePath → relativePath returned.
  final Map<String, String> copies = {};

  @override
  Future<String> copyAsset(String sourcePath, String documentPath) async {
    if (errorToThrow != null) throw errorToThrow!;
    final rel = '_assets/${sourcePath.split('/').last}';
    copies[sourcePath] = rel;
    return rel;
  }

  @override
  Future<(double, double)> readImageSize(String path) async {
    if (errorToThrow != null) throw errorToThrow!;
    return imageSize;
  }

  @override
  String resolveAsset(String relativePath, String documentPath) =>
      '/fake/$relativePath';

  @override
  Future<void> deleteAsset(String relativePath, String documentPath) async {
    deletedAssets.add(relativePath);
  }

  @override
  Future<List<String>> listAssets(String documentPath) async => [];
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

const _docId = '00000000-0000-0000-0000-000000000002';
const _docPath = '/tmp/runa_cleanup_test/doc.runa';
const _assetPath = '_assets/foto.png';
const _pdfAssetPath = '_assets/doc.pdf';

Document _makeDoc({List<Block> blocks = const []}) => Document(
      version: '0.1',
      id: _docId,
      createdAt: DateTime.utc(2024),
      updatedAt: DateTime.utc(2024),
      blocks: blocks,
    );

Block _imageBlock(String id, {String path = _assetPath}) => Block.image(
      id: id,
      path: path,
      naturalWidth: 1920.0,
      naturalHeight: 1080.0,
    );

Block _pdfBlock(String id, {String path = _pdfAssetPath}) => Block.pdf(
      id: id,
      path: path,
    );

Block _mdBlock(String id) => Block.markdown(id: id, content: 'texto');

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  late FakeDocumentRepository fakeRepo;
  late FakeAssetManager fakeAssets;
  late ProviderContainer container;
  late EditorNotifier notifier;

  EditorState state() => container.read(editorNotifierProvider(_docId));

  setUp(() {
    fakeRepo = FakeDocumentRepository()..seed(_docPath, _makeDoc());
    fakeAssets = FakeAssetManager();

    container = ProviderContainer(
      overrides: [
        documentRepositoryProvider.overrideWith((_) => fakeRepo),
        recentFilesServiceProvider
            .overrideWith((_) => FakeRecentFilesService()),
        fileSystemServiceProvider.overrideWith((_) => FakeFileSystemService()),
        assetManagerProvider.overrideWith((_) => fakeAssets),
      ],
    );
    addTearDown(container.dispose);

    notifier = container.read(editorNotifierProvider(_docId).notifier);
  });

  group('removeBlock — limpieza de assets', () {
    test('ImageBlock único → asset borrado del disco', () async {
      notifier.initFromDocument(
        _makeDoc(blocks: [_imageBlock('img-1')]),
        _docPath,
      );

      await notifier.removeBlock('img-1');

      expect(fakeAssets.deletedAssets, contains(_assetPath));
    });

    test('ImageBlock con duplicado → asset NO borrado', () async {
      notifier.initFromDocument(
        _makeDoc(blocks: [
          _imageBlock('img-1'),
          _imageBlock('img-2'),
        ]),
        _docPath,
      );

      await notifier.removeBlock('img-1');

      expect(fakeAssets.deletedAssets, isEmpty);
    });

    test('PdfBlock único → asset borrado del disco', () async {
      notifier.initFromDocument(
        _makeDoc(blocks: [_pdfBlock('pdf-1')]),
        _docPath,
      );

      await notifier.removeBlock('pdf-1');

      expect(fakeAssets.deletedAssets, contains(_pdfAssetPath));
    });

    test('PdfBlock con duplicado → asset NO borrado', () async {
      notifier.initFromDocument(
        _makeDoc(blocks: [
          _pdfBlock('pdf-1'),
          _pdfBlock('pdf-2'),
        ]),
        _docPath,
      );

      await notifier.removeBlock('pdf-1');

      expect(fakeAssets.deletedAssets, isEmpty);
    });

    test('MarkdownBlock → no llama deleteAsset', () async {
      notifier.initFromDocument(
        _makeDoc(blocks: [_mdBlock('md-1')]),
        _docPath,
      );

      await notifier.removeBlock('md-1');

      expect(fakeAssets.deletedAssets, isEmpty);
    });

    test('ImageBlock → bloque eliminado del estado independientemente del asset', () async {
      notifier.initFromDocument(
        _makeDoc(blocks: [_imageBlock('img-1')]),
        _docPath,
      );

      await notifier.removeBlock('img-1');

      expect(state().blocks, isEmpty);
    });
  });
}
