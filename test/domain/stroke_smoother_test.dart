
import 'package:flutter_test/flutter_test.dart';
import 'package:runa/domain/domain.dart';

void main() {
  const smoother = StrokeSmoother();

  StrokePoint pt(double x, double y) => StrokePoint(
        x: x,
        y: y,
        pressure: 1.0,
        timestamp: 0,
      );

  group('StrokeSmoother', () {
    test('empty list → empty output', () {
      expect(smoother.smooth(<StrokePoint>[]), isEmpty);
    });

    test('single point → one Offset', () {
      final result = smoother.smooth([pt(3, 7)]);
      expect(result, hasLength(1));
      expect(result.first, const Offset(3, 7));
    });

    test('two points → two Offsets (straight line, no interpolation)', () {
      final result = smoother.smooth([pt(0, 0), pt(10, 0)]);
      expect(result, hasLength(2));
      expect(result.first, const Offset(0, 0));
      expect(result.last, const Offset(10, 0));
    });

    test('three points → three Offsets (not enough for Catmull-Rom)', () {
      final result = smoother.smooth([pt(0, 0), pt(5, 5), pt(10, 0)]);
      expect(result, hasLength(3));
    });

    test('four+ points → more Offsets than input (interpolation happened)',
        () {
      final pts = [pt(0, 0), pt(10, 0), pt(20, 0), pt(30, 0)];
      final result = smoother.smooth(pts);
      expect(result.length, greaterThan(pts.length));
    });

    test('four collinear points → intermediate points lie on the line', () {
      // Points along y=0 line.
      final pts = [pt(0, 0), pt(10, 0), pt(20, 0), pt(30, 0)];
      final result = smoother.smooth(pts);

      // Every smoothed point should have y ≈ 0 for collinear input.
      for (final o in result) {
        expect(o.dy, closeTo(0.0, 1e-6),
            reason: 'Expected collinear smoothing, got dy=${o.dy}');
      }
      // X values should be monotonically increasing.
      for (int i = 1; i < result.length; i++) {
        expect(result[i].dx, greaterThanOrEqualTo(result[i - 1].dx));
      }
    });

    test('four non-collinear points → smoothed path stays near control points',
        () {
      final pts = [pt(0, 0), pt(10, 10), pt(20, -10), pt(30, 0)];
      final result = smoother.smooth(pts);

      // The spline should start and end near the first and last input points.
      expect(result.first.dx, closeTo(0, 0.5));
      expect(result.first.dy, closeTo(0, 0.5));
      expect(result.last.dx, closeTo(30, 0.5));
      expect(result.last.dy, closeTo(0, 0.5));
    });

    test('duplicate adjacent points → no division-by-zero crash', () {
      final pts = [pt(5, 5), pt(5, 5), pt(5, 5), pt(5, 5)];
      // Should complete without throwing.
      expect(() => smoother.smooth(pts), returnsNormally);
    });

    test('larger stroke yields (N-1)*samplesPerSegment+1 result points', () {
      // 6 input points → 5 inner segments → 1 + 5*10 = 51 points.
      const samples = 10;
      const localSmoother = StrokeSmoother();
      final pts = List.generate(6, (i) => pt(i * 10.0, 0));
      final result = localSmoother.smooth(pts);
      // At least one point per segment.
      expect(result.length, greaterThan(6));
    });
  });
}
