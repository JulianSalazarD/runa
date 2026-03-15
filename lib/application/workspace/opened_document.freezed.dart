// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'opened_document.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$OpenedDocument {
  /// The in-memory document model.
  Document get document => throw _privateConstructorUsedError;

  /// Absolute path to the `.runa` file on disk.
  String get path => throw _privateConstructorUsedError;

  /// Whether the in-memory [document] differs from the saved version.
  bool get hasUnsavedChanges => throw _privateConstructorUsedError;

  /// Whether to briefly show the "Guardado" indicator in the tab.
  ///
  /// Set to true after a manual Ctrl+S save; automatically cleared after 1.5 s.
  bool get showSavedIndicator => throw _privateConstructorUsedError;

  /// Create a copy of OpenedDocument
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $OpenedDocumentCopyWith<OpenedDocument> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $OpenedDocumentCopyWith<$Res> {
  factory $OpenedDocumentCopyWith(
    OpenedDocument value,
    $Res Function(OpenedDocument) then,
  ) = _$OpenedDocumentCopyWithImpl<$Res, OpenedDocument>;
  @useResult
  $Res call({
    Document document,
    String path,
    bool hasUnsavedChanges,
    bool showSavedIndicator,
  });

  $DocumentCopyWith<$Res> get document;
}

/// @nodoc
class _$OpenedDocumentCopyWithImpl<$Res, $Val extends OpenedDocument>
    implements $OpenedDocumentCopyWith<$Res> {
  _$OpenedDocumentCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of OpenedDocument
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? document = null,
    Object? path = null,
    Object? hasUnsavedChanges = null,
    Object? showSavedIndicator = null,
  }) {
    return _then(
      _value.copyWith(
            document: null == document
                ? _value.document
                : document // ignore: cast_nullable_to_non_nullable
                      as Document,
            path: null == path
                ? _value.path
                : path // ignore: cast_nullable_to_non_nullable
                      as String,
            hasUnsavedChanges: null == hasUnsavedChanges
                ? _value.hasUnsavedChanges
                : hasUnsavedChanges // ignore: cast_nullable_to_non_nullable
                      as bool,
            showSavedIndicator: null == showSavedIndicator
                ? _value.showSavedIndicator
                : showSavedIndicator // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }

  /// Create a copy of OpenedDocument
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
abstract class _$$OpenedDocumentImplCopyWith<$Res>
    implements $OpenedDocumentCopyWith<$Res> {
  factory _$$OpenedDocumentImplCopyWith(
    _$OpenedDocumentImpl value,
    $Res Function(_$OpenedDocumentImpl) then,
  ) = __$$OpenedDocumentImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    Document document,
    String path,
    bool hasUnsavedChanges,
    bool showSavedIndicator,
  });

  @override
  $DocumentCopyWith<$Res> get document;
}

/// @nodoc
class __$$OpenedDocumentImplCopyWithImpl<$Res>
    extends _$OpenedDocumentCopyWithImpl<$Res, _$OpenedDocumentImpl>
    implements _$$OpenedDocumentImplCopyWith<$Res> {
  __$$OpenedDocumentImplCopyWithImpl(
    _$OpenedDocumentImpl _value,
    $Res Function(_$OpenedDocumentImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of OpenedDocument
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? document = null,
    Object? path = null,
    Object? hasUnsavedChanges = null,
    Object? showSavedIndicator = null,
  }) {
    return _then(
      _$OpenedDocumentImpl(
        document: null == document
            ? _value.document
            : document // ignore: cast_nullable_to_non_nullable
                  as Document,
        path: null == path
            ? _value.path
            : path // ignore: cast_nullable_to_non_nullable
                  as String,
        hasUnsavedChanges: null == hasUnsavedChanges
            ? _value.hasUnsavedChanges
            : hasUnsavedChanges // ignore: cast_nullable_to_non_nullable
                  as bool,
        showSavedIndicator: null == showSavedIndicator
            ? _value.showSavedIndicator
            : showSavedIndicator // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc

class _$OpenedDocumentImpl implements _OpenedDocument {
  const _$OpenedDocumentImpl({
    required this.document,
    required this.path,
    this.hasUnsavedChanges = false,
    this.showSavedIndicator = false,
  });

  /// The in-memory document model.
  @override
  final Document document;

  /// Absolute path to the `.runa` file on disk.
  @override
  final String path;

  /// Whether the in-memory [document] differs from the saved version.
  @override
  @JsonKey()
  final bool hasUnsavedChanges;

  /// Whether to briefly show the "Guardado" indicator in the tab.
  ///
  /// Set to true after a manual Ctrl+S save; automatically cleared after 1.5 s.
  @override
  @JsonKey()
  final bool showSavedIndicator;

  @override
  String toString() {
    return 'OpenedDocument(document: $document, path: $path, hasUnsavedChanges: $hasUnsavedChanges, showSavedIndicator: $showSavedIndicator)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$OpenedDocumentImpl &&
            (identical(other.document, document) ||
                other.document == document) &&
            (identical(other.path, path) || other.path == path) &&
            (identical(other.hasUnsavedChanges, hasUnsavedChanges) ||
                other.hasUnsavedChanges == hasUnsavedChanges) &&
            (identical(other.showSavedIndicator, showSavedIndicator) ||
                other.showSavedIndicator == showSavedIndicator));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    document,
    path,
    hasUnsavedChanges,
    showSavedIndicator,
  );

  /// Create a copy of OpenedDocument
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$OpenedDocumentImplCopyWith<_$OpenedDocumentImpl> get copyWith =>
      __$$OpenedDocumentImplCopyWithImpl<_$OpenedDocumentImpl>(
        this,
        _$identity,
      );
}

abstract class _OpenedDocument implements OpenedDocument {
  const factory _OpenedDocument({
    required final Document document,
    required final String path,
    final bool hasUnsavedChanges,
    final bool showSavedIndicator,
  }) = _$OpenedDocumentImpl;

  /// The in-memory document model.
  @override
  Document get document;

  /// Absolute path to the `.runa` file on disk.
  @override
  String get path;

  /// Whether the in-memory [document] differs from the saved version.
  @override
  bool get hasUnsavedChanges;

  /// Whether to briefly show the "Guardado" indicator in the tab.
  ///
  /// Set to true after a manual Ctrl+S save; automatically cleared after 1.5 s.
  @override
  bool get showSavedIndicator;

  /// Create a copy of OpenedDocument
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$OpenedDocumentImplCopyWith<_$OpenedDocumentImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
