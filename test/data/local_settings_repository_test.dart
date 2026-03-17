import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:runa/application/application.dart';
import 'package:runa/data/repositories/local_settings_repository.dart';

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  late Directory tempDir;
  late LocalSettingsRepository repo;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('settings_test_');
    repo = LocalSettingsRepository(
        filePathOverride: p.join(tempDir.path, 'settings.json'));
  });

  tearDown(() async {
    await tempDir.delete(recursive: true);
  });

  // -------------------------------------------------------------------------
  // load
  // -------------------------------------------------------------------------

  group('load', () {
    test('returns default AppSettings when no file exists', () async {
      final settings = await repo.load();
      expect(settings, const AppSettings());
      expect(settings.autoSaveEnabled, isFalse);
      expect(settings.themeMode, ThemeMode.system);
    });

    test('returns default AppSettings on corrupted JSON', () async {
      final file = File(p.join(tempDir.path, 'settings.json'));
      await file.writeAsString('{ not valid json ');
      final settings = await repo.load();
      expect(settings, const AppSettings());
    });
  });

  // -------------------------------------------------------------------------
  // save → load round-trip
  // -------------------------------------------------------------------------

  group('save + load round-trip', () {
    test('persists themeMode', () async {
      await repo.save(const AppSettings(themeMode: ThemeMode.dark));
      final loaded = await repo.load();
      expect(loaded.themeMode, ThemeMode.dark);
    });

    test('persists markdownFontFamily and markdownFontSize', () async {
      await repo.save(const AppSettings(
        markdownFontFamily: 'Ubuntu',
        markdownFontSize: 18.0,
      ));
      final loaded = await repo.load();
      expect(loaded.markdownFontFamily, 'Ubuntu');
      expect(loaded.markdownFontSize, 18.0);
    });

    test('persists defaultInkColor', () async {
      await repo.save(
          const AppSettings(defaultInkColor: Color(0xFF1565C0)));
      final loaded = await repo.load();
      expect(loaded.defaultInkColor, const Color(0xFF1565C0));
    });

    test('persists nullable defaultCanvasBackground as null', () async {
      await repo.save(const AppSettings());
      final loaded = await repo.load();
      expect(loaded.defaultCanvasBackground, isNull);
    });

    test('persists nullable defaultCanvasBackground with a value', () async {
      await repo.save(
          const AppSettings(defaultCanvasBackground: Color(0xFFFFFDE7)));
      final loaded = await repo.load();
      expect(loaded.defaultCanvasBackground, const Color(0xFFFFFDE7));
    });

    test('persists autoSaveEnabled = false', () async {
      await repo.save(const AppSettings(autoSaveEnabled: false));
      final loaded = await repo.load();
      expect(loaded.autoSaveEnabled, isFalse);
    });

    test('persists autoSaveIntervalSeconds', () async {
      await repo.save(const AppSettings(autoSaveIntervalSeconds: 60));
      final loaded = await repo.load();
      expect(loaded.autoSaveIntervalSeconds, 60);
    });

    test('settings.json file is created on disk', () async {
      await repo.save(const AppSettings());
      final file = File(p.join(tempDir.path, 'settings.json'));
      expect(await file.exists(), isTrue);
    });
  });
}
