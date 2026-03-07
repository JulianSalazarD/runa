import 'package:flutter_test/flutter_test.dart';
import 'package:runa/domain/domain.dart';

const _point = StrokePoint(x: 5.0, y: 10.0, pressure: 0.6, timestamp: 500);

const _stroke = Stroke(
  id: '00000000-0000-0003-0000-000000000001',
  color: '#000000FF',
  width: 2.0,
  tool: StrokeTool.pen,
  points: [_point],
);

void main() {
  group('StrokeTool — JSON serialization', () {
    test('pen serializes as "pen"', () {
      final s = _stroke.copyWith(tool: StrokeTool.pen);
      expect(s.toJson()['tool'], 'pen');
    });

    test('marker serializes as "marker"', () {
      final s = _stroke.copyWith(tool: StrokeTool.marker);
      expect(s.toJson()['tool'], 'marker');
    });

    test('eraser serializes as "eraser"', () {
      final s = _stroke.copyWith(tool: StrokeTool.eraser);
      expect(s.toJson()['tool'], 'eraser');
    });

    test('fromJson deserializes tool enum', () {
      final json = _stroke.toJson()..['tool'] = 'pencil';
      final restored = Stroke.fromJson(json);
      expect(restored.tool, StrokeTool.pencil);
    });
  });

  group('Stroke — JSON round-trip', () {
    test('toJson contains all expected keys', () {
      final json = _stroke.toJson();
      expect(json['id'], _stroke.id);
      expect(json['color'], '#000000FF');
      expect(json['width'], 2.0);
      expect(json['tool'], 'pen');
      expect(json['points'], isList);
      expect((json['points'] as List).length, 1);
    });

    test('points are serialized as maps', () {
      final pointJson = (_stroke.toJson()['points'] as List)[0] as Map;
      expect(pointJson['x'], 5.0);
      expect(pointJson['pressure'], 0.6);
    });

    test('round-trip equality', () {
      expect(Stroke.fromJson(_stroke.toJson()), _stroke);
    });

    test('round-trip with multiple points', () {
      const s = Stroke(
        id: '00000000-0000-0003-0000-000000000002',
        color: '#FF0000FF',
        width: 4.0,
        tool: StrokeTool.marker,
        points: [
          StrokePoint(x: 0.0, y: 0.0, pressure: 0.5, timestamp: 0),
          StrokePoint(x: 10.0, y: 10.0, pressure: 0.8, timestamp: 16),
          StrokePoint(x: 20.0, y: 5.0, pressure: 0.3, timestamp: 32),
        ],
      );
      expect(Stroke.fromJson(s.toJson()), s);
    });

    test('round-trip with empty points list', () {
      // A stroke with zero points is unusual but representable at the model level.
      const s = Stroke(
        id: '00000000-0000-0003-0000-000000000003',
        color: '#000000FF',
        width: 1.0,
        tool: StrokeTool.pen,
        points: [],
      );
      expect(Stroke.fromJson(s.toJson()), s);
    });
  });

  group('Stroke — copyWith', () {
    test('copyWith changes color only', () {
      final red = _stroke.copyWith(color: '#FF0000FF');
      expect(red.color, '#FF0000FF');
      expect(red.id, _stroke.id);
      expect(red.tool, _stroke.tool);
    });

    test('copyWith with no args returns equal stroke', () {
      expect(_stroke.copyWith(), _stroke);
    });
  });

  group('Stroke — equality & hashCode', () {
    test('identical strokes are equal', () {
      const other = Stroke(
        id: '00000000-0000-0003-0000-000000000001',
        color: '#000000FF',
        width: 2.0,
        tool: StrokeTool.pen,
        points: [_point],
      );
      expect(_stroke, other);
      expect(_stroke.hashCode, other.hashCode);
    });

    test('different id → not equal', () {
      final other = _stroke.copyWith(id: '00000000-0000-0003-0000-000000000099');
      expect(_stroke, isNot(other));
    });

    test('different color → not equal', () {
      expect(_stroke, isNot(_stroke.copyWith(color: '#FFFFFFFF')));
    });
  });
}
