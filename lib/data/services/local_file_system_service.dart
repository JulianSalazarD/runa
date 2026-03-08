import 'dart:io';

import 'package:runa/application/services/file_system_service.dart';

/// [FileSystemService] backed by `dart:io`.
class LocalFileSystemService implements FileSystemService {
  const LocalFileSystemService();

  static const _runaExtension = '.runa';

  /// Lists all `.runa` files found recursively inside [directory],
  /// sorted alphabetically by absolute path.
  @override
  Future<List<String>> listRunaFiles(String directory) async {
    final dir = Directory(directory);
    if (!await dir.exists()) return const [];

    final paths = <String>[];
    await for (final entity in dir.list(recursive: true)) {
      if (entity is File && entity.path.endsWith(_runaExtension)) {
        paths.add(entity.path);
      }
    }
    paths.sort();
    return paths;
  }

  /// Returns a stream of file-system events for the top level of [directory].
  /// Callers should cancel the subscription when the directory is closed.
  @override
  Stream<FileSystemEvent> watchDirectory(String directory) =>
      Directory(directory).watch();

  /// Creates [path] and any missing intermediate directories.
  @override
  Future<void> createDirectory(String path) =>
      Directory(path).create(recursive: true);
}
