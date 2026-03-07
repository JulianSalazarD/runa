import 'package:flutter_test/flutter_test.dart';
import 'package:runa/domain/domain.dart';

void main() {
  const point = StrokePoint(x: 10.0, y: 20.0, pressure: 0.5, timestamp: 1000);

  group('StrokePoint — JSON round-trip', () {
    test('toJson produces correct keys', () {
      final json = point.toJson();
      expect(json['x'], 10.0);
      expect(json['y'], 20.0);
      expect(json['pressure'], 0.5);
      expect(json['timestamp'], 1000);
    });

    test('fromJson restores all fields', () {
      final json = point.toJson();
      final restored = StrokePoint.fromJson(json);
      expect(restored.x, 10.0);
      expect(restored.y, 20.0);
      expect(restored.pressure, 0.5);
      expect(restored.timestamp, 1000);
    });

    test('round-trip equality', () {
      expect(StrokePoint.fromJson(point.toJson()), point);
    });

    test('fromJson accepts integer coordinates', () {
      final json = {'x': 5, 'y': 10, 'pressure': 0.5, 'timestamp': 0};
      final p = StrokePoint.fromJson(json);
      expect(p.x, 5.0);
      expect(p.y, 10.0);
    });

    test('fromJson accepts pressure boundary values', () {
      final p0 = StrokePoint.fromJson({'x': 0, 'y': 0, 'pressure': 0.0, 'timestamp': 0});
      final p1 = StrokePoint.fromJson({'x': 0, 'y': 0, 'pressure': 1.0, 'timestamp': 0});
      expect(p0.pressure, 0.0);
      expect(p1.pressure, 1.0);
    });
  });

  group('StrokePoint — copyWith', () {
    test('copyWith changes only specified fields', () {
      final moved = point.copyWith(x: 99.0);
      expect(moved.x, 99.0);
      expect(moved.y, point.y);
      expect(moved.pressure, point.pressure);
      expect(moved.timestamp, point.timestamp);
    });

    test('copyWith with no args returns equal object', () {
      expect(point.copyWith(), point);
    });
  });

  group('StrokePoint — equality & hashCode', () {
    test('two identical StrokePoints are equal', () {
      const other = StrokePoint(x: 10.0, y: 20.0, pressure: 0.5, timestamp: 1000);
      expect(point, other);
      expect(point.hashCode, other.hashCode);
    });

    test('different x → not equal', () {
      expect(point, isNot(point.copyWith(x: 0.0)));
    });

    test('different timestamp → not equal', () {
      expect(point, isNot(point.copyWith(timestamp: 9999)));
    });
  });
}
