import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:runa/domain/domain.dart';
import 'package:runa/presentation/editor/block_widget.dart';
import 'package:runa/presentation/editor/ink_canvas_widget.dart';
import 'package:runa/presentation/editor/ink_toolbar_widget.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

const _emptyBlock = InkBlock(id: 'b1', height: 200);

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

InkBlock _blockWithStroke(Stroke stroke) =>
    const InkBlock(id: 'b1', height: 200).copyWith(strokes: [stroke]);

Stroke _stroke({StrokeTool tool = StrokeTool.pen}) => Stroke(
      id: 's1',
      color: '#000000FF',
      width: 3.0,
      tool: tool,
      points: const [
        StrokePoint(x: 10, y: 10, pressure: 1.0, timestamp: 0),
        StrokePoint(x: 20, y: 20, pressure: 1.0, timestamp: 10),
        StrokePoint(x: 30, y: 10, pressure: 1.0, timestamp: 20),
      ],
    );

// ---------------------------------------------------------------------------
// InkCanvasWidget tests
// ---------------------------------------------------------------------------

void main() {
  group('InkCanvasWidget', () {
    testWidgets('renders CustomPaint for empty canvas', (tester) async {
      await tester.pumpWidget(_wrap(const InkCanvasWidget(
        block: _emptyBlock,
        height: 200,
        activeTool: StrokeTool.pen,
        activeColor: '#000000FF',
        activeWidth: 3.0,
      )));

      // MaterialApp/Scaffold also use CustomPaint; check at least one exists.
      expect(find.byType(CustomPaint), findsAtLeast(1));
    });

    testWidgets('pointer down → move → up commits a stroke via onUpdate',
        (tester) async {
      InkBlock? updated;
      await tester.pumpWidget(_wrap(InkCanvasWidget(
        block: _emptyBlock,
        height: 200,
        activeTool: StrokeTool.pen,
        activeColor: '#FF0000FF',
        activeWidth: 4.0,
        onUpdate: (b) => updated = b,
      )));

      final gesture = await tester.startGesture(const Offset(50, 50));
      await gesture.moveBy(const Offset(20, 20));
      await gesture.up();
      await tester.pump();

      expect(updated, isNotNull);
      expect(updated!.strokes, hasLength(1));
      final stroke = updated!.strokes.first;
      expect(stroke.color, '#FF0000FF');
      expect(stroke.width, 4.0);
      expect(stroke.tool, StrokeTool.pen);
      expect(stroke.points, isNotEmpty);
    });

    testWidgets('pressure 0 (device fallback) → stored as 1.0', (tester) async {
      InkBlock? updated;
      await tester.pumpWidget(_wrap(InkCanvasWidget(
        block: _emptyBlock,
        height: 200,
        activeTool: StrokeTool.pen,
        activeColor: '#000000FF',
        activeWidth: 3.0,
        onUpdate: (b) => updated = b,
      )));

      // tester.startGesture sends pressure = 0.0 (no stylus).
      final gesture = await tester.startGesture(const Offset(30, 30));
      await gesture.up();
      await tester.pump();

      expect(updated, isNotNull);
      expect(updated!.strokes.first.points.first.pressure, 1.0);
    });

    testWidgets('eraser removes a stroke whose points overlap the eraser path',
        (tester) async {
      final block = _blockWithStroke(_stroke());
      InkBlock? updated;

      await tester.pumpWidget(_wrap(InkCanvasWidget(
        block: block,
        height: 200,
        activeTool: StrokeTool.eraser,
        activeColor: '#000000FF',
        activeWidth: 3.0,
        onUpdate: (b) => updated = b,
      )));

      // Drag through the stroke's points (x:10–30, y:10–20).
      final gesture = await tester.startGesture(const Offset(10, 10));
      await gesture.moveBy(const Offset(25, 0));
      await gesture.up();
      await tester.pump();

      expect(updated, isNotNull);
      expect(updated!.strokes, isEmpty);
    });

    testWidgets('eraser does not call onUpdate when no strokes are hit',
        (tester) async {
      final block = _blockWithStroke(_stroke());
      int updateCount = 0;

      await tester.pumpWidget(_wrap(InkCanvasWidget(
        block: block,
        height: 200,
        activeTool: StrokeTool.eraser,
        activeColor: '#000000FF',
        activeWidth: 3.0,
        onUpdate: (_) => updateCount++,
      )));

      // Erase far from the stroke's points (far bottom-right).
      final gesture = await tester.startGesture(const Offset(150, 150));
      await gesture.up();
      await tester.pump();

      expect(updateCount, 0);
    });

    testWidgets('pencil tool stores correct tool in committed stroke',
        (tester) async {
      InkBlock? updated;
      await tester.pumpWidget(_wrap(InkCanvasWidget(
        block: _emptyBlock,
        height: 200,
        activeTool: StrokeTool.pencil,
        activeColor: '#000000FF',
        activeWidth: 2.0,
        onUpdate: (b) => updated = b,
      )));

      final gesture = await tester.startGesture(const Offset(40, 40));
      await gesture.moveBy(const Offset(10, 0));
      await gesture.up();
      await tester.pump();

      expect(updated!.strokes.first.tool, StrokeTool.pencil);
    });
  });

  // -------------------------------------------------------------------------
  // InkToolbarWidget tests
  // -------------------------------------------------------------------------

  group('InkToolbarWidget', () {
    testWidgets('shows all four tool buttons', (tester) async {
      await tester.pumpWidget(_wrap(InkToolbarWidget(
        activeTool: StrokeTool.pen,
        activeColor: '#000000FF',
        activeWidth: 3.0,
        onToolChanged: (_) {},
        onColorChanged: (_) {},
        onWidthChanged: (_) {},
      )));

      expect(find.byIcon(Icons.edit), findsOneWidget);
      expect(find.byIcon(Icons.draw), findsOneWidget);
      expect(find.byIcon(Icons.brush), findsOneWidget);
      expect(find.byIcon(Icons.auto_fix_normal), findsOneWidget);
    });

    testWidgets('tapping a tool button calls onToolChanged', (tester) async {
      StrokeTool? selected;
      await tester.pumpWidget(_wrap(InkToolbarWidget(
        activeTool: StrokeTool.pen,
        activeColor: '#000000FF',
        activeWidth: 3.0,
        onToolChanged: (t) => selected = t,
        onColorChanged: (_) {},
        onWidthChanged: (_) {},
      )));

      await tester.tap(find.byIcon(Icons.brush)); // Marker
      await tester.pump();

      expect(selected, StrokeTool.marker);
    });

    testWidgets('tapping eraser tool calls onToolChanged with eraser',
        (tester) async {
      StrokeTool? selected;
      await tester.pumpWidget(_wrap(InkToolbarWidget(
        activeTool: StrokeTool.pen,
        activeColor: '#000000FF',
        activeWidth: 3.0,
        onToolChanged: (t) => selected = t,
        onColorChanged: (_) {},
        onWidthChanged: (_) {},
      )));

      await tester.tap(find.byIcon(Icons.auto_fix_normal));
      await tester.pump();

      expect(selected, StrokeTool.eraser);
    });

    testWidgets('tapping width button "Grueso" calls onWidthChanged with 8.0',
        (tester) async {
      double? selected;
      await tester.pumpWidget(_wrap(InkToolbarWidget(
        activeTool: StrokeTool.pen,
        activeColor: '#000000FF',
        activeWidth: 2.0,
        onToolChanged: (_) {},
        onColorChanged: (_) {},
        onWidthChanged: (w) => selected = w,
      )));

      await tester.tap(find.byTooltip('Grueso'));
      await tester.pump();

      expect(selected, 8.0);
    });
  });

  // -------------------------------------------------------------------------
  // _InkBlockView resize handle (via BlockWidget)
  // -------------------------------------------------------------------------

  group('_InkBlockView resize handle', () {
    testWidgets('drag down on handle increases canvas height', (tester) async {
      Block? updated;
      await tester.pumpWidget(_wrap(BlockWidget(
        block: const InkBlock(id: 'b1', height: 200),
        onUpdate: (b) => updated = b,
      )));

      // Locate the canvas and derive the handle position just below it.
      final canvasRect = tester.getRect(find.byType(InkCanvasWidget));
      final handleCenter = Offset(canvasRect.center.dx, canvasRect.bottom + 5);

      final gesture = await tester.startGesture(handleCenter);
      await gesture.moveBy(const Offset(0, 50));
      await gesture.up();
      await tester.pump();

      expect(updated, isNotNull);
      expect((updated! as InkBlock).height, closeTo(250, 5));
    });

    testWidgets('drag up cannot reduce height below 80 px', (tester) async {
      Block? updated;
      await tester.pumpWidget(_wrap(BlockWidget(
        block: const InkBlock(id: 'b1', height: 100),
        onUpdate: (b) => updated = b,
      )));

      final canvasRect = tester.getRect(find.byType(InkCanvasWidget));
      final handleCenter = Offset(canvasRect.center.dx, canvasRect.bottom + 5);

      // Try to drag up 60 px (would shrink to 40, below the 80 px minimum).
      final gesture = await tester.startGesture(handleCenter);
      await gesture.moveBy(const Offset(0, -60));
      await gesture.up();
      await tester.pump();

      expect(updated, isNotNull);
      expect((updated! as InkBlock).height, greaterThanOrEqualTo(80));
    });
  });
}
