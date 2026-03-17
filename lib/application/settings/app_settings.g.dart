// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_settings.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AppSettings _$AppSettingsFromJson(Map<String, dynamic> json) => _AppSettings(
  themeMode: json['theme_mode'] == null
      ? ThemeMode.system
      : const _ThemeModeConverter().fromJson(json['theme_mode'] as String),
  markdownFontFamily: json['markdown_font_family'] as String? ?? 'Roboto',
  markdownFontSize: (json['markdown_font_size'] as num?)?.toDouble() ?? 16.0,
  defaultInkColor: json['default_ink_color'] == null
      ? const Color(0xFF000000)
      : const _ColorConverter().fromJson(
          (json['default_ink_color'] as num).toInt(),
        ),
  defaultInkStrokeWidth:
      (json['default_ink_stroke_width'] as num?)?.toDouble() ?? 2.0,
  defaultCanvasBackground: const _NullableColorConverter().fromJson(
    (json['default_canvas_background'] as num?)?.toInt(),
  ),
  defaultLineColor: const _NullableColorConverter().fromJson(
    (json['default_line_color'] as num?)?.toInt(),
  ),
  autoSaveEnabled: json['auto_save_enabled'] as bool? ?? false,
  autoSaveIntervalSeconds:
      (json['auto_save_interval_seconds'] as num?)?.toInt() ?? 30,
  defaultInkBackground:
      $enumDecodeNullable(
        _$InkBackgroundEnumMap,
        json['default_ink_background'],
      ) ??
      InkBackground.plain,
  defaultBackgroundSpacing:
      (json['default_background_spacing'] as num?)?.toDouble() ?? 24.0,
  defaultWorkspacePath: json['default_workspace_path'] as String?,
  workspaceConfigured: json['workspace_configured'] as bool? ?? false,
  defaultEraserRadius:
      (json['default_eraser_radius'] as num?)?.toDouble() ?? 20.0,
  stylusOnlyMode: json['stylus_only_mode'] as bool? ?? false,
);

Map<String, dynamic> _$AppSettingsToJson(
  _AppSettings instance,
) => <String, dynamic>{
  'theme_mode': const _ThemeModeConverter().toJson(instance.themeMode),
  'markdown_font_family': instance.markdownFontFamily,
  'markdown_font_size': instance.markdownFontSize,
  'default_ink_color': const _ColorConverter().toJson(instance.defaultInkColor),
  'default_ink_stroke_width': instance.defaultInkStrokeWidth,
  'default_canvas_background': const _NullableColorConverter().toJson(
    instance.defaultCanvasBackground,
  ),
  'default_line_color': const _NullableColorConverter().toJson(
    instance.defaultLineColor,
  ),
  'auto_save_enabled': instance.autoSaveEnabled,
  'auto_save_interval_seconds': instance.autoSaveIntervalSeconds,
  'default_ink_background':
      _$InkBackgroundEnumMap[instance.defaultInkBackground]!,
  'default_background_spacing': instance.defaultBackgroundSpacing,
  'default_workspace_path': instance.defaultWorkspacePath,
  'workspace_configured': instance.workspaceConfigured,
  'default_eraser_radius': instance.defaultEraserRadius,
  'stylus_only_mode': instance.stylusOnlyMode,
};

const _$InkBackgroundEnumMap = {
  InkBackground.plain: 'plain',
  InkBackground.ruled: 'ruled',
  InkBackground.grid: 'grid',
  InkBackground.dotted: 'dotted',
  InkBackground.isometric: 'isometric',
};
