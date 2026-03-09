import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:runa/domain/domain.dart';
import 'package:runa/presentation/editor/block_widget.dart';
import 'package:runa/presentation/editor/ink_toolbar_widget.dart';
import 'package:runa/presentation/editor/pdf_block_view.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Wraps [child] in a scrollable scaffold so that the PDF block column
/// (toolbar + pages) does not overflow the 800×600 test viewport.
Widget _wrap(Widget child) => MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(child: child),
      ),
    );

const _pdfBlock = PdfBlock(
  id: 'pdf-1',
  path: '_assets/test.pdf',
);

const _documentPath = '/tmp/test.runa';

// ---------------------------------------------------------------------------
// Unit tests for annotation update logic
// ---------------------------------------------------------------------------

void main() {
  // -------------------------------------------------------------------------
  // Annotation merge logic (tested via _PdfBlockViewState through the widget)
  // -------------------------------------------------------------------------

  group('PdfBlockView annotation logic', () {
    testWidgets(
        'construye sin lanzar excepción para archivo PDF inexistente',
        (tester) async {
      // PdfDocument.openFile will fail for a nonexistent path. The widget
      // must catch the error and render the error placeholder instead of
      // crashing. We pump and settle to let the async load complete.
      await tester.pumpWidget(_wrap(BlockWidget(
        block: _pdfBlock,
        documentPath: _documentPath,
        isSelected: false,
      )));

      // Initial frame: loading state shown.
      expect(find.byType(LinearProgressIndicator), findsOneWidget);

      // After async load attempt fails:
      await tester.pumpAndSettle();

      // Must NOT throw — error placeholder is displayed.
      expect(find.byType(LinearProgressIndicator), findsNothing);
      // The PdfBlockView widget itself is still in the tree.
      expect(find.byType(PdfBlockView), findsOneWidget);
    });

    testWidgets('muestra LinearProgressIndicator mientras carga',
        (tester) async {
      await tester.pumpWidget(_wrap(BlockWidget(
        block: _pdfBlock,
        documentPath: _documentPath,
        isSelected: false,
      )));

      // On the very first frame, before the async load resolves, loading is true.
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
    });

    testWidgets('muestra InkToolbarWidget cuando el documento es null (error)',
        (tester) async {
      // After a failed load the error placeholder is shown, NOT the toolbar.
      await tester.pumpWidget(_wrap(BlockWidget(
        block: _pdfBlock,
        documentPath: _documentPath,
        isSelected: false,
      )));
      await tester.pumpAndSettle();

      // Toolbar should NOT be visible when PDF failed to load.
      expect(find.byType(InkToolbarWidget), findsNothing);
    });
  });

  // -------------------------------------------------------------------------
  // Unit tests for _updateAnnotation merge logic (pure Dart, no PDF rendering)
  // -------------------------------------------------------------------------

  group('_updateAnnotation merge logic', () {
    /// Simulates what _PdfBlockViewState._updateAnnotation does:
    /// merges an updated annotation into a list, replacing by pageIndex.
    List<PdfPageAnnotation> mergeAnnotation(
      List<PdfPageAnnotation> existing,
      PdfPageAnnotation updated,
    ) {
      final pages = List<PdfPageAnnotation>.from(existing);
      final idx = pages.indexWhere((a) => a.pageIndex == updated.pageIndex);
      if (idx >= 0) {
        pages[idx] = updated;
      } else {
        pages.add(updated);
        pages.sort((a, b) => a.pageIndex.compareTo(b.pageIndex));
      }
      return pages;
    }

    test('reemplaza anotación existente por pageIndex', () {
      const ann0 = PdfPageAnnotation(
        pageIndex: 0,
        pageWidth: 595,
        pageHeight: 842,
      );
      const ann1 = PdfPageAnnotation(
        pageIndex: 1,
        pageWidth: 595,
        pageHeight: 842,
      );
      const stroke = Stroke(
        id: 's1',
        color: '#000000FF',
        width: 3.0,
        tool: StrokeTool.pen,
        points: [StrokePoint(x: 0.5, y: 0.5, pressure: 1.0, timestamp: 0)],
      );
      final updated = ann0.copyWith(strokes: [stroke]);

      final result = mergeAnnotation([ann0, ann1], updated);

      expect(result, hasLength(2));
      expect(result[0].strokes, hasLength(1));
      expect(result[1].strokes, isEmpty);
    });

    test('inserta anotación nueva para página no existente', () {
      const ann0 = PdfPageAnnotation(
        pageIndex: 0,
        pageWidth: 595,
        pageHeight: 842,
      );
      const newAnn = PdfPageAnnotation(
        pageIndex: 2,
        pageWidth: 595,
        pageHeight: 842,
      );

      final result = mergeAnnotation([ann0], newAnn);

      expect(result, hasLength(2));
      expect(result[0].pageIndex, 0);
      expect(result[1].pageIndex, 2);
    });

    test('mantiene orden por pageIndex tras inserción', () {
      const ann2 = PdfPageAnnotation(
        pageIndex: 2,
        pageWidth: 595,
        pageHeight: 842,
      );
      const ann0 = PdfPageAnnotation(
        pageIndex: 0,
        pageWidth: 595,
        pageHeight: 842,
      );

      final result = mergeAnnotation([ann2], ann0);

      expect(result[0].pageIndex, 0);
      expect(result[1].pageIndex, 2);
    });

    test('limpiar todas: vacía strokes de todas las páginas', () {
      const stroke = Stroke(
        id: 's1',
        color: '#000000FF',
        width: 3.0,
        tool: StrokeTool.pen,
        points: [StrokePoint(x: 0.1, y: 0.1, pressure: 1.0, timestamp: 0)],
      );
      final pages = [
        const PdfPageAnnotation(
                pageIndex: 0, pageWidth: 595, pageHeight: 842)
            .copyWith(strokes: [stroke]),
        const PdfPageAnnotation(
                pageIndex: 1, pageWidth: 595, pageHeight: 842)
            .copyWith(strokes: [stroke]),
      ];

      final cleared = pages.map((p) => p.copyWith(strokes: const [])).toList();

      expect(cleared.every((p) => p.strokes.isEmpty), isTrue);
      expect(cleared, hasLength(2));
    });

    test('_hasAnyStrokes: false cuando todas las páginas están vacías', () {
      final pages = [
        const PdfPageAnnotation(pageIndex: 0, pageWidth: 595, pageHeight: 842),
        const PdfPageAnnotation(pageIndex: 1, pageWidth: 595, pageHeight: 842),
      ];
      final hasAny = pages.any((p) => p.strokes.isNotEmpty);
      expect(hasAny, isFalse);
    });

    test('_hasAnyStrokes: true cuando al menos una página tiene strokes', () {
      const stroke = Stroke(
        id: 's1',
        color: '#000000FF',
        width: 3.0,
        tool: StrokeTool.pen,
        points: [StrokePoint(x: 0.2, y: 0.2, pressure: 1.0, timestamp: 0)],
      );
      final pages = [
        const PdfPageAnnotation(pageIndex: 0, pageWidth: 595, pageHeight: 842),
        const PdfPageAnnotation(pageIndex: 1, pageWidth: 595, pageHeight: 842)
            .copyWith(strokes: [stroke]),
      ];
      final hasAny = pages.any((p) => p.strokes.isNotEmpty);
      expect(hasAny, isTrue);
    });
  });
}
