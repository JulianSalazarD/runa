import 'dart:io';

/// Service that provides file-system operations used by the application layer.
///
/// The interface lives in [application] so the [WorkspaceNotifier] can depend
/// on it without importing [dart:io] directly. Implementations live in [data].
abstract interface class FileSystemService {
  /// Returns the absolute paths of all `.runa` files found recursively inside
  /// [directory], sorted alphabetically. Returns an empty list if the
  /// directory does not exist.
  Future<List<String>> listRunaFiles(String directory);

  /// Returns a stream of low-level change events for [directory].
  /// The stream emits whenever a file or sub-directory inside [directory]
  /// is created, deleted, or modified.
  Stream<FileSystemEvent> watchDirectory(String directory);

  /// Creates [path] and any missing parent directories.
  Future<void> createDirectory(String path);
}
