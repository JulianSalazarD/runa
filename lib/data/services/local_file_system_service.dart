import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:runa/application/services/file_system_service.dart';

/// [FileSystemService] backed by `dart:io`.
class LocalFileSystemService implements FileSystemService {
  const LocalFileSystemService();

  static const _runaExtension = '.runa';

  @override
  Future<List<String>> listRunaFiles(String directory) async {
    final dir = Directory(directory);
    if (!await dir.exists()) return const [];

    final paths = <String>[];
    await for (final entity in dir.list(recursive: true)) {
      if (p.split(entity.path).contains('_assets')) continue;
      if (entity is File && entity.path.endsWith(_runaExtension)) {
        paths.add(entity.path);
      }
    }
    paths.sort();
    return paths;
  }

  @override
  Future<List<DirectoryItem>> listDirectory(String path) async {
    final dir = Directory(path);
    if (!await dir.exists()) return const [];

    final entities = await dir.list().toList();
    final items = <DirectoryItem>[];

    for (final entity in entities) {
      if (entity is Directory) {
        if (p.basename(entity.path) == '_assets') continue; // hide asset dirs
        items.add(DirectoryItem(path: entity.path, isDirectory: true));
      } else if (entity is File && entity.path.endsWith(_runaExtension)) {
        items.add(DirectoryItem(path: entity.path, isDirectory: false));
      }
    }

    // Folders first, then files; both sorted alphabetically.
    items.sort((a, b) {
      if (a.isDirectory != b.isDirectory) return a.isDirectory ? -1 : 1;
      return a.path.compareTo(b.path);
    });

    return items;
  }

  /// Watches [directory] and all its descendants for file-system changes.
  @override
  Stream<FileSystemEvent> watchDirectory(String directory) =>
      Directory(directory).watch(recursive: true);

  @override
  Future<void> createDirectory(String path) =>
      Directory(path).create(recursive: true);

  @override
  Future<void> renameEntry(String oldPath, String newPath) async {
    final type = await FileSystemEntity.type(oldPath);
    if (type == FileSystemEntityType.directory) {
      await Directory(oldPath).rename(newPath);
    } else {
      await File(oldPath).rename(newPath);
    }
  }

  @override
  Future<void> deleteFile(String path) => File(path).delete();

  @override
  Future<void> deleteDirectory(String path) =>
      Directory(path).delete(recursive: true);
}
