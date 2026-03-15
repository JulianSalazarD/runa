import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../providers.dart';
import 'app_settings.dart';

part 'settings_notifier.g.dart';

@riverpod
class SettingsNotifier extends _$SettingsNotifier {
  @override
  AppSettings build() => const AppSettings();

  /// Loads persisted settings from disk. Call once on app startup.
  Future<void> initialize() async {
    state = await ref.read(settingsRepositoryProvider).load();
  }

  /// Persists [settings] and updates the in-memory state immediately.
  Future<void> update(AppSettings settings) async {
    state = settings;
    await ref.read(settingsRepositoryProvider).save(settings);
  }
}
