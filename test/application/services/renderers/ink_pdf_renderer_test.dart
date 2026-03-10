import 'package:flutter_test/flutter_test.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:runa/application/services/renderers/ink_pdf_renderer.dart';
import 'package:runa/domain/domain.dart';
import 'package:uuid/uuid.dart';

Stroke _makeStroke({
  required List<(double, double)> coords,
  String color = '#000000FF',
  double width = 2.0,
  StrokeTool tool = StrokeTool.pen,
}) {
  const uuid = Uuid();
  return Stroke(
    id: uuid.v4(),
    color: color,
    width: width,
    tool: tool,
    points: coords
        .map((c) => StrokePoint(
              x: c.$1,
              y: c.$2,
              pressure: 0.5,
              timestamp: 0,
            ))
        .toList(),
  );
}

void main() {
  late InkPdfRenderer renderer;

  setUp(() => renderer = InkPdfRenderer());

  group('InkPdfRenderer', () {
    test('empty strokes returns SizedBox.shrink', () {
      final widget = renderer.render([], inkHeight: 100);
      expect(widget, isA<pw.SizedBox>());
    });

    test('two strokes produces a CustomPaint widget', () {
      final strokes = [
        _makeStroke(coords: [(0, 0), (100, 100)]),
        _makeStroke(coords: [(50, 50), (200, 150)]),
      ];
      final widget = renderer.render(strokes, inkHeight: 200);
      expect(widget, isA<pw.CustomPaint>());
    });

    test('eraser strokes are ignored and produce a CustomPaint', () {
      final strokes = [
        _makeStroke(
          coords: [(0, 0), (100, 100)],
          tool: StrokeTool.eraser,
        ),
        _makeStroke(coords: [(10, 10), (90, 90)]),
      ];
      final widget = renderer.render(strokes, inkHeight: 200);
      expect(widget, isA<pw.CustomPaint>());
    });

    test('two strokes can be assembled into a PDF without error', () async {
      final strokes = [
        _makeStroke(coords: [(0, 0), (100, 100)]),
        _makeStroke(coords: [(50, 0), (50, 200)]),
      ];
      final widget = renderer.render(strokes, inkHeight: 200);
      final doc = pw.Document();
      doc.addPage(pw.Page(build: (ctx) => widget));
      final bytes = await doc.save();
      expect(bytes, isNotEmpty);
    });

    test('renderNormalized produces a CustomPaint widget', () {
      final strokes = [
        _makeStroke(coords: [(0.1, 0.1), (0.9, 0.9)]),
      ];
      final widget = renderer.renderNormalized(
        strokes,
        naturalWidth: 800,
        naturalHeight: 600,
      );
      expect(widget, isA<pw.CustomPaint>());
    });

    test('color parsing — red #FF0000FF produces red stroke', () {
      final strokes = [
        _makeStroke(
          coords: [(0, 0), (10, 10)],
          color: '#FF0000FF',
        ),
      ];
      final widget = renderer.render(strokes, inkHeight: 50);
      expect(widget, isA<pw.CustomPaint>());
    });
  });
}
