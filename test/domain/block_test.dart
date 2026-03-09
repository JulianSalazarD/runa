import 'package:flutter_test/flutter_test.dart';
import 'package:runa/domain/domain.dart';

const _stroke = Stroke(
  id: '00000000-0000-0003-0000-000000000001',
  color: '#000000FF',
  width: 2.0,
  tool: StrokeTool.pen,
  points: [StrokePoint(x: 0.0, y: 0.0, pressure: 0.5, timestamp: 0)],
);

const _markdownBlock = MarkdownBlock(
  id: '00000000-0000-0001-0000-000000000001',
  content: '# Hello',
);

const _inkBlock = InkBlock(
  id: '00000000-0000-0002-0000-000000000001',
  height: 200.0,
  strokes: [_stroke],
);

void main() {
  // -------------------------------------------------------------------------
  // MarkdownBlock
  // -------------------------------------------------------------------------

  group('MarkdownBlock — JSON round-trip', () {
    test('toJson includes type discriminator', () {
      final json = _markdownBlock.toJson();
      expect(json['type'], 'markdown');
      expect(json['id'], _markdownBlock.id);
      expect(json['content'], '# Hello');
    });

    test('round-trip equality', () {
      expect(MarkdownBlock.fromJson(_markdownBlock.toJson()), _markdownBlock);
    });

    test('Block.fromJson dispatches to MarkdownBlock', () {
      final block = Block.fromJson(_markdownBlock.toJson());
      expect(block, isA<MarkdownBlock>());
      expect((block as MarkdownBlock).content, '# Hello');
    });

    test('empty content round-trips correctly', () {
      const empty = MarkdownBlock(
        id: '00000000-0000-0001-0000-000000000002',
        content: '',
      );
      expect(MarkdownBlock.fromJson(empty.toJson()), empty);
    });

    test('multiline markdown content round-trips correctly', () {
      const md = MarkdownBlock(
        id: '00000000-0000-0001-0000-000000000003',
        content: '# Title\n\nParagraph with **bold** and _italic_.\n\n- item 1\n- item 2',
      );
      expect(MarkdownBlock.fromJson(md.toJson()), md);
    });
  });

  group('MarkdownBlock — copyWith', () {
    test('copyWith changes content', () {
      final updated = _markdownBlock.copyWith(content: '## Updated');
      expect(updated.content, '## Updated');
      expect(updated.id, _markdownBlock.id);
    });

    test('copyWith with no args returns equal block', () {
      expect(_markdownBlock.copyWith(), _markdownBlock);
    });
  });

  group('MarkdownBlock — equality & hashCode', () {
    test('identical blocks are equal', () {
      const other = MarkdownBlock(
        id: '00000000-0000-0001-0000-000000000001',
        content: '# Hello',
      );
      expect(_markdownBlock, other);
      expect(_markdownBlock.hashCode, other.hashCode);
    });

    test('different content → not equal', () {
      expect(_markdownBlock, isNot(_markdownBlock.copyWith(content: 'other')));
    });
  });

  // -------------------------------------------------------------------------
  // InkBlock
  // -------------------------------------------------------------------------

  group('InkBlock — JSON round-trip', () {
    test('toJson includes type discriminator', () {
      final json = _inkBlock.toJson();
      expect(json['type'], 'ink');
      expect(json['id'], _inkBlock.id);
      expect(json['height'], 200.0);
    });

    test('strokes are serialized as list of maps', () {
      final json = _inkBlock.toJson();
      final strokes = json['strokes'] as List;
      expect(strokes.length, 1);
      expect((strokes[0] as Map)['color'], '#000000FF');
    });

    test('round-trip equality', () {
      expect(InkBlock.fromJson(_inkBlock.toJson()), _inkBlock);
    });

    test('Block.fromJson dispatches to InkBlock', () {
      final block = Block.fromJson(_inkBlock.toJson());
      expect(block, isA<InkBlock>());
      expect((block as InkBlock).height, 200.0);
    });

    test('empty strokes round-trips correctly', () {
      const empty = InkBlock(
        id: '00000000-0000-0002-0000-000000000002',
        height: 120.0,
      );
      final restored = InkBlock.fromJson(empty.toJson());
      expect(restored, empty);
      expect(restored.strokes, isEmpty);
    });

    test('default height from constructor', () {
      const b = InkBlock(id: '00000000-0000-0002-0000-000000000003', height: 300.0);
      expect(b.strokes, isEmpty);
    });
  });

  group('InkBlock — copyWith', () {
    test('copyWith changes height', () {
      final taller = _inkBlock.copyWith(height: 400.0);
      expect(taller.height, 400.0);
      expect(taller.strokes, _inkBlock.strokes);
    });

    test('copyWith replaces strokes', () {
      final cleared = _inkBlock.copyWith(strokes: []);
      expect(cleared.strokes, isEmpty);
    });
  });

  group('InkBlock — equality & hashCode', () {
    test('identical InkBlocks are equal', () {
      const other = InkBlock(
        id: '00000000-0000-0002-0000-000000000001',
        height: 200.0,
        strokes: [_stroke],
      );
      expect(_inkBlock, other);
      expect(_inkBlock.hashCode, other.hashCode);
    });

    test('different height → not equal', () {
      expect(_inkBlock, isNot(_inkBlock.copyWith(height: 100.0)));
    });
  });

  // -------------------------------------------------------------------------
  // Block sealed class — pattern matching
  // -------------------------------------------------------------------------

  group('Block — pattern matching', () {
    test('switch on MarkdownBlock extracts content', () {
      const Block block = _markdownBlock;
      final result = switch (block) {
        MarkdownBlock(:final content) => content,
        InkBlock() => 'ink',
        ImageBlock() => 'image',
        PdfBlock() => 'pdf',
      };
      expect(result, '# Hello');
    });

    test('switch on InkBlock extracts strokes count', () {
      const Block block = _inkBlock;
      final result = switch (block) {
        MarkdownBlock() => -1,
        InkBlock(:final strokes) => strokes.length,
        ImageBlock() => -1,
        PdfBlock() => -1,
      };
      expect(result, 1);
    });
  });

  group('Block.fromJson — error handling', () {
    test('throws on unknown type', () {
      expect(
        () => Block.fromJson({'type': 'audio', 'id': '00000000-0000-0001-0000-000000000001'}),
        throwsA(anything),
      );
    });
  });
}
