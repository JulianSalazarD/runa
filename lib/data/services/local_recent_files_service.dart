import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:runa/application/services/recent_files_service.dart';

/// [RecentFilesService] backed by a JSON file in the app support directory.
///
/// The list is capped at [_maxRecents] entries (most recent first).
///
/// ### Testing
/// Pass [filePathOverride] to use a custom file path instead of the
/// platform-specific support directory, so tests don't need platform setup:
///
/// ```dart
/// final svc = LocalRecentFilesService(
///   filePathOverride: '${tempDir.path}/recents.json',
/// );
/// ```
class LocalRecentFilesService implements RecentFilesService {
  const LocalRecentFilesService({String? filePathOverride})
      : _filePathOverride = filePathOverride;

  final String? _filePathOverride;

  static const _maxRecents = 20;
  static const _fileName = 'runa_recents.json';

  Future<String> _resolveFilePath() async {
    if (_filePathOverride != null) return _filePathOverride;
    final dir = await getApplicationSupportDirectory();
    return p.join(dir.path, _fileName);
  }

  @override
  Future<List<String>> loadRecents() async {
    final file = File(await _resolveFilePath());
    if (!await file.exists()) return [];
    try {
      final decoded = jsonDecode(await file.readAsString());
      if (decoded is! List) return [];
      return decoded.cast<String>();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<void> addRecent(String path) async {
    var recents = await loadRecents();
    recents.remove(path);
    recents.insert(0, path);
    if (recents.length > _maxRecents) {
      recents = recents.sublist(0, _maxRecents);
    }
    await _save(recents);
  }

  @override
  Future<void> remove(String path) async {
    final recents = await loadRecents();
    recents.remove(path);
    await _save(recents);
  }

  @override
  Future<void> clear() => _save([]);

  Future<void> _save(List<String> recents) async {
    final filePath = await _resolveFilePath();
    final file = File(filePath);
    await file.parent.create(recursive: true);
    await file.writeAsString(jsonEncode(recents));
  }
}
