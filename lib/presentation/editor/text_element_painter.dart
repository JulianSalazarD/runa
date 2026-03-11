import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:runa/domain/domain.dart';

/// [CustomPainter] that renders [TextElement]s on the ink canvas.
///
/// Coordinates are denormalised from [0.0, 1.0] to canvas pixels.
class TextElementPainter extends CustomPainter {
  const TextElementPainter({required this.elements});

  final List<TextElement> elements;

  @override
  void paint(Canvas canvas, Size size) {
    for (final el in elements) {
      if (el.content.isEmpty) continue;
      final x = el.x * size.width;
      final y = el.y * size.height;
      final color = _parseColor(el.color);

      final pb = ui.ParagraphBuilder(
        ui.ParagraphStyle(
          textDirection: ui.TextDirection.ltr,
          fontSize: el.fontSize,
          fontFamily: el.fontFamily,
          fontWeight: el.bold ? FontWeight.bold : FontWeight.normal,
          fontStyle: el.italic ? FontStyle.italic : FontStyle.normal,
        ),
      )
        ..pushStyle(ui.TextStyle(color: color))
        ..addText(el.content);

      final para = pb.build()
        ..layout(ui.ParagraphConstraints(width: size.width - x));
      canvas.drawParagraph(para, Offset(x, y));
    }
  }

  @override
  bool shouldRepaint(TextElementPainter old) => old.elements != elements;

  static Color _parseColor(String hex) {
    final h = hex.replaceFirst('#', '');
    final r = int.parse(h.substring(0, 2), radix: 16);
    final g = int.parse(h.substring(2, 4), radix: 16);
    final b = int.parse(h.substring(4, 6), radix: 16);
    final a = int.parse(h.substring(6, 8), radix: 16);
    return Color.fromARGB(a, r, g, b);
  }
}
