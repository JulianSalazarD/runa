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
const _path = '/tmp/runa_test/doc.runa';

Document _makeDoc({List<Block> blocks = const []}) => Document(
      version: '0.1',
      id: _docId,
      createdAt: DateTime.utc(2024),
      updatedAt: DateTime.utc(2024),
      blocks: blocks,
    );

Block _mdBlock(String id, {String content = ''}) =>
    Block.markdown(id: id, content: content);

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  late FakeDocumentRepository fakeRepo;
  late ProviderContainer container;
  late EditorNotifier notifier;

  EditorState state() => container.read(editorNotifierProvider(_docId));

  setUp(() {
    fakeRepo = FakeDocumentRepository();

    container = ProviderContainer(
      overrides: [
        documentRepositoryProvider.overrideWith((_) => fakeRepo),
        recentFilesServiceProvider
            .overrideWith((_) => FakeRecentFilesService()),
        fileSystemServiceProvider.overrideWith((_) => FakeFileSystemService()),
      ],
    );
    addTearDown(container.dispose);

    notifier = container.read(editorNotifierProvider(_docId).notifier);
  });

  // -------------------------------------------------------------------------
  // loadDocument
  // -------------------------------------------------------------------------

  group('loadDocument', () {
    test('cargar documento con 2 bloques → state tiene 2 bloques', () async {
      final doc = _makeDoc(blocks: [_mdBlock('b1'), _mdBlock('b2')]);
      fakeRepo.seed(_path, doc);

      await notifier.loadDocument(_path);

      expect(state().blocks, hasLength(2));
      expect(state().blocks.first.id, 'b1');
      expect(state().blocks.last.id, 'b2');
    });

    test('cargar documento → isDirty es false', () async {
      fakeRepo.seed(_path, _makeDoc());
      await notifier.loadDocument(_path);

      expect(state().isDirty, isFalse);
    });

    test('cargar archivo inexistente → lanza DocumentNotFoundException',
        () async {
      await expectLater(
        notifier.loadDocument('/does/not/exist.runa'),
        throwsA(isA<DocumentNotFoundException>()),
      );
    });
  });

  // -------------------------------------------------------------------------
  // saveDocument
  // -------------------------------------------------------------------------

  group('saveDocument', () {
    setUp(() async {
      fakeRepo.seed(_path, _makeDoc(blocks: [_mdBlock('b1')]));
      await notifier.loadDocument(_path);
      notifier.addBlock(_mdBlock('b2')); // makes isDirty = true
    });

    test('guardar → isDirty false', () async {
      await notifier.saveDocument();
      expect(state().isDirty, isFalse);
    });

    test('guardar → llama DocumentRepository.save con bloques correctos',
        () async {
      await notifier.saveDocument();

      expect(fakeRepo.saves, hasLength(1));
      expect(fakeRepo.saves.first.path, _path);
      expect(fakeRepo.saves.first.doc.blocks, hasLength(2));
    });

    test(
        'guardar → llama markHasUnsavedChanges(value: false) en WorkspaceNotifier',
        () async {
      // Abre el directorio y el documento en WorkspaceNotifier para que
      // exista en openedDocuments.
      final wsNotifier =
          container.read(workspaceNotifierProvider.notifier);
      await wsNotifier.openDirectory('/tmp/runa_test');
      await wsNotifier.openDocument(_path);
      wsNotifier.markHasUnsavedChanges(_docId);

      expect(
        container
            .read(workspaceNotifierProvider)
            .openedDocuments
            .first
            .hasUnsavedChanges,
        isTrue,
      );

      await notifier.saveDocument();

      expect(
        container
            .read(workspaceNotifierProvider)
            .openedDocuments
            .first
            .hasUnsavedChanges,
        isFalse,
      );
    });
  });

  // -------------------------------------------------------------------------
  // addBlock
  // -------------------------------------------------------------------------

  group('addBlock', () {
    setUp(() async {
      final doc = _makeDoc(blocks: [_mdBlock('b1'), _mdBlock('b2')]);
      fakeRepo.seed(_path, doc);
      await notifier.loadDocument(_path);
    });

    test('sin afterId → bloque añadido al final', () {
      notifier.addBlock(_mdBlock('b3'));

      expect(state().blocks, hasLength(3));
      expect(state().blocks.last.id, 'b3');
    });

    test('con afterId válido → bloque insertado después de ese bloque', () {
      notifier.addBlock(_mdBlock('b-mid'), afterId: 'b1');

      expect(state().blocks, hasLength(3));
      expect(state().blocks[1].id, 'b-mid');
    });

    test('con afterId inválido → bloque añadido al final', () {
      notifier.addBlock(_mdBlock('b-end'), afterId: 'no-existe');

      expect(state().blocks.last.id, 'b-end');
    });

    test('addBlock → isDirty true', () {
      notifier.addBlock(_mdBlock('bx'));
      expect(state().isDirty, isTrue);
    });
  });

  // -------------------------------------------------------------------------
  // removeBlock
  // -------------------------------------------------------------------------

  group('removeBlock', () {
    setUp(() async {
      final doc = _makeDoc(blocks: [_mdBlock('b1'), _mdBlock('b2')]);
      fakeRepo.seed(_path, doc);
      await notifier.loadDocument(_path);
    });

    test('eliminar bloque existente → desaparece de la lista', () async {
      await notifier.removeBlock('b1');

      expect(state().blocks, hasLength(1));
      expect(state().blocks.first.id, 'b2');
    });

    test('eliminar id no existente → no-op', () async {
      await notifier.removeBlock('fantasma');
      expect(state().blocks, hasLength(2));
    });

    test('removeBlock → isDirty true', () async {
      await notifier.removeBlock('b1');
      expect(state().isDirty, isTrue);
    });
  });

  // -------------------------------------------------------------------------
  // updateBlock
  // -------------------------------------------------------------------------

  group('updateBlock', () {
    setUp(() async {
      final doc = _makeDoc(
        blocks: [_mdBlock('b1', content: 'original'), _mdBlock('b2')],
      );
      fakeRepo.seed(_path, doc);
      await notifier.loadDocument(_path);
    });

    test('actualizar bloque → contenido correcto en la lista', () {
      notifier.updateBlock(const Block.markdown(id: 'b1', content: 'actualizado'));

      final updated = state().blocks.first as MarkdownBlock;
      expect(updated.content, 'actualizado');
    });

    test('bloque no encontrado → no-op', () {
      notifier.updateBlock(const Block.markdown(id: 'no-existe', content: 'x'));
      expect(state().blocks, hasLength(2));
    });

    test('updateBlock → isDirty true', () {
      notifier.updateBlock(const Block.markdown(id: 'b1', content: 'cambio'));
      expect(state().isDirty, isTrue);
    });
  });

  // -------------------------------------------------------------------------
  // moveBlock
  // -------------------------------------------------------------------------

  group('moveBlock', () {
    setUp(() async {
      final doc =
          _makeDoc(blocks: [_mdBlock('b0'), _mdBlock('b1'), _mdBlock('b2')]);
      fakeRepo.seed(_path, doc);
      await notifier.loadDocument(_path);
    });

    test('mover bloque 0 a posición 2 → orden correcto', () {
      notifier.moveBlock('b0', 2);

      final ids = state().blocks.map((b) => b.id).toList();
      expect(ids, ['b1', 'b2', 'b0']);
    });

    test('mover bloque fuera de bounds → clamp al final', () {
      notifier.moveBlock('b0', 999);

      expect(state().blocks.last.id, 'b0');
    });

    test('id no encontrado → no-op', () {
      notifier.moveBlock('fantasma', 0);

      final ids = state().blocks.map((b) => b.id).toList();
      expect(ids, ['b0', 'b1', 'b2']);
    });

    test('moveBlock → isDirty true', () {
      notifier.moveBlock('b0', 1);
      expect(state().isDirty, isTrue);
    });
  });

  // -------------------------------------------------------------------------
  // setSelectedBlock
  // -------------------------------------------------------------------------

  group('setSelectedBlock', () {
    test('seleccionar bloque → selectedBlockId actualizado', () {
      notifier.setSelectedBlock('b1');
      expect(state().selectedBlockId, 'b1');
    });

    test('deseleccionar (null) → selectedBlockId null', () {
      notifier.setSelectedBlock('b1');
      notifier.setSelectedBlock(null);
      expect(state().selectedBlockId, isNull);
    });
  });

  // -------------------------------------------------------------------------
  // Sincronización isDirty ↔ WorkspaceNotifier
  // -------------------------------------------------------------------------

  group('isDirty sync con WorkspaceNotifier', () {
    late Directory tempDir;

    setUp(() async {
      tempDir = Directory.systemTemp.createTempSync('runa_editor_sync_');
      final docPath = '${tempDir.path}/doc.runa';
      final doc = _makeDoc();
      fakeRepo.seed(docPath, doc);

      // Abre el documento en WorkspaceNotifier para que aparezca en tabs.
      final wsNotifier = container.read(workspaceNotifierProvider.notifier);
      await wsNotifier.openDirectory(tempDir.path);
      await wsNotifier.openDocument(docPath);

      // Carga el mismo documento en el EditorNotifier.
      await notifier.loadDocument(docPath);
    });

    tearDown(() {
      if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
    });

    WorkspaceState ws() => container.read(workspaceNotifierProvider);

    test('addBlock → hasUnsavedChanges true en WorkspaceNotifier', () {
      notifier.addBlock(_mdBlock('new'));

      expect(ws().openedDocuments.first.hasUnsavedChanges, isTrue);
    });

    test('saveDocument → hasUnsavedChanges false en WorkspaceNotifier',
        () async {
      notifier.addBlock(_mdBlock('new'));
      await notifier.saveDocument();

      expect(ws().openedDocuments.first.hasUnsavedChanges, isFalse);
    });
  });
}
