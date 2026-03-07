import 'package:freezed_annotation/freezed_annotation.dart';

import 'stroke.dart';

part 'block.freezed.dart';
part 'block.g.dart';

/// A content block within a [Document].
///
/// Discriminated by the [type] field in JSON (`"markdown"` or `"ink"`).
/// Use pattern matching to access subtype-specific fields:
///
/// ```dart
/// switch (block) {
///   case MarkdownBlock(:final content) => print(content);
///   case InkBlock(:final strokes) => print(strokes.length);
/// }
/// ```
@Freezed(unionKey: 'type')
sealed class Block with _$Block {
  /// A block of raw Markdown text.
  @FreezedUnionValue('markdown')
  @JsonSerializable(explicitToJson: true)
  const factory Block.markdown({
    /// Unique block identifier (UUID v4).
    required String id,

    /// Raw Markdown content. Empty string is valid (new empty block).
    required String content,
  }) = MarkdownBlock;

  /// A block containing freehand ink strokes drawn on a canvas.
  @FreezedUnionValue('ink')
  @JsonSerializable(explicitToJson: true)
  const factory Block.ink({
    /// Unique block identifier (UUID v4).
    required String id,

    /// Canvas height in logical pixels. Must be positive.
    required double height,

    /// Ink strokes in draw order (painter's algorithm). May be empty.
    @Default([]) List<Stroke> strokes,
  }) = InkBlock;

  factory Block.fromJson(Map<String, dynamic> json) => _$BlockFromJson(json);
}
