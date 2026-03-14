import 'package:flutter_math_fork/flutter_math.dart' show MathStyle;
import 'package:flutter_test/flutter_test.dart';
import 'package:runa/application/services/math_rasterizer.dart';

void main() {
  // MathRasterizer calls dart:ui image.toByteData() which is a real async
  // callback — it cannot complete inside testWidgets' FakeAsync zone.
  // Every call to rasterize() must be wrapped with tester.runAsync().

  group('MathRasterizer.rasterize', () {
    late MathRasterizer rasterizer;

    setUp(() {
      rasterizer = MathRasterizer();
    });

    testWidgets('valid expression returns non-empty PNG bytes',
        (tester) async {
      final bytes =
          await tester.runAsync(() => rasterizer.rasterize(r'E = mc^2'));
      expect(bytes, isNotEmpty);
      // PNG header: 0x89 P N G
      expect(bytes!.sublist(0, 4), [0x89, 0x50, 0x4E, 0x47]);
    });

    testWidgets('same expression called twice returns identical instance',
        (tester) async {
      const tex = r'\frac{1}{2}';
      final a = await tester.runAsync(() => rasterizer.rasterize(tex));
      final b = await tester.runAsync(() => rasterizer.rasterize(tex));
      expect(identical(a, b), isTrue);
    });

    testWidgets('different expressions both produce valid PNG', (tester) async {
      final a = await tester.runAsync(() => rasterizer.rasterize(r'x^2'));
      final b = await tester.runAsync(() => rasterizer.rasterize(r'x^3'));
      // KaTeX fonts don't load in the headless test pipeline, so both
      // expressions may render as an identical blank image.  We verify
      // only that each produces a valid, non-empty PNG.
      expect(a, isNotEmpty);
      expect(b, isNotEmpty);
      expect(a!.sublist(0, 4), [0x89, 0x50, 0x4E, 0x47]);
      expect(b!.sublist(0, 4), [0x89, 0x50, 0x4E, 0x47]);
    });

    testWidgets('invalid TeX throws MathRasterizeError', (tester) async {
      // parseError is detected synchronously — no runAsync needed.
      expect(
        () => rasterizer.rasterize(r'\invaliddcommand{broken'),
        throwsA(isA<MathRasterizeError>()),
      );
    });

    testWidgets('MathRasterizeError has a non-empty message', (tester) async {
      try {
        await rasterizer.rasterize(r'\invaliddcommand{broken');
        fail('Expected MathRasterizeError');
      } on MathRasterizeError catch (e) {
        expect(e.message, isNotEmpty);
        expect(e.toString(), contains('MathRasterizeError'));
      }
    });

    testWidgets('display style produces non-empty PNG', (tester) async {
      final bytes = await tester.runAsync(() => rasterizer.rasterize(
            r'\int_0^\infty e^{-x}\,dx',
            style: MathStyle.display,
            fontSize: 20,
          ));
      expect(bytes, isNotEmpty);
      expect(bytes!.sublist(0, 4), [0x89, 0x50, 0x4E, 0x47]);
    });

    testWidgets('cache key includes style — text vs display differ',
        (tester) async {
      const tex = r'\sum_{n=1}^{\infty}';
      final text =
          await tester.runAsync(() => rasterizer.rasterize(tex));
      final display =
          await tester.runAsync(() => rasterizer.rasterize(tex, style: MathStyle.display));
      expect(identical(text, display), isFalse);
    });
  });
}
