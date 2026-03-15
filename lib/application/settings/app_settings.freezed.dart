// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'app_settings.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

AppSettings _$AppSettingsFromJson(Map<String, dynamic> json) {
  return _AppSettings.fromJson(json);
}

/// @nodoc
mixin _$AppSettings {
  /// Light / dark / system theme.
  @_ThemeModeConverter()
  ThemeMode get themeMode => throw _privateConstructorUsedError;

  /// Font family used in Markdown blocks.
  String get markdownFontFamily => throw _privateConstructorUsedError;

  /// Base font size used in Markdown blocks.
  double get markdownFontSize => throw _privateConstructorUsedError;

  /// Default ink stroke color.
  @_ColorConverter()
  Color get defaultInkColor => throw _privateConstructorUsedError;

  /// Default ink stroke width.
  double get defaultInkStrokeWidth => throw _privateConstructorUsedError;

  /// Default canvas background. `null` → derived from current theme.
  @_NullableColorConverter()
  Color? get defaultCanvasBackground => throw _privateConstructorUsedError;

  /// Whether auto-save is enabled.
  bool get autoSaveEnabled => throw _privateConstructorUsedError;

  /// Auto-save interval in seconds (ignored when [autoSaveEnabled] is false).
  int get autoSaveIntervalSeconds => throw _privateConstructorUsedError;

  /// Default background pattern for new ink canvas blocks.
  InkBackground get defaultInkBackground => throw _privateConstructorUsedError;

  /// Default workspace directory path. `null` → ~/Runa.
  String? get defaultWorkspacePath => throw _privateConstructorUsedError;

  /// Serializes this AppSettings to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AppSettings
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AppSettingsCopyWith<AppSettings> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AppSettingsCopyWith<$Res> {
  factory $AppSettingsCopyWith(
    AppSettings value,
    $Res Function(AppSettings) then,
  ) = _$AppSettingsCopyWithImpl<$Res, AppSettings>;
  @useResult
  $Res call({
    @_ThemeModeConverter() ThemeMode themeMode,
    String markdownFontFamily,
    double markdownFontSize,
    @_ColorConverter() Color defaultInkColor,
    double defaultInkStrokeWidth,
    @_NullableColorConverter() Color? defaultCanvasBackground,
    bool autoSaveEnabled,
    int autoSaveIntervalSeconds,
    InkBackground defaultInkBackground,
    String? defaultWorkspacePath,
  });
}

/// @nodoc
class _$AppSettingsCopyWithImpl<$Res, $Val extends AppSettings>
    implements $AppSettingsCopyWith<$Res> {
  _$AppSettingsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AppSettings
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? themeMode = null,
    Object? markdownFontFamily = null,
    Object? markdownFontSize = null,
    Object? defaultInkColor = null,
    Object? defaultInkStrokeWidth = null,
    Object? defaultCanvasBackground = freezed,
    Object? autoSaveEnabled = null,
    Object? autoSaveIntervalSeconds = null,
    Object? defaultInkBackground = null,
    Object? defaultWorkspacePath = freezed,
  }) {
    return _then(
      _value.copyWith(
            themeMode: null == themeMode
                ? _value.themeMode
                : themeMode // ignore: cast_nullable_to_non_nullable
                      as ThemeMode,
            markdownFontFamily: null == markdownFontFamily
                ? _value.markdownFontFamily
                : markdownFontFamily // ignore: cast_nullable_to_non_nullable
                      as String,
            markdownFontSize: null == markdownFontSize
                ? _value.markdownFontSize
                : markdownFontSize // ignore: cast_nullable_to_non_nullable
                      as double,
            defaultInkColor: null == defaultInkColor
                ? _value.defaultInkColor
                : defaultInkColor // ignore: cast_nullable_to_non_nullable
                      as Color,
            defaultInkStrokeWidth: null == defaultInkStrokeWidth
                ? _value.defaultInkStrokeWidth
                : defaultInkStrokeWidth // ignore: cast_nullable_to_non_nullable
                      as double,
            defaultCanvasBackground: freezed == defaultCanvasBackground
                ? _value.defaultCanvasBackground
                : defaultCanvasBackground // ignore: cast_nullable_to_non_nullable
                      as Color?,
            autoSaveEnabled: null == autoSaveEnabled
                ? _value.autoSaveEnabled
                : autoSaveEnabled // ignore: cast_nullable_to_non_nullable
                      as bool,
            autoSaveIntervalSeconds: null == autoSaveIntervalSeconds
                ? _value.autoSaveIntervalSeconds
                : autoSaveIntervalSeconds // ignore: cast_nullable_to_non_nullable
                      as int,
            defaultInkBackground: null == defaultInkBackground
                ? _value.defaultInkBackground
                : defaultInkBackground // ignore: cast_nullable_to_non_nullable
                      as InkBackground,
            defaultWorkspacePath: freezed == defaultWorkspacePath
                ? _value.defaultWorkspacePath
                : defaultWorkspacePath // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$AppSettingsImplCopyWith<$Res>
    implements $AppSettingsCopyWith<$Res> {
  factory _$$AppSettingsImplCopyWith(
    _$AppSettingsImpl value,
    $Res Function(_$AppSettingsImpl) then,
  ) = __$$AppSettingsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @_ThemeModeConverter() ThemeMode themeMode,
    String markdownFontFamily,
    double markdownFontSize,
    @_ColorConverter() Color defaultInkColor,
    double defaultInkStrokeWidth,
    @_NullableColorConverter() Color? defaultCanvasBackground,
    bool autoSaveEnabled,
    int autoSaveIntervalSeconds,
    InkBackground defaultInkBackground,
    String? defaultWorkspacePath,
  });
}

/// @nodoc
class __$$AppSettingsImplCopyWithImpl<$Res>
    extends _$AppSettingsCopyWithImpl<$Res, _$AppSettingsImpl>
    implements _$$AppSettingsImplCopyWith<$Res> {
  __$$AppSettingsImplCopyWithImpl(
    _$AppSettingsImpl _value,
    $Res Function(_$AppSettingsImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AppSettings
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? themeMode = null,
    Object? markdownFontFamily = null,
    Object? markdownFontSize = null,
    Object? defaultInkColor = null,
    Object? defaultInkStrokeWidth = null,
    Object? defaultCanvasBackground = freezed,
    Object? autoSaveEnabled = null,
    Object? autoSaveIntervalSeconds = null,
    Object? defaultInkBackground = null,
    Object? defaultWorkspacePath = freezed,
  }) {
    return _then(
      _$AppSettingsImpl(
        themeMode: null == themeMode
            ? _value.themeMode
            : themeMode // ignore: cast_nullable_to_non_nullable
                  as ThemeMode,
        markdownFontFamily: null == markdownFontFamily
            ? _value.markdownFontFamily
            : markdownFontFamily // ignore: cast_nullable_to_non_nullable
                  as String,
        markdownFontSize: null == markdownFontSize
            ? _value.markdownFontSize
            : markdownFontSize // ignore: cast_nullable_to_non_nullable
                  as double,
        defaultInkColor: null == defaultInkColor
            ? _value.defaultInkColor
            : defaultInkColor // ignore: cast_nullable_to_non_nullable
                  as Color,
        defaultInkStrokeWidth: null == defaultInkStrokeWidth
            ? _value.defaultInkStrokeWidth
            : defaultInkStrokeWidth // ignore: cast_nullable_to_non_nullable
                  as double,
        defaultCanvasBackground: freezed == defaultCanvasBackground
            ? _value.defaultCanvasBackground
            : defaultCanvasBackground // ignore: cast_nullable_to_non_nullable
                  as Color?,
        autoSaveEnabled: null == autoSaveEnabled
            ? _value.autoSaveEnabled
            : autoSaveEnabled // ignore: cast_nullable_to_non_nullable
                  as bool,
        autoSaveIntervalSeconds: null == autoSaveIntervalSeconds
            ? _value.autoSaveIntervalSeconds
            : autoSaveIntervalSeconds // ignore: cast_nullable_to_non_nullable
                  as int,
        defaultInkBackground: null == defaultInkBackground
            ? _value.defaultInkBackground
            : defaultInkBackground // ignore: cast_nullable_to_non_nullable
                  as InkBackground,
        defaultWorkspacePath: freezed == defaultWorkspacePath
            ? _value.defaultWorkspacePath
            : defaultWorkspacePath // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc

@JsonSerializable(explicitToJson: true, fieldRename: FieldRename.snake)
class _$AppSettingsImpl implements _AppSettings {
  const _$AppSettingsImpl({
    @_ThemeModeConverter() this.themeMode = ThemeMode.system,
    this.markdownFontFamily = 'Roboto',
    this.markdownFontSize = 16.0,
    @_ColorConverter() this.defaultInkColor = const Color(0xFF000000),
    this.defaultInkStrokeWidth = 2.0,
    @_NullableColorConverter() this.defaultCanvasBackground,
    this.autoSaveEnabled = true,
    this.autoSaveIntervalSeconds = 30,
    this.defaultInkBackground = InkBackground.plain,
    this.defaultWorkspacePath,
  });

  factory _$AppSettingsImpl.fromJson(Map<String, dynamic> json) =>
      _$$AppSettingsImplFromJson(json);

  /// Light / dark / system theme.
  @override
  @JsonKey()
  @_ThemeModeConverter()
  final ThemeMode themeMode;

  /// Font family used in Markdown blocks.
  @override
  @JsonKey()
  final String markdownFontFamily;

  /// Base font size used in Markdown blocks.
  @override
  @JsonKey()
  final double markdownFontSize;

  /// Default ink stroke color.
  @override
  @JsonKey()
  @_ColorConverter()
  final Color defaultInkColor;

  /// Default ink stroke width.
  @override
  @JsonKey()
  final double defaultInkStrokeWidth;

  /// Default canvas background. `null` → derived from current theme.
  @override
  @_NullableColorConverter()
  final Color? defaultCanvasBackground;

  /// Whether auto-save is enabled.
  @override
  @JsonKey()
  final bool autoSaveEnabled;

  /// Auto-save interval in seconds (ignored when [autoSaveEnabled] is false).
  @override
  @JsonKey()
  final int autoSaveIntervalSeconds;

  /// Default background pattern for new ink canvas blocks.
  @override
  @JsonKey()
  final InkBackground defaultInkBackground;

  /// Default workspace directory path. `null` → ~/Runa.
  @override
  final String? defaultWorkspacePath;

  @override
  String toString() {
    return 'AppSettings(themeMode: $themeMode, markdownFontFamily: $markdownFontFamily, markdownFontSize: $markdownFontSize, defaultInkColor: $defaultInkColor, defaultInkStrokeWidth: $defaultInkStrokeWidth, defaultCanvasBackground: $defaultCanvasBackground, autoSaveEnabled: $autoSaveEnabled, autoSaveIntervalSeconds: $autoSaveIntervalSeconds, defaultInkBackground: $defaultInkBackground, defaultWorkspacePath: $defaultWorkspacePath)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AppSettingsImpl &&
            (identical(other.themeMode, themeMode) ||
                other.themeMode == themeMode) &&
            (identical(other.markdownFontFamily, markdownFontFamily) ||
                other.markdownFontFamily == markdownFontFamily) &&
            (identical(other.markdownFontSize, markdownFontSize) ||
                other.markdownFontSize == markdownFontSize) &&
            (identical(other.defaultInkColor, defaultInkColor) ||
                other.defaultInkColor == defaultInkColor) &&
            (identical(other.defaultInkStrokeWidth, defaultInkStrokeWidth) ||
                other.defaultInkStrokeWidth == defaultInkStrokeWidth) &&
            (identical(
                  other.defaultCanvasBackground,
                  defaultCanvasBackground,
                ) ||
                other.defaultCanvasBackground == defaultCanvasBackground) &&
            (identical(other.autoSaveEnabled, autoSaveEnabled) ||
                other.autoSaveEnabled == autoSaveEnabled) &&
            (identical(
                  other.autoSaveIntervalSeconds,
                  autoSaveIntervalSeconds,
                ) ||
                other.autoSaveIntervalSeconds == autoSaveIntervalSeconds) &&
            (identical(other.defaultInkBackground, defaultInkBackground) ||
                other.defaultInkBackground == defaultInkBackground) &&
            (identical(other.defaultWorkspacePath, defaultWorkspacePath) ||
                other.defaultWorkspacePath == defaultWorkspacePath));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    themeMode,
    markdownFontFamily,
    markdownFontSize,
    defaultInkColor,
    defaultInkStrokeWidth,
    defaultCanvasBackground,
    autoSaveEnabled,
    autoSaveIntervalSeconds,
    defaultInkBackground,
    defaultWorkspacePath,
  );

  /// Create a copy of AppSettings
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AppSettingsImplCopyWith<_$AppSettingsImpl> get copyWith =>
      __$$AppSettingsImplCopyWithImpl<_$AppSettingsImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AppSettingsImplToJson(this);
  }
}

abstract class _AppSettings implements AppSettings {
  const factory _AppSettings({
    @_ThemeModeConverter() final ThemeMode themeMode,
    final String markdownFontFamily,
    final double markdownFontSize,
    @_ColorConverter() final Color defaultInkColor,
    final double defaultInkStrokeWidth,
    @_NullableColorConverter() final Color? defaultCanvasBackground,
    final bool autoSaveEnabled,
    final int autoSaveIntervalSeconds,
    final InkBackground defaultInkBackground,
    final String? defaultWorkspacePath,
  }) = _$AppSettingsImpl;

  factory _AppSettings.fromJson(Map<String, dynamic> json) =
      _$AppSettingsImpl.fromJson;

  /// Light / dark / system theme.
  @override
  @_ThemeModeConverter()
  ThemeMode get themeMode;

  /// Font family used in Markdown blocks.
  @override
  String get markdownFontFamily;

  /// Base font size used in Markdown blocks.
  @override
  double get markdownFontSize;

  /// Default ink stroke color.
  @override
  @_ColorConverter()
  Color get defaultInkColor;

  /// Default ink stroke width.
  @override
  double get defaultInkStrokeWidth;

  /// Default canvas background. `null` → derived from current theme.
  @override
  @_NullableColorConverter()
  Color? get defaultCanvasBackground;

  /// Whether auto-save is enabled.
  @override
  bool get autoSaveEnabled;

  /// Auto-save interval in seconds (ignored when [autoSaveEnabled] is false).
  @override
  int get autoSaveIntervalSeconds;

  /// Default background pattern for new ink canvas blocks.
  @override
  InkBackground get defaultInkBackground;

  /// Default workspace directory path. `null` → ~/Runa.
  @override
  String? get defaultWorkspacePath;

  /// Create a copy of AppSettings
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AppSettingsImplCopyWith<_$AppSettingsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
