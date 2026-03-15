// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'editor_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$EditorState {

/// Absolute path to the `.runa` file on disk.
 String get path;/// The in-memory representation of the document.
 Document get document;/// The [Block.id] of the block that currently has focus, or null.
 String? get selectedBlockId;/// Whether the in-memory state differs from the last save.
 bool get isDirty;/// Whether to show the "Guardado automáticamente" indicator briefly.
 bool get autosaveMessage;/// Whether an asset import (image/PDF copy) is in progress.
 bool get isImporting;
/// Create a copy of EditorState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EditorStateCopyWith<EditorState> get copyWith => _$EditorStateCopyWithImpl<EditorState>(this as EditorState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EditorState&&(identical(other.path, path) || other.path == path)&&(identical(other.document, document) || other.document == document)&&(identical(other.selectedBlockId, selectedBlockId) || other.selectedBlockId == selectedBlockId)&&(identical(other.isDirty, isDirty) || other.isDirty == isDirty)&&(identical(other.autosaveMessage, autosaveMessage) || other.autosaveMessage == autosaveMessage)&&(identical(other.isImporting, isImporting) || other.isImporting == isImporting));
}


@override
int get hashCode => Object.hash(runtimeType,path,document,selectedBlockId,isDirty,autosaveMessage,isImporting);

@override
String toString() {
  return 'EditorState(path: $path, document: $document, selectedBlockId: $selectedBlockId, isDirty: $isDirty, autosaveMessage: $autosaveMessage, isImporting: $isImporting)';
}


}

/// @nodoc
abstract mixin class $EditorStateCopyWith<$Res>  {
  factory $EditorStateCopyWith(EditorState value, $Res Function(EditorState) _then) = _$EditorStateCopyWithImpl;
@useResult
$Res call({
 String path, Document document, String? selectedBlockId, bool isDirty, bool autosaveMessage, bool isImporting
});


$DocumentCopyWith<$Res> get document;

}
/// @nodoc
class _$EditorStateCopyWithImpl<$Res>
    implements $EditorStateCopyWith<$Res> {
  _$EditorStateCopyWithImpl(this._self, this._then);

  final EditorState _self;
  final $Res Function(EditorState) _then;

/// Create a copy of EditorState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? path = null,Object? document = null,Object? selectedBlockId = freezed,Object? isDirty = null,Object? autosaveMessage = null,Object? isImporting = null,}) {
  return _then(_self.copyWith(
path: null == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as String,document: null == document ? _self.document : document // ignore: cast_nullable_to_non_nullable
as Document,selectedBlockId: freezed == selectedBlockId ? _self.selectedBlockId : selectedBlockId // ignore: cast_nullable_to_non_nullable
as String?,isDirty: null == isDirty ? _self.isDirty : isDirty // ignore: cast_nullable_to_non_nullable
as bool,autosaveMessage: null == autosaveMessage ? _self.autosaveMessage : autosaveMessage // ignore: cast_nullable_to_non_nullable
as bool,isImporting: null == isImporting ? _self.isImporting : isImporting // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}
/// Create a copy of EditorState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DocumentCopyWith<$Res> get document {
  
  return $DocumentCopyWith<$Res>(_self.document, (value) {
    return _then(_self.copyWith(document: value));
  });
}
}


/// Adds pattern-matching-related methods to [EditorState].
extension EditorStatePatterns on EditorState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EditorState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EditorState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EditorState value)  $default,){
final _that = this;
switch (_that) {
case _EditorState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EditorState value)?  $default,){
final _that = this;
switch (_that) {
case _EditorState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String path,  Document document,  String? selectedBlockId,  bool isDirty,  bool autosaveMessage,  bool isImporting)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EditorState() when $default != null:
return $default(_that.path,_that.document,_that.selectedBlockId,_that.isDirty,_that.autosaveMessage,_that.isImporting);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String path,  Document document,  String? selectedBlockId,  bool isDirty,  bool autosaveMessage,  bool isImporting)  $default,) {final _that = this;
switch (_that) {
case _EditorState():
return $default(_that.path,_that.document,_that.selectedBlockId,_that.isDirty,_that.autosaveMessage,_that.isImporting);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String path,  Document document,  String? selectedBlockId,  bool isDirty,  bool autosaveMessage,  bool isImporting)?  $default,) {final _that = this;
switch (_that) {
case _EditorState() when $default != null:
return $default(_that.path,_that.document,_that.selectedBlockId,_that.isDirty,_that.autosaveMessage,_that.isImporting);case _:
  return null;

}
}

}

/// @nodoc


class _EditorState extends EditorState {
  const _EditorState({required this.path, required this.document, this.selectedBlockId, this.isDirty = false, this.autosaveMessage = false, this.isImporting = false}): super._();
  

/// Absolute path to the `.runa` file on disk.
@override final  String path;
/// The in-memory representation of the document.
@override final  Document document;
/// The [Block.id] of the block that currently has focus, or null.
@override final  String? selectedBlockId;
/// Whether the in-memory state differs from the last save.
@override@JsonKey() final  bool isDirty;
/// Whether to show the "Guardado automáticamente" indicator briefly.
@override@JsonKey() final  bool autosaveMessage;
/// Whether an asset import (image/PDF copy) is in progress.
@override@JsonKey() final  bool isImporting;

/// Create a copy of EditorState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EditorStateCopyWith<_EditorState> get copyWith => __$EditorStateCopyWithImpl<_EditorState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _EditorState&&(identical(other.path, path) || other.path == path)&&(identical(other.document, document) || other.document == document)&&(identical(other.selectedBlockId, selectedBlockId) || other.selectedBlockId == selectedBlockId)&&(identical(other.isDirty, isDirty) || other.isDirty == isDirty)&&(identical(other.autosaveMessage, autosaveMessage) || other.autosaveMessage == autosaveMessage)&&(identical(other.isImporting, isImporting) || other.isImporting == isImporting));
}


@override
int get hashCode => Object.hash(runtimeType,path,document,selectedBlockId,isDirty,autosaveMessage,isImporting);

@override
String toString() {
  return 'EditorState(path: $path, document: $document, selectedBlockId: $selectedBlockId, isDirty: $isDirty, autosaveMessage: $autosaveMessage, isImporting: $isImporting)';
}


}

/// @nodoc
abstract mixin class _$EditorStateCopyWith<$Res> implements $EditorStateCopyWith<$Res> {
  factory _$EditorStateCopyWith(_EditorState value, $Res Function(_EditorState) _then) = __$EditorStateCopyWithImpl;
@override @useResult
$Res call({
 String path, Document document, String? selectedBlockId, bool isDirty, bool autosaveMessage, bool isImporting
});


@override $DocumentCopyWith<$Res> get document;

}
/// @nodoc
class __$EditorStateCopyWithImpl<$Res>
    implements _$EditorStateCopyWith<$Res> {
  __$EditorStateCopyWithImpl(this._self, this._then);

  final _EditorState _self;
  final $Res Function(_EditorState) _then;

/// Create a copy of EditorState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? path = null,Object? document = null,Object? selectedBlockId = freezed,Object? isDirty = null,Object? autosaveMessage = null,Object? isImporting = null,}) {
  return _then(_EditorState(
path: null == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as String,document: null == document ? _self.document : document // ignore: cast_nullable_to_non_nullable
as Document,selectedBlockId: freezed == selectedBlockId ? _self.selectedBlockId : selectedBlockId // ignore: cast_nullable_to_non_nullable
as String?,isDirty: null == isDirty ? _self.isDirty : isDirty // ignore: cast_nullable_to_non_nullable
as bool,autosaveMessage: null == autosaveMessage ? _self.autosaveMessage : autosaveMessage // ignore: cast_nullable_to_non_nullable
as bool,isImporting: null == isImporting ? _self.isImporting : isImporting // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of EditorState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DocumentCopyWith<$Res> get document {
  
  return $DocumentCopyWith<$Res>(_self.document, (value) {
    return _then(_self.copyWith(document: value));
  });
}
}

// dart format on
