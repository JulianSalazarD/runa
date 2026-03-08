// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'workspace_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$WorkspaceState {
  /// Absolute path of the directory currently open in the sidebar, or null.
  String? get openedDirectoryPath => throw _privateConstructorUsedError;

  /// Documents that are currently open as tabs (ordered by open time).
  List<OpenedDocument> get openedDocuments =>
      throw _privateConstructorUsedError;

  /// The [Document.id] of the document shown in the editor area, or null
  /// when no tab is active (e.g. after closing the last document).
  String? get activeDocumentId => throw _privateConstructorUsedError;

  /// Most-recently-used document paths (most recent first, max 20).
  List<String> get recentPaths => throw _privateConstructorUsedError;

  /// Create a copy of WorkspaceState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $WorkspaceStateCopyWith<WorkspaceState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WorkspaceStateCopyWith<$Res> {
  factory $WorkspaceStateCopyWith(
    WorkspaceState value,
    $Res Function(WorkspaceState) then,
  ) = _$WorkspaceStateCopyWithImpl<$Res, WorkspaceState>;
  @useResult
  $Res call({
    String? openedDirectoryPath,
    List<OpenedDocument> openedDocuments,
    String? activeDocumentId,
    List<String> recentPaths,
  });
}

/// @nodoc
class _$WorkspaceStateCopyWithImpl<$Res, $Val extends WorkspaceState>
    implements $WorkspaceStateCopyWith<$Res> {
  _$WorkspaceStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of WorkspaceState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? openedDirectoryPath = freezed,
    Object? openedDocuments = null,
    Object? activeDocumentId = freezed,
    Object? recentPaths = null,
  }) {
    return _then(
      _value.copyWith(
            openedDirectoryPath: freezed == openedDirectoryPath
                ? _value.openedDirectoryPath
                : openedDirectoryPath // ignore: cast_nullable_to_non_nullable
                      as String?,
            openedDocuments: null == openedDocuments
                ? _value.openedDocuments
                : openedDocuments // ignore: cast_nullable_to_non_nullable
                      as List<OpenedDocument>,
            activeDocumentId: freezed == activeDocumentId
                ? _value.activeDocumentId
                : activeDocumentId // ignore: cast_nullable_to_non_nullable
                      as String?,
            recentPaths: null == recentPaths
                ? _value.recentPaths
                : recentPaths // ignore: cast_nullable_to_non_nullable
                      as List<String>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$WorkspaceStateImplCopyWith<$Res>
    implements $WorkspaceStateCopyWith<$Res> {
  factory _$$WorkspaceStateImplCopyWith(
    _$WorkspaceStateImpl value,
    $Res Function(_$WorkspaceStateImpl) then,
  ) = __$$WorkspaceStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String? openedDirectoryPath,
    List<OpenedDocument> openedDocuments,
    String? activeDocumentId,
    List<String> recentPaths,
  });
}

/// @nodoc
class __$$WorkspaceStateImplCopyWithImpl<$Res>
    extends _$WorkspaceStateCopyWithImpl<$Res, _$WorkspaceStateImpl>
    implements _$$WorkspaceStateImplCopyWith<$Res> {
  __$$WorkspaceStateImplCopyWithImpl(
    _$WorkspaceStateImpl _value,
    $Res Function(_$WorkspaceStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of WorkspaceState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? openedDirectoryPath = freezed,
    Object? openedDocuments = null,
    Object? activeDocumentId = freezed,
    Object? recentPaths = null,
  }) {
    return _then(
      _$WorkspaceStateImpl(
        openedDirectoryPath: freezed == openedDirectoryPath
            ? _value.openedDirectoryPath
            : openedDirectoryPath // ignore: cast_nullable_to_non_nullable
                  as String?,
        openedDocuments: null == openedDocuments
            ? _value._openedDocuments
            : openedDocuments // ignore: cast_nullable_to_non_nullable
                  as List<OpenedDocument>,
        activeDocumentId: freezed == activeDocumentId
            ? _value.activeDocumentId
            : activeDocumentId // ignore: cast_nullable_to_non_nullable
                  as String?,
        recentPaths: null == recentPaths
            ? _value._recentPaths
            : recentPaths // ignore: cast_nullable_to_non_nullable
                  as List<String>,
      ),
    );
  }
}

/// @nodoc

class _$WorkspaceStateImpl implements _WorkspaceState {
  const _$WorkspaceStateImpl({
    this.openedDirectoryPath,
    final List<OpenedDocument> openedDocuments = const [],
    this.activeDocumentId,
    final List<String> recentPaths = const [],
  }) : _openedDocuments = openedDocuments,
       _recentPaths = recentPaths;

  /// Absolute path of the directory currently open in the sidebar, or null.
  @override
  final String? openedDirectoryPath;

  /// Documents that are currently open as tabs (ordered by open time).
  final List<OpenedDocument> _openedDocuments;

  /// Documents that are currently open as tabs (ordered by open time).
  @override
  @JsonKey()
  List<OpenedDocument> get openedDocuments {
    if (_openedDocuments is EqualUnmodifiableListView) return _openedDocuments;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_openedDocuments);
  }

  /// The [Document.id] of the document shown in the editor area, or null
  /// when no tab is active (e.g. after closing the last document).
  @override
  final String? activeDocumentId;

  /// Most-recently-used document paths (most recent first, max 20).
  final List<String> _recentPaths;

  /// Most-recently-used document paths (most recent first, max 20).
  @override
  @JsonKey()
  List<String> get recentPaths {
    if (_recentPaths is EqualUnmodifiableListView) return _recentPaths;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_recentPaths);
  }

  @override
  String toString() {
    return 'WorkspaceState(openedDirectoryPath: $openedDirectoryPath, openedDocuments: $openedDocuments, activeDocumentId: $activeDocumentId, recentPaths: $recentPaths)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WorkspaceStateImpl &&
            (identical(other.openedDirectoryPath, openedDirectoryPath) ||
                other.openedDirectoryPath == openedDirectoryPath) &&
            const DeepCollectionEquality().equals(
              other._openedDocuments,
              _openedDocuments,
            ) &&
            (identical(other.activeDocumentId, activeDocumentId) ||
                other.activeDocumentId == activeDocumentId) &&
            const DeepCollectionEquality().equals(
              other._recentPaths,
              _recentPaths,
            ));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    openedDirectoryPath,
    const DeepCollectionEquality().hash(_openedDocuments),
    activeDocumentId,
    const DeepCollectionEquality().hash(_recentPaths),
  );

  /// Create a copy of WorkspaceState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$WorkspaceStateImplCopyWith<_$WorkspaceStateImpl> get copyWith =>
      __$$WorkspaceStateImplCopyWithImpl<_$WorkspaceStateImpl>(
        this,
        _$identity,
      );
}

abstract class _WorkspaceState implements WorkspaceState {
  const factory _WorkspaceState({
    final String? openedDirectoryPath,
    final List<OpenedDocument> openedDocuments,
    final String? activeDocumentId,
    final List<String> recentPaths,
  }) = _$WorkspaceStateImpl;

  /// Absolute path of the directory currently open in the sidebar, or null.
  @override
  String? get openedDirectoryPath;

  /// Documents that are currently open as tabs (ordered by open time).
  @override
  List<OpenedDocument> get openedDocuments;

  /// The [Document.id] of the document shown in the editor area, or null
  /// when no tab is active (e.g. after closing the last document).
  @override
  String? get activeDocumentId;

  /// Most-recently-used document paths (most recent first, max 20).
  @override
  List<String> get recentPaths;

  /// Create a copy of WorkspaceState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WorkspaceStateImplCopyWith<_$WorkspaceStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
