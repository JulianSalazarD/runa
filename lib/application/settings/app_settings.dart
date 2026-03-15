import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:runa/domain/domain.dart';

part 'app_settings.freezed.dart';
part 'app_settings.g.dart';

// ---------------------------------------------------------------------------
// JSON converters
// ---------------------------------------------------------------------------

class _ThemeModeConverter extends JsonConverter<ThemeMode, String> {
  const _ThemeModeConverter();

  @override
  ThemeMode fromJson(String json) => switch (json) {
        'light' => ThemeMode.light,
        'dark' => ThemeMode.dark,
        _ => ThemeMode.system,
      };

  @override
  String toJson(ThemeMode mode) => switch (mode) {
        ThemeMode.light => 'light',
        ThemeMode.dark => 'dark',
        _ => 'system',
      };
}

class _ColorConverter extends JsonConverter<Color, int> {
  const _ColorConverter();

  @override
  Color fromJson(int json) => Color(json);

  @override
  int toJson(Color color) => color.toARGB32();
}

class _NullableColorConverter extends JsonConverter<Color?, int?> {
  const _NullableColorConverter();

  @override
  Color? fromJson(int? json) => json != null ? Color(json) : null;

  @override
  int? toJson(Color? color) => color?.toARGB32();
}

// ---------------------------------------------------------------------------
// AppSettings model
// ---------------------------------------------------------------------------

@freezed
class AppSettings with _$AppSettings {
  @JsonSerializable(explicitToJson: true, fieldRename: FieldRename.snake)
  const factory AppSettings({
    /// Light / dark / system theme.
    @_ThemeModeConverter()
    @Default(ThemeMode.system)
    ThemeMode themeMode,

    /// Font family used in Markdown blocks.
    @Default('Roboto') String markdownFontFamily,

    /// Base font size used in Markdown blocks.
    @Default(16.0) double markdownFontSize,

    /// Default ink stroke color.
    @_ColorConverter()
    @Default(Color(0xFF000000))
    Color defaultInkColor,

    /// Default ink stroke width.
    @Default(2.0) double defaultInkStrokeWidth,

    /// Default canvas background. `null` → derived from current theme.
    @_NullableColorConverter() Color? defaultCanvasBackground,

    /// Whether auto-save is enabled.
    @Default(true) bool autoSaveEnabled,

    /// Auto-save interval in seconds (ignored when [autoSaveEnabled] is false).
    @Default(30) int autoSaveIntervalSeconds,

    /// Default background pattern for new ink canvas blocks.
    @Default(InkBackground.plain) InkBackground defaultInkBackground,

    /// Default workspace directory path. `null` → ~/Runa.
    String? defaultWorkspacePath,
  }) = _AppSettings;

  factory AppSettings.fromJson(Map<String, dynamic> json) =>
      _$AppSettingsFromJson(json);
}
