import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:runa/application/services/recent_entry.dart';
import 'package:runa/application/services/recent_files_service.dart';

/// [RecentFilesService] backed by a JSON file in the app support directory.
///
/// The list is capped at [_maxRecents] entries (most recent first).
///
/// ### JSON format
/// Each element is `{"path": "...", "openedAt": "...ISO8601..."}`.
/// Old plain-string elements are accepted for backward compatibility and get
/// an `openedAt` of `DateTime.fromMillisecondsSinceEpoch(0)`.
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
  Future<List<RecentEntry>> loadRecentEntries() async {
    final file = File(await _resolveFilePath());
    if (!await file.exists()) return [];
    try {
      final decoded = jsonDecode(await file.readAsString());
      if (decoded is! List) return [];
      return decoded.map<RecentEntry?>((e) {
        if (e is String) {
          // Backward compat: plain path string from old format.
          return RecentEntry(
            path: e,
            openedAt: DateTime.fromMillisecondsSinceEpoch(0),
          );
        }
        if (e is Map<String, dynamic>) {
          final path = e['path'] as String?;
          final openedAtRaw = e['openedAt'] as String?;
          if (path == null) return null;
          return RecentEntry(
            path: path,
            openedAt: openedAtRaw != null
                ? DateTime.tryParse(openedAtRaw) ??
                    DateTime.fromMillisecondsSinceEpoch(0)
                : DateTime.fromMillisecondsSinceEpoch(0),
          );
        }
        return null;
      }).whereType<RecentEntry>().toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<List<String>> loadRecents() async {
    final entries = await loadRecentEntries();
    return entries.map((e) => e.path).toList();
  }

  @override
  Future<void> addRecent(String path) async {
    var entries = await loadRecentEntries();
    entries.removeWhere((e) => e.path == path);
    entries.insert(0, RecentEntry(path: path, openedAt: DateTime.now().toUtc()));
    if (entries.length > _maxRecents) {
      entries = entries.sublist(0, _maxRecents);
    }
    await _saveEntries(entries);
  }

  @override
  Future<void> remove(String path) async {
    final entries = await loadRecentEntries();
    entries.removeWhere((e) => e.path == path);
    await _saveEntries(entries);
  }

  @override
  Future<void> clear() => _saveEntries([]);

  Future<void> _saveEntries(List<RecentEntry> entries) async {
    final filePath = await _resolveFilePath();
    final file = File(filePath);
    await file.parent.create(recursive: true);
    await file.writeAsString(
      jsonEncode(
        entries
            .map((e) => {
                  'path': e.path,
                  'openedAt': e.openedAt.toIso8601String(),
                })
            .toList(),
      ),
    );
  }
}
