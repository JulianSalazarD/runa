import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

// ---------------------------------------------------------------------------
// Minimal schema validator
//
// Validates JSON maps against the rules defined in docs/runa.schema.json
// without requiring an external JSON Schema library. These tests serve as a
// living contract for the .runa format and will be complemented by
// model-level tests once freezed classes exist (Phase 0 / Part 3).
// ---------------------------------------------------------------------------

final _uuidPattern = RegExp(
  r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
  caseSensitive: false,
);

final _iso8601UtcPattern = RegExp(
  r'^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}(\.\d+)?Z$',
);

final _colorPattern = RegExp(r'^#[0-9A-Fa-f]{8}$');

const _supportedVersions = {'0.1'};
const _validTools = {'pen', 'pencil', 'marker', 'eraser'};

/// Returns a list of validation errors for [doc].
/// An empty list means the document is valid.
List<String> validateDocument(Map<String, dynamic> doc) {
  final errors = <String>[];

  // --- Root required fields ---
  for (final field in ['version', 'id', 'created_at', 'updated_at', 'blocks']) {
    if (!doc.containsKey(field)) errors.add('Missing root field: $field');
  }
  if (errors.isNotEmpty) return errors;

  // --- version ---
  final version = doc['version'];
  if (version is! String) {
    errors.add('version must be a string');
  } else if (!_supportedVersions.contains(version)) {
    errors.add('Unsupported version "$version". Supported: $_supportedVersions');
  }

  // --- id ---
  final id = doc['id'];
  if (id is! String || !_uuidPattern.hasMatch(id)) {
    errors.add('id must be a UUID string');
  }

  // --- timestamps ---
  for (final field in ['created_at', 'updated_at']) {
    final value = doc[field];
    if (value is! String || !_iso8601UtcPattern.hasMatch(value)) {
      errors.add('$field must be an ISO 8601 UTC datetime string');
    }
  }

  // --- blocks ---
  final blocks = doc['blocks'];
  if (blocks is! List) {
    errors.add('blocks must be an array');
    return errors;
  }
  for (var i = 0; i < blocks.length; i++) {
    final block = blocks[i];
    if (block is! Map<String, dynamic>) {
      errors.add('blocks[$i] must be an object');
      continue;
    }
    errors.addAll(_validateBlock(block, i));
  }

  return errors;
}

List<String> _validateBlock(Map<String, dynamic> block, int index) {
  final errors = <String>[];
  final prefix = 'blocks[$index]';

  if (!block.containsKey('type')) {
    errors.add('$prefix: missing field "type"');
    return errors;
  }
  final blockId = block['id'];
  if (blockId == null) {
    errors.add('$prefix: missing field "id"');
  } else if (blockId is! String || !_uuidPattern.hasMatch(blockId)) {
    errors.add('$prefix.id must be a UUID');
  }

  switch (block['type']) {
    case 'markdown':
      errors.addAll(_validateMarkdownBlock(block, prefix));
    case 'ink':
      errors.addAll(_validateInkBlock(block, prefix));
    default:
      errors.add('$prefix: unknown block type "${block['type']}"');
  }
  return errors;
}

List<String> _validateMarkdownBlock(Map<String, dynamic> block, String prefix) {
  final errors = <String>[];
  if (!block.containsKey('content')) {
    errors.add('$prefix: MarkdownBlock missing field "content"');
  } else if (block['content'] is! String) {
    errors.add('$prefix.content must be a string');
  }
  return errors;
}

List<String> _validateInkBlock(Map<String, dynamic> block, String prefix) {
  final errors = <String>[];

  final height = block['height'];
  if (height == null) {
    errors.add('$prefix: InkBlock missing field "height"');
  } else if (height is! num || height <= 0) {
    errors.add('$prefix.height must be a positive number');
  }

  final strokes = block['strokes'];
  if (strokes == null) {
    errors.add('$prefix: InkBlock missing field "strokes"');
    return errors;
  }
  if (strokes is! List) {
    errors.add('$prefix.strokes must be an array');
    return errors;
  }
  for (var i = 0; i < strokes.length; i++) {
    final stroke = strokes[i];
    if (stroke is! Map<String, dynamic>) {
      errors.add('$prefix.strokes[$i] must be an object');
      continue;
    }
    errors.addAll(_validateStroke(stroke, '$prefix.strokes[$i]'));
  }
  return errors;
}

List<String> _validateStroke(Map<String, dynamic> stroke, String prefix) {
  final errors = <String>[];

  final strokeId = stroke['id'];
  if (strokeId == null) {
    errors.add('$prefix: missing field "id"');
  } else if (strokeId is! String || !_uuidPattern.hasMatch(strokeId)) {
    errors.add('$prefix.id must be a UUID');
  }

  final color = stroke['color'];
  if (color == null) {
    errors.add('$prefix: missing field "color"');
  } else if (color is! String || !_colorPattern.hasMatch(color)) {
    errors.add('$prefix.color must match #RRGGBBAA (e.g. "#000000FF")');
  }

  final width = stroke['width'];
  if (width == null) {
    errors.add('$prefix: missing field "width"');
  } else if (width is! num || width <= 0) {
    errors.add('$prefix.width must be a positive number');
  }

  final tool = stroke['tool'];
  if (tool == null) {
    errors.add('$prefix: missing field "tool"');
  } else if (!_validTools.contains(tool)) {
    errors.add('$prefix.tool must be one of $_validTools, got "$tool"');
  }

  final points = stroke['points'];
  if (points == null) {
    errors.add('$prefix: missing field "points"');
    return errors;
  }
  if (points is! List) {
    errors.add('$prefix.points must be an array');
    return errors;
  }
  if (points.isEmpty) {
    errors.add('$prefix.points must have at least one point');
  }
  for (var i = 0; i < points.length; i++) {
    final point = points[i];
    if (point is! Map<String, dynamic>) {
      errors.add('$prefix.points[$i] must be an object');
      continue;
    }
    errors.addAll(_validateStrokePoint(point, '$prefix.points[$i]'));
  }
  return errors;
}

List<String> _validateStrokePoint(Map<String, dynamic> point, String prefix) {
  final errors = <String>[];

  for (final field in ['x', 'y']) {
    if (!point.containsKey(field)) {
      errors.add('$prefix: missing field "$field"');
    } else if (point[field] is! num) {
      errors.add('$prefix.$field must be a number');
    }
  }

  final pressure = point['pressure'];
  if (pressure == null) {
    errors.add('$prefix: missing field "pressure"');
  } else if (pressure is! num || pressure < 0.0 || pressure > 1.0) {
    errors.add('$prefix.pressure must be a number in [0.0, 1.0]');
  }

  final timestamp = point['timestamp'];
  if (timestamp == null) {
    errors.add('$prefix: missing field "timestamp"');
  } else if (timestamp is! int || timestamp < 0) {
    errors.add('$prefix.timestamp must be a non-negative integer (ms since epoch)');
  }

  return errors;
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Map<String, dynamic> _loadFixture(String name) {
  final content = File('test/fixtures/$name').readAsStringSync();
  return jsonDecode(content) as Map<String, dynamic>;
}

void _expectValid(Map<String, dynamic> doc) {
  final errors = validateDocument(doc);
  expect(errors, isEmpty, reason: 'Unexpected validation errors:\n${errors.join('\n')}');
}

void _expectInvalid(Map<String, dynamic> doc, {required String containing}) {
  final errors = validateDocument(doc);
  expect(errors, isNotEmpty, reason: 'Expected validation to fail but it passed');
  expect(
    errors.any((e) => e.contains(containing)),
    isTrue,
    reason: 'Expected an error containing "$containing", got:\n${errors.join('\n')}',
  );
}

Map<String, dynamic> _validInkBlock() => {
      'type': 'ink',
      'id': '00000000-0000-0002-0000-000000000001',
      'height': 200.0,
      'strokes': [
        {
          'id': '00000000-0000-0003-0000-000000000001',
          'color': '#000000FF',
          'width': 2.0,
          'tool': 'pen',
          'points': [
            {'x': 0.0, 'y': 0.0, 'pressure': 0.5, 'timestamp': 0},
          ],
        },
      ],
    };

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('fixture: minimal_document.runa', () {
    late Map<String, dynamic> doc;
    setUp(() => doc = _loadFixture('minimal_document.runa'));

    test('is valid', () => _expectValid(doc));
    test('has version 0.1', () => expect(doc['version'], '0.1'));
    test('id is a UUID', () => expect(_uuidPattern.hasMatch(doc['id'] as String), isTrue));
    test('blocks list is empty', () => expect(doc['blocks'], isEmpty));
  });

  group('fixture: full_document.runa', () {
    late Map<String, dynamic> doc;
    setUp(() => doc = _loadFixture('full_document.runa'));

    test('is valid', () => _expectValid(doc));
    test('has 4 blocks', () => expect((doc['blocks'] as List).length, 4));

    test('first block is MarkdownBlock with content', () {
      final block = (doc['blocks'] as List)[0] as Map<String, dynamic>;
      expect(block['type'], 'markdown');
      expect(block['content'], contains('Hello, Runa!'));
    });

    test('second block is empty MarkdownBlock', () {
      final block = (doc['blocks'] as List)[1] as Map<String, dynamic>;
      expect(block['type'], 'markdown');
      expect(block['content'], '');
    });

    test('third block is InkBlock with two strokes', () {
      final block = (doc['blocks'] as List)[2] as Map<String, dynamic>;
      expect(block['type'], 'ink');
      expect(block['height'], 200.0);
      expect((block['strokes'] as List).length, 2);
    });

    test('first stroke has 3 points, pen tool, opaque black', () {
      final block = (doc['blocks'] as List)[2] as Map<String, dynamic>;
      final stroke = (block['strokes'] as List)[0] as Map<String, dynamic>;
      expect(stroke['color'], '#000000FF');
      expect(stroke['tool'], 'pen');
      expect((stroke['points'] as List).length, 3);
    });

    test('fourth block is empty InkBlock', () {
      final block = (doc['blocks'] as List)[3] as Map<String, dynamic>;
      expect(block['type'], 'ink');
      expect((block['strokes'] as List), isEmpty);
    });
  });

  // --- Versioning policy ---

  group('versioning policy', () {
    test('accepts version "0.1"', () {
      _expectValid(_loadFixture('minimal_document.runa'));
    });

    test('rejects unsupported version', () {
      final doc = _loadFixture('minimal_document.runa')..['version'] = '99.0';
      _expectInvalid(doc, containing: 'version');
    });

    test('rejects missing version', () {
      final doc = _loadFixture('minimal_document.runa')..remove('version');
      _expectInvalid(doc, containing: 'version');
    });
  });

  // --- Root field validation ---

  group('root field validation', () {
    late Map<String, dynamic> base;
    setUp(() => base = _loadFixture('minimal_document.runa'));

    test('rejects missing id', () => _expectInvalid(base..remove('id'), containing: 'id'));
    test('rejects malformed id', () => _expectInvalid(base..['id'] = 'not-a-uuid', containing: 'id'));
    test('rejects missing created_at', () => _expectInvalid(base..remove('created_at'), containing: 'created_at'));
    test('rejects missing updated_at', () => _expectInvalid(base..remove('updated_at'), containing: 'updated_at'));
    test('rejects missing blocks', () => _expectInvalid(base..remove('blocks'), containing: 'blocks'));
    test('rejects non-array blocks', () => _expectInvalid(base..['blocks'] = 'bad', containing: 'blocks'));
  });

  // --- Block validation ---

  group('block validation', () {
    late Map<String, dynamic> base;

    setUp(() {
      base = _loadFixture('minimal_document.runa');
      base['blocks'] = [
        {'type': 'markdown', 'id': '00000000-0000-0001-0000-000000000001', 'content': 'hello'},
      ];
    });

    test('valid MarkdownBlock passes', () => _expectValid(base));

    test('rejects block without type', () {
      base['blocks'] = [{'id': '00000000-0000-0001-0000-000000000001', 'content': 'hi'}];
      _expectInvalid(base, containing: 'type');
    });

    test('rejects unknown block type', () {
      base['blocks'] = [{'type': 'audio', 'id': '00000000-0000-0001-0000-000000000001'}];
      _expectInvalid(base, containing: 'unknown block type');
    });

    test('rejects MarkdownBlock without content', () {
      base['blocks'] = [{'type': 'markdown', 'id': '00000000-0000-0001-0000-000000000001'}];
      _expectInvalid(base, containing: 'content');
    });
  });

  // --- InkBlock validation ---

  group('InkBlock validation', () {
    late Map<String, dynamic> base;
    setUp(() {
      base = _loadFixture('minimal_document.runa');
      base['blocks'] = [_validInkBlock()];
    });

    test('valid InkBlock passes', () => _expectValid(base));

    test('rejects negative height', () {
      final b = _validInkBlock()..['height'] = -1.0;
      base['blocks'] = [b];
      _expectInvalid(base, containing: 'height');
    });

    test('rejects zero height', () {
      final b = _validInkBlock()..['height'] = 0.0;
      base['blocks'] = [b];
      _expectInvalid(base, containing: 'height');
    });

    test('rejects missing height', () {
      final b = _validInkBlock()..remove('height');
      base['blocks'] = [b];
      _expectInvalid(base, containing: 'height');
    });
  });

  // --- Stroke validation ---

  group('Stroke validation', () {
    late Map<String, dynamic> base;
    setUp(() {
      base = _loadFixture('minimal_document.runa');
      base['blocks'] = [_validInkBlock()];
    });

    test('rejects invalid color format (short hex)', () {
      final b = _validInkBlock();
      (b['strokes'] as List<dynamic>)[0]['color'] = '#FFF';
      base['blocks'] = [b];
      _expectInvalid(base, containing: 'color');
    });

    test('rejects invalid color format (6-char without alpha)', () {
      final b = _validInkBlock();
      (b['strokes'] as List<dynamic>)[0]['color'] = '#000000';
      base['blocks'] = [b];
      _expectInvalid(base, containing: 'color');
    });

    test('rejects unknown tool', () {
      final b = _validInkBlock();
      (b['strokes'] as List<dynamic>)[0]['tool'] = 'crayon';
      base['blocks'] = [b];
      _expectInvalid(base, containing: 'tool');
    });

    test('rejects empty points list', () {
      final b = _validInkBlock();
      (b['strokes'] as List<dynamic>)[0]['points'] = <dynamic>[];
      base['blocks'] = [b];
      _expectInvalid(base, containing: 'points');
    });
  });

  // --- StrokePoint validation ---

  group('StrokePoint validation', () {
    late Map<String, dynamic> base;

    void setPoints(List<dynamic> points) {
      base = _loadFixture('minimal_document.runa');
      final b = _validInkBlock();
      (b['strokes'] as List<dynamic>)[0]['points'] = points;
      base['blocks'] = [b];
    }

    test('rejects pressure > 1.0', () {
      setPoints([{'x': 0.0, 'y': 0.0, 'pressure': 1.5, 'timestamp': 0}]);
      _expectInvalid(base, containing: 'pressure');
    });

    test('rejects pressure < 0.0', () {
      setPoints([{'x': 0.0, 'y': 0.0, 'pressure': -0.1, 'timestamp': 0}]);
      _expectInvalid(base, containing: 'pressure');
    });

    test('rejects negative timestamp', () {
      setPoints([{'x': 0.0, 'y': 0.0, 'pressure': 0.5, 'timestamp': -1}]);
      _expectInvalid(base, containing: 'timestamp');
    });

    test('rejects missing x', () {
      setPoints([{'y': 0.0, 'pressure': 0.5, 'timestamp': 0}]);
      _expectInvalid(base, containing: 'x');
    });

    test('rejects missing y', () {
      setPoints([{'x': 0.0, 'pressure': 0.5, 'timestamp': 0}]);
      _expectInvalid(base, containing: 'y');
    });

    test('accepts pressure at boundary values 0.0 and 1.0', () {
      setPoints([
        {'x': 0.0, 'y': 0.0, 'pressure': 0.0, 'timestamp': 0},
        {'x': 1.0, 'y': 1.0, 'pressure': 1.0, 'timestamp': 1},
      ]);
      _expectValid(base);
    });
  });
}
