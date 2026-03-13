import 'package:freezed_annotation/freezed_annotation.dart';

import 'shape_type.dart';

part 'shape_element.freezed.dart';
part 'shape_element.g.dart';

/// A geometric shape placed on an [InkBlock] canvas.
///
/// [x1],[y1],[x2],[y2] are normalised to [0.0, 1.0] relative to canvas size.
@freezed
class ShapeElement with _$ShapeElement {
  const factory ShapeElement({
    required String id,
    required ShapeType type,
    required double x1,
    required double y1,
    required double x2,
    required double y2,
    @Default('#000000FF') String color,
    @Default(2.0) double strokeWidth,
    @Default(false) bool filled,
    String? fillColor,
  }) = _ShapeElement;

  factory ShapeElement.fromJson(Map<String, dynamic> json) =>
      _$ShapeElementFromJson(json);
}
