import 'dart:math' as math;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:runa/domain/domain.dart';

class InkPdfRenderer {
  /// Reference logical pixel width (typical Flutter desktop content width).
  static const double _referenceWidth = 800.0;

  /// Renders [strokes] from an [InkBlock] (raw logical pixel coordinates).
  ///
  /// [inkHeight] is `block.height` in logical pixels.
  /// [pdfContentWidth] is the available PDF page width (default A4 content area).
  pw.Widget render(
    List<Stroke> strokes, {
    required double inkHeight,
    double pdfContentWidth = 460.0,
  }) {
    if (strokes.isEmpty) return pw.SizedBox.shrink();

    final scale = pdfContentWidth / _referenceWidth;
    final pdfHeight = math.max(inkHeight * scale, 1.0);

    return pw.CustomPaint(
      size: PdfPoint(pdfContentWidth, pdfHeight),
      painter: (canvas, size) {
        for (final stroke in strokes) {
          if (stroke.tool == StrokeTool.eraser) continue;
          if (stroke.points.isEmpty) continue;
          _drawStroke(canvas, stroke, size, scale);
        }
      },
    );
  }

  /// Renders [strokes] from an [ImageBlock] or [PdfPageBlock].
  ///
  /// Coordinates are normalized [0.0, 1.0]. [naturalWidth]/[naturalHeight]
  /// are the original dimensions in logical pixels.
  pw.Widget renderNormalized(
    List<Stroke> strokes, {
    required double naturalWidth,
    required double naturalHeight,
    double pdfContentWidth = 460.0,
  }) {
    if (strokes.isEmpty) return pw.SizedBox.shrink();

    final scale = pdfContentWidth / naturalWidth;
    final pdfHeight = math.max(naturalHeight * scale, 1.0);

    return pw.CustomPaint(
      size: PdfPoint(pdfContentWidth, pdfHeight),
      painter: (canvas, size) {
        for (final stroke in strokes) {
          if (stroke.tool == StrokeTool.eraser) continue;
          if (stroke.points.isEmpty) continue;
          // De-normalize before drawing
          final denormalized = stroke.copyWith(
            points: stroke.points
                .map((p) => p.copyWith(
                      x: p.x * naturalWidth,
                      y: p.y * naturalHeight,
                    ))
                .toList(),
          );
          _drawStroke(canvas, denormalized, size, scale);
        }
      },
    );
  }

  void _drawStroke(
    PdfGraphics canvas,
    Stroke stroke,
    PdfPoint size,
    double scale,
  ) {
    final color = _parseColor(stroke.color);
    canvas
      ..setStrokeColor(color)
      ..setLineWidth(math.max(stroke.width * scale, 0.5))
      ..setLineCap(PdfLineCap.round)
      ..setLineJoin(PdfLineJoin.round);

    final pts = stroke.points;
    // PDF origin is bottom-left; Flutter is top-left → flip Y
    canvas.moveTo(pts.first.x * scale, size.y - pts.first.y * scale);
    for (final pt in pts.skip(1)) {
      canvas.lineTo(pt.x * scale, size.y - pt.y * scale);
    }
    canvas.strokePath();
  }

  PdfColor _parseColor(String hexColor) {
    // Format: #RRGGBBAA
    try {
      final hex = hexColor.replaceFirst('#', '');
      if (hex.length == 8) {
        final r = int.parse(hex.substring(0, 2), radix: 16) / 255.0;
        final g = int.parse(hex.substring(2, 4), radix: 16) / 255.0;
        final b = int.parse(hex.substring(4, 6), radix: 16) / 255.0;
        final a = int.parse(hex.substring(6, 8), radix: 16) / 255.0;
        return PdfColor(r, g, b, a);
      }
    } catch (_) {}
    return PdfColors.black;
  }
}
