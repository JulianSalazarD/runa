import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:runa/application/services/recent_entry.dart';
import 'package:runa/data/data.dart';

void main() {
  late Directory tempDir;
  late LocalRecentFilesService svc;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('runa_recents_test_');
    svc = LocalRecentFilesService(
      filePathOverride: '${tempDir.path}/recents.json',
    );
  });

  tearDown(() {
    if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
  });

  // -------------------------------------------------------------------------
  // loadRecents
  // -------------------------------------------------------------------------

  group('loadRecents', () {
    test('returns empty list when file does not exist', () async {
      expect(await svc.loadRecents(), isEmpty);
    });

    test('returns empty list after clear()', () async {
      await svc.addRecent('/a/doc.runa');
      await svc.clear();
      expect(await svc.loadRecents(), isEmpty);
    });

    test('returns paths in most-recent-first order', () async {
      await svc.addRecent('/a/doc.runa');
      await svc.addRecent('/b/doc.runa');
      final recents = await svc.loadRecents();
      expect(recents, ['/b/doc.runa', '/a/doc.runa']);
    });
  });

  // -------------------------------------------------------------------------
  // addRecent
  // -------------------------------------------------------------------------

  group('addRecent', () {
    test('adds a path to the front of the list', () async {
      await svc.addRecent('/a/doc.runa');
      expect(await svc.loadRecents(), ['/a/doc.runa']);
    });

    test('moves an existing entry to the front instead of duplicating', () async {
      await svc.addRecent('/a/doc.runa');
      await svc.addRecent('/b/doc.runa');
      await svc.addRecent('/a/doc.runa'); // re-open /a
      final recents = await svc.loadRecents();
      expect(recents, ['/a/doc.runa', '/b/doc.runa']);
      expect(recents.length, 2);
    });

    test('caps the list at 20 entries', () async {
      for (var i = 0; i < 25; i++) {
        await svc.addRecent('/doc_$i.runa');
      }
      final recents = await svc.loadRecents();
      expect(recents.length, 20);
      // Most recent entry is the last one added
      expect(recents.first, '/doc_24.runa');
    });

    test('persists across service instances', () async {
      await svc.addRecent('/a/doc.runa');

      final svc2 = LocalRecentFilesService(
        filePathOverride: '${tempDir.path}/recents.json',
      );
      expect(await svc2.loadRecents(), ['/a/doc.runa']);
    });
  });

  // -------------------------------------------------------------------------
  // remove
  // -------------------------------------------------------------------------

  group('remove', () {
    test('removes the specified path', () async {
      await svc.addRecent('/a/doc.runa');
      await svc.addRecent('/b/doc.runa');
      await svc.remove('/a/doc.runa');
      expect(await svc.loadRecents(), ['/b/doc.runa']);
    });

    test('no-op when path is not in the list', () async {
      await svc.addRecent('/a/doc.runa');
      await svc.remove('/nonexistent.runa');
      expect(await svc.loadRecents(), ['/a/doc.runa']);
    });
  });

  // -------------------------------------------------------------------------
  // clear
  // -------------------------------------------------------------------------

  group('clear', () {
    test('removes all entries', () async {
      await svc.addRecent('/a/doc.runa');
      await svc.addRecent('/b/doc.runa');
      await svc.clear();
      expect(await svc.loadRecents(), isEmpty);
    });

    test('clear on empty list does not throw', () async {
      await expectLater(svc.clear(), completes);
    });
  });

  // -------------------------------------------------------------------------
  // loadRecentEntries
  // -------------------------------------------------------------------------

  group('loadRecentEntries', () {
    test('returns empty list when no file exists', () async {
      expect(await svc.loadRecentEntries(), isEmpty);
    });

    test('returns entries with paths and timestamps after addRecent', () async {
      final before = DateTime.now().subtract(const Duration(seconds: 1));
      await svc.addRecent('/a/doc.runa');
      final entries = await svc.loadRecentEntries();
      expect(entries.length, 1);
      expect(entries.first.path, '/a/doc.runa');
      expect(entries.first.openedAt.isAfter(before), isTrue);
    });

    test('returns entries in most-recent-first order', () async {
      await svc.addRecent('/a/doc.runa');
      await svc.addRecent('/b/doc.runa');
      final entries = await svc.loadRecentEntries();
      expect(entries.map((e) => e.path).toList(),
          ['/b/doc.runa', '/a/doc.runa']);
    });

    test('backward compat: plain string entries get epoch timestamp', () async {
      // Write old-format JSON (plain array of strings, not objects).
      final file = File('${tempDir.path}/recents.json');
      await file.writeAsString('["/a/old.runa"]');

      final entries = await svc.loadRecentEntries();
      expect(entries.length, 1);
      expect(entries.first.path, '/a/old.runa');
      expect(entries.first.openedAt,
          DateTime.fromMillisecondsSinceEpoch(0));
    });

    test('returns empty list after clear()', () async {
      await svc.addRecent('/a/doc.runa');
      await svc.clear();
      expect(await svc.loadRecentEntries(), isEmpty);
    });
  });
}
