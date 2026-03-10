import 'dart:typed_data';
import 'package:path/path.dart' as p;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:runa/domain/domain.dart';

import 'renderers/image_pdf_renderer.dart';
import 'renderers/ink_pdf_renderer.dart';
import 'renderers/markdown_pdf_renderer.dart';

class PdfExporter {
  PdfExporter({
    MarkdownPdfRenderer? markdownRenderer,
    InkPdfRenderer? inkRenderer,
    ImagePdfRenderer? imageRenderer,
  })  : _markdownRenderer = markdownRenderer ?? MarkdownPdfRenderer(),
        _inkRenderer = inkRenderer ?? InkPdfRenderer(),
        _imageRenderer = imageRenderer ?? ImagePdfRenderer();

  final MarkdownPdfRenderer _markdownRenderer;
  final InkPdfRenderer _inkRenderer;
  final ImagePdfRenderer _imageRenderer;

  /// Exports [document] to PDF bytes.
  ///
  /// [documentPath] is the absolute path to the `.runa` file, used to resolve
  /// relative asset paths.
  Future<Uint8List> export(
    Document document, {
    required String documentPath,
  }) async {
    final doc = pw.Document(
      title: p.basenameWithoutExtension(documentPath),
    );

    final contentWidgets = <pw.Widget>[];

    for (final block in document.blocks) {
      switch (block) {
        case MarkdownBlock(:final content):
          if (content.trim().isNotEmpty) {
            contentWidgets.addAll(_markdownRenderer.render(content));
            contentWidgets.add(pw.SizedBox(height: 8));
          }
        case InkBlock(:final strokes, :final height):
          if (strokes.isNotEmpty) {
            contentWidgets.add(
              _inkRenderer.render(strokes, inkHeight: height),
            );
            contentWidgets.add(pw.SizedBox(height: 8));
          }
        case ImageBlock(
            :final path,
            :final naturalWidth,
            :final naturalHeight,
            :final strokes,
          ):
          final absPath = p.join(p.dirname(documentPath), path);
          final widget = await _imageRenderer.render(
            absPath,
            naturalWidth,
            naturalHeight,
            strokes,
          );
          if (widget != null) {
            contentWidgets.add(widget);
            contentWidgets.add(pw.SizedBox(height: 8));
          }
        case PdfPageBlock(:final path, :final pageIndex):
          contentWidgets.add(
            pw.Container(
              padding: const pw.EdgeInsets.all(8),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey300),
                borderRadius:
                    const pw.BorderRadius.all(pw.Radius.circular(4)),
              ),
              child: pw.Text(
                'PDF: ${p.basename(path)}, page ${pageIndex + 1}',
                style: pw.TextStyle(
                  font: pw.Font.helveticaOblique(),
                  color: PdfColors.grey600,
                  fontSize: 10,
                ),
              ),
            ),
          );
          contentWidgets.add(pw.SizedBox(height: 8));
      }
    }

    if (contentWidgets.isEmpty) {
      contentWidgets.add(
        pw.Text(
          '(Documento vacío)',
          style: pw.TextStyle(
            font: pw.Font.helveticaOblique(),
            color: PdfColors.grey500,
          ),
        ),
      );
    }

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(56.69), // 2 cm
        build: (context) => contentWidgets,
      ),
    );

    return doc.save();
  }
}
