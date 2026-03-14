import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:pdf/widgets.dart' as pw;
import 'package:pdfrx/pdfrx.dart';
import 'package:runa/domain/domain.dart';

import 'ink_pdf_renderer.dart';

/// Rasterizes a PDF page from a [PdfDocument] (opened with pdfrx) and returns
/// a [pw.Widget] for embedding in the exported PDF.
///
/// Ink [strokes] (normalised [0,1] coordinates) are overlaid as vector paths
/// on top of the rasterized page image using [InkPdfRenderer.renderNormalized].
class PdfPagePdfRenderer {
  PdfPagePdfRenderer({InkPdfRenderer? inkRenderer})
      : _inkRenderer = inkRenderer ?? InkPdfRenderer();

  final InkPdfRenderer _inkRenderer;

  /// Available width in the output PDF (A4 with 2 cm margins).
  static const double _pdfContentWidth = 460.0;

  /// Pixel ratio for rasterization — 2× gives ≈144 DPI on A4 content width.
  static const double _pixelRatio = 2.0;

  /// Renders page [pageIndex] of the already-open [doc].
  ///
  /// [pageWidth] / [pageHeight] are the stored PDF-point dimensions from the
  /// [PdfPageBlock] (populated at import time). Falls back to the page's own
  /// dimensions if either value is zero.
  ///
  /// Returns `null` on any error so the exporter can silently skip the block.
  Future<pw.Widget?> render(
    PdfDocument doc,
    int pageIndex,
    double pageWidth,
    double pageHeight,
    List<Stroke> strokes,
  ) async {
    try {
      if (pageIndex < 0 || pageIndex >= doc.pages.length) return null;

      final page = doc.pages[pageIndex];

      // Prefer stored dimensions (matches the aspect ratio used when the user
      // annotated the page). Fall back to pdfrx's intrinsic values.
      final w = pageWidth > 0 ? pageWidth : page.width;
      final h = pageHeight > 0 ? pageHeight : page.height;

      // Scale to fill the output PDF's content width.
      final scale = _pdfContentWidth / w;
      final pdfHeight = h * scale;

      // Render at _pixelRatio × logical size for crisp text/graphics.
      final renderW = (w * scale * _pixelRatio).round();
      final renderH = (h * scale * _pixelRatio).round();

      final pngBytes = await _renderToPng(page, renderW, renderH);
      if (pngBytes == null) return null;

      final imageWidget = pw.Image(
        pw.MemoryImage(pngBytes),
        width: _pdfContentWidth,
        height: pdfHeight,
        fit: pw.BoxFit.fill,
      );

      if (strokes.isEmpty) return imageWidget;

      // Overlay ink annotations (normalised coords → de-normalised in PDF space).
      final inkWidget = _inkRenderer.renderNormalized(
        strokes,
        naturalWidth: w,
        naturalHeight: h,
      );

      return pw.Stack(children: [imageWidget, inkWidget]);
    } catch (_) {
      return null;
    }
  }

  /// Calls [pdfrx]'s page.render() and encodes the raw BGRA pixels as PNG.
  Future<Uint8List?> _renderToPng(PdfPage page, int width, int height) async {
    final pdfImage = await page.render(
      width: width,
      height: height,
      fullWidth: width.toDouble(),
      fullHeight: height.toDouble(),
    );
    if (pdfImage == null) return null;

    try {
      // PdfImageExt.createImage() (from pdfrx_flutter.dart) decodes the raw
      // BGRA8888 pixels into a dart:ui Image via decodeImageFromPixels().
      final uiImage = await pdfImage.createImage();
      try {
        final byteData =
            await uiImage.toByteData(format: ui.ImageByteFormat.png);
        return byteData?.buffer.asUint8List();
      } finally {
        uiImage.dispose();
      }
    } finally {
      pdfImage.dispose();
    }
  }
}
