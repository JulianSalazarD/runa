// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'text_element.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

TextElement _$TextElementFromJson(Map<String, dynamic> json) {
  return _TextElement.fromJson(json);
}

/// @nodoc
mixin _$TextElement {
  String get id => throw _privateConstructorUsedError;
  double get x => throw _privateConstructorUsedError;
  double get y => throw _privateConstructorUsedError;
  String get content => throw _privateConstructorUsedError;
  double get fontSize => throw _privateConstructorUsedError;
  String get color => throw _privateConstructorUsedError;
  String? get fontFamily => throw _privateConstructorUsedError;
  bool get bold => throw _privateConstructorUsedError;
  bool get italic => throw _privateConstructorUsedError;

  /// Serializes this TextElement to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TextElement
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TextElementCopyWith<TextElement> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TextElementCopyWith<$Res> {
  factory $TextElementCopyWith(
    TextElement value,
    $Res Function(TextElement) then,
  ) = _$TextElementCopyWithImpl<$Res, TextElement>;
  @useResult
  $Res call({
    String id,
    double x,
    double y,
    String content,
    double fontSize,
    String color,
    String? fontFamily,
    bool bold,
    bool italic,
  });
}

/// @nodoc
class _$TextElementCopyWithImpl<$Res, $Val extends TextElement>
    implements $TextElementCopyWith<$Res> {
  _$TextElementCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TextElement
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? x = null,
    Object? y = null,
    Object? content = null,
    Object? fontSize = null,
    Object? color = null,
    Object? fontFamily = freezed,
    Object? bold = null,
    Object? italic = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            x: null == x
                ? _value.x
                : x // ignore: cast_nullable_to_non_nullable
                      as double,
            y: null == y
                ? _value.y
                : y // ignore: cast_nullable_to_non_nullable
                      as double,
            content: null == content
                ? _value.content
                : content // ignore: cast_nullable_to_non_nullable
                      as String,
            fontSize: null == fontSize
                ? _value.fontSize
                : fontSize // ignore: cast_nullable_to_non_nullable
                      as double,
            color: null == color
                ? _value.color
                : color // ignore: cast_nullable_to_non_nullable
                      as String,
            fontFamily: freezed == fontFamily
                ? _value.fontFamily
                : fontFamily // ignore: cast_nullable_to_non_nullable
                      as String?,
            bold: null == bold
                ? _value.bold
                : bold // ignore: cast_nullable_to_non_nullable
                      as bool,
            italic: null == italic
                ? _value.italic
                : italic // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$TextElementImplCopyWith<$Res>
    implements $TextElementCopyWith<$Res> {
  factory _$$TextElementImplCopyWith(
    _$TextElementImpl value,
    $Res Function(_$TextElementImpl) then,
  ) = __$$TextElementImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    double x,
    double y,
    String content,
    double fontSize,
    String color,
    String? fontFamily,
    bool bold,
    bool italic,
  });
}

/// @nodoc
class __$$TextElementImplCopyWithImpl<$Res>
    extends _$TextElementCopyWithImpl<$Res, _$TextElementImpl>
    implements _$$TextElementImplCopyWith<$Res> {
  __$$TextElementImplCopyWithImpl(
    _$TextElementImpl _value,
    $Res Function(_$TextElementImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TextElement
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? x = null,
    Object? y = null,
    Object? content = null,
    Object? fontSize = null,
    Object? color = null,
    Object? fontFamily = freezed,
    Object? bold = null,
    Object? italic = null,
  }) {
    return _then(
      _$TextElementImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        x: null == x
            ? _value.x
            : x // ignore: cast_nullable_to_non_nullable
                  as double,
        y: null == y
            ? _value.y
            : y // ignore: cast_nullable_to_non_nullable
                  as double,
        content: null == content
            ? _value.content
            : content // ignore: cast_nullable_to_non_nullable
                  as String,
        fontSize: null == fontSize
            ? _value.fontSize
            : fontSize // ignore: cast_nullable_to_non_nullable
                  as double,
        color: null == color
            ? _value.color
            : color // ignore: cast_nullable_to_non_nullable
                  as String,
        fontFamily: freezed == fontFamily
            ? _value.fontFamily
            : fontFamily // ignore: cast_nullable_to_non_nullable
                  as String?,
        bold: null == bold
            ? _value.bold
            : bold // ignore: cast_nullable_to_non_nullable
                  as bool,
        italic: null == italic
            ? _value.italic
            : italic // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$TextElementImpl implements _TextElement {
  const _$TextElementImpl({
    required this.id,
    required this.x,
    required this.y,
    required this.content,
    this.fontSize = 16.0,
    this.color = '#000000FF',
    this.fontFamily,
    this.bold = false,
    this.italic = false,
  });

  factory _$TextElementImpl.fromJson(Map<String, dynamic> json) =>
      _$$TextElementImplFromJson(json);

  @override
  final String id;
  @override
  final double x;
  @override
  final double y;
  @override
  final String content;
  @override
  @JsonKey()
  final double fontSize;
  @override
  @JsonKey()
  final String color;
  @override
  final String? fontFamily;
  @override
  @JsonKey()
  final bool bold;
  @override
  @JsonKey()
  final bool italic;

  @override
  String toString() {
    return 'TextElement(id: $id, x: $x, y: $y, content: $content, fontSize: $fontSize, color: $color, fontFamily: $fontFamily, bold: $bold, italic: $italic)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TextElementImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.x, x) || other.x == x) &&
            (identical(other.y, y) || other.y == y) &&
            (identical(other.content, content) || other.content == content) &&
            (identical(other.fontSize, fontSize) ||
                other.fontSize == fontSize) &&
            (identical(other.color, color) || other.color == color) &&
            (identical(other.fontFamily, fontFamily) ||
                other.fontFamily == fontFamily) &&
            (identical(other.bold, bold) || other.bold == bold) &&
            (identical(other.italic, italic) || other.italic == italic));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    x,
    y,
    content,
    fontSize,
    color,
    fontFamily,
    bold,
    italic,
  );

  /// Create a copy of TextElement
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TextElementImplCopyWith<_$TextElementImpl> get copyWith =>
      __$$TextElementImplCopyWithImpl<_$TextElementImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TextElementImplToJson(this);
  }
}

abstract class _TextElement implements TextElement {
  const factory _TextElement({
    required final String id,
    required final double x,
    required final double y,
    required final String content,
    final double fontSize,
    final String color,
    final String? fontFamily,
    final bool bold,
    final bool italic,
  }) = _$TextElementImpl;

  factory _TextElement.fromJson(Map<String, dynamic> json) =
      _$TextElementImpl.fromJson;

  @override
  String get id;
  @override
  double get x;
  @override
  double get y;
  @override
  String get content;
  @override
  double get fontSize;
  @override
  String get color;
  @override
  String? get fontFamily;
  @override
  bool get bold;
  @override
  bool get italic;

  /// Create a copy of TextElement
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TextElementImplCopyWith<_$TextElementImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
