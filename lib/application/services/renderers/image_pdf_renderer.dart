import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:runa/domain/domain.dart';
import 'ink_pdf_renderer.dart';

class ImagePdfRenderer {
  ImagePdfRenderer({InkPdfRenderer? inkRenderer})
      : _inkRenderer = inkRenderer ?? InkPdfRenderer();

  final InkPdfRenderer _inkRenderer;
  static const double _pdfContentWidth = 460.0;

  /// Returns a stack of [image + ink overlay], or null if image can't be loaded.
  Future<pw.Widget?> render(
    String absolutePath,
    double naturalWidth,
    double naturalHeight,
    List<Stroke> strokes,
  ) async {
    try {
      final file = File(absolutePath);
      if (!file.existsSync()) return null;
      final bytes = await file.readAsBytes();

      final ext = absolutePath.toLowerCase();
      // pdf package supports PNG and JPEG natively
      if (!ext.endsWith('.png') &&
          !ext.endsWith('.jpg') &&
          !ext.endsWith('.jpeg')) {
        // Unsupported format: render placeholder
        return pw.Text(
          '[Image: $absolutePath]',
          style: pw.TextStyle(
            font: pw.Font.helveticaOblique(),
            color: PdfColors.grey600,
            fontSize: 10,
          ),
        );
      }

      final image = pw.MemoryImage(bytes);
      final scale = _pdfContentWidth / naturalWidth;
      final pdfHeight = naturalHeight * scale;

      final imageWidget = pw.Image(
        image,
        width: _pdfContentWidth,
        height: pdfHeight,
        fit: pw.BoxFit.fill,
      );

      if (strokes.isEmpty) return imageWidget;

      // Overlay ink strokes
      final inkWidget = _inkRenderer.renderNormalized(
        strokes,
        naturalWidth: naturalWidth,
        naturalHeight: naturalHeight,
      );

      return pw.Stack(children: [imageWidget, inkWidget]);
    } catch (_) {
      return null;
    }
  }
}
