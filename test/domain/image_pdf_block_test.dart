import 'package:flutter_test/flutter_test.dart';
import 'package:runa/domain/domain.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

const _strokeId = '00000000-0000-0000-0000-000000000099';

Stroke _makeStroke() => const Stroke(
      id: _strokeId,
      color: '#FF0000FF',
      width: 3.0,
      tool: StrokeTool.pen,
      points: [StrokePoint(x: 0.1, y: 0.2, pressure: 0.5, timestamp: 1000)],
    );

// ---------------------------------------------------------------------------
// ImageBlock tests
// ---------------------------------------------------------------------------

void main() {
  group('ImageBlock', () {
    test('fromJson / toJson round-trip (no strokes)', () {
      const block = Block.image(
        id: '00000000-0000-0000-0000-000000000001',
        path: '_assets/foto.png',
        naturalWidth: 1920.0,
        naturalHeight: 1080.0,
      );

      final json = block.toJson();
      final restored = Block.fromJson(json);

      expect(restored, isA<ImageBlock>());
      final img = restored as ImageBlock;
      expect(img.id, '00000000-0000-0000-0000-000000000001');
      expect(img.path, '_assets/foto.png');
      expect(img.naturalWidth, 1920.0);
      expect(img.naturalHeight, 1080.0);
      expect(img.strokes, isEmpty);
    });

    test('fromJson / toJson round-trip (with strokes)', () {
      final block = Block.image(
        id: '00000000-0000-0000-0000-000000000002',
        path: '_assets/foto.jpg',
        naturalWidth: 800.0,
        naturalHeight: 600.0,
        strokes: [_makeStroke()],
      );

      final json = block.toJson();
      final restored = Block.fromJson(json) as ImageBlock;

      expect(restored.strokes, hasLength(1));
      expect(restored.strokes.first.id, _strokeId);
    });

    test('toJson includes type discriminator "image"', () {
      const block = Block.image(
        id: '00000000-0000-0000-0000-000000000003',
        path: '_assets/img.png',
        naturalWidth: 100.0,
        naturalHeight: 100.0,
      );

      expect(block.toJson()['type'], 'image');
    });

    test('toJson includes all required fields', () {
      const block = Block.image(
        id: '00000000-0000-0000-0000-000000000004',
        path: '_assets/img.png',
        naturalWidth: 400.0,
        naturalHeight: 300.0,
      );

      final json = block.toJson();
      expect(json['id'], isNotNull);
      expect(json['path'], '_assets/img.png');
      expect(json['naturalWidth'], 400.0);
      expect(json['naturalHeight'], 300.0);
      expect(json['strokes'], isA<List<dynamic>>());
    });

    test('copyWith changes only specified fields', () {
      const original = Block.image(
        id: '00000000-0000-0000-0000-000000000005',
        path: '_assets/old.png',
        naturalWidth: 200.0,
        naturalHeight: 150.0,
      );

      final modified =
          (original as ImageBlock).copyWith(path: '_assets/new.png');

      expect(modified.path, '_assets/new.png');
      expect(modified.naturalWidth, 200.0);
      expect(modified.naturalHeight, 150.0);
    });
  });

  // ---------------------------------------------------------------------------
  // PdfPageBlock tests
  // ---------------------------------------------------------------------------

  group('PdfPageBlock', () {
    test('fromJson / toJson round-trip (no strokes)', () {
      const block = Block.pdfPage(
        id: '00000000-0000-0000-0000-000000000010',
        path: '_assets/doc.pdf',
        pageIndex: 0,
        pageWidth: 595.0,
        pageHeight: 842.0,
      );

      final json = block.toJson();
      final restored = Block.fromJson(json);

      expect(restored, isA<PdfPageBlock>());
      final pdf = restored as PdfPageBlock;
      expect(pdf.id, '00000000-0000-0000-0000-000000000010');
      expect(pdf.path, '_assets/doc.pdf');
      expect(pdf.pageIndex, 0);
      expect(pdf.pageWidth, 595.0);
      expect(pdf.pageHeight, 842.0);
      expect(pdf.strokes, isEmpty);
    });

    test('fromJson / toJson round-trip (with strokes)', () {
      final block = Block.pdfPage(
        id: '00000000-0000-0000-0000-000000000011',
        path: '_assets/report.pdf',
        pageIndex: 2,
        pageWidth: 612.0,
        pageHeight: 792.0,
        strokes: [_makeStroke()],
      );

      final json = block.toJson();
      final restored = Block.fromJson(json) as PdfPageBlock;

      expect(restored.pageIndex, 2);
      expect(restored.strokes, hasLength(1));
      expect(restored.strokes.first.id, _strokeId);
    });

    test('toJson includes type discriminator "pdf_page"', () {
      const block = Block.pdfPage(
        id: '00000000-0000-0000-0000-000000000012',
        path: '_assets/doc.pdf',
        pageIndex: 0,
      );

      expect(block.toJson()['type'], 'pdf_page');
    });

    test('toJson includes all required fields', () {
      const block = Block.pdfPage(
        id: '00000000-0000-0000-0000-000000000013',
        path: '_assets/doc.pdf',
        pageIndex: 3,
        pageWidth: 595.0,
        pageHeight: 842.0,
      );

      final json = block.toJson();
      expect(json['id'], isNotNull);
      expect(json['path'], '_assets/doc.pdf');
      expect(json['pageIndex'], 3);
      expect(json['pageWidth'], 595.0);
      expect(json['pageHeight'], 842.0);
      expect(json['strokes'], isA<List<dynamic>>());
    });

    test('default pageWidth / pageHeight are 0.0', () {
      const PdfPageBlock block = PdfPageBlock(
        id: '00000000-0000-0000-0000-000000000014',
        path: '_assets/doc.pdf',
        pageIndex: 0,
      );

      expect(block.pageWidth, 0.0);
      expect(block.pageHeight, 0.0);
    });

    test('copyWith changes only specified fields', () {
      const PdfPageBlock original = PdfPageBlock(
        id: '00000000-0000-0000-0000-000000000015',
        path: '_assets/old.pdf',
        pageIndex: 0,
        pageWidth: 595.0,
        pageHeight: 842.0,
      );

      final modified = original.copyWith(pageIndex: 1);

      expect(modified.pageIndex, 1);
      expect(modified.path, '_assets/old.pdf');
      expect(modified.pageWidth, 595.0);
      expect(modified.pageHeight, 842.0);
      expect(modified.id, '00000000-0000-0000-0000-000000000015');
    });

    test('multiple pages sharing same path have different pageIndex', () {
      const PdfPageBlock page0 = PdfPageBlock(
        id: '00000000-0000-0000-0000-000000000020',
        path: '_assets/multi.pdf',
        pageIndex: 0,
        pageWidth: 595.0,
        pageHeight: 842.0,
      );
      const PdfPageBlock page1 = PdfPageBlock(
        id: '00000000-0000-0000-0000-000000000021',
        path: '_assets/multi.pdf',
        pageIndex: 1,
        pageWidth: 595.0,
        pageHeight: 842.0,
      );

      expect(page0.path, page1.path);
      expect(page0.pageIndex, 0);
      expect(page1.pageIndex, 1);
    });
  });
}
