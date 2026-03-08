import 'package:flutter/material.dart';
import 'package:runa/domain/domain.dart';

// ---------------------------------------------------------------------------
// Palette constants
// ---------------------------------------------------------------------------

/// Fixed color palette in `#RRGGBBAA` format (10 colors).
const _kColors = [
  '#000000FF', // Black
  '#FFFFFFFF', // White
  '#FF0000FF', // Red
  '#00AA00FF', // Green
  '#0000FFFF', // Blue
  '#FFCC00FF', // Yellow
  '#FF8800FF', // Orange
  '#8800FFFF', // Purple
  '#00CCFFFF', // Cyan
  '#884400FF', // Brown
];

/// Available stroke widths: fine / medium / thick.
const _kWidths = [2.0, 4.0, 8.0];
const _kWidthLabels = ['Fino', 'Medio', 'Grueso'];

// ---------------------------------------------------------------------------
// InkToolbarWidget
// ---------------------------------------------------------------------------

/// Horizontal toolbar for selecting ink tool, color, and stroke width.
///
/// All state is managed externally; notify changes through the callbacks.
class InkToolbarWidget extends StatelessWidget {
  const InkToolbarWidget({
    super.key,
    required this.activeTool,
    required this.activeColor,
    required this.activeWidth,
    required this.onToolChanged,
    required this.onColorChanged,
    required this.onWidthChanged,
  });

  final StrokeTool activeTool;
  final String activeColor;
  final double activeWidth;
  final ValueChanged<StrokeTool> onToolChanged;
  final ValueChanged<String> onColorChanged;
  final ValueChanged<double> onWidthChanged;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            // Tool buttons.
            _ToolButton(
              icon: Icons.edit,
              label: 'Pluma',
              tool: StrokeTool.pen,
              activeTool: activeTool,
              onTap: onToolChanged,
            ),
            _ToolButton(
              icon: Icons.draw,
              label: 'Lápiz',
              tool: StrokeTool.pencil,
              activeTool: activeTool,
              onTap: onToolChanged,
            ),
            _ToolButton(
              icon: Icons.brush,
              label: 'Rotulador',
              tool: StrokeTool.marker,
              activeTool: activeTool,
              onTap: onToolChanged,
            ),
            _ToolButton(
              icon: Icons.auto_fix_normal,
              label: 'Borrador',
              tool: StrokeTool.eraser,
              activeTool: activeTool,
              onTap: onToolChanged,
            ),
            const VerticalDivider(indent: 4, endIndent: 4),
            // Color swatches.
            for (final color in _kColors)
              _ColorSwatch(
                color: color,
                isSelected: color == activeColor,
                onTap: () => onColorChanged(color),
              ),
            const VerticalDivider(indent: 4, endIndent: 4),
            // Width options.
            for (int i = 0; i < _kWidths.length; i++)
              _WidthButton(
                width: _kWidths[i],
                label: _kWidthLabels[i],
                isSelected: activeWidth == _kWidths[i],
                onTap: () => onWidthChanged(_kWidths[i]),
              ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// _ToolButton
// ---------------------------------------------------------------------------

class _ToolButton extends StatelessWidget {
  const _ToolButton({
    required this.icon,
    required this.label,
    required this.tool,
    required this.activeTool,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final StrokeTool tool;
  final StrokeTool activeTool;
  final ValueChanged<StrokeTool> onTap;

  @override
  Widget build(BuildContext context) {
    final isActive = tool == activeTool;
    final colorScheme = Theme.of(context).colorScheme;
    return Tooltip(
      message: label,
      child: InkWell(
        onTap: () => onTap(tool),
        borderRadius: BorderRadius.circular(6),
        child: Container(
          width: 32,
          height: 32,
          margin: const EdgeInsets.symmetric(horizontal: 2),
          decoration: BoxDecoration(
            color: isActive ? colorScheme.primaryContainer : null,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(
            icon,
            size: 18,
            color:
                isActive ? colorScheme.onPrimaryContainer : colorScheme.onSurface,
            semanticLabel: label,
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// _ColorSwatch
// ---------------------------------------------------------------------------

class _ColorSwatch extends StatelessWidget {
  const _ColorSwatch({
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  final String color;
  final bool isSelected;
  final VoidCallback onTap;

  Color _toFlutterColor() {
    final h = color.replaceFirst('#', '');
    final r = int.parse(h.substring(0, 2), radix: 16);
    final g = int.parse(h.substring(2, 4), radix: 16);
    final b = int.parse(h.substring(4, 6), radix: 16);
    final a = int.parse(h.substring(6, 8), radix: 16);
    return Color.fromARGB(a, r, g, b);
  }

  @override
  Widget build(BuildContext context) {
    final c = _toFlutterColor();
    return Tooltip(
      message: color,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 22,
          height: 22,
          margin: const EdgeInsets.symmetric(horizontal: 2),
          decoration: BoxDecoration(
            color: c,
            shape: BoxShape.circle,
            border: Border.all(
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.outlineVariant,
              width: isSelected ? 2 : 1,
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// _WidthButton
// ---------------------------------------------------------------------------

class _WidthButton extends StatelessWidget {
  const _WidthButton({
    required this.width,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final double width;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Tooltip(
      message: label,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 32,
          height: 32,
          margin: const EdgeInsets.symmetric(horizontal: 2),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? colorScheme.primaryContainer : null,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Container(
            width: width.clamp(2.0, 12.0),
            height: width.clamp(2.0, 12.0),
            decoration: BoxDecoration(
              color: isSelected
                  ? colorScheme.onPrimaryContainer
                  : colorScheme.onSurface,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }
}
