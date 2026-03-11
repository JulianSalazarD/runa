import 'package:freezed_annotation/freezed_annotation.dart';

import 'stroke_point.dart';

part 'stroke.freezed.dart';
part 'stroke.g.dart';

/// The tool that produced an ink stroke. Affects rendering style.
@JsonEnum()
enum StrokeTool { pen, pencil, marker, eraser, text }

/// A single continuous ink stroke composed of [StrokePoint]s.
@freezed
class Stroke with _$Stroke {
  @JsonSerializable(explicitToJson: true)
  const factory Stroke({
    /// Unique stroke identifier (UUID v4).
    required String id,

    /// Color in #RRGGBBAA format (e.g. "#000000FF" = opaque black).
    required String color,

    /// Base stroke width in logical pixels before pressure scaling.
    required double width,

    /// Tool that produced this stroke.
    required StrokeTool tool,

    /// Ordered sequence of input points. At least one point is required.
    required List<StrokePoint> points,
  }) = _Stroke;

  factory Stroke.fromJson(Map<String, dynamic> json) => _$StrokeFromJson(json);
}
