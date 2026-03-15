import 'app_settings.dart';

/// Persistence contract for [AppSettings].
abstract interface class SettingsRepository {
  /// Loads persisted settings, returning defaults if no file exists yet.
  Future<AppSettings> load();

  /// Persists [settings] to the backing store.
  Future<void> save(AppSettings settings);
}
