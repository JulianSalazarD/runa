import 'dart:typed_data';
import 'package:path/path.dart' as p;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdfrx/pdfrx.dart' as pdfrx;
import 'package:runa/domain/domain.dart';

import 'renderers/image_pdf_renderer.dart';
import 'renderers/ink_pdf_renderer.dart';
import 'renderers/markdown_pdf_renderer.dart';
import 'renderers/pdf_page_pdf_renderer.dart';

class PdfExporter {
  PdfExporter({
    MarkdownPdfRenderer? markdownRenderer,
    InkPdfRenderer? inkRenderer,
    ImagePdfRenderer? imageRenderer,
    PdfPagePdfRenderer? pdfPageRenderer,
  })  : _markdownRenderer = markdownRenderer ?? MarkdownPdfRenderer(),
        _inkRenderer = inkRenderer ?? InkPdfRenderer(),
        _imageRenderer = imageRenderer ?? ImagePdfRenderer(),
        _pdfPageRenderer = pdfPageRenderer ?? PdfPagePdfRenderer();

  final MarkdownPdfRenderer _markdownRenderer;
  final InkPdfRenderer _inkRenderer;
  final ImagePdfRenderer _imageRenderer;
  final PdfPagePdfRenderer _pdfPageRenderer;

  /// Exports [document] to PDF bytes.
  ///
  /// [documentPath] is the absolute path to the `.runa` file, used to resolve
  /// relative asset paths stored inside blocks.
  ///
  /// [onProgress] is called after each block is processed with the current
  /// block index (0-based) and the total block count.
  Future<Uint8List> export(
    Document document, {
    required String documentPath,
    void Function(int current, int total)? onProgress,
  }) async {
    final doc = pw.Document(
      title: p.basenameWithoutExtension(documentPath),
    );

    final contentWidgets = <pw.Widget>[];

    // Cache of open PdfDocuments keyed by absolute path so we open each source
    // PDF at most once regardless of how many PdfPageBlocks it contains.
    final openDocs = <String, pdfrx.PdfDocument>{};

    try {
      final blocks = document.blocks;
      final total = blocks.length;

      for (var i = 0; i < total; i++) {
        onProgress?.call(i, total);
        final block = blocks[i];

        switch (block) {
          case MarkdownBlock(:final content):
            if (content.trim().isNotEmpty) {
              contentWidgets.addAll(await _markdownRenderer.render(content));
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

          case PdfPageBlock(
              :final path,
              :final pageIndex,
              :final pageWidth,
              :final pageHeight,
              :final strokes,
            ):
            try {
              final absPath = p.join(p.dirname(documentPath), path);
              // Open the source PDF lazily; reuse across blocks from same file.
              openDocs[absPath] ??= await pdfrx.PdfDocument.openFile(absPath);
              final widget = await _pdfPageRenderer.render(
                openDocs[absPath]!,
                pageIndex,
                pageWidth,
                pageHeight,
                strokes,
              );
              if (widget != null) {
                contentWidgets.add(widget);
                contentWidgets.add(pw.SizedBox(height: 8));
              }
            } catch (_) {
              // Skip unreadable PDF pages rather than aborting the export.
            }
        }
      }

      onProgress?.call(total, total);
    } finally {
      // Always close every source PDF we opened.
      for (final openDoc in openDocs.values) {
        await openDoc.dispose();
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
