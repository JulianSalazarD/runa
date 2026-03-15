import 'package:flutter/material.dart';

/// Shared canvas background color palette used in both the settings screen
/// and the ink toolbar background picker.
const kCanvasColors = [
  Color(0xFFFFFFFF), // white
  Color(0xFFFFFDE7), // cream
  Color(0xFFF3E5F5), // lavender
  Color(0xFFE8F5E9), // mint
  Color(0xFFE3F2FD), // light blue
  Color(0xFFFCE4EC), // light pink
  Color(0xFF212121), // dark grey
  Color(0xFF1A1A2E), // dark navy
  Color(0xFF1B1B1B), // near-black
];

/// Same palette as [kCanvasColors] in `#RRGGBBAA` hex format,
/// for use with [InkBlock.backgroundColor] fields.
final kCanvasColorsHex = kCanvasColors.map(_colorToHex).toList();

String _colorToHex(Color color) {
  final v = color.toARGB32(); // 0xAARRGGBB
  final a = (v >> 24) & 0xFF;
  final r = (v >> 16) & 0xFF;
  final g = (v >> 8) & 0xFF;
  final b = v & 0xFF;
  return '#'
      '${r.toRadixString(16).padLeft(2, '0')}'
      '${g.toRadixString(16).padLeft(2, '0')}'
      '${b.toRadixString(16).padLeft(2, '0')}'
      '${a.toRadixString(16).padLeft(2, '0')}';
}
