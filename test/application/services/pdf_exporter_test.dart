import 'package:flutter_test/flutter_test.dart';
import 'package:runa/application/services/pdf_exporter.dart';
import 'package:runa/domain/domain.dart';
import 'package:uuid/uuid.dart';

const _uuid = Uuid();

Document _makeDoc(List<Block> blocks) => Document(
      version: '0.1',
      id: _uuid.v4(),
      createdAt: DateTime.utc(2024),
      updatedAt: DateTime.utc(2024),
      blocks: blocks,
    );

Stroke _makeStroke() => Stroke(
      id: _uuid.v4(),
      color: '#000000FF',
      width: 2.0,
      tool: StrokeTool.pen,
      points: [
        const StrokePoint(x: 0, y: 0, pressure: 0.5, timestamp: 0),
        const StrokePoint(x: 100, y: 100, pressure: 0.5, timestamp: 10),
      ],
    );

void main() {
  late PdfExporter exporter;

  setUp(() => exporter = PdfExporter());

  group('PdfExporter', () {
    test('empty document produces non-empty PDF bytes', () async {
      final doc = _makeDoc([]);
      final bytes = await exporter.export(doc, documentPath: '/tmp/test.runa');
      expect(bytes, isNotEmpty);
    });

    test('markdown block produces non-empty PDF bytes', () async {
      final doc = _makeDoc([
        Block.markdown(id: _uuid.v4(), content: '# Heading\n\nSome text.'),
      ]);
      final bytes = await exporter.export(doc, documentPath: '/tmp/test.runa');
      expect(bytes, isNotEmpty);
    });

    test('ink block with strokes produces non-empty PDF bytes', () async {
      final doc = _makeDoc([
        Block.ink(
          id: _uuid.v4(),
          height: 200,
          strokes: [_makeStroke(), _makeStroke()],
        ),
      ]);
      final bytes = await exporter.export(doc, documentPath: '/tmp/test.runa');
      expect(bytes, isNotEmpty);
    });

    test('document with mixed block types produces non-empty PDF bytes',
        () async {
      final doc = _makeDoc([
        Block.markdown(
          id: _uuid.v4(),
          content: '# Title\n\nText with **bold**.',
        ),
        Block.ink(
          id: _uuid.v4(),
          height: 100,
          strokes: [_makeStroke()],
        ),
        Block.pdfPage(
          id: _uuid.v4(),
          path: '_assets/doc.pdf',
          pageIndex: 0,
        ),
      ]);
      final bytes = await exporter.export(doc, documentPath: '/tmp/test.runa');
      expect(bytes, isNotEmpty);
    });

    test('multiple markdown blocks produce a valid PDF', () async {
      final doc = _makeDoc([
        Block.markdown(id: _uuid.v4(), content: '## Section 1\n\nFirst.'),
        Block.markdown(id: _uuid.v4(), content: '## Section 2\n\nSecond.'),
        Block.markdown(
          id: _uuid.v4(),
          content: '| Col 1 | Col 2 |\n|---|---|\n| A | B |',
        ),
      ]);
      final bytes = await exporter.export(doc, documentPath: '/tmp/test.runa');
      expect(bytes, isNotEmpty);
    });
  });
}
