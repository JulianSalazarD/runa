// Domain layer: pure data models with no Flutter or dart:io dependencies.
//
// Contains:
//   - Value objects: Document, Block (sealed), Stroke, StrokePoint
//   - Repository interfaces (abstract classes only)
//   - No framework imports (no Flutter, no Riverpod, no json_annotation)
library;

export 'models/block.dart';
export 'models/document.dart';
export 'models/stroke.dart';
export 'models/stroke_point.dart';
