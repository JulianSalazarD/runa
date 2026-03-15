import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:runa/application/settings/app_settings.dart';
import 'package:runa/application/settings/settings_repository.dart';

const _jsonEncoder = JsonEncoder.withIndent('  ');

/// [SettingsRepository] backed by a `settings.json` file in the app's
/// support directory.
///
/// Pass [filePathOverride] in tests to redirect I/O to a temporary file.
class LocalSettingsRepository implements SettingsRepository {
  const LocalSettingsRepository({this.filePathOverride});

  final String? filePathOverride;

  Future<File> get _file async {
    if (filePathOverride != null) return File(filePathOverride!);
    final dir = await getApplicationSupportDirectory();
    return File(p.join(dir.path, 'settings.json'));
  }

  @override
  Future<AppSettings> load() async {
    try {
      final file = await _file;
      if (!await file.exists()) return const AppSettings();
      final content = await file.readAsString();
      final json = jsonDecode(content) as Map<String, dynamic>;
      return AppSettings.fromJson(json);
    } catch (_) {
      return const AppSettings();
    }
  }

  @override
  Future<void> save(AppSettings settings) async {
    final file = await _file;
    await file.parent.create(recursive: true);
    await file.writeAsString(_jsonEncoder.convert(settings.toJson()));
  }
}
