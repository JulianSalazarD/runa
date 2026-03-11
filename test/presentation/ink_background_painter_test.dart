import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:runa/domain/domain.dart';
import 'package:runa/presentation/editor/ink_background_painter.dart';

void main() {
  group('InkBackgroundPainter.shouldRepaint', () {
    const base = InkBackgroundPainter(
      background: InkBackground.ruled,
      spacing: 24.0,
      defaultColor: Colors.grey,
    );

    test('returns false when params are identical', () {
      const other = InkBackgroundPainter(
        background: InkBackground.ruled,
        spacing: 24.0,
        defaultColor: Colors.grey,
      );
      expect(base.shouldRepaint(other), isFalse);
    });

    test('returns true when background changes', () {
      const other = InkBackgroundPainter(
        background: InkBackground.grid,
        spacing: 24.0,
        defaultColor: Colors.grey,
      );
      expect(base.shouldRepaint(other), isTrue);
    });

    test('returns true when spacing changes', () {
      const other = InkBackgroundPainter(
        background: InkBackground.ruled,
        spacing: 32.0,
        defaultColor: Colors.grey,
      );
      expect(base.shouldRepaint(other), isTrue);
    });

    test('returns true when lineColor changes', () {
      const withColor = InkBackgroundPainter(
        background: InkBackground.ruled,
        spacing: 24.0,
        lineColor: Colors.blue,
        defaultColor: Colors.grey,
      );
      expect(withColor.shouldRepaint(base), isTrue);
    });

    test('returns true when defaultColor changes', () {
      const other = InkBackgroundPainter(
        background: InkBackground.ruled,
        spacing: 24.0,
        defaultColor: Colors.blue,
      );
      expect(base.shouldRepaint(other), isTrue);
    });
  });

  group('InkBackgroundPainter — plain background', () {
    test('plain background does not throw', () {
      const painter = InkBackgroundPainter(
        background: InkBackground.plain,
        spacing: 24.0,
        defaultColor: Colors.grey,
      );
      // Instantiating and calling shouldRepaint should not throw.
      expect(
        painter.shouldRepaint(painter),
        isFalse,
      );
    });
  });
}
