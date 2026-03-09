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
// PdfPageAnnotation tests
// ---------------------------------------------------------------------------

void main() {
  group('PdfPageAnnotation', () {
    test('fromJson / toJson round-trip (no strokes)', () {
      const annotation = PdfPageAnnotation(
        pageIndex: 0,
        pageWidth: 595.0,
        pageHeight: 842.0,
      );

      final json = annotation.toJson();
      final restored = PdfPageAnnotation.fromJson(json);

      expect(restored.pageIndex, 0);
      expect(restored.pageWidth, 595.0);
      expect(restored.pageHeight, 842.0);
      expect(restored.strokes, isEmpty);
    });

    test('fromJson / toJson round-trip (with strokes)', () {
      final annotation = PdfPageAnnotation(
        pageIndex: 2,
        pageWidth: 612.0,
        pageHeight: 792.0,
        strokes: [_makeStroke()],
      );

      final json = annotation.toJson();
      final restored = PdfPageAnnotation.fromJson(json);

      expect(restored.pageIndex, 2);
      expect(restored.strokes, hasLength(1));
      expect(restored.strokes.first.id, _strokeId);
      expect(restored.strokes.first.color, '#FF0000FF');
    });

    test('toJson includes all required fields', () {
      const annotation = PdfPageAnnotation(
        pageIndex: 1,
        pageWidth: 200.0,
        pageHeight: 300.0,
      );

      final json = annotation.toJson();

      expect(json['pageIndex'], 1);
      expect(json['pageWidth'], 200.0);
      expect(json['pageHeight'], 300.0);
      expect(json["strokes"], isA<List<dynamic>>());
    });

    test('copyWith changes only specified fields', () {
      const original = PdfPageAnnotation(
        pageIndex: 0,
        pageWidth: 595.0,
        pageHeight: 842.0,
      );

      final modified = original.copyWith(pageIndex: 3);

      expect(modified.pageIndex, 3);
      expect(modified.pageWidth, 595.0);
      expect(modified.pageHeight, 842.0);
    });

    test('equality by value', () {
      const a = PdfPageAnnotation(
        pageIndex: 0,
        pageWidth: 595.0,
        pageHeight: 842.0,
      );
      const b = PdfPageAnnotation(
        pageIndex: 0,
        pageWidth: 595.0,
        pageHeight: 842.0,
      );

      expect(a, equals(b));
    });
  });

  // ---------------------------------------------------------------------------
  // ImageBlock tests
  // ---------------------------------------------------------------------------

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
      expect(json["strokes"], isA<List<dynamic>>());
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
  // PdfBlock tests
  // ---------------------------------------------------------------------------

  group('PdfBlock', () {
    test('fromJson / toJson round-trip (no pages)', () {
      const block = Block.pdf(
        id: '00000000-0000-0000-0000-000000000010',
        path: '_assets/doc.pdf',
      );

      final json = block.toJson();
      final restored = Block.fromJson(json);

      expect(restored, isA<PdfBlock>());
      final pdf = restored as PdfBlock;
      expect(pdf.id, '00000000-0000-0000-0000-000000000010');
      expect(pdf.path, '_assets/doc.pdf');
      expect(pdf.pages, isEmpty);
    });

    test('fromJson / toJson round-trip (with page annotations)', () {
      final block = Block.pdf(
        id: '00000000-0000-0000-0000-000000000011',
        path: '_assets/report.pdf',
        pages: [
          PdfPageAnnotation(
            pageIndex: 0,
            pageWidth: 595.0,
            pageHeight: 842.0,
            strokes: [_makeStroke()],
          ),
          const PdfPageAnnotation(
            pageIndex: 1,
            pageWidth: 595.0,
            pageHeight: 842.0,
          ),
        ],
      );

      final json = block.toJson();
      final restored = Block.fromJson(json) as PdfBlock;

      expect(restored.pages, hasLength(2));
      expect(restored.pages[0].pageIndex, 0);
      expect(restored.pages[0].strokes, hasLength(1));
      expect(restored.pages[1].pageIndex, 1);
      expect(restored.pages[1].strokes, isEmpty);
    });

    test('toJson includes type discriminator "pdf"', () {
      const block = Block.pdf(
        id: '00000000-0000-0000-0000-000000000012',
        path: '_assets/doc.pdf',
      );

      expect(block.toJson()['type'], 'pdf');
    });

    test('toJson includes all required fields', () {
      const block = Block.pdf(
        id: '00000000-0000-0000-0000-000000000013',
        path: '_assets/doc.pdf',
      );

      final json = block.toJson();
      expect(json['id'], isNotNull);
      expect(json['path'], '_assets/doc.pdf');
      expect(json["pages"], isA<List<dynamic>>());
    });

    test('copyWith changes only specified fields', () {
      const original = Block.pdf(
        id: '00000000-0000-0000-0000-000000000014',
        path: '_assets/old.pdf',
      );

      final modified = (original as PdfBlock).copyWith(path: '_assets/new.pdf');

      expect(modified.path, '_assets/new.pdf');
      expect(modified.id, '00000000-0000-0000-0000-000000000014');
    });
  });
}
