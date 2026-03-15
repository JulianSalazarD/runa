// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'workspace_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$WorkspaceState {

/// Absolute path of the directory currently open in the sidebar, or null.
 String? get openedDirectoryPath;/// Documents that are currently open as tabs (ordered by open time).
 List<OpenedDocument> get openedDocuments;/// The [Document.id] of the document shown in the editor area, or null
/// when no tab is active (e.g. after closing the last document).
 String? get activeDocumentId;/// Most-recently-used document paths (most recent first, max 20).
 List<String> get recentPaths;
/// Create a copy of WorkspaceState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WorkspaceStateCopyWith<WorkspaceState> get copyWith => _$WorkspaceStateCopyWithImpl<WorkspaceState>(this as WorkspaceState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WorkspaceState&&(identical(other.openedDirectoryPath, openedDirectoryPath) || other.openedDirectoryPath == openedDirectoryPath)&&const DeepCollectionEquality().equals(other.openedDocuments, openedDocuments)&&(identical(other.activeDocumentId, activeDocumentId) || other.activeDocumentId == activeDocumentId)&&const DeepCollectionEquality().equals(other.recentPaths, recentPaths));
}


@override
int get hashCode => Object.hash(runtimeType,openedDirectoryPath,const DeepCollectionEquality().hash(openedDocuments),activeDocumentId,const DeepCollectionEquality().hash(recentPaths));

@override
String toString() {
  return 'WorkspaceState(openedDirectoryPath: $openedDirectoryPath, openedDocuments: $openedDocuments, activeDocumentId: $activeDocumentId, recentPaths: $recentPaths)';
}


}

/// @nodoc
abstract mixin class $WorkspaceStateCopyWith<$Res>  {
  factory $WorkspaceStateCopyWith(WorkspaceState value, $Res Function(WorkspaceState) _then) = _$WorkspaceStateCopyWithImpl;
@useResult
$Res call({
 String? openedDirectoryPath, List<OpenedDocument> openedDocuments, String? activeDocumentId, List<String> recentPaths
});




}
/// @nodoc
class _$WorkspaceStateCopyWithImpl<$Res>
    implements $WorkspaceStateCopyWith<$Res> {
  _$WorkspaceStateCopyWithImpl(this._self, this._then);

  final WorkspaceState _self;
  final $Res Function(WorkspaceState) _then;

/// Create a copy of WorkspaceState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? openedDirectoryPath = freezed,Object? openedDocuments = null,Object? activeDocumentId = freezed,Object? recentPaths = null,}) {
  return _then(_self.copyWith(
openedDirectoryPath: freezed == openedDirectoryPath ? _self.openedDirectoryPath : openedDirectoryPath // ignore: cast_nullable_to_non_nullable
as String?,openedDocuments: null == openedDocuments ? _self.openedDocuments : openedDocuments // ignore: cast_nullable_to_non_nullable
as List<OpenedDocument>,activeDocumentId: freezed == activeDocumentId ? _self.activeDocumentId : activeDocumentId // ignore: cast_nullable_to_non_nullable
as String?,recentPaths: null == recentPaths ? _self.recentPaths : recentPaths // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [WorkspaceState].
extension WorkspaceStatePatterns on WorkspaceState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WorkspaceState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WorkspaceState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WorkspaceState value)  $default,){
final _that = this;
switch (_that) {
case _WorkspaceState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WorkspaceState value)?  $default,){
final _that = this;
switch (_that) {
case _WorkspaceState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? openedDirectoryPath,  List<OpenedDocument> openedDocuments,  String? activeDocumentId,  List<String> recentPaths)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WorkspaceState() when $default != null:
return $default(_that.openedDirectoryPath,_that.openedDocuments,_that.activeDocumentId,_that.recentPaths);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? openedDirectoryPath,  List<OpenedDocument> openedDocuments,  String? activeDocumentId,  List<String> recentPaths)  $default,) {final _that = this;
switch (_that) {
case _WorkspaceState():
return $default(_that.openedDirectoryPath,_that.openedDocuments,_that.activeDocumentId,_that.recentPaths);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? openedDirectoryPath,  List<OpenedDocument> openedDocuments,  String? activeDocumentId,  List<String> recentPaths)?  $default,) {final _that = this;
switch (_that) {
case _WorkspaceState() when $default != null:
return $default(_that.openedDirectoryPath,_that.openedDocuments,_that.activeDocumentId,_that.recentPaths);case _:
  return null;

}
}

}

/// @nodoc


class _WorkspaceState implements WorkspaceState {
  const _WorkspaceState({this.openedDirectoryPath, final  List<OpenedDocument> openedDocuments = const [], this.activeDocumentId, final  List<String> recentPaths = const []}): _openedDocuments = openedDocuments,_recentPaths = recentPaths;
  

/// Absolute path of the directory currently open in the sidebar, or null.
@override final  String? openedDirectoryPath;
/// Documents that are currently open as tabs (ordered by open time).
 final  List<OpenedDocument> _openedDocuments;
/// Documents that are currently open as tabs (ordered by open time).
@override@JsonKey() List<OpenedDocument> get openedDocuments {
  if (_openedDocuments is EqualUnmodifiableListView) return _openedDocuments;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_openedDocuments);
}

/// The [Document.id] of the document shown in the editor area, or null
/// when no tab is active (e.g. after closing the last document).
@override final  String? activeDocumentId;
/// Most-recently-used document paths (most recent first, max 20).
 final  List<String> _recentPaths;
/// Most-recently-used document paths (most recent first, max 20).
@override@JsonKey() List<String> get recentPaths {
  if (_recentPaths is EqualUnmodifiableListView) return _recentPaths;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_recentPaths);
}


/// Create a copy of WorkspaceState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WorkspaceStateCopyWith<_WorkspaceState> get copyWith => __$WorkspaceStateCopyWithImpl<_WorkspaceState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _WorkspaceState&&(identical(other.openedDirectoryPath, openedDirectoryPath) || other.openedDirectoryPath == openedDirectoryPath)&&const DeepCollectionEquality().equals(other._openedDocuments, _openedDocuments)&&(identical(other.activeDocumentId, activeDocumentId) || other.activeDocumentId == activeDocumentId)&&const DeepCollectionEquality().equals(other._recentPaths, _recentPaths));
}


@override
int get hashCode => Object.hash(runtimeType,openedDirectoryPath,const DeepCollectionEquality().hash(_openedDocuments),activeDocumentId,const DeepCollectionEquality().hash(_recentPaths));

@override
String toString() {
  return 'WorkspaceState(openedDirectoryPath: $openedDirectoryPath, openedDocuments: $openedDocuments, activeDocumentId: $activeDocumentId, recentPaths: $recentPaths)';
}


}

/// @nodoc
abstract mixin class _$WorkspaceStateCopyWith<$Res> implements $WorkspaceStateCopyWith<$Res> {
  factory _$WorkspaceStateCopyWith(_WorkspaceState value, $Res Function(_WorkspaceState) _then) = __$WorkspaceStateCopyWithImpl;
@override @useResult
$Res call({
 String? openedDirectoryPath, List<OpenedDocument> openedDocuments, String? activeDocumentId, List<String> recentPaths
});




}
/// @nodoc
class __$WorkspaceStateCopyWithImpl<$Res>
    implements _$WorkspaceStateCopyWith<$Res> {
  __$WorkspaceStateCopyWithImpl(this._self, this._then);

  final _WorkspaceState _self;
  final $Res Function(_WorkspaceState) _then;

/// Create a copy of WorkspaceState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? openedDirectoryPath = freezed,Object? openedDocuments = null,Object? activeDocumentId = freezed,Object? recentPaths = null,}) {
  return _then(_WorkspaceState(
openedDirectoryPath: freezed == openedDirectoryPath ? _self.openedDirectoryPath : openedDirectoryPath // ignore: cast_nullable_to_non_nullable
as String?,openedDocuments: null == openedDocuments ? _self._openedDocuments : openedDocuments // ignore: cast_nullable_to_non_nullable
as List<OpenedDocument>,activeDocumentId: freezed == activeDocumentId ? _self.activeDocumentId : activeDocumentId // ignore: cast_nullable_to_non_nullable
as String?,recentPaths: null == recentPaths ? _self._recentPaths : recentPaths // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}

// dart format on
