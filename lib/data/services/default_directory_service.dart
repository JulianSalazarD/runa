import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart'
    show getApplicationDocumentsDirectory;

/// Thrown when the home directory cannot be resolved.
final class DefaultDirectoryException implements Exception {
  const DefaultDirectoryException(this.message);

  final String message;

  @override
  String toString() => 'DefaultDirectoryException: $message';
}

/// Resolves and ensures the existence of the default Runa documents directory.
///
/// The directory is `~/Runa/` on all platforms, where `~` is the user's home:
/// - Linux / macOS: `$HOME`
/// - Windows:       `%USERPROFILE%`
///
/// The directory is created automatically on the first call if it does not
/// exist. Subsequent calls are idempotent.
///
/// ### Testing
/// Pass [homeOverride] to substitute a temporary directory for the home,
/// so tests do not write to the real `~/Runa/`:
///
/// ```dart
/// final service = DefaultDirectoryService(homeOverride: tempDir.path);
/// ```
class DefaultDirectoryService {
  const DefaultDirectoryService({String? homeOverride})
      : _homeOverride = homeOverride;

  final String? _homeOverride;

  static const _dirName = 'Runa';

  /// Returns the default Runa [Directory], creating it on disk if absent.
  ///
  /// - Android / iOS: `<app-documents>/Runa/`
  /// - Desktop: `~/Runa/`
  ///
  /// Throws [DefaultDirectoryException] if the home directory cannot be
  /// determined from the environment (desktop only).
  Future<Directory> getDefaultDirectory() async {
    if (_homeOverride != null) {
      final dir = Directory(p.join(_homeOverride, _dirName));
      await dir.create(recursive: true);
      return dir;
    }
    if (Platform.isAndroid || Platform.isIOS) {
      final docs = await getApplicationDocumentsDirectory();
      final dir = Directory(p.join(docs.path, _dirName));
      await dir.create(recursive: true);
      return dir;
    }
    final home = _resolveHome();
    final dir = Directory(p.join(home, _dirName));
    await dir.create(recursive: true);
    return dir;
  }

  String _resolveHome() {
    final home = Platform.isWindows
        ? Platform.environment['USERPROFILE']
        : Platform.environment['HOME'];

    if (home == null || home.isEmpty) {
      throw const DefaultDirectoryException(
        'Could not determine the home directory. '
        r'Neither $HOME (Unix) nor %USERPROFILE% (Windows) is set.',
      );
    }
    return home;
  }
}
