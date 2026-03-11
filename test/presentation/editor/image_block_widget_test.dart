import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:runa/domain/domain.dart';
import 'package:runa/presentation/editor/block_widget.dart';
import 'package:runa/presentation/editor/ink_annotation_layer.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Widget _wrapLayer(Widget child) => MaterialApp(
      home: Scaffold(
        body: SizedBox(
          width: 300,
          height: 150,
          child: child,
        ),
      ),
    );

/// Wraps [child] in a scrollable scaffold with ample vertical space so the
/// ImageBlock column (toolbar + button + AspectRatio image) does not overflow
/// in the 800×600 test viewport.
Widget _wrapBlock(Widget child) => MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(child: child),
      ),
    );

const _imageBlock = ImageBlock(
  id: 'img-1',
  path: '_assets/test.png',
  naturalWidth: 800,
  naturalHeight: 600,
);

// A stroke with normalised coordinates roughly at the centre of a 300×150
// render area (x=0.5, y=0.5) — used in eraser tests.
Stroke _centreStroke() => Stroke(
      id: 's1',
      color: '#000000FF',
      width: 3.0,
      tool: StrokeTool.pen,
      points: const [
        StrokePoint(x: 0.5, y: 0.5, pressure: 1.0, timestamp: 0),
        StrokePoint(x: 0.51, y: 0.51, pressure: 1.0, timestamp: 10),
      ],
    );

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  // -------------------------------------------------------------------------
  // _ImageBlockView (via BlockWidget, since _ImageBlockView is private)
  // -------------------------------------------------------------------------

  group('ImageBlock via BlockWidget', () {
    testWidgets('construye sin lanzar excepción para un archivo inexistente',
        (tester) async {
      // Image.file with a non-existent path: in the headless test runner the
      // codec error surfaces asynchronously and the errorBuilder fires only
      // after the image decode attempt settles. What we can always assert is:
      //  1. The widget tree builds and pumps without throwing a synchronous
      //     exception.
      //  2. The AspectRatio + Stack structure (image layer + annotation layer)
      //     is present in the tree, confirming _ImageBlockView rendered.
      await tester.pumpWidget(_wrapBlock(BlockWidget(
        block: _imageBlock,
        documentPath: '/tmp/test.runa',
        isSelected: true,
      )));
      await tester.pump();

      // Widget built without error and contains the annotation layer.
      expect(find.byType(InkAnnotationLayer), findsOneWidget);
      // The AspectRatio respects naturalWidth/naturalHeight (800/600 ≈ 1.33).
      expect(find.byType(AspectRatio), findsOneWidget);
    });

    testWidgets('botón Limpiar anotaciones deshabilitado con strokes vacíos',
        (tester) async {
      await tester.pumpWidget(_wrapBlock(BlockWidget(
        block: _imageBlock, // strokes: [] by default
        documentPath: '/tmp/test.runa',
        isSelected: true,
      )));
      await tester.pump();

      // The button exists but has no onPressed (disabled).
      final button = tester.widget<TextButton>(
        find.widgetWithText(TextButton, 'Limpiar anotaciones'),
      );
      expect(button.onPressed, isNull);
    });

    testWidgets(
        'botón Limpiar anotaciones llama onUpdate con strokes vacíos',
        (tester) async {
      final blockWithStroke =
          _imageBlock.copyWith(strokes: [_centreStroke()]);
      Block? updated;

      await tester.pumpWidget(_wrapBlock(BlockWidget(
        block: blockWithStroke,
        documentPath: '/tmp/test.runa',
        isSelected: true,
        onUpdate: (b) => updated = b,
      )));
      await tester.pump();

      await tester.tap(find.widgetWithText(TextButton, 'Limpiar anotaciones'));
      await tester.pump();

      expect(updated, isNotNull);
      expect((updated! as ImageBlock).strokes, isEmpty);
    });

    testWidgets('InkAnnotationLayer se renderiza dentro de ImageBlock',
        (tester) async {
      await tester.pumpWidget(_wrapBlock(BlockWidget(
        block: _imageBlock,
        documentPath: '/tmp/test.runa',
        isSelected: true,
      )));
      await tester.pump();

      // The InkToolbarWidget now lives in the top editor bar (not inside
      // the block), so we verify the annotation layer is present instead.
      expect(find.byType(InkAnnotationLayer), findsOneWidget);
    });
  });

  // -------------------------------------------------------------------------
  // InkAnnotationLayer
  // -------------------------------------------------------------------------

  group('InkAnnotationLayer', () {
    testWidgets('en modo readOnly no captura gestos ni llama onStrokesChanged',
        (tester) async {
      int callCount = 0;
      await tester.pumpWidget(_wrapLayer(InkAnnotationLayer(
        strokes: const [],
        onStrokesChanged: (_) => callCount++,
        activeTool: StrokeTool.pen,
        activeColor: '#000000FF',
        activeWidth: 3.0,
        readOnly: true,
      )));
      await tester.pumpAndSettle();

      final gesture = await tester.startGesture(const Offset(50, 50));
      await gesture.moveBy(const Offset(20, 20));
      await gesture.up();
      await tester.pump();

      expect(callCount, 0);
    });

    testWidgets('trazo simple añade un Stroke vía onStrokesChanged',
        (tester) async {
      List<Stroke>? result;
      await tester.pumpWidget(_wrapLayer(InkAnnotationLayer(
        strokes: const [],
        onStrokesChanged: (s) => result = s,
        activeTool: StrokeTool.pen,
        activeColor: '#FF0000FF',
        activeWidth: 4.0,
      )));
      await tester.pumpAndSettle();

      final gesture = await tester.startGesture(const Offset(50, 50));
      await gesture.moveBy(const Offset(10, 10));
      await gesture.up();
      await tester.pump();

      expect(result, isNotNull);
      expect(result, hasLength(1));
      expect(result!.first.color, '#FF0000FF');
      expect(result!.first.tool, StrokeTool.pen);
    });

    testWidgets(
        'coordenadas normalizadas: esquina inferior derecha → aprox (1.0, 1.0)',
        (tester) async {
      List<Stroke>? result;
      await tester.pumpWidget(_wrapLayer(InkAnnotationLayer(
        strokes: const [],
        onStrokesChanged: (s) => result = s,
        activeTool: StrokeTool.pen,
        activeColor: '#000000FF',
        activeWidth: 3.0,
      )));
      await tester.pumpAndSettle();

      // Tap at bottom-right corner of the 300×150 SizedBox.
      final gesture = await tester.startGesture(const Offset(299, 149));
      await gesture.up();
      await tester.pump();

      expect(result, isNotNull);
      expect(result!, isNotEmpty);
      final point = result!.first.points.first;
      expect(point.x, closeTo(1.0, 0.02));
      expect(point.y, closeTo(1.0, 0.02));
    });

    testWidgets('coordenadas normalizadas: centro → aprox (0.5, 0.5)',
        (tester) async {
      List<Stroke>? result;
      await tester.pumpWidget(_wrapLayer(InkAnnotationLayer(
        strokes: const [],
        onStrokesChanged: (s) => result = s,
        activeTool: StrokeTool.pen,
        activeColor: '#000000FF',
        activeWidth: 3.0,
      )));
      await tester.pumpAndSettle();

      // Centre of the 300×150 SizedBox is (150, 75).
      final gesture = await tester.startGesture(const Offset(150, 75));
      await gesture.up();
      await tester.pump();

      expect(result, isNotNull);
      expect(result!, isNotEmpty);
      final point = result!.first.points.first;
      expect(point.x, closeTo(0.5, 0.02));
      expect(point.y, closeTo(0.5, 0.02));
    });

    testWidgets('borrador elimina trazo que se superpone con el gesto',
        (tester) async {
      // Stroke at normalised (0.5, 0.5) → pixel (150, 75) in a 300×150 canvas.
      final existing = _centreStroke();
      List<Stroke>? result;

      await tester.pumpWidget(_wrapLayer(InkAnnotationLayer(
        strokes: [existing],
        onStrokesChanged: (s) => result = s,
        activeTool: StrokeTool.eraser,
        activeColor: '#000000FF',
        activeWidth: 3.0,
      )));
      await tester.pumpAndSettle();

      // Erase directly over the stroke's pixel position (150, 75).
      final gesture = await tester.startGesture(const Offset(150, 75));
      await gesture.moveBy(const Offset(5, 0));
      await gesture.up();
      await tester.pump();

      expect(result, isNotNull);
      expect(result, isEmpty);
    });
  });
}
