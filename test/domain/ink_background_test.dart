import 'package:flutter_test/flutter_test.dart';
import 'package:runa/domain/domain.dart';

void main() {
  group('InkBackground — JSON round-trip', () {
    test('all InkBackground values round-trip through InkBlock JSON', () {
      for (final bg in InkBackground.values) {
        final block = Block.ink(
          id: 'id',
          height: 200,
          background: bg,
          backgroundSpacing: 20.0,
        );
        final json = block.toJson();
        final restored = Block.fromJson(json) as InkBlock;
        expect(restored.background, bg,
            reason: 'Background $bg failed to round-trip');
      }
    });

    test('backgroundSpacing round-trips', () {
      const block = Block.ink(id: 'id', height: 200, backgroundSpacing: 32.0);
      final restored = Block.fromJson(block.toJson()) as InkBlock;
      expect(restored.backgroundSpacing, 32.0);
    });

    test('backgroundLineColor round-trips', () {
      const block = Block.ink(
        id: 'id',
        height: 200,
        backgroundLineColor: '#FF0000FF',
      );
      final restored = Block.fromJson(block.toJson()) as InkBlock;
      expect(restored.backgroundLineColor, '#FF0000FF');
    });

    test('backgroundLineColor is null by default', () {
      const block = Block.ink(id: 'id', height: 200);
      expect((block as InkBlock).backgroundLineColor, isNull);
      final restored = Block.fromJson(block.toJson()) as InkBlock;
      expect(restored.backgroundLineColor, isNull);
    });

    test('default values', () {
      const block = Block.ink(id: 'id', height: 200) as InkBlock;
      expect(block.background, InkBackground.plain);
      expect(block.backgroundSpacing, 24.0);
    });

    test('JSON key is "background" with string value', () {
      const block = Block.ink(id: 'id', height: 200, background: InkBackground.grid);
      final json = block.toJson();
      expect(json['background'], 'grid');
    });

    test('backgroundColor round-trips', () {
      const block = Block.ink(id: 'id', height: 200, backgroundColor: '#FFFF00FF');
      final restored = Block.fromJson(block.toJson()) as InkBlock;
      expect(restored.backgroundColor, '#FFFF00FF');
    });

    test('backgroundColor is null by default', () {
      const block = Block.ink(id: 'id', height: 200) as InkBlock;
      expect(block.backgroundColor, isNull);
      final restored = Block.fromJson(block.toJson()) as InkBlock;
      expect(restored.backgroundColor, isNull);
    });
  });
}
