// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'app_settings.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AppSettings {

/// Light / dark / system theme.
@_ThemeModeConverter() ThemeMode get themeMode;/// Font family used in Markdown blocks.
 String get markdownFontFamily;/// Base font size used in Markdown blocks.
 double get markdownFontSize;/// Default ink stroke color.
@_ColorConverter() Color get defaultInkColor;/// Default ink stroke width.
 double get defaultInkStrokeWidth;/// Default canvas background. `null` → derived from current theme.
@_NullableColorConverter() Color? get defaultCanvasBackground;/// Default line color for ruled/grid/dotted/isometric backgrounds.
/// `null` → derived from theme (outlineVariant at 20% opacity).
@_NullableColorConverter() Color? get defaultLineColor;/// Whether auto-save is enabled.
 bool get autoSaveEnabled;/// Auto-save interval in seconds (ignored when [autoSaveEnabled] is false).
 int get autoSaveIntervalSeconds;/// Default background pattern for new ink canvas blocks.
 InkBackground get defaultInkBackground;/// Default workspace directory path. `null` → ~/Runa.
 String? get defaultWorkspacePath;/// Whether the initial workspace setup has been completed.
/// `false` on first launch → triggers the setup flow.
 bool get workspaceConfigured;
/// Create a copy of AppSettings
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AppSettingsCopyWith<AppSettings> get copyWith => _$AppSettingsCopyWithImpl<AppSettings>(this as AppSettings, _$identity);

  /// Serializes this AppSettings to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AppSettings&&(identical(other.themeMode, themeMode) || other.themeMode == themeMode)&&(identical(other.markdownFontFamily, markdownFontFamily) || other.markdownFontFamily == markdownFontFamily)&&(identical(other.markdownFontSize, markdownFontSize) || other.markdownFontSize == markdownFontSize)&&(identical(other.defaultInkColor, defaultInkColor) || other.defaultInkColor == defaultInkColor)&&(identical(other.defaultInkStrokeWidth, defaultInkStrokeWidth) || other.defaultInkStrokeWidth == defaultInkStrokeWidth)&&(identical(other.defaultCanvasBackground, defaultCanvasBackground) || other.defaultCanvasBackground == defaultCanvasBackground)&&(identical(other.defaultLineColor, defaultLineColor) || other.defaultLineColor == defaultLineColor)&&(identical(other.autoSaveEnabled, autoSaveEnabled) || other.autoSaveEnabled == autoSaveEnabled)&&(identical(other.autoSaveIntervalSeconds, autoSaveIntervalSeconds) || other.autoSaveIntervalSeconds == autoSaveIntervalSeconds)&&(identical(other.defaultInkBackground, defaultInkBackground) || other.defaultInkBackground == defaultInkBackground)&&(identical(other.defaultWorkspacePath, defaultWorkspacePath) || other.defaultWorkspacePath == defaultWorkspacePath)&&(identical(other.workspaceConfigured, workspaceConfigured) || other.workspaceConfigured == workspaceConfigured));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,themeMode,markdownFontFamily,markdownFontSize,defaultInkColor,defaultInkStrokeWidth,defaultCanvasBackground,defaultLineColor,autoSaveEnabled,autoSaveIntervalSeconds,defaultInkBackground,defaultWorkspacePath,workspaceConfigured);

@override
String toString() {
  return 'AppSettings(themeMode: $themeMode, markdownFontFamily: $markdownFontFamily, markdownFontSize: $markdownFontSize, defaultInkColor: $defaultInkColor, defaultInkStrokeWidth: $defaultInkStrokeWidth, defaultCanvasBackground: $defaultCanvasBackground, defaultLineColor: $defaultLineColor, autoSaveEnabled: $autoSaveEnabled, autoSaveIntervalSeconds: $autoSaveIntervalSeconds, defaultInkBackground: $defaultInkBackground, defaultWorkspacePath: $defaultWorkspacePath, workspaceConfigured: $workspaceConfigured)';
}


}

/// @nodoc
abstract mixin class $AppSettingsCopyWith<$Res>  {
  factory $AppSettingsCopyWith(AppSettings value, $Res Function(AppSettings) _then) = _$AppSettingsCopyWithImpl;
@useResult
$Res call({
@_ThemeModeConverter() ThemeMode themeMode, String markdownFontFamily, double markdownFontSize,@_ColorConverter() Color defaultInkColor, double defaultInkStrokeWidth,@_NullableColorConverter() Color? defaultCanvasBackground,@_NullableColorConverter() Color? defaultLineColor, bool autoSaveEnabled, int autoSaveIntervalSeconds, InkBackground defaultInkBackground, String? defaultWorkspacePath, bool workspaceConfigured
});




}
/// @nodoc
class _$AppSettingsCopyWithImpl<$Res>
    implements $AppSettingsCopyWith<$Res> {
  _$AppSettingsCopyWithImpl(this._self, this._then);

  final AppSettings _self;
  final $Res Function(AppSettings) _then;

/// Create a copy of AppSettings
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? themeMode = null,Object? markdownFontFamily = null,Object? markdownFontSize = null,Object? defaultInkColor = null,Object? defaultInkStrokeWidth = null,Object? defaultCanvasBackground = freezed,Object? defaultLineColor = freezed,Object? autoSaveEnabled = null,Object? autoSaveIntervalSeconds = null,Object? defaultInkBackground = null,Object? defaultWorkspacePath = freezed,Object? workspaceConfigured = null,}) {
  return _then(_self.copyWith(
themeMode: null == themeMode ? _self.themeMode : themeMode // ignore: cast_nullable_to_non_nullable
as ThemeMode,markdownFontFamily: null == markdownFontFamily ? _self.markdownFontFamily : markdownFontFamily // ignore: cast_nullable_to_non_nullable
as String,markdownFontSize: null == markdownFontSize ? _self.markdownFontSize : markdownFontSize // ignore: cast_nullable_to_non_nullable
as double,defaultInkColor: null == defaultInkColor ? _self.defaultInkColor : defaultInkColor // ignore: cast_nullable_to_non_nullable
as Color,defaultInkStrokeWidth: null == defaultInkStrokeWidth ? _self.defaultInkStrokeWidth : defaultInkStrokeWidth // ignore: cast_nullable_to_non_nullable
as double,defaultCanvasBackground: freezed == defaultCanvasBackground ? _self.defaultCanvasBackground : defaultCanvasBackground // ignore: cast_nullable_to_non_nullable
as Color?,defaultLineColor: freezed == defaultLineColor ? _self.defaultLineColor : defaultLineColor // ignore: cast_nullable_to_non_nullable
as Color?,autoSaveEnabled: null == autoSaveEnabled ? _self.autoSaveEnabled : autoSaveEnabled // ignore: cast_nullable_to_non_nullable
as bool,autoSaveIntervalSeconds: null == autoSaveIntervalSeconds ? _self.autoSaveIntervalSeconds : autoSaveIntervalSeconds // ignore: cast_nullable_to_non_nullable
as int,defaultInkBackground: null == defaultInkBackground ? _self.defaultInkBackground : defaultInkBackground // ignore: cast_nullable_to_non_nullable
as InkBackground,defaultWorkspacePath: freezed == defaultWorkspacePath ? _self.defaultWorkspacePath : defaultWorkspacePath // ignore: cast_nullable_to_non_nullable
as String?,workspaceConfigured: null == workspaceConfigured ? _self.workspaceConfigured : workspaceConfigured // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [AppSettings].
extension AppSettingsPatterns on AppSettings {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AppSettings value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AppSettings() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AppSettings value)  $default,){
final _that = this;
switch (_that) {
case _AppSettings():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AppSettings value)?  $default,){
final _that = this;
switch (_that) {
case _AppSettings() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@_ThemeModeConverter()  ThemeMode themeMode,  String markdownFontFamily,  double markdownFontSize, @_ColorConverter()  Color defaultInkColor,  double defaultInkStrokeWidth, @_NullableColorConverter()  Color? defaultCanvasBackground, @_NullableColorConverter()  Color? defaultLineColor,  bool autoSaveEnabled,  int autoSaveIntervalSeconds,  InkBackground defaultInkBackground,  String? defaultWorkspacePath,  bool workspaceConfigured)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AppSettings() when $default != null:
return $default(_that.themeMode,_that.markdownFontFamily,_that.markdownFontSize,_that.defaultInkColor,_that.defaultInkStrokeWidth,_that.defaultCanvasBackground,_that.defaultLineColor,_that.autoSaveEnabled,_that.autoSaveIntervalSeconds,_that.defaultInkBackground,_that.defaultWorkspacePath,_that.workspaceConfigured);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@_ThemeModeConverter()  ThemeMode themeMode,  String markdownFontFamily,  double markdownFontSize, @_ColorConverter()  Color defaultInkColor,  double defaultInkStrokeWidth, @_NullableColorConverter()  Color? defaultCanvasBackground, @_NullableColorConverter()  Color? defaultLineColor,  bool autoSaveEnabled,  int autoSaveIntervalSeconds,  InkBackground defaultInkBackground,  String? defaultWorkspacePath,  bool workspaceConfigured)  $default,) {final _that = this;
switch (_that) {
case _AppSettings():
return $default(_that.themeMode,_that.markdownFontFamily,_that.markdownFontSize,_that.defaultInkColor,_that.defaultInkStrokeWidth,_that.defaultCanvasBackground,_that.defaultLineColor,_that.autoSaveEnabled,_that.autoSaveIntervalSeconds,_that.defaultInkBackground,_that.defaultWorkspacePath,_that.workspaceConfigured);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@_ThemeModeConverter()  ThemeMode themeMode,  String markdownFontFamily,  double markdownFontSize, @_ColorConverter()  Color defaultInkColor,  double defaultInkStrokeWidth, @_NullableColorConverter()  Color? defaultCanvasBackground, @_NullableColorConverter()  Color? defaultLineColor,  bool autoSaveEnabled,  int autoSaveIntervalSeconds,  InkBackground defaultInkBackground,  String? defaultWorkspacePath,  bool workspaceConfigured)?  $default,) {final _that = this;
switch (_that) {
case _AppSettings() when $default != null:
return $default(_that.themeMode,_that.markdownFontFamily,_that.markdownFontSize,_that.defaultInkColor,_that.defaultInkStrokeWidth,_that.defaultCanvasBackground,_that.defaultLineColor,_that.autoSaveEnabled,_that.autoSaveIntervalSeconds,_that.defaultInkBackground,_that.defaultWorkspacePath,_that.workspaceConfigured);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(explicitToJson: true, fieldRename: FieldRename.snake)
class _AppSettings implements AppSettings {
  const _AppSettings({@_ThemeModeConverter() this.themeMode = ThemeMode.system, this.markdownFontFamily = 'Roboto', this.markdownFontSize = 16.0, @_ColorConverter() this.defaultInkColor = const Color(0xFF000000), this.defaultInkStrokeWidth = 2.0, @_NullableColorConverter() this.defaultCanvasBackground, @_NullableColorConverter() this.defaultLineColor, this.autoSaveEnabled = true, this.autoSaveIntervalSeconds = 30, this.defaultInkBackground = InkBackground.plain, this.defaultWorkspacePath, this.workspaceConfigured = false});
  factory _AppSettings.fromJson(Map<String, dynamic> json) => _$AppSettingsFromJson(json);

/// Light / dark / system theme.
@override@JsonKey()@_ThemeModeConverter() final  ThemeMode themeMode;
/// Font family used in Markdown blocks.
@override@JsonKey() final  String markdownFontFamily;
/// Base font size used in Markdown blocks.
@override@JsonKey() final  double markdownFontSize;
/// Default ink stroke color.
@override@JsonKey()@_ColorConverter() final  Color defaultInkColor;
/// Default ink stroke width.
@override@JsonKey() final  double defaultInkStrokeWidth;
/// Default canvas background. `null` → derived from current theme.
@override@_NullableColorConverter() final  Color? defaultCanvasBackground;
/// Default line color for ruled/grid/dotted/isometric backgrounds.
/// `null` → derived from theme (outlineVariant at 20% opacity).
@override@_NullableColorConverter() final  Color? defaultLineColor;
/// Whether auto-save is enabled.
@override@JsonKey() final  bool autoSaveEnabled;
/// Auto-save interval in seconds (ignored when [autoSaveEnabled] is false).
@override@JsonKey() final  int autoSaveIntervalSeconds;
/// Default background pattern for new ink canvas blocks.
@override@JsonKey() final  InkBackground defaultInkBackground;
/// Default workspace directory path. `null` → ~/Runa.
@override final  String? defaultWorkspacePath;
/// Whether the initial workspace setup has been completed.
/// `false` on first launch → triggers the setup flow.
@override@JsonKey() final  bool workspaceConfigured;

/// Create a copy of AppSettings
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AppSettingsCopyWith<_AppSettings> get copyWith => __$AppSettingsCopyWithImpl<_AppSettings>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AppSettingsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AppSettings&&(identical(other.themeMode, themeMode) || other.themeMode == themeMode)&&(identical(other.markdownFontFamily, markdownFontFamily) || other.markdownFontFamily == markdownFontFamily)&&(identical(other.markdownFontSize, markdownFontSize) || other.markdownFontSize == markdownFontSize)&&(identical(other.defaultInkColor, defaultInkColor) || other.defaultInkColor == defaultInkColor)&&(identical(other.defaultInkStrokeWidth, defaultInkStrokeWidth) || other.defaultInkStrokeWidth == defaultInkStrokeWidth)&&(identical(other.defaultCanvasBackground, defaultCanvasBackground) || other.defaultCanvasBackground == defaultCanvasBackground)&&(identical(other.defaultLineColor, defaultLineColor) || other.defaultLineColor == defaultLineColor)&&(identical(other.autoSaveEnabled, autoSaveEnabled) || other.autoSaveEnabled == autoSaveEnabled)&&(identical(other.autoSaveIntervalSeconds, autoSaveIntervalSeconds) || other.autoSaveIntervalSeconds == autoSaveIntervalSeconds)&&(identical(other.defaultInkBackground, defaultInkBackground) || other.defaultInkBackground == defaultInkBackground)&&(identical(other.defaultWorkspacePath, defaultWorkspacePath) || other.defaultWorkspacePath == defaultWorkspacePath)&&(identical(other.workspaceConfigured, workspaceConfigured) || other.workspaceConfigured == workspaceConfigured));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,themeMode,markdownFontFamily,markdownFontSize,defaultInkColor,defaultInkStrokeWidth,defaultCanvasBackground,defaultLineColor,autoSaveEnabled,autoSaveIntervalSeconds,defaultInkBackground,defaultWorkspacePath,workspaceConfigured);

@override
String toString() {
  return 'AppSettings(themeMode: $themeMode, markdownFontFamily: $markdownFontFamily, markdownFontSize: $markdownFontSize, defaultInkColor: $defaultInkColor, defaultInkStrokeWidth: $defaultInkStrokeWidth, defaultCanvasBackground: $defaultCanvasBackground, defaultLineColor: $defaultLineColor, autoSaveEnabled: $autoSaveEnabled, autoSaveIntervalSeconds: $autoSaveIntervalSeconds, defaultInkBackground: $defaultInkBackground, defaultWorkspacePath: $defaultWorkspacePath, workspaceConfigured: $workspaceConfigured)';
}


}

/// @nodoc
abstract mixin class _$AppSettingsCopyWith<$Res> implements $AppSettingsCopyWith<$Res> {
  factory _$AppSettingsCopyWith(_AppSettings value, $Res Function(_AppSettings) _then) = __$AppSettingsCopyWithImpl;
@override @useResult
$Res call({
@_ThemeModeConverter() ThemeMode themeMode, String markdownFontFamily, double markdownFontSize,@_ColorConverter() Color defaultInkColor, double defaultInkStrokeWidth,@_NullableColorConverter() Color? defaultCanvasBackground,@_NullableColorConverter() Color? defaultLineColor, bool autoSaveEnabled, int autoSaveIntervalSeconds, InkBackground defaultInkBackground, String? defaultWorkspacePath, bool workspaceConfigured
});




}
/// @nodoc
class __$AppSettingsCopyWithImpl<$Res>
    implements _$AppSettingsCopyWith<$Res> {
  __$AppSettingsCopyWithImpl(this._self, this._then);

  final _AppSettings _self;
  final $Res Function(_AppSettings) _then;

/// Create a copy of AppSettings
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? themeMode = null,Object? markdownFontFamily = null,Object? markdownFontSize = null,Object? defaultInkColor = null,Object? defaultInkStrokeWidth = null,Object? defaultCanvasBackground = freezed,Object? defaultLineColor = freezed,Object? autoSaveEnabled = null,Object? autoSaveIntervalSeconds = null,Object? defaultInkBackground = null,Object? defaultWorkspacePath = freezed,Object? workspaceConfigured = null,}) {
  return _then(_AppSettings(
themeMode: null == themeMode ? _self.themeMode : themeMode // ignore: cast_nullable_to_non_nullable
as ThemeMode,markdownFontFamily: null == markdownFontFamily ? _self.markdownFontFamily : markdownFontFamily // ignore: cast_nullable_to_non_nullable
as String,markdownFontSize: null == markdownFontSize ? _self.markdownFontSize : markdownFontSize // ignore: cast_nullable_to_non_nullable
as double,defaultInkColor: null == defaultInkColor ? _self.defaultInkColor : defaultInkColor // ignore: cast_nullable_to_non_nullable
as Color,defaultInkStrokeWidth: null == defaultInkStrokeWidth ? _self.defaultInkStrokeWidth : defaultInkStrokeWidth // ignore: cast_nullable_to_non_nullable
as double,defaultCanvasBackground: freezed == defaultCanvasBackground ? _self.defaultCanvasBackground : defaultCanvasBackground // ignore: cast_nullable_to_non_nullable
as Color?,defaultLineColor: freezed == defaultLineColor ? _self.defaultLineColor : defaultLineColor // ignore: cast_nullable_to_non_nullable
as Color?,autoSaveEnabled: null == autoSaveEnabled ? _self.autoSaveEnabled : autoSaveEnabled // ignore: cast_nullable_to_non_nullable
as bool,autoSaveIntervalSeconds: null == autoSaveIntervalSeconds ? _self.autoSaveIntervalSeconds : autoSaveIntervalSeconds // ignore: cast_nullable_to_non_nullable
as int,defaultInkBackground: null == defaultInkBackground ? _self.defaultInkBackground : defaultInkBackground // ignore: cast_nullable_to_non_nullable
as InkBackground,defaultWorkspacePath: freezed == defaultWorkspacePath ? _self.defaultWorkspacePath : defaultWorkspacePath // ignore: cast_nullable_to_non_nullable
as String?,workspaceConfigured: null == workspaceConfigured ? _self.workspaceConfigured : workspaceConfigured // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
