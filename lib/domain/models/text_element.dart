import 'package:freezed_annotation/freezed_annotation.dart';

part 'text_element.freezed.dart';
part 'text_element.g.dart';

/// A typographic text element placed on an [InkBlock] canvas.
///
/// [x] and [y] are normalised to `[0.0, 1.0]` relative to the canvas size.
@freezed
abstract class TextElement with _$TextElement {
  const factory TextElement({
    required String id,
    required double x,
    required double y,
    required String content,
    @Default(16.0) double fontSize,
    @Default('#000000FF') String color,
    String? fontFamily,
    @Default(false) bool bold,
    @Default(false) bool italic,
  }) = _TextElement;

  factory TextElement.fromJson(Map<String, dynamic> json) =>
      _$TextElementFromJson(json);
}
