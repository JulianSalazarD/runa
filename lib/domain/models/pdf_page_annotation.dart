import 'package:freezed_annotation/freezed_annotation.dart';

import 'stroke.dart';

part 'pdf_page_annotation.freezed.dart';
part 'pdf_page_annotation.g.dart';

/// Annotations (ink strokes) for a single page of a [PdfBlock].
///
/// Stroke coordinates are normalised to `[0.0, 1.0]` relative to
/// [pageWidth] × [pageHeight] (in points), matching the convention used
/// by [ImageBlock].
@freezed
class PdfPageAnnotation with _$PdfPageAnnotation {
  @JsonSerializable(explicitToJson: true)
  const factory PdfPageAnnotation({
    /// Zero-based index of the PDF page this annotation belongs to.
    required int pageIndex,

    /// Width of the page in points (pt) as reported by the PDF renderer.
    required double pageWidth,

    /// Height of the page in points (pt) as reported by the PDF renderer.
    required double pageHeight,

    /// Ink strokes drawn on this page, in draw order (painter's algorithm).
    @Default([]) List<Stroke> strokes,
  }) = _PdfPageAnnotation;

  factory PdfPageAnnotation.fromJson(Map<String, dynamic> json) =>
      _$PdfPageAnnotationFromJson(json);
}
