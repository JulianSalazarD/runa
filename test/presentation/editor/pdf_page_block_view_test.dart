import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:runa/domain/domain.dart';
import 'package:runa/presentation/editor/block_widget.dart';
import 'package:runa/presentation/editor/ink_toolbar_widget.dart';
import 'package:runa/presentation/editor/pdf_page_block_view.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Wraps [child] in a scrollable scaffold so the PDF page column does not
/// overflow the 800×600 test viewport.
Widget _wrap(Widget child) => MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(child: child),
      ),
    );

const _pdfPageBlock = PdfPageBlock(
  id: 'pdf-page-1',
  path: '_assets/test.pdf',
  pageIndex: 0,
  pageWidth: 595.0,
  pageHeight: 842.0,
);

const _documentPath = '/tmp/test.runa';

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('PdfPageBlockView', () {
    testWidgets(
        'construye sin lanzar excepción para archivo PDF inexistente',
        (tester) async {
      // PdfDocument.openFile will fail for a nonexistent path. The widget
      // must catch the error and show the error placeholder, not crash.
      await tester.pumpWidget(_wrap(const BlockWidget(
        block: _pdfPageBlock,
        documentPath: _documentPath,
      )));

      // Initial frame: loading state shown.
      expect(find.byType(LinearProgressIndicator), findsOneWidget);

      // After async load attempt fails:
      await tester.pumpAndSettle();

      // Must NOT throw — error placeholder is displayed instead.
      expect(find.byType(LinearProgressIndicator), findsNothing);
      // The PdfPageBlockView widget itself is still in the tree.
      expect(find.byType(PdfPageBlockView), findsOneWidget);
    });

    testWidgets('muestra LinearProgressIndicator mientras carga',
        (tester) async {
      await tester.pumpWidget(_wrap(const BlockWidget(
        block: _pdfPageBlock,
        documentPath: _documentPath,
      )));

      // On the very first frame, before the async load resolves, loading is true.
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
    });

    testWidgets('no muestra InkToolbarWidget cuando el PDF falla al cargar',
        (tester) async {
      // After a failed load the error placeholder is shown, NOT the toolbar.
      await tester.pumpWidget(_wrap(const BlockWidget(
        block: _pdfPageBlock,
        documentPath: _documentPath,
      )));
      await tester.pumpAndSettle();

      expect(find.byType(InkToolbarWidget), findsNothing);
    });

    testWidgets('muestra número de página correcto en placeholder de error',
        (tester) async {
      await tester.pumpWidget(_wrap(const BlockWidget(
        block: _pdfPageBlock,
        documentPath: _documentPath,
      )));
      await tester.pumpAndSettle();

      // pageIndex 0 → "Página 1" in the error message.
      expect(find.textContaining('página 1'), findsOneWidget);
    });

    testWidgets('página 2 muestra "página 2" en placeholder de error',
        (tester) async {
      const page2 = PdfPageBlock(
        id: 'pdf-page-2',
        path: '_assets/test.pdf',
        pageIndex: 1,
        pageWidth: 595.0,
        pageHeight: 842.0,
      );

      await tester.pumpWidget(_wrap(const BlockWidget(
        block: page2,
        documentPath: _documentPath,
      )));
      await tester.pumpAndSettle();

      expect(find.textContaining('página 2'), findsOneWidget);
    });
  });
}
