import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:runa/data/services/local_asset_manager.dart';

void main() {
  late Directory tempDir;
  late String documentPath;
  late LocalAssetManager manager;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('runa_asset_test_');
    documentPath = p.join(tempDir.path, 'doc.runa');
    manager = const LocalAssetManager();
  });

  tearDown(() async {
    await tempDir.delete(recursive: true);
  });

  // ---------------------------------------------------------------------------
  // copyAsset
  // ---------------------------------------------------------------------------

  group('copyAsset', () {
    test('copies file to _assets/ and returns relative path', () async {
      final src = File(p.join(tempDir.path, 'foto.png'));
      await src.writeAsString('fake image data');

      final rel = await manager.copyAsset(src.path, documentPath);

      expect(rel, '_assets/foto.png');
      final dest = File(p.join(tempDir.path, '_assets', 'foto.png'));
      expect(await dest.exists(), isTrue);
      expect(await dest.readAsString(), 'fake image data');
    });

    test('creates _assets/ directory if it does not exist', () async {
      final src = File(p.join(tempDir.path, 'doc.pdf'));
      await src.writeAsString('fake pdf');

      await manager.copyAsset(src.path, documentPath);

      final assetsDir = Directory(p.join(tempDir.path, '_assets'));
      expect(await assetsDir.exists(), isTrue);
    });

    test('returns path separator-joined relative path on all platforms', () async {
      final src = File(p.join(tempDir.path, 'img.jpg'));
      await src.writeAsString('jpg');

      final rel = await manager.copyAsset(src.path, documentPath);

      // Path must start with _assets and use the system separator.
      expect(rel, p.join('_assets', 'img.jpg'));
    });

    test('does not duplicate if same-named file already exists', () async {
      final src = File(p.join(tempDir.path, 'foto.png'));
      await src.writeAsString('original');

      // First import.
      await manager.copyAsset(src.path, documentPath);

      // Write different content to the source (simulating a "same name, different file").
      await src.writeAsString('changed');

      // Second import — should NOT overwrite.
      final rel = await manager.copyAsset(src.path, documentPath);

      expect(rel, '_assets/foto.png');
      final dest = File(p.join(tempDir.path, '_assets', 'foto.png'));
      expect(await dest.readAsString(), 'original'); // unchanged
    });

    test('importing same file twice returns same relative path', () async {
      final src = File(p.join(tempDir.path, 'doc.pdf'));
      await src.writeAsString('pdf content');

      final rel1 = await manager.copyAsset(src.path, documentPath);
      final rel2 = await manager.copyAsset(src.path, documentPath);

      expect(rel1, rel2);
    });
  });

  // ---------------------------------------------------------------------------
  // resolveAsset
  // ---------------------------------------------------------------------------

  group('resolveAsset', () {
    test('converts relative path to absolute path', () {
      final abs = manager.resolveAsset('_assets/foto.png', documentPath);
      expect(abs, p.join(tempDir.path, '_assets', 'foto.png'));
    });

    test('is deterministic (no I/O)', () {
      final abs1 = manager.resolveAsset('_assets/a.pdf', documentPath);
      final abs2 = manager.resolveAsset('_assets/a.pdf', documentPath);
      expect(abs1, abs2);
    });
  });

  // ---------------------------------------------------------------------------
  // deleteAsset
  // ---------------------------------------------------------------------------

  group('deleteAsset', () {
    test('deletes the asset file', () async {
      final assetsDir = Directory(p.join(tempDir.path, '_assets'));
      await assetsDir.create();
      final asset = File(p.join(assetsDir.path, 'foto.png'));
      await asset.writeAsString('data');

      await manager.deleteAsset('_assets/foto.png', documentPath);

      expect(await asset.exists(), isFalse);
    });

    test('does nothing if file does not exist', () async {
      // Should not throw.
      await manager.deleteAsset('_assets/missing.png', documentPath);
    });
  });

  // ---------------------------------------------------------------------------
  // listAssets
  // ---------------------------------------------------------------------------

  group('listAssets', () {
    test('returns empty list when _assets/ does not exist', () async {
      final assets = await manager.listAssets(documentPath);
      expect(assets, isEmpty);
    });

    test('lists all files in _assets/ as relative paths', () async {
      final assetsDir = Directory(p.join(tempDir.path, '_assets'));
      await assetsDir.create();
      await File(p.join(assetsDir.path, 'b.pdf')).writeAsString('pdf');
      await File(p.join(assetsDir.path, 'a.png')).writeAsString('img');

      final assets = await manager.listAssets(documentPath);

      expect(assets, [
        p.join('_assets', 'a.png'),
        p.join('_assets', 'b.pdf'),
      ]);
    });

    test('returns sorted list', () async {
      final assetsDir = Directory(p.join(tempDir.path, '_assets'));
      await assetsDir.create();
      for (final name in ['z.png', 'm.jpg', 'a.pdf']) {
        await File(p.join(assetsDir.path, name)).writeAsString('data');
      }

      final assets = await manager.listAssets(documentPath);

      final names = assets.map(p.basename).toList();
      expect(names, ['a.pdf', 'm.jpg', 'z.png']);
    });

    test('round-trip: copyAsset then listAssets includes the file', () async {
      final src = File(p.join(tempDir.path, 'imagen.png'));
      await src.writeAsString('pixels');

      await manager.copyAsset(src.path, documentPath);
      final assets = await manager.listAssets(documentPath);

      expect(assets, contains(p.join('_assets', 'imagen.png')));
    });
  });
}
