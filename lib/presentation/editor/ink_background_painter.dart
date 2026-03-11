import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:runa/domain/domain.dart';

/// [CustomPainter] that renders the background pattern of an [InkBlock].
///
/// Intended to be used as the [CustomPaint.painter] property, with
/// [InkPainter] as the [CustomPaint.foregroundPainter].
class InkBackgroundPainter extends CustomPainter {
  const InkBackgroundPainter({
    required this.background,
    required this.spacing,
    this.lineColor,
    required this.defaultColor,
    this.backgroundColor,
  });

  final InkBackground background;
  final double spacing;

  /// Explicit line color. When null, [defaultColor] at 20% opacity is used.
  final Color? lineColor;

  /// Theme color used as fallback when [lineColor] is null.
  final Color defaultColor;

  /// Canvas fill color. When null the canvas is transparent.
  final Color? backgroundColor;

  @override
  void paint(Canvas canvas, Size size) {
    if (backgroundColor != null) {
      canvas.drawRect(
        Offset.zero & size,
        Paint()..color = backgroundColor!,
      );
    }

    if (background == InkBackground.plain) return;

    final color = lineColor ?? defaultColor.withValues(alpha: 0.2);
    final paint = Paint()
      ..color = color
      ..strokeWidth = 0.5;

    switch (background) {
      case InkBackground.plain:
        break;
      case InkBackground.ruled:
        _drawRuled(canvas, size, paint);
      case InkBackground.grid:
        _drawGrid(canvas, size, paint);
      case InkBackground.dotted:
        _drawDotted(canvas, size, paint);
      case InkBackground.isometric:
        _drawIsometric(canvas, size, paint);
    }
  }

  void _drawRuled(Canvas canvas, Size size, Paint paint) {
    for (var y = spacing; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  void _drawGrid(Canvas canvas, Size size, Paint paint) {
    _drawRuled(canvas, size, paint);
    for (var x = spacing; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
  }

  void _drawDotted(Canvas canvas, Size size, Paint paint) {
    final dotPaint = Paint()
      ..color = paint.color
      ..style = PaintingStyle.fill;
    for (var y = spacing; y < size.height; y += spacing) {
      for (var x = spacing; x < size.width; x += spacing) {
        canvas.drawCircle(Offset(x, y), 1.5, dotPaint);
      }
    }
  }

  void _drawIsometric(Canvas canvas, Size size, Paint paint) {
    // Row height for equilateral triangles with base = spacing.
    final h = spacing * (math.sqrt(3) / 2);
    // Horizontal extent a diagonal line covers across the full height.
    final run = size.height / math.sqrt(3);

    // Horizontal lines.
    for (var y = h; y < size.height; y += h) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
    // Diagonals at +60° (upper-left to lower-right).
    for (var x = -run; x <= size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x + run, size.height), paint);
    }
    // Diagonals at -60° / 120° (upper-right to lower-left).
    for (var x = 0.0; x <= size.width + run; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x - run, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(InkBackgroundPainter old) =>
      old.background != background ||
      old.spacing != spacing ||
      old.lineColor != lineColor ||
      old.defaultColor != defaultColor ||
      old.backgroundColor != backgroundColor;
}
