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
  /// If non-null, all async methods throw this exception.
  Object? errorToThrow;

  /// Controls the size returned by [readImageSize].
  (double, double) imageSize = (1920.0, 1080.0);

  /// Controls the pages returned by [readPdfInfo].
  List<(double, double)> pdfPages = [(595.0, 842.0)];

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
  Future<List<(double, double)>> readPdfInfo(String path) async {
    if (errorToThrow != null) throw errorToThrow!;
    return pdfPages;
  }

  @override
  String resolveAsset(String relativePath, String documentPath) =>
      '/fake/$relativePath';

  @override
  Future<void> deleteAsset(String relativePath, String documentPath) async {}

  @override
  Future<List<String>> listAssets(String documentPath) async => const [];
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

const _docId = '00000000-0000-0000-0000-000000000001';
const _docPath = '/tmp/runa_import_test/doc.runa';

Document _makeDoc({List<Block> blocks = const []}) => Document(
      version: '0.1',
      id: _docId,
      createdAt: DateTime.utc(2024),
      updatedAt: DateTime.utc(2024),
      blocks: blocks,
    );

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  late FakeDocumentRepository fakeRepo;
  late FakeAssetManager fakeAssets;
  late ProviderContainer container;
  late EditorNotifier notifier;

  EditorState state() => container.read(editorProvider(_docId));

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

    notifier = container.read(editorProvider(_docId).notifier);
    notifier.initFromDocument(_makeDoc(), _docPath);
  });

  // -------------------------------------------------------------------------
  // importImage
  // -------------------------------------------------------------------------

  group('importImage', () {
    test('inserta ImageBlock con path relativo correcto', () async {
      await notifier.importImage('/external/foto.png');

      expect(state().blocks, hasLength(1));
      final block = state().blocks.first;
      expect(block, isA<ImageBlock>());
      final img = block as ImageBlock;
      expect(img.path, '_assets/foto.png');
    });

    test('lee las dimensiones naturales de la imagen', () async {
      fakeAssets.imageSize = (800.0, 600.0);

      await notifier.importImage('/external/foto.png');

      final img = state().blocks.first as ImageBlock;
      expect(img.naturalWidth, 800.0);
      expect(img.naturalHeight, 600.0);
    });

    test('inserta después de afterBlockId cuando se especifica', () async {
      const mdBlock = Block.markdown(id: 'md-1', content: 'hola');
      notifier.addBlock(mdBlock);

      await notifier.importImage('/external/foto.png', afterBlockId: 'md-1');

      expect(state().blocks, hasLength(2));
      expect(state().blocks[0].id, 'md-1');
      expect(state().blocks[1], isA<ImageBlock>());
    });

    test('marca isDirty tras importar', () async {
      await notifier.importImage('/external/foto.png');

      expect(state().isDirty, isTrue);
    });

    test('isImporting es false tras completar', () async {
      await notifier.importImage('/external/foto.png');

      expect(state().isImporting, isFalse);
    });

    test('error de I/O: no añade bloque y isImporting queda en false', () async {
      fakeAssets.errorToThrow = Exception('archivo no encontrado');

      await expectLater(
        notifier.importImage('/external/missing.png'),
        throwsA(isA<Exception>()),
      );

      expect(state().blocks, isEmpty);
      expect(state().isImporting, isFalse);
    });
  });

  // -------------------------------------------------------------------------
  // importPdf
  // -------------------------------------------------------------------------

  group('importPdf', () {
    test('crea un PdfPageBlock por cada página del PDF', () async {
      fakeAssets.pdfPages = [(595.0, 842.0), (595.0, 842.0)];

      await notifier.importPdf('/external/doc.pdf');

      expect(state().blocks, hasLength(2));
      expect(state().blocks.every((b) => b is PdfPageBlock), isTrue);
      final p0 = state().blocks[0] as PdfPageBlock;
      final p1 = state().blocks[1] as PdfPageBlock;
      expect(p0.pageIndex, 0);
      expect(p1.pageIndex, 1);
      expect(p0.path, '_assets/doc.pdf');
      expect(p0.path, p1.path); // same PDF asset
    });

    test('PdfPageBlock tiene dimensiones de página correctas', () async {
      fakeAssets.pdfPages = [(612.0, 792.0)];

      await notifier.importPdf('/external/doc.pdf');

      final page = state().blocks.first as PdfPageBlock;
      expect(page.pageWidth, 612.0);
      expect(page.pageHeight, 792.0);
    });

    test('inserta páginas después de afterBlockId cuando se especifica', () async {
      fakeAssets.pdfPages = [(595.0, 842.0)];
      notifier.addBlock(const Block.markdown(id: 'md-1', content: 'before'));
      notifier.addBlock(const Block.markdown(id: 'md-2', content: 'after'));

      await notifier.importPdf('/external/doc.pdf', afterBlockId: 'md-1');

      // Expected order: md-1, pdf-page-0, md-2
      expect(state().blocks, hasLength(3));
      expect(state().blocks[0].id, 'md-1');
      expect(state().blocks[1], isA<PdfPageBlock>());
      expect(state().blocks[2].id, 'md-2');
    });

    test('marca isDirty tras importar', () async {
      await notifier.importPdf('/external/doc.pdf');

      expect(state().isDirty, isTrue);
    });

    test('isImporting es false tras completar', () async {
      await notifier.importPdf('/external/doc.pdf');

      expect(state().isImporting, isFalse);
    });

    test('error de I/O: no añade bloque y isImporting queda en false', () async {
      fakeAssets.errorToThrow = Exception('archivo no encontrado');

      await expectLater(
        notifier.importPdf('/external/missing.pdf'),
        throwsA(isA<Exception>()),
      );

      expect(state().blocks, isEmpty);
      expect(state().isImporting, isFalse);
    });
  });
}
