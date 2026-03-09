import 'dart:io';
import 'dart:ui' as ui;

import 'package:path/path.dart' as p;

import 'package:runa/application/services/asset_manager.dart';

/// [AssetManager] implementation backed by the local file system.
///
/// Assets are stored in an `_assets/` subdirectory next to the `.runa` file.
class LocalAssetManager implements AssetManager {
  const LocalAssetManager();

  static const _assetsDir = '_assets';

  @override
  Future<String> copyAsset(String sourcePath, String documentPath) async {
    final docDir = p.dirname(documentPath);
    final assetsDir = Directory(p.join(docDir, _assetsDir));
    await assetsDir.create(recursive: true);

    final fileName = p.basename(sourcePath);
    final destPath = p.join(assetsDir.path, fileName);

    // Deduplication: if a file with the same name already exists, skip copy.
    if (!await File(destPath).exists()) {
      await File(sourcePath).copy(destPath);
    }

    return p.join(_assetsDir, fileName);
  }

  @override
  String resolveAsset(String relativePath, String documentPath) {
    return p.join(p.dirname(documentPath), relativePath);
  }

  @override
  Future<void> deleteAsset(String relativePath, String documentPath) async {
    final absolutePath = resolveAsset(relativePath, documentPath);
    final file = File(absolutePath);
    if (await file.exists()) {
      await file.delete();
    }
  }

  @override
  Future<List<String>> listAssets(String documentPath) async {
    final docDir = p.dirname(documentPath);
    final assetsDir = Directory(p.join(docDir, _assetsDir));
    if (!await assetsDir.exists()) return const [];

    final paths = <String>[];
    await for (final entity in assetsDir.list()) {
      if (entity is File) {
        paths.add(p.join(_assetsDir, p.basename(entity.path)));
      }
    }
    paths.sort();
    return paths;
  }

  @override
  Future<(double, double)> readImageSize(String path) async {
    final bytes = await File(path).readAsBytes();
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    final width = frame.image.width.toDouble();
    final height = frame.image.height.toDouble();
    frame.image.dispose();
    codec.dispose();
    return (width, height);
  }
}
