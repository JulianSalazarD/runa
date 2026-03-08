import 'dart:io';

/// A single entry returned by [FileSystemService.listDirectory].
class DirectoryItem {
  const DirectoryItem({required this.path, required this.isDirectory});

  final String path;
  final bool isDirectory;
}

/// Service that provides file-system operations used by the application layer.
///
/// The interface lives in [application] so the [WorkspaceNotifier] can depend
/// on it without importing [dart:io] directly. Implementations live in [data].
abstract interface class FileSystemService {
  /// Returns the absolute paths of all `.runa` files found recursively inside
  /// [directory], sorted alphabetically. Returns an empty list if the
  /// directory does not exist.
  Future<List<String>> listRunaFiles(String directory);

  /// Lists the immediate children of [path]: subdirectories and `.runa` files.
  ///
  /// Sorted: directories first, then files; both alphabetically.
  /// Returns an empty list if [path] does not exist.
  Future<List<DirectoryItem>> listDirectory(String path);

  /// Returns a stream of low-level change events for [directory] and its
  /// descendants. The stream emits whenever a file or sub-directory is
  /// created, deleted, or modified.
  Stream<FileSystemEvent> watchDirectory(String directory);

  /// Creates [path] and any missing parent directories.
  Future<void> createDirectory(String path);

  /// Renames (or moves) the entry at [oldPath] to [newPath].
  Future<void> renameEntry(String oldPath, String newPath);

  /// Deletes the file at [path].
  Future<void> deleteFile(String path);

  /// Deletes the directory at [path] and all its contents.
  Future<void> deleteDirectory(String path);
}
