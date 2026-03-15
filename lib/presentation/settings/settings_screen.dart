import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:runa/application/application.dart';
import 'package:runa/domain/domain.dart';
import 'package:runa/presentation/shared/canvas_colors.dart';

// ---------------------------------------------------------------------------
// Preset palettes
// ---------------------------------------------------------------------------

const _kInkColors = [
  Color(0xFF000000), // black
  Color(0xFF1E1E2E), // dark blue-black
  Color(0xFF212121), // near-black
  Color(0xFF5C4033), // dark brown
  Color(0xFF1565C0), // dark blue
  Color(0xFF1B5E20), // dark green
  Color(0xFF880E4F), // dark pink
  Color(0xFFB71C1C), // dark red
  Color(0xFFE65100), // dark orange
  Color(0xFFF9A825), // amber
  Color(0xFFFFFFFF), // white
  Color(0xFF9E9E9E), // grey
];


const _kFontFamilies = [
  'Roboto',
  'Ubuntu',
  'Liberation Serif',
  'Noto Serif',
  'Fira Code',
  'DejaVu Sans',
];

// ---------------------------------------------------------------------------
// SettingsScreen
// ---------------------------------------------------------------------------

/// Full-screen settings panel accessible from the sidebar gear icon.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Configuración')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ---------------------------------------------------------------
          // Apariencia
          // ---------------------------------------------------------------
          _SectionHeader('Apariencia'),
          _SettingsTile(
            label: 'Tema',
            child: SegmentedButton<ThemeMode>(
              segments: const [
                ButtonSegment(
                  value: ThemeMode.system,
                  label: Text('Sistema'),
                  icon: Icon(Icons.brightness_auto),
                ),
                ButtonSegment(
                  value: ThemeMode.light,
                  label: Text('Claro'),
                  icon: Icon(Icons.light_mode),
                ),
                ButtonSegment(
                  value: ThemeMode.dark,
                  label: Text('Oscuro'),
                  icon: Icon(Icons.dark_mode),
                ),
              ],
              selected: {settings.themeMode},
              onSelectionChanged: (s) =>
                  notifier.update(settings.copyWith(themeMode: s.first)),
            ),
          ),
          const Divider(height: 32),

          // ---------------------------------------------------------------
          // Markdown
          // ---------------------------------------------------------------
          _SectionHeader('Markdown'),
          _SettingsTile(
            label: 'Fuente',
            child: DropdownButton<String>(
              value: _kFontFamilies.contains(settings.markdownFontFamily)
                  ? settings.markdownFontFamily
                  : _kFontFamilies.first,
              items: _kFontFamilies
                  .map((f) => DropdownMenuItem(value: f, child: Text(f)))
                  .toList(),
              onChanged: (f) {
                if (f != null) {
                  notifier.update(settings.copyWith(markdownFontFamily: f));
                }
              },
            ),
          ),
          _SettingsTile(
            label: 'Tamaño (${settings.markdownFontSize.round()} pt)',
            child: Slider(
              value: settings.markdownFontSize,
              min: 10,
              max: 32,
              divisions: 22,
              label: '${settings.markdownFontSize.round()}',
              onChanged: (v) =>
                  notifier.update(settings.copyWith(markdownFontSize: v)),
            ),
          ),
          const Divider(height: 32),

          // ---------------------------------------------------------------
          // Canvas de escritura
          // ---------------------------------------------------------------
          _SectionHeader('Canvas de escritura'),
          _SettingsTile(
            label: 'Color del lápiz',
            child: _ColorSwatchRow(
              colors: _kInkColors,
              selected: settings.defaultInkColor,
              onSelected: (c) =>
                  notifier.update(settings.copyWith(defaultInkColor: c)),
            ),
          ),
          _SettingsTile(
            label:
                'Grosor del lápiz (${settings.defaultInkStrokeWidth.toStringAsFixed(1)})',
            child: Slider(
              value: settings.defaultInkStrokeWidth,
              min: 0.5,
              max: 10,
              divisions: 19,
              label: settings.defaultInkStrokeWidth.toStringAsFixed(1),
              onChanged: (v) =>
                  notifier.update(settings.copyWith(defaultInkStrokeWidth: v)),
            ),
          ),
          _SettingsTile(
            label: 'Tipo de fondo del canvas',
            child: _InkBackgroundSelector(
              selected: settings.defaultInkBackground,
              onSelected: (bg) =>
                  notifier.update(settings.copyWith(defaultInkBackground: bg)),
            ),
          ),
          _SettingsTile(
            label: 'Color de fondo del canvas',
            child: _NullableColorSwatchRow(
              colors: kCanvasColors,
              selected: settings.defaultCanvasBackground,
              onSelected: (c) =>
                  notifier.update(settings.copyWith(defaultCanvasBackground: c)),
            ),
          ),
          _SettingsTile(
            label: 'Color de líneas del canvas',
            child: _NullableColorSwatchRow(
              colors: _kInkColors,
              selected: settings.defaultLineColor,
              onSelected: (c) =>
                  notifier.update(settings.copyWith(defaultLineColor: c)),
            ),
          ),
          const Divider(height: 32),

          // ---------------------------------------------------------------
          // Workspace
          // ---------------------------------------------------------------
          _SectionHeader('Workspace'),
          SwitchListTile(
            title: const Text('Auto-guardado'),
            subtitle: const Text('Guardar automáticamente al editar'),
            value: settings.autoSaveEnabled,
            onChanged: (v) =>
                notifier.update(settings.copyWith(autoSaveEnabled: v)),
          ),
          _SettingsTile(
            label:
                'Intervalo de auto-guardado (${settings.autoSaveIntervalSeconds} s)',
            child: Slider(
              value: settings.autoSaveIntervalSeconds.toDouble(),
              min: 5,
              max: 300,
              divisions: 59,
              label: '${settings.autoSaveIntervalSeconds} s',
              onChanged: settings.autoSaveEnabled
                  ? (v) => notifier.update(
                      settings.copyWith(autoSaveIntervalSeconds: v.round()))
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Helper widgets
// ---------------------------------------------------------------------------

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.title);
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: Theme.of(context)
            .textTheme
            .titleMedium
            ?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({required this.label, required this.child});
  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 4),
          child,
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Color swatch pickers
// ---------------------------------------------------------------------------

class _ColorSwatchRow extends StatelessWidget {
  const _ColorSwatchRow({
    required this.colors,
    required this.selected,
    required this.onSelected,
  });

  final List<Color> colors;
  final Color selected;
  final ValueChanged<Color> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: colors.map((c) => _Swatch(color: c, isSelected: c == selected, onTap: () => onSelected(c))).toList(),
    );
  }
}

/// Like [_ColorSwatchRow] but also has a "Auto" chip that sets the value to null.
class _NullableColorSwatchRow extends StatelessWidget {
  const _NullableColorSwatchRow({
    required this.colors,
    required this.selected,
    required this.onSelected,
  });

  final List<Color> colors;
  final Color? selected;
  final ValueChanged<Color?> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        // "Auto" chip
        GestureDetector(
          onTap: () => onSelected(null),
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              border: Border.all(
                color: selected == null
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).dividerColor,
                width: selected == null ? 2.5 : 1,
              ),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Center(
              child: Text(
                'A',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
          ),
        ),
        ...colors.map((c) => _Swatch(
              color: c,
              isSelected: c == selected,
              onTap: () => onSelected(c),
            )),
      ],
    );
  }
}

class _Swatch extends StatelessWidget {
  const _Swatch({
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: color,
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).dividerColor,
            width: isSelected ? 2.5 : 1,
          ),
          borderRadius: BorderRadius.circular(6),
        ),
        child: isSelected
            ? Icon(
                Icons.check,
                size: 16,
                color: color.computeLuminance() > 0.5
                    ? Colors.black
                    : Colors.white,
              )
            : null,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Ink background type selector
// ---------------------------------------------------------------------------

const _kInkBackgroundOptions = [
  (value: InkBackground.plain, label: 'Sin fondo', icon: Icons.crop_square),
  (value: InkBackground.ruled, label: 'Rayado', icon: Icons.reorder),
  (value: InkBackground.grid, label: 'Cuadriculado', icon: Icons.grid_4x4),
  (value: InkBackground.dotted, label: 'Punteado', icon: Icons.grain),
  (value: InkBackground.isometric, label: 'Isométrico', icon: Icons.change_history_outlined),
];

class _InkBackgroundSelector extends StatelessWidget {
  const _InkBackgroundSelector({
    required this.selected,
    required this.onSelected,
  });

  final InkBackground selected;
  final ValueChanged<InkBackground> onSelected;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _kInkBackgroundOptions.map((opt) {
        final isSelected = opt.value == selected;
        return GestureDetector(
          onTap: () => onSelected(opt.value),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: isSelected
                  ? colorScheme.primaryContainer
                  : colorScheme.surfaceContainerHighest,
              border: Border.all(
                color: isSelected ? colorScheme.primary : colorScheme.outline,
                width: isSelected ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(opt.icon, size: 16,
                    color: isSelected
                        ? colorScheme.onPrimaryContainer
                        : colorScheme.onSurface),
                const SizedBox(width: 4),
                Text(opt.label,
                    style: TextStyle(
                      fontSize: 12,
                      color: isSelected
                          ? colorScheme.onPrimaryContainer
                          : colorScheme.onSurface,
                    )),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
