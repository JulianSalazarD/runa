// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'opened_document.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$OpenedDocument {

/// The in-memory document model.
 Document get document;/// Absolute path to the `.runa` file on disk.
 String get path;/// Whether the in-memory [document] differs from the saved version.
 bool get hasUnsavedChanges;/// Whether to briefly show the "Guardado" indicator in the tab.
///
/// Set to true after a manual Ctrl+S save; automatically cleared after 1.5 s.
 bool get showSavedIndicator;
/// Create a copy of OpenedDocument
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OpenedDocumentCopyWith<OpenedDocument> get copyWith => _$OpenedDocumentCopyWithImpl<OpenedDocument>(this as OpenedDocument, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OpenedDocument&&(identical(other.document, document) || other.document == document)&&(identical(other.path, path) || other.path == path)&&(identical(other.hasUnsavedChanges, hasUnsavedChanges) || other.hasUnsavedChanges == hasUnsavedChanges)&&(identical(other.showSavedIndicator, showSavedIndicator) || other.showSavedIndicator == showSavedIndicator));
}


@override
int get hashCode => Object.hash(runtimeType,document,path,hasUnsavedChanges,showSavedIndicator);

@override
String toString() {
  return 'OpenedDocument(document: $document, path: $path, hasUnsavedChanges: $hasUnsavedChanges, showSavedIndicator: $showSavedIndicator)';
}


}

/// @nodoc
abstract mixin class $OpenedDocumentCopyWith<$Res>  {
  factory $OpenedDocumentCopyWith(OpenedDocument value, $Res Function(OpenedDocument) _then) = _$OpenedDocumentCopyWithImpl;
@useResult
$Res call({
 Document document, String path, bool hasUnsavedChanges, bool showSavedIndicator
});


$DocumentCopyWith<$Res> get document;

}
/// @nodoc
class _$OpenedDocumentCopyWithImpl<$Res>
    implements $OpenedDocumentCopyWith<$Res> {
  _$OpenedDocumentCopyWithImpl(this._self, this._then);

  final OpenedDocument _self;
  final $Res Function(OpenedDocument) _then;

/// Create a copy of OpenedDocument
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? document = null,Object? path = null,Object? hasUnsavedChanges = null,Object? showSavedIndicator = null,}) {
  return _then(_self.copyWith(
document: null == document ? _self.document : document // ignore: cast_nullable_to_non_nullable
as Document,path: null == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as String,hasUnsavedChanges: null == hasUnsavedChanges ? _self.hasUnsavedChanges : hasUnsavedChanges // ignore: cast_nullable_to_non_nullable
as bool,showSavedIndicator: null == showSavedIndicator ? _self.showSavedIndicator : showSavedIndicator // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}
/// Create a copy of OpenedDocument
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DocumentCopyWith<$Res> get document {
  
  return $DocumentCopyWith<$Res>(_self.document, (value) {
    return _then(_self.copyWith(document: value));
  });
}
}


/// Adds pattern-matching-related methods to [OpenedDocument].
extension OpenedDocumentPatterns on OpenedDocument {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OpenedDocument value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OpenedDocument() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OpenedDocument value)  $default,){
final _that = this;
switch (_that) {
case _OpenedDocument():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OpenedDocument value)?  $default,){
final _that = this;
switch (_that) {
case _OpenedDocument() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Document document,  String path,  bool hasUnsavedChanges,  bool showSavedIndicator)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OpenedDocument() when $default != null:
return $default(_that.document,_that.path,_that.hasUnsavedChanges,_that.showSavedIndicator);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Document document,  String path,  bool hasUnsavedChanges,  bool showSavedIndicator)  $default,) {final _that = this;
switch (_that) {
case _OpenedDocument():
return $default(_that.document,_that.path,_that.hasUnsavedChanges,_that.showSavedIndicator);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Document document,  String path,  bool hasUnsavedChanges,  bool showSavedIndicator)?  $default,) {final _that = this;
switch (_that) {
case _OpenedDocument() when $default != null:
return $default(_that.document,_that.path,_that.hasUnsavedChanges,_that.showSavedIndicator);case _:
  return null;

}
}

}

/// @nodoc


class _OpenedDocument implements OpenedDocument {
  const _OpenedDocument({required this.document, required this.path, this.hasUnsavedChanges = false, this.showSavedIndicator = false});
  

/// The in-memory document model.
@override final  Document document;
/// Absolute path to the `.runa` file on disk.
@override final  String path;
/// Whether the in-memory [document] differs from the saved version.
@override@JsonKey() final  bool hasUnsavedChanges;
/// Whether to briefly show the "Guardado" indicator in the tab.
///
/// Set to true after a manual Ctrl+S save; automatically cleared after 1.5 s.
@override@JsonKey() final  bool showSavedIndicator;

/// Create a copy of OpenedDocument
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OpenedDocumentCopyWith<_OpenedDocument> get copyWith => __$OpenedDocumentCopyWithImpl<_OpenedDocument>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OpenedDocument&&(identical(other.document, document) || other.document == document)&&(identical(other.path, path) || other.path == path)&&(identical(other.hasUnsavedChanges, hasUnsavedChanges) || other.hasUnsavedChanges == hasUnsavedChanges)&&(identical(other.showSavedIndicator, showSavedIndicator) || other.showSavedIndicator == showSavedIndicator));
}


@override
int get hashCode => Object.hash(runtimeType,document,path,hasUnsavedChanges,showSavedIndicator);

@override
String toString() {
  return 'OpenedDocument(document: $document, path: $path, hasUnsavedChanges: $hasUnsavedChanges, showSavedIndicator: $showSavedIndicator)';
}


}

/// @nodoc
abstract mixin class _$OpenedDocumentCopyWith<$Res> implements $OpenedDocumentCopyWith<$Res> {
  factory _$OpenedDocumentCopyWith(_OpenedDocument value, $Res Function(_OpenedDocument) _then) = __$OpenedDocumentCopyWithImpl;
@override @useResult
$Res call({
 Document document, String path, bool hasUnsavedChanges, bool showSavedIndicator
});


@override $DocumentCopyWith<$Res> get document;

}
/// @nodoc
class __$OpenedDocumentCopyWithImpl<$Res>
    implements _$OpenedDocumentCopyWith<$Res> {
  __$OpenedDocumentCopyWithImpl(this._self, this._then);

  final _OpenedDocument _self;
  final $Res Function(_OpenedDocument) _then;

/// Create a copy of OpenedDocument
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? document = null,Object? path = null,Object? hasUnsavedChanges = null,Object? showSavedIndicator = null,}) {
  return _then(_OpenedDocument(
document: null == document ? _self.document : document // ignore: cast_nullable_to_non_nullable
as Document,path: null == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as String,hasUnsavedChanges: null == hasUnsavedChanges ? _self.hasUnsavedChanges : hasUnsavedChanges // ignore: cast_nullable_to_non_nullable
as bool,showSavedIndicator: null == showSavedIndicator ? _self.showSavedIndicator : showSavedIndicator // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of OpenedDocument
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
