// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'block.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Block _$BlockFromJson(Map<String, dynamic> json) {
  switch (json['type']) {
    case 'markdown':
      return MarkdownBlock.fromJson(json);
    case 'ink':
      return InkBlock.fromJson(json);

    default:
      throw CheckedFromJsonException(
        json,
        'type',
        'Block',
        'Invalid union type "${json['type']}"!',
      );
  }
}

/// @nodoc
mixin _$Block {
  /// Unique block identifier (UUID v4).
  String get id => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String id, String content) markdown,
    required TResult Function(String id, double height, List<Stroke> strokes)
    ink,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String id, String content)? markdown,
    TResult? Function(String id, double height, List<Stroke> strokes)? ink,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String id, String content)? markdown,
    TResult Function(String id, double height, List<Stroke> strokes)? ink,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(MarkdownBlock value) markdown,
    required TResult Function(InkBlock value) ink,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(MarkdownBlock value)? markdown,
    TResult? Function(InkBlock value)? ink,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(MarkdownBlock value)? markdown,
    TResult Function(InkBlock value)? ink,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;

  /// Serializes this Block to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Block
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BlockCopyWith<Block> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BlockCopyWith<$Res> {
  factory $BlockCopyWith(Block value, $Res Function(Block) then) =
      _$BlockCopyWithImpl<$Res, Block>;
  @useResult
  $Res call({String id});
}

/// @nodoc
class _$BlockCopyWithImpl<$Res, $Val extends Block>
    implements $BlockCopyWith<$Res> {
  _$BlockCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Block
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? id = null}) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$MarkdownBlockImplCopyWith<$Res>
    implements $BlockCopyWith<$Res> {
  factory _$$MarkdownBlockImplCopyWith(
    _$MarkdownBlockImpl value,
    $Res Function(_$MarkdownBlockImpl) then,
  ) = __$$MarkdownBlockImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String id, String content});
}

/// @nodoc
class __$$MarkdownBlockImplCopyWithImpl<$Res>
    extends _$BlockCopyWithImpl<$Res, _$MarkdownBlockImpl>
    implements _$$MarkdownBlockImplCopyWith<$Res> {
  __$$MarkdownBlockImplCopyWithImpl(
    _$MarkdownBlockImpl _value,
    $Res Function(_$MarkdownBlockImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Block
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? id = null, Object? content = null}) {
    return _then(
      _$MarkdownBlockImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        content: null == content
            ? _value.content
            : content // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _$MarkdownBlockImpl implements MarkdownBlock {
  const _$MarkdownBlockImpl({
    required this.id,
    required this.content,
    final String? $type,
  }) : $type = $type ?? 'markdown';

  factory _$MarkdownBlockImpl.fromJson(Map<String, dynamic> json) =>
      _$$MarkdownBlockImplFromJson(json);

  /// Unique block identifier (UUID v4).
  @override
  final String id;

  /// Raw Markdown content. Empty string is valid (new empty block).
  @override
  final String content;

  @JsonKey(name: 'type')
  final String $type;

  @override
  String toString() {
    return 'Block.markdown(id: $id, content: $content)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MarkdownBlockImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.content, content) || other.content == content));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, content);

  /// Create a copy of Block
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MarkdownBlockImplCopyWith<_$MarkdownBlockImpl> get copyWith =>
      __$$MarkdownBlockImplCopyWithImpl<_$MarkdownBlockImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String id, String content) markdown,
    required TResult Function(String id, double height, List<Stroke> strokes)
    ink,
  }) {
    return markdown(id, content);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String id, String content)? markdown,
    TResult? Function(String id, double height, List<Stroke> strokes)? ink,
  }) {
    return markdown?.call(id, content);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String id, String content)? markdown,
    TResult Function(String id, double height, List<Stroke> strokes)? ink,
    required TResult orElse(),
  }) {
    if (markdown != null) {
      return markdown(id, content);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(MarkdownBlock value) markdown,
    required TResult Function(InkBlock value) ink,
  }) {
    return markdown(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(MarkdownBlock value)? markdown,
    TResult? Function(InkBlock value)? ink,
  }) {
    return markdown?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(MarkdownBlock value)? markdown,
    TResult Function(InkBlock value)? ink,
    required TResult orElse(),
  }) {
    if (markdown != null) {
      return markdown(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$MarkdownBlockImplToJson(this);
  }
}

abstract class MarkdownBlock implements Block {
  const factory MarkdownBlock({
    required final String id,
    required final String content,
  }) = _$MarkdownBlockImpl;

  factory MarkdownBlock.fromJson(Map<String, dynamic> json) =
      _$MarkdownBlockImpl.fromJson;

  /// Unique block identifier (UUID v4).
  @override
  String get id;

  /// Raw Markdown content. Empty string is valid (new empty block).
  String get content;

  /// Create a copy of Block
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MarkdownBlockImplCopyWith<_$MarkdownBlockImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$InkBlockImplCopyWith<$Res> implements $BlockCopyWith<$Res> {
  factory _$$InkBlockImplCopyWith(
    _$InkBlockImpl value,
    $Res Function(_$InkBlockImpl) then,
  ) = __$$InkBlockImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String id, double height, List<Stroke> strokes});
}

/// @nodoc
class __$$InkBlockImplCopyWithImpl<$Res>
    extends _$BlockCopyWithImpl<$Res, _$InkBlockImpl>
    implements _$$InkBlockImplCopyWith<$Res> {
  __$$InkBlockImplCopyWithImpl(
    _$InkBlockImpl _value,
    $Res Function(_$InkBlockImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Block
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? height = null,
    Object? strokes = null,
  }) {
    return _then(
      _$InkBlockImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        height: null == height
            ? _value.height
            : height // ignore: cast_nullable_to_non_nullable
                  as double,
        strokes: null == strokes
            ? _value._strokes
            : strokes // ignore: cast_nullable_to_non_nullable
                  as List<Stroke>,
      ),
    );
  }
}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _$InkBlockImpl implements InkBlock {
  const _$InkBlockImpl({
    required this.id,
    required this.height,
    final List<Stroke> strokes = const [],
    final String? $type,
  }) : _strokes = strokes,
       $type = $type ?? 'ink';

  factory _$InkBlockImpl.fromJson(Map<String, dynamic> json) =>
      _$$InkBlockImplFromJson(json);

  /// Unique block identifier (UUID v4).
  @override
  final String id;

  /// Canvas height in logical pixels. Must be positive.
  @override
  final double height;

  /// Ink strokes in draw order (painter's algorithm). May be empty.
  final List<Stroke> _strokes;

  /// Ink strokes in draw order (painter's algorithm). May be empty.
  @override
  @JsonKey()
  List<Stroke> get strokes {
    if (_strokes is EqualUnmodifiableListView) return _strokes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_strokes);
  }

  @JsonKey(name: 'type')
  final String $type;

  @override
  String toString() {
    return 'Block.ink(id: $id, height: $height, strokes: $strokes)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$InkBlockImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.height, height) || other.height == height) &&
            const DeepCollectionEquality().equals(other._strokes, _strokes));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    height,
    const DeepCollectionEquality().hash(_strokes),
  );

  /// Create a copy of Block
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$InkBlockImplCopyWith<_$InkBlockImpl> get copyWith =>
      __$$InkBlockImplCopyWithImpl<_$InkBlockImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String id, String content) markdown,
    required TResult Function(String id, double height, List<Stroke> strokes)
    ink,
  }) {
    return ink(id, height, strokes);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String id, String content)? markdown,
    TResult? Function(String id, double height, List<Stroke> strokes)? ink,
  }) {
    return ink?.call(id, height, strokes);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String id, String content)? markdown,
    TResult Function(String id, double height, List<Stroke> strokes)? ink,
    required TResult orElse(),
  }) {
    if (ink != null) {
      return ink(id, height, strokes);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(MarkdownBlock value) markdown,
    required TResult Function(InkBlock value) ink,
  }) {
    return ink(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(MarkdownBlock value)? markdown,
    TResult? Function(InkBlock value)? ink,
  }) {
    return ink?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(MarkdownBlock value)? markdown,
    TResult Function(InkBlock value)? ink,
    required TResult orElse(),
  }) {
    if (ink != null) {
      return ink(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$InkBlockImplToJson(this);
  }
}

abstract class InkBlock implements Block {
  const factory InkBlock({
    required final String id,
    required final double height,
    final List<Stroke> strokes,
  }) = _$InkBlockImpl;

  factory InkBlock.fromJson(Map<String, dynamic> json) =
      _$InkBlockImpl.fromJson;

  /// Unique block identifier (UUID v4).
  @override
  String get id;

  /// Canvas height in logical pixels. Must be positive.
  double get height;

  /// Ink strokes in draw order (painter's algorithm). May be empty.
  List<Stroke> get strokes;

  /// Create a copy of Block
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$InkBlockImplCopyWith<_$InkBlockImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
