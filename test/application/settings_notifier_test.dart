import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:runa/application/application.dart';

// ---------------------------------------------------------------------------
// Fake
// ---------------------------------------------------------------------------

class FakeSettingsRepository implements SettingsRepository {
  AppSettings _stored = const AppSettings();
  int saveCount = 0;

  void seed(AppSettings settings) => _stored = settings;

  @override
  Future<AppSettings> load() async => _stored;

  @override
  Future<void> save(AppSettings settings) async {
    saveCount++;
    _stored = settings;
  }
}

// ---------------------------------------------------------------------------
// Helper
// ---------------------------------------------------------------------------

ProviderContainer _makeContainer(FakeSettingsRepository repo) {
  final container = ProviderContainer(
    overrides: [
      settingsRepositoryProvider.overrideWith((_) => repo),
    ],
  );
  // Keep the auto-dispose provider alive for the test.
  container.listen(settingsNotifierProvider, (_, next) {});
  return container;
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  // -------------------------------------------------------------------------
  // Initial state
  // -------------------------------------------------------------------------

  group('initial state', () {
    test('starts with default AppSettings', () {
      final container = _makeContainer(FakeSettingsRepository());
      addTearDown(container.dispose);

      final settings = container.read(settingsNotifierProvider);
      expect(settings.themeMode, ThemeMode.system);
      expect(settings.autoSaveEnabled, isTrue);
      expect(settings.autoSaveIntervalSeconds, 30);
      expect(settings.markdownFontSize, 16.0);
    });
  });

  // -------------------------------------------------------------------------
  // initialize
  // -------------------------------------------------------------------------

  group('initialize', () {
    test('loads settings from repository into state', () async {
      final repo = FakeSettingsRepository();
      repo.seed(const AppSettings(themeMode: ThemeMode.dark, autoSaveEnabled: false));
      final container = _makeContainer(repo);
      addTearDown(container.dispose);

      await container.read(settingsNotifierProvider.notifier).initialize();

      final settings = container.read(settingsNotifierProvider);
      expect(settings.themeMode, ThemeMode.dark);
      expect(settings.autoSaveEnabled, isFalse);
    });

    test('empty / default repository → default AppSettings', () async {
      final container = _makeContainer(FakeSettingsRepository());
      addTearDown(container.dispose);

      await container.read(settingsNotifierProvider.notifier).initialize();

      expect(container.read(settingsNotifierProvider).themeMode, ThemeMode.system);
    });
  });

  // -------------------------------------------------------------------------
  // update
  // -------------------------------------------------------------------------

  group('update', () {
    test('updates state immediately', () async {
      final container = _makeContainer(FakeSettingsRepository());
      addTearDown(container.dispose);

      final updated = const AppSettings().copyWith(themeMode: ThemeMode.light);
      await container.read(settingsNotifierProvider.notifier).update(updated);

      expect(container.read(settingsNotifierProvider).themeMode, ThemeMode.light);
    });

    test('persists to repository', () async {
      final repo = FakeSettingsRepository();
      final container = _makeContainer(repo);
      addTearDown(container.dispose);

      final updated = const AppSettings().copyWith(markdownFontSize: 20.0);
      await container.read(settingsNotifierProvider.notifier).update(updated);

      expect(repo.saveCount, 1);
      expect(repo._stored.markdownFontSize, 20.0);
    });

    test('subsequent update replaces previous state', () async {
      final container = _makeContainer(FakeSettingsRepository());
      addTearDown(container.dispose);

      final notifier = container.read(settingsNotifierProvider.notifier);
      await notifier.update(const AppSettings().copyWith(themeMode: ThemeMode.dark));
      await notifier.update(const AppSettings().copyWith(themeMode: ThemeMode.light));

      expect(container.read(settingsNotifierProvider).themeMode, ThemeMode.light);
    });
  });
}
