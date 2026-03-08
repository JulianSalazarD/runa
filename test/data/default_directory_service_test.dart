import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:runa/data/data.dart';
import 'package:runa/domain/domain.dart';

void main() {
  late Directory fakeHome;
  late DefaultDirectoryService service;

  setUp(() {
    fakeHome = Directory.systemTemp.createTempSync('runa_home_test_');
    service = DefaultDirectoryService(homeOverride: fakeHome.path);
  });

  tearDown(() {
    if (fakeHome.existsSync()) fakeHome.deleteSync(recursive: true);
  });

  // -------------------------------------------------------------------------
  // Directory creation
  // -------------------------------------------------------------------------

  group('getDefaultDirectory — creation', () {
    test('creates ~/Runa/ when it does not exist', () async {
      final runaPath = p.join(fakeHome.path, 'Runa');
      expect(Directory(runaPath).existsSync(), isFalse);

      await service.getDefaultDirectory();

      expect(Directory(runaPath).existsSync(), isTrue);
    });

    test('returned directory exists on disk', () async {
      final dir = await service.getDefaultDirectory();
      expect(dir.existsSync(), isTrue);
    });

    test('is idempotent — calling twice does not throw', () async {
      await service.getDefaultDirectory();
      await service.getDefaultDirectory();
    });

    test('does not throw when ~/Runa/ already exists', () async {
      final runaDir = Directory(p.join(fakeHome.path, 'Runa'))..createSync();
      final dir = await service.getDefaultDirectory();
      expect(dir.path, runaDir.path);
    });
  });

  // -------------------------------------------------------------------------
  // Path correctness
  // -------------------------------------------------------------------------

  group('getDefaultDirectory — path', () {
    test('directory name is "Runa"', () async {
      final dir = await service.getDefaultDirectory();
      expect(p.basename(dir.path), 'Runa');
    });

    test('directory is a direct child of the home directory', () async {
      final dir = await service.getDefaultDirectory();
      expect(p.dirname(dir.path), fakeHome.path);
    });

    test('absolute path equals <home>/Runa', () async {
      final dir = await service.getDefaultDirectory();
      expect(dir.path, p.join(fakeHome.path, 'Runa'));
    });

    test('returned path is absolute', () async {
      final dir = await service.getDefaultDirectory();
      expect(p.isAbsolute(dir.path), isTrue);
    });
  });

  // -------------------------------------------------------------------------
  // Integration with LocalDocumentRepository
  // -------------------------------------------------------------------------

  group('integration with LocalDocumentRepository', () {
    test('default directory can be used to list documents', () async {
      final dir = await service.getDefaultDirectory();
      const repo = LocalDocumentRepository();
      final docs = await repo.listDocuments(dir.path);
      expect(docs, isEmpty); // fresh directory
    });

    test('documents saved to default directory are listed', () async {
      final dir = await service.getDefaultDirectory();
      const repo = LocalDocumentRepository();

      final doc = Document(
        version: '0.1',
        id: '00000000-0000-0000-0000-000000000001',
        createdAt: DateTime.utc(2024, 1),
        updatedAt: DateTime.utc(2024, 1),
        blocks: const [],
      );
      await repo.save(doc, p.join(dir.path, 'my_notes.runa'));

      final listed = await repo.listDocuments(dir.path);
      expect(listed.length, 1);
      expect(p.basename(listed.first), 'my_notes.runa');
    });
  });
}
