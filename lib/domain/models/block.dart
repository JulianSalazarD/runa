import 'package:freezed_annotation/freezed_annotation.dart';

import 'pdf_page_annotation.dart';
import 'stroke.dart';

part 'block.freezed.dart';
part 'block.g.dart';

/// A content block within a [Document].
///
/// Discriminated by the [type] field in JSON:
/// `"markdown"`, `"ink"`, `"image"`, or `"pdf"`.
///
/// Use pattern matching to access subtype-specific fields:
///
/// ```dart
/// switch (block) {
///   case MarkdownBlock(:final content) => print(content);
///   case InkBlock(:final strokes) => print(strokes.length);
///   case ImageBlock(:final path) => print(path);
///   case PdfBlock(:final path) => print(path);
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

  /// A block displaying an image with an ink annotation layer on top.
  ///
  /// [path] is a relative path from the `.runa` file, e.g. `_assets/foto.png`.
  /// Stroke coordinates in [strokes] are normalised to `[0.0, 1.0]`
  /// relative to [naturalWidth] × [naturalHeight].
  @FreezedUnionValue('image')
  @JsonSerializable(explicitToJson: true)
  const factory Block.image({
    /// Unique block identifier (UUID v4).
    required String id,

    /// Relative path to the image asset (e.g. `_assets/foto.png`).
    required String path,

    /// Original image width in logical pixels (used for coordinate normalisation).
    required double naturalWidth,

    /// Original image height in logical pixels (used for coordinate normalisation).
    required double naturalHeight,

    /// Ink annotation strokes. Coordinates normalised to [0.0, 1.0].
    @Default([]) List<Stroke> strokes,
  }) = ImageBlock;

  /// A block displaying a PDF with per-page ink annotation layers.
  ///
  /// [path] is a relative path from the `.runa` file, e.g. `_assets/doc.pdf`.
  /// Each entry in [pages] holds the annotations for one PDF page.
  @FreezedUnionValue('pdf')
  @JsonSerializable(explicitToJson: true)
  const factory Block.pdf({
    /// Unique block identifier (UUID v4).
    required String id,

    /// Relative path to the PDF asset (e.g. `_assets/doc.pdf`).
    required String path,

    /// Per-page annotation data. One entry per annotated page; pages without
    /// annotations may be absent from the list.
    @Default([]) List<PdfPageAnnotation> pages,
  }) = PdfBlock;

  factory Block.fromJson(Map<String, dynamic> json) => _$BlockFromJson(json);
}
