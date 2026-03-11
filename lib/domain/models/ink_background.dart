import 'package:freezed_annotation/freezed_annotation.dart';

/// The background pattern rendered behind ink strokes in an [InkBlock].
@JsonEnum()
enum InkBackground {
  /// No background lines (default).
  plain,

  /// Horizontal ruled lines separated by [InkBlock.backgroundSpacing].
  ruled,

  /// Horizontal and vertical grid lines.
  grid,

  /// Dots at grid intersections.
  dotted,

  /// Isometric triangular tessellation.
  isometric,
}
