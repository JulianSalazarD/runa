// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'editor_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$EditorState {
  /// Absolute path to the `.runa` file on disk.
  String get path => throw _privateConstructorUsedError;

  /// The in-memory representation of the document.
  Document get document => throw _privateConstructorUsedError;

  /// The [Block.id] of the block that currently has focus, or null.
  String? get selectedBlockId => throw _privateConstructorUsedError;

  /// Whether the in-memory state differs from the last save.
  bool get isDirty => throw _privateConstructorUsedError;

  /// Whether to show the "Guardado automáticamente" indicator briefly.
  bool get autosaveMessage => throw _privateConstructorUsedError;

  /// Whether an asset import (image/PDF copy) is in progress.
  bool get isImporting => throw _privateConstructorUsedError;

  /// Create a copy of EditorState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $EditorStateCopyWith<EditorState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $EditorStateCopyWith<$Res> {
  factory $EditorStateCopyWith(
    EditorState value,
    $Res Function(EditorState) then,
  ) = _$EditorStateCopyWithImpl<$Res, EditorState>;
  @useResult
  $Res call({
    String path,
    Document document,
    String? selectedBlockId,
    bool isDirty,
    bool autosaveMessage,
    bool isImporting,
  });

  $DocumentCopyWith<$Res> get document;
}

/// @nodoc
class _$EditorStateCopyWithImpl<$Res, $Val extends EditorState>
    implements $EditorStateCopyWith<$Res> {
  _$EditorStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of EditorState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? path = null,
    Object? document = null,
    Object? selectedBlockId = freezed,
    Object? isDirty = null,
    Object? autosaveMessage = null,
    Object? isImporting = null,
  }) {
    return _then(
      _value.copyWith(
            path: null == path
                ? _value.path
                : path // ignore: cast_nullable_to_non_nullable
                      as String,
            document: null == document
                ? _value.document
                : document // ignore: cast_nullable_to_non_nullable
                      as Document,
            selectedBlockId: freezed == selectedBlockId
                ? _value.selectedBlockId
                : selectedBlockId // ignore: cast_nullable_to_non_nullable
                      as String?,
            isDirty: null == isDirty
                ? _value.isDirty
                : isDirty // ignore: cast_nullable_to_non_nullable
                      as bool,
            autosaveMessage: null == autosaveMessage
                ? _value.autosaveMessage
                : autosaveMessage // ignore: cast_nullable_to_non_nullable
                      as bool,
            isImporting: null == isImporting
                ? _value.isImporting
                : isImporting // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }

  /// Create a copy of EditorState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $DocumentCopyWith<$Res> get document {
    return $DocumentCopyWith<$Res>(_value.document, (value) {
      return _then(_value.copyWith(document: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$EditorStateImplCopyWith<$Res>
    implements $EditorStateCopyWith<$Res> {
  factory _$$EditorStateImplCopyWith(
    _$EditorStateImpl value,
    $Res Function(_$EditorStateImpl) then,
  ) = __$$EditorStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String path,
    Document document,
    String? selectedBlockId,
    bool isDirty,
    bool autosaveMessage,
    bool isImporting,
  });

  @override
  $DocumentCopyWith<$Res> get document;
}

/// @nodoc
class __$$EditorStateImplCopyWithImpl<$Res>
    extends _$EditorStateCopyWithImpl<$Res, _$EditorStateImpl>
    implements _$$EditorStateImplCopyWith<$Res> {
  __$$EditorStateImplCopyWithImpl(
    _$EditorStateImpl _value,
    $Res Function(_$EditorStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of EditorState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? path = null,
    Object? document = null,
    Object? selectedBlockId = freezed,
    Object? isDirty = null,
    Object? autosaveMessage = null,
    Object? isImporting = null,
  }) {
    return _then(
      _$EditorStateImpl(
        path: null == path
            ? _value.path
            : path // ignore: cast_nullable_to_non_nullable
                  as String,
        document: null == document
            ? _value.document
            : document // ignore: cast_nullable_to_non_nullable
                  as Document,
        selectedBlockId: freezed == selectedBlockId
            ? _value.selectedBlockId
            : selectedBlockId // ignore: cast_nullable_to_non_nullable
                  as String?,
        isDirty: null == isDirty
            ? _value.isDirty
            : isDirty // ignore: cast_nullable_to_non_nullable
                  as bool,
        autosaveMessage: null == autosaveMessage
            ? _value.autosaveMessage
            : autosaveMessage // ignore: cast_nullable_to_non_nullable
                  as bool,
        isImporting: null == isImporting
            ? _value.isImporting
            : isImporting // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc

class _$EditorStateImpl extends _EditorState {
  const _$EditorStateImpl({
    required this.path,
    required this.document,
    this.selectedBlockId,
    this.isDirty = false,
    this.autosaveMessage = false,
    this.isImporting = false,
  }) : super._();

  /// Absolute path to the `.runa` file on disk.
  @override
  final String path;

  /// The in-memory representation of the document.
  @override
  final Document document;

  /// The [Block.id] of the block that currently has focus, or null.
  @override
  final String? selectedBlockId;

  /// Whether the in-memory state differs from the last save.
  @override
  @JsonKey()
  final bool isDirty;

  /// Whether to show the "Guardado automáticamente" indicator briefly.
  @override
  @JsonKey()
  final bool autosaveMessage;

  /// Whether an asset import (image/PDF copy) is in progress.
  @override
  @JsonKey()
  final bool isImporting;

  @override
  String toString() {
    return 'EditorState(path: $path, document: $document, selectedBlockId: $selectedBlockId, isDirty: $isDirty, autosaveMessage: $autosaveMessage, isImporting: $isImporting)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$EditorStateImpl &&
            (identical(other.path, path) || other.path == path) &&
            (identical(other.document, document) ||
                other.document == document) &&
            (identical(other.selectedBlockId, selectedBlockId) ||
                other.selectedBlockId == selectedBlockId) &&
            (identical(other.isDirty, isDirty) || other.isDirty == isDirty) &&
            (identical(other.autosaveMessage, autosaveMessage) ||
                other.autosaveMessage == autosaveMessage) &&
            (identical(other.isImporting, isImporting) ||
                other.isImporting == isImporting));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    path,
    document,
    selectedBlockId,
    isDirty,
    autosaveMessage,
    isImporting,
  );

  /// Create a copy of EditorState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$EditorStateImplCopyWith<_$EditorStateImpl> get copyWith =>
      __$$EditorStateImplCopyWithImpl<_$EditorStateImpl>(this, _$identity);
}

abstract class _EditorState extends EditorState {
  const factory _EditorState({
    required final String path,
    required final Document document,
    final String? selectedBlockId,
    final bool isDirty,
    final bool autosaveMessage,
    final bool isImporting,
  }) = _$EditorStateImpl;
  const _EditorState._() : super._();

  /// Absolute path to the `.runa` file on disk.
  @override
  String get path;

  /// The in-memory representation of the document.
  @override
  Document get document;

  /// The [Block.id] of the block that currently has focus, or null.
  @override
  String? get selectedBlockId;

  /// Whether the in-memory state differs from the last save.
  @override
  bool get isDirty;

  /// Whether to show the "Guardado automáticamente" indicator briefly.
  @override
  bool get autosaveMessage;

  /// Whether an asset import (image/PDF copy) is in progress.
  @override
  bool get isImporting;

  /// Create a copy of EditorState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$EditorStateImplCopyWith<_$EditorStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
