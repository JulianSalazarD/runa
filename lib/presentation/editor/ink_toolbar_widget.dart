import 'package:flutter/material.dart';
import 'package:runa/domain/domain.dart';
import 'package:runa/presentation/shared/canvas_colors.dart';

import 'selection_mode.dart';

// ---------------------------------------------------------------------------
// Shape tool metadata
// ---------------------------------------------------------------------------

const _kShapeTools = [
  (type: ShapeType.line, icon: Icons.remove, label: 'Línea'),
  (type: ShapeType.rect, icon: Icons.crop_square_outlined, label: 'Rectángulo'),
  (type: ShapeType.oval, icon: Icons.circle_outlined, label: 'Óvalo'),
  (type: ShapeType.triangle, icon: Icons.change_history_outlined, label: 'Triángulo'),
  (type: ShapeType.arrow, icon: Icons.arrow_forward, label: 'Flecha'),
];

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

/// Available stroke widths: very fine / fine / medium / thick.
const _kWidths = [1.0, 2.0, 4.0, 8.0];
const _kWidthLabels = ['Muy fino', 'Fino', 'Medio', 'Grueso'];

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
    this.activeBackground,
    this.backgroundSpacing,
    this.backgroundLineColor,
    this.backgroundCanvasColor,
    this.onBackgroundChanged,
    this.onBackgroundSpacingChanged,
    this.onBackgroundLineColorChanged,
    this.onBackgroundCanvasColorChanged,
    this.textFontSize,
    this.textBold,
    this.textItalic,
    this.onTextFontSizeChanged,
    this.onTextBoldChanged,
    this.onTextItalicChanged,
    this.activeShapeType,
    this.onShapeTypeChanged,
    this.activeSelectionMode,
    this.onSelectionModeChanged,
  });

  final StrokeTool activeTool;
  final String activeColor;
  final double activeWidth;
  final ValueChanged<StrokeTool> onToolChanged;
  final ValueChanged<String> onColorChanged;
  final ValueChanged<double> onWidthChanged;
  final InkBackground? activeBackground;
  final double? backgroundSpacing;
  final String? backgroundLineColor;

  /// Canvas fill color in `#RRGGBBAA` format. Null = transparent.
  final String? backgroundCanvasColor;
  final ValueChanged<InkBackground>? onBackgroundChanged;
  final ValueChanged<double>? onBackgroundSpacingChanged;
  final ValueChanged<String>? onBackgroundLineColorChanged;

  /// Called with the new canvas color, or null to reset to transparent.
  final ValueChanged<String?>? onBackgroundCanvasColorChanged;

  final double? textFontSize;
  final bool? textBold;
  final bool? textItalic;
  final ValueChanged<double>? onTextFontSizeChanged;
  final ValueChanged<bool>? onTextBoldChanged;
  final ValueChanged<bool>? onTextItalicChanged;

  /// Currently active geometric shape tool. Null = no shape tool selected.
  final ShapeType? activeShapeType;

  /// Called when the user selects or deselects a shape tool.
  final ValueChanged<ShapeType?>? onShapeTypeChanged;

  /// Active selection sub-mode. Null = selection tool not active.
  final SelectionMode? activeSelectionMode;

  /// Called when the user activates/changes/deactivates the selection tool.
  final ValueChanged<SelectionMode?>? onSelectionModeChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
      child: Wrap(
        spacing: 2,
        runSpacing: 4,
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
            _ToolButton(
              icon: Icons.text_fields,
              label: 'Texto',
              tool: StrokeTool.text,
              activeTool: activeTool,
              onTap: onToolChanged,
            ),
            const SizedBox(width: 8),
            // Color swatches.
            for (final color in _kColors)
              _ColorSwatch(
                color: color,
                isSelected: color == activeColor,
                onTap: () => onColorChanged(color),
              ),
            const SizedBox(width: 8),
            // Width options.
            for (int i = 0; i < _kWidths.length; i++)
              _WidthButton(
                width: _kWidths[i],
                label: _kWidthLabels[i],
                isSelected: activeWidth == _kWidths[i],
                onTap: () => onWidthChanged(_kWidths[i]),
              ),
            if (activeTool == StrokeTool.text &&
                onTextFontSizeChanged != null) ...[
              const SizedBox(width: 8),
              for (final size in [10.0, 14.0, 18.0, 24.0, 32.0])
                _FontSizeButton(
                  fontSize: size,
                  isSelected: textFontSize == size,
                  onTap: () => onTextFontSizeChanged!(size),
                ),
              const SizedBox(width: 4),
              // Bold toggle
              Tooltip(
                message: 'Negrita',
                child: InkWell(
                  onTap: () =>
                      onTextBoldChanged?.call(!(textBold ?? false)),
                  borderRadius: BorderRadius.circular(6),
                  child: Container(
                    width: 28,
                    height: 28,
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: (textBold ?? false)
                          ? Theme.of(context).colorScheme.primaryContainer
                          : null,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'B',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: (textBold ?? false)
                            ? Theme.of(context)
                                .colorScheme
                                .onPrimaryContainer
                            : Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
                ),
              ),
              // Italic toggle
              Tooltip(
                message: 'Cursiva',
                child: InkWell(
                  onTap: () =>
                      onTextItalicChanged?.call(!(textItalic ?? false)),
                  borderRadius: BorderRadius.circular(6),
                  child: Container(
                    width: 28,
                    height: 28,
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: (textItalic ?? false)
                          ? Theme.of(context).colorScheme.primaryContainer
                          : null,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'I',
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        fontSize: 14,
                        color: (textItalic ?? false)
                            ? Theme.of(context)
                                .colorScheme
                                .onPrimaryContainer
                            : Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
                ),
              ),
            ],
            if (onSelectionModeChanged != null) ...[
              const SizedBox(width: 8),
              // Main selection toggle button.
              _SelectionButton(
                activeSelectionMode: activeSelectionMode,
                onTap: () {
                  // Toggle: activate rect by default, deactivate if already on.
                  onSelectionModeChanged!(
                    activeSelectionMode != null ? null : SelectionMode.rect,
                  );
                },
              ),
              // Rect / Lasso sub-toggle (only when selection is active).
              if (activeSelectionMode != null) ...[
                const SizedBox(width: 4),
                _SelectionSubButton(
                  icon: Icons.crop_square_outlined,
                  label: 'Rectangular',
                  isActive: activeSelectionMode == SelectionMode.rect,
                  onTap: () =>
                      onSelectionModeChanged!(SelectionMode.rect),
                ),
                _SelectionSubButton(
                  icon: Icons.gesture,
                  label: 'Lasso',
                  isActive: activeSelectionMode == SelectionMode.lasso,
                  onTap: () =>
                      onSelectionModeChanged!(SelectionMode.lasso),
                ),
              ],
            ],
            if (onShapeTypeChanged != null) ...[
              const SizedBox(width: 8),
              for (final entry in _kShapeTools)
                _ShapeButton(
                  icon: entry.icon,
                  label: entry.label,
                  shapeType: entry.type,
                  activeShapeType: activeShapeType,
                  onTap: (ShapeType type) {
                    // Toggle off if already active, else activate.
                    onShapeTypeChanged!(type == activeShapeType ? null : type);
                  },
                ),
            ],
            if (onBackgroundChanged != null) ...[
              const SizedBox(width: 8),
              _BackgroundButton(
                background: activeBackground!,
                spacing: backgroundSpacing!,
                lineColor: backgroundLineColor,
                canvasColor: backgroundCanvasColor,
                onBackgroundChanged: onBackgroundChanged!,
                onSpacingChanged: onBackgroundSpacingChanged!,
                onLineColorChanged: onBackgroundLineColorChanged!,
                onCanvasColorChanged: onBackgroundCanvasColorChanged,
              ),
            ],
        ],
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

// ---------------------------------------------------------------------------
// _BackgroundButton — opens a dialog to configure InkBlock background
// ---------------------------------------------------------------------------

class _BackgroundButton extends StatefulWidget {
  const _BackgroundButton({
    required this.background,
    required this.spacing,
    this.lineColor,
    this.canvasColor,
    required this.onBackgroundChanged,
    required this.onSpacingChanged,
    required this.onLineColorChanged,
    this.onCanvasColorChanged,
  });

  final InkBackground background;
  final double spacing;
  final String? lineColor;
  final String? canvasColor;
  final ValueChanged<InkBackground> onBackgroundChanged;
  final ValueChanged<double> onSpacingChanged;
  final ValueChanged<String> onLineColorChanged;
  final ValueChanged<String?>? onCanvasColorChanged;

  @override
  State<_BackgroundButton> createState() => _BackgroundButtonState();
}

class _BackgroundButtonState extends State<_BackgroundButton> {
  void _openDialog() {
    showDialog<void>(
      context: context,
      builder: (ctx) => _BackgroundDialog(
        background: widget.background,
        spacing: widget.spacing,
        lineColor: widget.lineColor,
        canvasColor: widget.canvasColor,
        onBackgroundChanged: widget.onBackgroundChanged,
        onSpacingChanged: widget.onSpacingChanged,
        onLineColorChanged: widget.onLineColorChanged,
        onCanvasColorChanged: widget.onCanvasColorChanged,
      ),
    );
  }

  static IconData _icon(InkBackground bg) => switch (bg) {
        InkBackground.plain => Icons.crop_landscape_outlined,
        InkBackground.ruled => Icons.format_align_justify,
        InkBackground.grid => Icons.grid_on_outlined,
        InkBackground.dotted => Icons.grain,
        InkBackground.isometric => Icons.change_history_outlined,
      };

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Tooltip(
      message: 'Fondo del canvas',
      child: InkWell(
        onTap: _openDialog,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          width: 32,
          height: 32,
          margin: const EdgeInsets.symmetric(horizontal: 2),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: widget.background != InkBackground.plain
                ? colorScheme.primaryContainer
                : null,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(
            _icon(widget.background),
            size: 18,
            color: widget.background != InkBackground.plain
                ? colorScheme.onPrimaryContainer
                : colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// _BackgroundDialog
// ---------------------------------------------------------------------------

class _BackgroundDialog extends StatefulWidget {
  const _BackgroundDialog({
    required this.background,
    required this.spacing,
    this.lineColor,
    this.canvasColor,
    required this.onBackgroundChanged,
    required this.onSpacingChanged,
    required this.onLineColorChanged,
    this.onCanvasColorChanged,
  });

  final InkBackground background;
  final double spacing;
  final String? lineColor;
  final String? canvasColor;
  final ValueChanged<InkBackground> onBackgroundChanged;
  final ValueChanged<double> onSpacingChanged;
  final ValueChanged<String> onLineColorChanged;
  final ValueChanged<String?>? onCanvasColorChanged;

  @override
  State<_BackgroundDialog> createState() => _BackgroundDialogState();
}

class _BackgroundDialogState extends State<_BackgroundDialog> {
  late double _spacing;

  @override
  void initState() {
    super.initState();
    _spacing = widget.spacing;
  }

  static String _label(InkBackground bg) => switch (bg) {
        InkBackground.plain => 'Sin fondo',
        InkBackground.ruled => 'Rayado',
        InkBackground.grid => 'Cuadriculado',
        InkBackground.dotted => 'Puntilleado',
        InkBackground.isometric => 'Isométrico',
      };

  static IconData _icon(InkBackground bg) => switch (bg) {
        InkBackground.plain => Icons.crop_landscape_outlined,
        InkBackground.ruled => Icons.format_align_justify,
        InkBackground.grid => Icons.grid_on_outlined,
        InkBackground.dotted => Icons.grain,
        InkBackground.isometric => Icons.change_history_outlined,
      };

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return AlertDialog(
      title: const Text('Fondo del canvas'),
      contentPadding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      content: SizedBox(
        width: 320,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Background type grid
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: InkBackground.values.map((bg) {
                final isSelected = bg == widget.background;
                return GestureDetector(
                  onTap: () {
                    widget.onBackgroundChanged(bg);
                    Navigator.of(context).pop();
                  },
                  child: Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? colorScheme.primaryContainer
                          : colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                      border: isSelected
                          ? Border.all(color: colorScheme.primary, width: 2)
                          : null,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _icon(bg),
                          size: 20,
                          color: isSelected
                              ? colorScheme.onPrimaryContainer
                              : colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _label(bg),
                          style: TextStyle(
                            fontSize: 9,
                            color: isSelected
                                ? colorScheme.onPrimaryContainer
                                : colorScheme.onSurfaceVariant,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            if (widget.background != InkBackground.plain) ...[
              const SizedBox(height: 16),
              Text(
                'Espaciado: ${_spacing.round()} px',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              Slider(
                value: _spacing,
                min: 12,
                max: 48,
                divisions: 9,
                onChanged: (v) {
                  setState(() => _spacing = v);
                  widget.onSpacingChanged(v);
                },
              ),
              const SizedBox(height: 8),
              Text(
                'Color de líneas',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 4,
                children: [
                  // "Auto" option (null = theme default)
                  Container(
                    width: 22,
                    height: 22,
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: widget.lineColor == null
                            ? colorScheme.primary
                            : colorScheme.outlineVariant,
                        width: widget.lineColor == null ? 2 : 1,
                      ),
                    ),
                    child: Icon(Icons.auto_awesome, size: 10, color: colorScheme.onSurface),
                  ),
                  ..._kColors.map((color) {
                    final isSelected = color == widget.lineColor;
                    final c = _hexToColor(color);
                    return GestureDetector(
                      onTap: () => widget.onLineColorChanged(color),
                      child: Container(
                        width: 22,
                        height: 22,
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        decoration: BoxDecoration(
                          color: c,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected ? colorScheme.primary : colorScheme.outlineVariant,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ],
            if (widget.onCanvasColorChanged != null) ...[
              const SizedBox(height: 12),
              Text('Color de fondo', style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: 6),
              Wrap(
                spacing: 4,
                children: [
                  // "Transparente" option
                  GestureDetector(
                    onTap: () => widget.onCanvasColorChanged!(null),
                    child: Container(
                      width: 22,
                      height: 22,
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: widget.canvasColor == null
                              ? colorScheme.primary
                              : colorScheme.outlineVariant,
                          width: widget.canvasColor == null ? 2 : 1,
                        ),
                      ),
                      child: Icon(Icons.do_not_disturb_alt, size: 12, color: colorScheme.onSurface),
                    ),
                  ),
                  ...kCanvasColorsHex.map((color) {
                    final isSelected = color == widget.canvasColor;
                    final c = _hexToColor(color);
                    return GestureDetector(
                      onTap: () => widget.onCanvasColorChanged!(color),
                      child: Container(
                        width: 22,
                        height: 22,
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        decoration: BoxDecoration(
                          color: c,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected ? colorScheme.primary : colorScheme.outlineVariant,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ],
            const SizedBox(height: 12),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cerrar'),
        ),
      ],
    );
  }

  static Color _hexToColor(String hex) {
    final h = hex.replaceFirst('#', '');
    final r = int.parse(h.substring(0, 2), radix: 16);
    final g = int.parse(h.substring(2, 4), radix: 16);
    final b = int.parse(h.substring(4, 6), radix: 16);
    final a = int.parse(h.substring(6, 8), radix: 16);
    return Color.fromARGB(a, r, g, b);
  }
}

// ---------------------------------------------------------------------------
// _SelectionButton / _SelectionSubButton
// ---------------------------------------------------------------------------

class _SelectionButton extends StatelessWidget {
  const _SelectionButton({
    required this.activeSelectionMode,
    required this.onTap,
  });

  final SelectionMode? activeSelectionMode;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isActive = activeSelectionMode != null;
    final colorScheme = Theme.of(context).colorScheme;
    return Tooltip(
      message: 'Selección',
      child: InkWell(
        onTap: onTap,
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
            Icons.open_with,
            size: 18,
            color: isActive
                ? colorScheme.onPrimaryContainer
                : colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}

class _SelectionSubButton extends StatelessWidget {
  const _SelectionSubButton({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Tooltip(
      message: label,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          width: 28,
          height: 28,
          margin: const EdgeInsets.symmetric(horizontal: 1),
          decoration: BoxDecoration(
            color: isActive ? colorScheme.secondaryContainer : null,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(
            icon,
            size: 16,
            color: isActive
                ? colorScheme.onSecondaryContainer
                : colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// _ShapeButton
// ---------------------------------------------------------------------------

class _ShapeButton extends StatelessWidget {
  const _ShapeButton({
    required this.icon,
    required this.label,
    required this.shapeType,
    required this.activeShapeType,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final ShapeType shapeType;
  final ShapeType? activeShapeType;
  final ValueChanged<ShapeType> onTap;

  @override
  Widget build(BuildContext context) {
    final isActive = shapeType == activeShapeType;
    final colorScheme = Theme.of(context).colorScheme;
    return Tooltip(
      message: label,
      child: InkWell(
        onTap: () => onTap(shapeType),
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
            color: isActive
                ? colorScheme.onPrimaryContainer
                : colorScheme.onSurface,
            semanticLabel: label,
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// _FontSizeButton
// ---------------------------------------------------------------------------

class _FontSizeButton extends StatelessWidget {
  const _FontSizeButton({
    required this.fontSize,
    required this.isSelected,
    required this.onTap,
  });

  final double fontSize;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Tooltip(
      message: '${fontSize.round()}px',
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 28,
          height: 28,
          margin: const EdgeInsets.symmetric(horizontal: 1),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? colorScheme.primaryContainer : null,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            '${fontSize.round()}',
            style: TextStyle(
              fontSize: 10,
              color: isSelected
                  ? colorScheme.onPrimaryContainer
                  : colorScheme.onSurface,
            ),
          ),
        ),
      ),
    );
  }
}
