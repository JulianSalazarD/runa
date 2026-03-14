import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:pdf/widgets.dart' as pw;
import 'package:pdfrx/pdfrx.dart' as pdfrx;
import 'package:runa/application/services/renderers/pdf_page_pdf_renderer.dart';
import 'package:runa/domain/domain.dart';

// ---------------------------------------------------------------------------
// Helper: create a minimal PDF with [pageCount] blank pages using the `pdf`
// package so tests have a real PDF without external fixtures.
// ---------------------------------------------------------------------------
Future<String> _createTestPdf(int pageCount, Directory dir) async {
  final doc = pw.Document();
  for (var i = 0; i < pageCount; i++) {
    doc.addPage(pw.Page(
      build: (ctx) => pw.Center(child: pw.Text('Page ${i + 1}')),
    ));
  }
  final file = File(p.join(dir.path, 'test_$pageCount.pdf'));
  await file.writeAsBytes(await doc.save());
  return file.path;
}

void main() {
  // Every operation in these tests involves real async I/O (file write/read,
  // pdfrx native rendering, dart:ui GPU calls).  Inside testWidgets the event
  // loop is FakeAsync, so ALL such work must be wrapped with tester.runAsync().

  group('PdfPagePdfRenderer', () {
    late PdfPagePdfRenderer renderer;
    late Directory tempDir;

    setUp(() async {
      renderer = PdfPagePdfRenderer();
      // setUp runs outside FakeAsync — real I/O is fine here.
      tempDir =
          await Directory.systemTemp.createTemp('pdf_page_renderer_test');
      // pdfrx requires getCacheDirectory to be set before openFile() is called.
      pdfrx.Pdfrx.getCacheDirectory = () => Future.value(tempDir.path);
    });

    tearDown(() async {
      // tearDown also runs outside FakeAsync.
      await tempDir.delete(recursive: true);
    });

    testWidgets('page 0 without strokes returns pw.Image', (tester) async {
      final widget = await tester.runAsync(() async {
        final pdfPath = await _createTestPdf(1, tempDir);
        final doc = await pdfrx.PdfDocument.openFile(pdfPath);
        try {
          return await renderer.render(doc, 0, 595.28, 841.89, const []);
        } finally {
          await doc.dispose();
        }
      });
      expect(widget, isNotNull);
      expect(widget, isA<pw.Image>());
    });

    testWidgets('page 0 with one stroke returns pw.Stack', (tester) async {
      const stroke = Stroke(
        id: 'test-stroke',
        color: '#000000FF',
        width: 2.0,
        tool: StrokeTool.pen,
        points: [
          StrokePoint(x: 0.5, y: 0.5, pressure: 0.5, timestamp: 0),
          StrokePoint(x: 0.6, y: 0.6, pressure: 0.5, timestamp: 1),
        ],
      );
      final widget = await tester.runAsync(() async {
        final pdfPath = await _createTestPdf(1, tempDir);
        final doc = await pdfrx.PdfDocument.openFile(pdfPath);
        try {
          return await renderer.render(doc, 0, 595.28, 841.89, [stroke]);
        } finally {
          await doc.dispose();
        }
      });
      expect(widget, isNotNull);
      expect(widget, isA<pw.Stack>());
    });

    testWidgets('renders all 3 pages of a 3-page PDF', (tester) async {
      final results = await tester.runAsync(() async {
        final pdfPath = await _createTestPdf(3, tempDir);
        final doc = await pdfrx.PdfDocument.openFile(pdfPath);
        try {
          expect(doc.pages.length, 3);
          return [
            for (var i = 0; i < 3; i++)
              await renderer.render(doc, i, 595.28, 841.89, const []),
          ];
        } finally {
          await doc.dispose();
        }
      });
      expect(results, isNotNull);
      for (final w in results!) {
        expect(w, isNotNull);
      }
    });

    testWidgets('out-of-range page index returns null', (tester) async {
      final widget = await tester.runAsync(() async {
        final pdfPath = await _createTestPdf(1, tempDir);
        final doc = await pdfrx.PdfDocument.openFile(pdfPath);
        try {
          return await renderer.render(doc, 99, 595.28, 841.89, const []);
        } finally {
          await doc.dispose();
        }
      });
      expect(widget, isNull);
    });

    testWidgets('zero stored dims falls back to page intrinsic size',
        (tester) async {
      final widget = await tester.runAsync(() async {
        final pdfPath = await _createTestPdf(1, tempDir);
        final doc = await pdfrx.PdfDocument.openFile(pdfPath);
        try {
          return await renderer.render(doc, 0, 0, 0, const []);
        } finally {
          await doc.dispose();
        }
      });
      expect(widget, isNotNull);
    });
  });
}
