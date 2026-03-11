import 'package:freezed_annotation/freezed_annotation.dart';

import 'ink_background.dart';
import 'stroke.dart';
import 'text_element.dart';

part 'block.freezed.dart';
part 'block.g.dart';

/// A content block within a [Document].
///
/// Discriminated by the [type] field in JSON:
/// `"markdown"`, `"ink"`, `"image"`, or `"pdf_page"`.
///
/// Use pattern matching to access subtype-specific fields:
///
/// ```dart
/// switch (block) {
///   case MarkdownBlock(:final content) => print(content);
///   case InkBlock(:final strokes) => print(strokes.length);
///   case ImageBlock(:final path) => print(path);
///   case PdfPageBlock(:final path) => print(path);
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

    /// Background pattern rendered behind the strokes.
    @Default(InkBackground.plain) InkBackground background,

    /// Spacing between background lines/dots in logical pixels.
    @Default(24.0) double backgroundSpacing,

    /// Explicit line color in `#RRGGBBAA` format. When null, the theme
    /// default (outlineVariant at 20% opacity) is used.
    String? backgroundLineColor,

    /// Canvas fill color in `#RRGGBBAA` format. When null the canvas is
    /// transparent (shows the widget background / theme surface).
    String? backgroundColor,

    /// Typographic text elements placed on the canvas.
    @Default([]) List<TextElement> textElements,
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

  /// A block displaying one page of a PDF with an ink annotation layer.
  ///
  /// Multiple [PdfPageBlock]s sharing the same [path] represent pages from the
  /// same PDF. Any block type may be inserted between them.
  ///
  /// [path] is a relative path from the `.runa` file, e.g. `_assets/doc.pdf`.
  /// [pageIndex] is 0-based. [pageWidth] and [pageHeight] are in PDF points.
  @FreezedUnionValue('pdf_page')
  @JsonSerializable(explicitToJson: true)
  const factory Block.pdfPage({
    /// Unique block identifier (UUID v4).
    required String id,

    /// Relative path to the PDF asset (e.g. `_assets/doc.pdf`).
    required String path,

    /// Zero-based index of the PDF page this block represents.
    required int pageIndex,

    /// Width of the page in PDF points, as reported by the renderer.
    @Default(0.0) double pageWidth,

    /// Height of the page in PDF points, as reported by the renderer.
    @Default(0.0) double pageHeight,

    /// Ink annotation strokes drawn on this page.
    @Default([]) List<Stroke> strokes,
  }) = PdfPageBlock;

  factory Block.fromJson(Map<String, dynamic> json) => _$BlockFromJson(json);
}
