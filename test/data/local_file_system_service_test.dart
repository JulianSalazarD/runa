import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:runa/data/data.dart';

void main() {
  late Directory tempDir;
  const svc = LocalFileSystemService();

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('runa_fs_test_');
  });

  tearDown(() {
    if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
  });

  // -------------------------------------------------------------------------
  // listRunaFiles
  // -------------------------------------------------------------------------

  group('listRunaFiles', () {
    test('returns empty list for an empty directory', () async {
      expect(await svc.listRunaFiles(tempDir.path), isEmpty);
    });

    test('returns empty list for a non-existent directory', () async {
      expect(
        await svc.listRunaFiles('${tempDir.path}/does_not_exist'),
        isEmpty,
      );
    });

    test('finds .runa files at the top level', () async {
      File('${tempDir.path}/a.runa').writeAsStringSync('{}');
      File('${tempDir.path}/b.runa').writeAsStringSync('{}');
      final files = await svc.listRunaFiles(tempDir.path);
      expect(files.length, 2);
      expect(files.every((f) => f.endsWith('.runa')), isTrue);
    });

    test('finds .runa files recursively inside subdirectories', () async {
      Directory('${tempDir.path}/sub').createSync();
      File('${tempDir.path}/top.runa').writeAsStringSync('{}');
      File('${tempDir.path}/sub/nested.runa').writeAsStringSync('{}');
      final files = await svc.listRunaFiles(tempDir.path);
      expect(files.length, 2);
    });

    test('ignores non-.runa files', () async {
      File('${tempDir.path}/readme.md').writeAsStringSync('# README');
      File('${tempDir.path}/data.json').writeAsStringSync('{}');
      File('${tempDir.path}/doc.runa').writeAsStringSync('{}');
      final files = await svc.listRunaFiles(tempDir.path);
      expect(files.length, 1);
      expect(files.first, endsWith('doc.runa'));
    });

    test('results are sorted alphabetically', () async {
      File('${tempDir.path}/gamma.runa').writeAsStringSync('{}');
      File('${tempDir.path}/alpha.runa').writeAsStringSync('{}');
      File('${tempDir.path}/beta.runa').writeAsStringSync('{}');
      final files = await svc.listRunaFiles(tempDir.path);
      final names = files.map((f) => f.split('/').last).toList();
      expect(names, ['alpha.runa', 'beta.runa', 'gamma.runa']);
    });

    test('returned paths are absolute', () async {
      File('${tempDir.path}/doc.runa').writeAsStringSync('{}');
      final files = await svc.listRunaFiles(tempDir.path);
      expect(files.first, startsWith('/'));
    });

    test('ignora archivos dentro de directorios _assets/', () async {
      final assetsDir = Directory('${tempDir.path}/_assets')..createSync();
      File('${assetsDir.path}/hidden.runa').writeAsStringSync('{}');
      File('${tempDir.path}/visible.runa').writeAsStringSync('{}');

      final files = await svc.listRunaFiles(tempDir.path);

      expect(files, hasLength(1));
      expect(files.first, endsWith('visible.runa'));
    });

    test('ignora _assets/ en subdirectorios', () async {
      final sub = Directory('${tempDir.path}/project')..createSync();
      final assets = Directory('${sub.path}/_assets')..createSync();
      File('${assets.path}/img.runa').writeAsStringSync('{}');
      File('${sub.path}/doc.runa').writeAsStringSync('{}');

      final files = await svc.listRunaFiles(tempDir.path);

      expect(files, hasLength(1));
      expect(files.first, endsWith('doc.runa'));
    });
  });

  // -------------------------------------------------------------------------
  // listDirectory
  // -------------------------------------------------------------------------

  group('listDirectory', () {
    test('excluye el directorio _assets/ de los resultados', () async {
      Directory('${tempDir.path}/subfolder').createSync();
      Directory('${tempDir.path}/_assets').createSync();
      File('${tempDir.path}/doc.runa').writeAsStringSync('{}');

      final items = await svc.listDirectory(tempDir.path);

      final names = items.map((i) => p.basename(i.path)).toList();
      expect(names, isNot(contains('_assets')));
      expect(names, contains('subfolder'));
      expect(names.where((n) => n.endsWith('.runa')), hasLength(1));
    });

    test('_assets/ anidado en subdirectorio también se excluye', () async {
      final sub = Directory('${tempDir.path}/project')..createSync();
      Directory('${sub.path}/_assets').createSync();

      final items = await svc.listDirectory(sub.path);

      expect(items.where((i) => p.basename(i.path) == '_assets'), isEmpty);
    });

    test('directorio vacío devuelve lista vacía', () async {
      expect(await svc.listDirectory(tempDir.path), isEmpty);
    });

    test('directorio inexistente devuelve lista vacía', () async {
      expect(
        await svc.listDirectory('${tempDir.path}/does_not_exist'),
        isEmpty,
      );
    });
  });

  // -------------------------------------------------------------------------
  // createDirectory
  // -------------------------------------------------------------------------

  group('createDirectory', () {
    test('creates a directory that does not exist', () async {
      final newDir = '${tempDir.path}/new_folder';
      expect(Directory(newDir).existsSync(), isFalse);
      await svc.createDirectory(newDir);
      expect(Directory(newDir).existsSync(), isTrue);
    });

    test('creates nested directories recursively', () async {
      final nested = '${tempDir.path}/a/b/c';
      await svc.createDirectory(nested);
      expect(Directory(nested).existsSync(), isTrue);
    });

    test('is idempotent when directory already exists', () async {
      final dir = '${tempDir.path}/existing';
      Directory(dir).createSync();
      await expectLater(svc.createDirectory(dir), completes);
    });
  });

  // -------------------------------------------------------------------------
  // watchDirectory
  // -------------------------------------------------------------------------

  group('watchDirectory', () {
    test('returns a Stream', () {
      final stream = svc.watchDirectory(tempDir.path);
      expect(stream, isA<Stream<FileSystemEvent>>());
    });
  });
}
