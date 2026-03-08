import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:runa/domain/domain.dart';

Document _buildDocument({List<Block> blocks = const []}) {
  return Document(
    version: '0.1',
    id: '00000000-0000-0000-0000-000000000001',
    createdAt: DateTime.utc(2024, 1),
    updatedAt: DateTime.utc(2024, 1),
    blocks: blocks,
  );
}

void main() {
  // -------------------------------------------------------------------------
  // JSON round-trip
  // -------------------------------------------------------------------------

  group('Document — JSON round-trip', () {
    test('empty document round-trips correctly', () {
      final doc = _buildDocument();
      expect(Document.fromJson(doc.toJson()), doc);
    });

    test('toJson uses snake_case keys', () {
      final json = _buildDocument().toJson();
      expect(json.containsKey('created_at'), isTrue);
      expect(json.containsKey('updated_at'), isTrue);
      expect(json.containsKey('createdAt'), isFalse);
    });

    test('toJson serializes DateTime as ISO 8601 UTC', () {
      final json = _buildDocument().toJson();
      expect(json['created_at'], '2024-01-01T00:00:00.000Z');
    });

    test('document with MarkdownBlock round-trips', () {
      final doc = _buildDocument(blocks: [
        const MarkdownBlock(
          id: '00000000-0000-0001-0000-000000000001',
          content: '# Hello',
        ),
      ]);
      expect(Document.fromJson(doc.toJson()), doc);
    });

    test('document with InkBlock round-trips', () {
      final doc = _buildDocument(blocks: [
        const InkBlock(
          id: '00000000-0000-0002-0000-000000000001',
          height: 200.0,
          strokes: [
            Stroke(
              id: '00000000-0000-0003-0000-000000000001',
              color: '#000000FF',
              width: 2.0,
              tool: StrokeTool.pen,
              points: [
                StrokePoint(x: 10.0, y: 20.0, pressure: 0.5, timestamp: 1000),
                StrokePoint(x: 15.0, y: 25.0, pressure: 0.6, timestamp: 1016),
              ],
            ),
          ],
        ),
      ]);
      expect(Document.fromJson(doc.toJson()), doc);
    });

    test('document with mixed blocks round-trips', () {
      final doc = _buildDocument(blocks: [
        const MarkdownBlock(
          id: '00000000-0000-0001-0000-000000000001',
          content: '# Title',
        ),
        const InkBlock(
          id: '00000000-0000-0002-0000-000000000001',
          height: 150.0,
        ),
        const MarkdownBlock(
          id: '00000000-0000-0001-0000-000000000002',
          content: 'Paragraph after ink.',
        ),
      ]);
      expect(Document.fromJson(doc.toJson()), doc);
    });
  });

  // -------------------------------------------------------------------------
  // Fixtures
  // -------------------------------------------------------------------------

  group('Document — fixture files', () {
    test('minimal_document.runa parses correctly', () {
      final json = jsonDecode(
        File('test/fixtures/minimal_document.runa').readAsStringSync(),
      ) as Map<String, dynamic>;
      final doc = Document.fromJson(json);

      expect(doc.version, '0.1');
      expect(doc.id, '00000000-0000-0000-0000-000000000001');
      expect(doc.createdAt, DateTime.utc(2024, 1));
      expect(doc.blocks, isEmpty);
    });

    test('full_document.runa parses correctly', () {
      final json = jsonDecode(
        File('test/fixtures/full_document.runa').readAsStringSync(),
      ) as Map<String, dynamic>;
      final doc = Document.fromJson(json);

      expect(doc.version, '0.1');
      expect(doc.blocks.length, 4);
    });

    test('full_document.runa — first block is MarkdownBlock', () {
      final json = jsonDecode(
        File('test/fixtures/full_document.runa').readAsStringSync(),
      ) as Map<String, dynamic>;
      final doc = Document.fromJson(json);

      expect(doc.blocks[0], isA<MarkdownBlock>());
      final md = doc.blocks[0] as MarkdownBlock;
      expect(md.content, contains('Hello, Runa!'));
    });

    test('full_document.runa — third block is InkBlock with two strokes', () {
      final json = jsonDecode(
        File('test/fixtures/full_document.runa').readAsStringSync(),
      ) as Map<String, dynamic>;
      final doc = Document.fromJson(json);

      expect(doc.blocks[2], isA<InkBlock>());
      final ink = doc.blocks[2] as InkBlock;
      expect(ink.strokes.length, 2);
      expect(ink.strokes[0].color, '#000000FF');
      expect(ink.strokes[0].tool, StrokeTool.pen);
      expect(ink.strokes[0].points.length, 3);
    });

    test('full_document.runa round-trips back to equivalent JSON', () {
      final rawJson = jsonDecode(
        File('test/fixtures/full_document.runa').readAsStringSync(),
      ) as Map<String, dynamic>;
      final doc = Document.fromJson(rawJson);
      final reEncoded = doc.toJson();

      // Re-parse the re-encoded JSON and compare as Document
      final doc2 = Document.fromJson(reEncoded);
      expect(doc2, doc);
    });
  });

  // -------------------------------------------------------------------------
  // copyWith
  // -------------------------------------------------------------------------

  group('Document — copyWith', () {
    test('copyWith changes updatedAt only', () {
      final original = _buildDocument();
      final updated = original.copyWith(updatedAt: DateTime.utc(2024, 6));
      expect(updated.updatedAt, DateTime.utc(2024, 6));
      expect(updated.createdAt, original.createdAt);
      expect(updated.id, original.id);
      expect(updated.blocks, original.blocks);
    });

    test('copyWith appends a block', () {
      final original = _buildDocument();
      final withBlock = original.copyWith(blocks: [
        const MarkdownBlock(
          id: '00000000-0000-0001-0000-000000000001',
          content: 'New block',
        ),
      ]);
      expect(withBlock.blocks.length, 1);
      expect(original.blocks, isEmpty);
    });
  });

  // -------------------------------------------------------------------------
  // Equality & hashCode
  // -------------------------------------------------------------------------

  group('Document — equality & hashCode', () {
    test('identical documents are equal', () {
      final a = _buildDocument();
      final b = _buildDocument();
      expect(a, b);
      expect(a.hashCode, b.hashCode);
    });

    test('different id → not equal', () {
      final a = _buildDocument();
      final b = a.copyWith(id: '00000000-0000-0000-0000-000000000099');
      expect(a, isNot(b));
    });

    test('different blocks → not equal', () {
      final a = _buildDocument();
      final b = a.copyWith(blocks: [
        const MarkdownBlock(
          id: '00000000-0000-0001-0000-000000000001',
          content: 'extra',
        ),
      ]);
      expect(a, isNot(b));
    });
  });
}
