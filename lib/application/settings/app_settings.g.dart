// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_settings.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AppSettingsImpl _$$AppSettingsImplFromJson(Map<String, dynamic> json) =>
    _$AppSettingsImpl(
      themeMode: json['theme_mode'] == null
          ? ThemeMode.system
          : const _ThemeModeConverter().fromJson(json['theme_mode'] as String),
      markdownFontFamily: json['markdown_font_family'] as String? ?? 'Roboto',
      markdownFontSize:
          (json['markdown_font_size'] as num?)?.toDouble() ?? 16.0,
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
      autoSaveEnabled: json['auto_save_enabled'] as bool? ?? true,
      autoSaveIntervalSeconds:
          (json['auto_save_interval_seconds'] as num?)?.toInt() ?? 30,
      defaultInkBackground:
          $enumDecodeNullable(
            _$InkBackgroundEnumMap,
            json['default_ink_background'],
          ) ??
          InkBackground.plain,
      defaultWorkspacePath: json['default_workspace_path'] as String?,
    );

Map<String, dynamic> _$$AppSettingsImplToJson(
  _$AppSettingsImpl instance,
) => <String, dynamic>{
  'theme_mode': const _ThemeModeConverter().toJson(instance.themeMode),
  'markdown_font_family': instance.markdownFontFamily,
  'markdown_font_size': instance.markdownFontSize,
  'default_ink_color': const _ColorConverter().toJson(instance.defaultInkColor),
  'default_ink_stroke_width': instance.defaultInkStrokeWidth,
  'default_canvas_background': const _NullableColorConverter().toJson(
    instance.defaultCanvasBackground,
  ),
  'auto_save_enabled': instance.autoSaveEnabled,
  'auto_save_interval_seconds': instance.autoSaveIntervalSeconds,
  'default_ink_background':
      _$InkBackgroundEnumMap[instance.defaultInkBackground]!,
  'default_workspace_path': instance.defaultWorkspacePath,
};

const _$InkBackgroundEnumMap = {
  InkBackground.plain: 'plain',
  InkBackground.ruled: 'ruled',
  InkBackground.grid: 'grid',
  InkBackground.dotted: 'dotted',
  InkBackground.isometric: 'isometric',
};
