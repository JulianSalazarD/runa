import 'package:freezed_annotation/freezed_annotation.dart';

part 'stroke_point.freezed.dart';
part 'stroke_point.g.dart';

/// A single sampled input point within a [Stroke].
@freezed
class StrokePoint with _$StrokePoint {
  const factory StrokePoint({
    /// X coordinate in logical pixels relative to the [InkBlock] canvas origin.
    required double x,

    /// Y coordinate in logical pixels relative to the [InkBlock] canvas origin.
    required double y,

    /// Normalised stylus/touch pressure in [0.0, 1.0].
    /// Use 0.5 when the device does not report pressure.
    required double pressure,

    /// Milliseconds since Unix epoch when this point was sampled.
    required int timestamp,
  }) = _StrokePoint;

  factory StrokePoint.fromJson(Map<String, dynamic> json) =>
      _$StrokePointFromJson(json);
}
