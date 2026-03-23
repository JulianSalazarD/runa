import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:runa/data/data.dart';
import 'package:runa/domain/domain.dart';

// ---------------------------------------------------------------------------
// Test helpers
// ---------------------------------------------------------------------------

Document _doc({
  String id = '00000000-0000-0000-0000-000000000001',
  List<Block> blocks = const [],
}) {
  return Document(
    version: '0.1',
    id: id,
    createdAt: DateTime.utc(2024),
    updatedAt: DateTime.utc(2024),
    blocks: blocks,
  );
}

const _inkBlock = InkBlock(
  id: '00000000-0000-0002-0000-000000000001',
  height: 250.0,
  strokes: [
    Stroke(
      id: '00000000-0000-0003-0000-000000000001',
      color: '#1A237EFF',
      width: 3.0,
      tool: StrokeTool.pen,
      points: [
        StrokePoint(x: 10.0, y: 20.0, pressure: 0.4, timestamp: 1000),
        StrokePoint(x: 15.5, y: 25.5, pressure: 0.6, timestamp: 1016),
        StrokePoint(x: 21.0, y: 31.0, pressure: 0.8, timestamp: 1032),
        StrokePoint(x: 26.0, y: 36.5, pressure: 0.7, timestamp: 1048),
      ],
    ),
    Stroke(
      id: '00000000-0000-0003-0000-000000000002',
      color: '#B71C1CFF',
      width: 1.5,
      tool: StrokeTool.pencil,
      points: [
        StrokePoint(x: 50.0, y: 60.0, pressure: 0.3, timestamp: 2000),
      ],
    ),
  ],
);

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  late Directory tempDir;
  late LocalDocumentRepository repo;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('runa_test_');
    repo = const LocalDocumentRepository();
  });

  tearDown(() {
    if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
  });

  String path(String name) => '${tempDir.path}/$name.runa';

  // -------------------------------------------------------------------------
  // save + load round-trips
  // -------------------------------------------------------------------------

  group('save + load — round-trip', () {
    test('empty document', () async {
      final doc = _doc();
      await repo.save(doc, path('empty'));
      expect(await repo.load(path('empty')), doc);
    });

    test('document with MarkdownBlock', () async {
      final doc = _doc(blocks: [
        const MarkdownBlock(
          id: '00000000-0000-0001-0000-000000000001',
          content: '# Title\n\nSome paragraph with **bold** and _italic_.',
        ),
      ]);
      await repo.save(doc, path('markdown'));
      expect(await repo.load(path('markdown')), doc);
    });

    test('document with InkBlock with real strokes', () async {
      final doc = _doc(blocks: [_inkBlock]);
      await repo.save(doc, path('ink'));
      final loaded = await repo.load(path('ink'));
      expect(loaded, doc);

      // Verify strokes are correctly preserved
      final ink = loaded.blocks.first as InkBlock;
      expect(ink.strokes.length, 2);
      expect(ink.strokes[0].color, '#1A237EFF');
      expect(ink.strokes[0].tool, StrokeTool.pen);
      expect(ink.strokes[0].points.length, 4);
      expect(ink.strokes[0].points[2].pressure, 0.8);
      expect(ink.strokes[1].tool, StrokeTool.pencil);
    });

    test('document with multiple mixed blocks', () async {
      final doc = _doc(blocks: [
        const MarkdownBlock(
          id: '00000000-0000-0001-0000-000000000001',
          content: '# Notes',
        ),
        _inkBlock,
        const MarkdownBlock(
          id: '00000000-0000-0001-0000-000000000002',
          content: 'Continued below the ink block.',
        ),
        const InkBlock(
          id: '00000000-0000-0002-0000-000000000002',
          height: 120.0,
        ),
      ]);
      await repo.save(doc, path('mixed'));
      expect(await repo.load(path('mixed')), doc);
    });

    test('block order is preserved', () async {
      final doc = _doc(blocks: [
        const MarkdownBlock(
          id: '00000000-0000-0001-0000-000000000001',
          content: 'First',
        ),
        const MarkdownBlock(
          id: '00000000-0000-0001-0000-000000000002',
          content: 'Second',
        ),
        const MarkdownBlock(
          id: '00000000-0000-0001-0000-000000000003',
          content: 'Third',
        ),
      ]);
      await repo.save(doc, path('order'));
      final loaded = await repo.load(path('order'));
      expect(
        loaded.blocks.map((b) => (b as MarkdownBlock).content),
        ['First', 'Second', 'Third'],
      );
    });

    test('saved file is pretty-printed JSON', () async {
      await repo.save(_doc(), path('pretty'));
      final content = File(path('pretty')).readAsStringSync();
      expect(content, contains('\n'));
      expect(content, contains('  '));
    });

    test('saved file contains the type discriminator for each block', () async {
      final doc = _doc(blocks: [
        const MarkdownBlock(
          id: '00000000-0000-0001-0000-000000000001',
          content: 'hello',
        ),
        const InkBlock(id: '00000000-0000-0002-0000-000000000001', height: 100.0),
      ]);
      await repo.save(doc, path('discriminator'));
      final raw = jsonDecode(File(path('discriminator')).readAsStringSync())
          as Map<String, dynamic>;
      final blocks = raw['blocks'] as List<dynamic>;
      expect(blocks[0]['type'], 'markdown');
      expect(blocks[1]['type'], 'ink');
    });

    test('save creates parent directories that do not exist', () async {
      final nestedPath = '${tempDir.path}/sub/folder/doc.runa';
      await repo.save(_doc(), nestedPath);
      expect(File(nestedPath).existsSync(), isTrue);
    });

    test('save overwrites an existing file', () async {
      final p = path('overwrite');
      await repo.save(_doc(), p);
      await repo.save(_doc(id: '00000000-0000-0000-0000-000000000002'), p);
      final loaded = await repo.load(p);
      expect(loaded.id, '00000000-0000-0000-0000-000000000002');
    });
  });

  // -------------------------------------------------------------------------
  // Error handling — load
  // -------------------------------------------------------------------------

  group('load — DocumentNotFoundException', () {
    test('throws for a missing file', () async {
      await expectLater(
        () => repo.load('${tempDir.path}/ghost.runa'),
        throwsA(isA<DocumentNotFoundException>()),
      );
    });

    test('exception includes the requested path', () async {
      final p = '${tempDir.path}/ghost.runa';
      try {
        await repo.load(p);
        fail('Expected DocumentNotFoundException');
      } on DocumentNotFoundException catch (e) {
        expect(e.path, p);
      }
    });
  });

  group('load — DocumentParseException', () {
    test('throws for an empty file', () async {
      final p = path('empty_file');
      File(p).writeAsStringSync('');
      await expectLater(
        () => repo.load(p),
        throwsA(isA<DocumentParseException>()),
      );
    });

    test('throws for malformed JSON', () async {
      final p = path('bad_json');
      File(p).writeAsStringSync('not { valid } json <<<');
      await expectLater(
        () => repo.load(p),
        throwsA(isA<DocumentParseException>()),
      );
    });

    test('throws when root is a JSON array instead of object', () async {
      final p = path('json_array');
      File(p).writeAsStringSync('[1, 2, 3]');
      await expectLater(
        () => repo.load(p),
        throwsA(isA<DocumentParseException>()),
      );
    });

    test('throws for a document with an invalid date field', () async {
      final p = path('bad_date');
      File(p).writeAsStringSync(jsonEncode({
        'version': '0.1',
        'id': '00000000-0000-0000-0000-000000000001',
        'created_at': 'not-a-date',
        'updated_at': '2024-01-01T00:00:00.000Z',
        'blocks': <dynamic>[],
      }));
      await expectLater(
        () => repo.load(p),
        throwsA(isA<DocumentParseException>()),
      );
    });

    test('exception includes the path', () async {
      final p = path('parse_error');
      File(p).writeAsStringSync('{}');
      try {
        await repo.load(p);
        fail('Expected an exception');
      } on DocumentRepositoryException catch (e) {
        expect(e.path, p);
      }
    });
  });

  group('load — DocumentVersionException', () {
    Map<String, dynamic> baseJson({required String? version}) => {
          'version': ?version,
          'id': '00000000-0000-0000-0000-000000000001',
          'created_at': '2024-01-01T00:00:00.000Z',
          'updated_at': '2024-01-01T00:00:00.000Z',
          'blocks': <dynamic>[],
        };

    test('throws for an unsupported version', () async {
      final p = path('bad_version');
      File(p).writeAsStringSync(jsonEncode(baseJson(version: '99.0')));
      await expectLater(
        () => repo.load(p),
        throwsA(isA<DocumentVersionException>()),
      );
    });

    test('exception includes the bad version string', () async {
      final p = path('version_detail');
      File(p).writeAsStringSync(jsonEncode(baseJson(version: '2.0')));
      try {
        await repo.load(p);
        fail('Expected DocumentVersionException');
      } on DocumentVersionException catch (e) {
        expect(e.version, '2.0');
        expect(e.path, p);
      }
    });

    test('throws when version field is missing', () async {
      final p = path('no_version');
      File(p).writeAsStringSync(jsonEncode(baseJson(version: null)));
      await expectLater(
        () => repo.load(p),
        throwsA(isA<DocumentVersionException>()),
      );
    });

    test('version "missing" label appears when version key is absent', () async {
      final p = path('missing_label');
      File(p).writeAsStringSync(jsonEncode(baseJson(version: null)));
      try {
        await repo.load(p);
        fail('Expected DocumentVersionException');
      } on DocumentVersionException catch (e) {
        expect(e.version, 'missing');
      }
    });
  });

  // -------------------------------------------------------------------------
  // listDocuments
  // -------------------------------------------------------------------------

  group('listDocuments', () {
    test('returns empty list for an empty directory', () async {
      final paths = await repo.listDocuments(tempDir.path);
      expect(paths, isEmpty);
    });

    test('returns empty list for a non-existent directory', () async {
      final paths = await repo.listDocuments('${tempDir.path}/no_such_dir');
      expect(paths, isEmpty);
    });

    test('returns paths of .runa files', () async {
      await repo.save(_doc(), path('a'));
      await repo.save(_doc(id: '00000000-0000-0000-0000-000000000002'), path('b'));
      final paths = await repo.listDocuments(tempDir.path);
      expect(paths.length, 2);
      expect(paths.every((p) => p.endsWith('.runa')), isTrue);
    });

    test('ignores non-.runa files', () async {
      File('${tempDir.path}/readme.md').writeAsStringSync('# Readme');
      File('${tempDir.path}/data.json').writeAsStringSync('{}');
      File('${tempDir.path}/image.runa.bak').writeAsStringSync('backup');
      await repo.save(_doc(), path('real'));
      final paths = await repo.listDocuments(tempDir.path);
      expect(paths.length, 1);
      expect(paths.first, endsWith('real.runa'));
    });

    test('results are sorted alphabetically', () async {
      await repo.save(_doc(id: '00000000-0000-0000-0000-000000000003'), path('gamma'));
      await repo.save(_doc(), path('alpha'));
      await repo.save(_doc(id: '00000000-0000-0000-0000-000000000002'), path('beta'));
      final paths = await repo.listDocuments(tempDir.path);
      final names = paths.map((p) => p.split('/').last).toList();
      expect(names, ['alpha.runa', 'beta.runa', 'gamma.runa']);
    });

    test('returned paths are absolute', () async {
      await repo.save(_doc(), path('doc'));
      final paths = await repo.listDocuments(tempDir.path);
      expect(paths.first, startsWith('/'));
    });
  });
}
