// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'stroke.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Stroke _$StrokeFromJson(Map<String, dynamic> json) {
  return _Stroke.fromJson(json);
}

/// @nodoc
mixin _$Stroke {
  /// Unique stroke identifier (UUID v4).
  String get id => throw _privateConstructorUsedError;

  /// Color in #RRGGBBAA format (e.g. "#000000FF" = opaque black).
  String get color => throw _privateConstructorUsedError;

  /// Base stroke width in logical pixels before pressure scaling.
  double get width => throw _privateConstructorUsedError;

  /// Tool that produced this stroke.
  StrokeTool get tool => throw _privateConstructorUsedError;

  /// Ordered sequence of input points. At least one point is required.
  List<StrokePoint> get points => throw _privateConstructorUsedError;

  /// Serializes this Stroke to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Stroke
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $StrokeCopyWith<Stroke> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $StrokeCopyWith<$Res> {
  factory $StrokeCopyWith(Stroke value, $Res Function(Stroke) then) =
      _$StrokeCopyWithImpl<$Res, Stroke>;
  @useResult
  $Res call({
    String id,
    String color,
    double width,
    StrokeTool tool,
    List<StrokePoint> points,
  });
}

/// @nodoc
class _$StrokeCopyWithImpl<$Res, $Val extends Stroke>
    implements $StrokeCopyWith<$Res> {
  _$StrokeCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Stroke
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? color = null,
    Object? width = null,
    Object? tool = null,
    Object? points = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            color: null == color
                ? _value.color
                : color // ignore: cast_nullable_to_non_nullable
                      as String,
            width: null == width
                ? _value.width
                : width // ignore: cast_nullable_to_non_nullable
                      as double,
            tool: null == tool
                ? _value.tool
                : tool // ignore: cast_nullable_to_non_nullable
                      as StrokeTool,
            points: null == points
                ? _value.points
                : points // ignore: cast_nullable_to_non_nullable
                      as List<StrokePoint>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$StrokeImplCopyWith<$Res> implements $StrokeCopyWith<$Res> {
  factory _$$StrokeImplCopyWith(
    _$StrokeImpl value,
    $Res Function(_$StrokeImpl) then,
  ) = __$$StrokeImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String color,
    double width,
    StrokeTool tool,
    List<StrokePoint> points,
  });
}

/// @nodoc
class __$$StrokeImplCopyWithImpl<$Res>
    extends _$StrokeCopyWithImpl<$Res, _$StrokeImpl>
    implements _$$StrokeImplCopyWith<$Res> {
  __$$StrokeImplCopyWithImpl(
    _$StrokeImpl _value,
    $Res Function(_$StrokeImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Stroke
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? color = null,
    Object? width = null,
    Object? tool = null,
    Object? points = null,
  }) {
    return _then(
      _$StrokeImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        color: null == color
            ? _value.color
            : color // ignore: cast_nullable_to_non_nullable
                  as String,
        width: null == width
            ? _value.width
            : width // ignore: cast_nullable_to_non_nullable
                  as double,
        tool: null == tool
            ? _value.tool
            : tool // ignore: cast_nullable_to_non_nullable
                  as StrokeTool,
        points: null == points
            ? _value._points
            : points // ignore: cast_nullable_to_non_nullable
                  as List<StrokePoint>,
      ),
    );
  }
}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _$StrokeImpl implements _Stroke {
  const _$StrokeImpl({
    required this.id,
    required this.color,
    required this.width,
    required this.tool,
    required final List<StrokePoint> points,
  }) : _points = points;

  factory _$StrokeImpl.fromJson(Map<String, dynamic> json) =>
      _$$StrokeImplFromJson(json);

  /// Unique stroke identifier (UUID v4).
  @override
  final String id;

  /// Color in #RRGGBBAA format (e.g. "#000000FF" = opaque black).
  @override
  final String color;

  /// Base stroke width in logical pixels before pressure scaling.
  @override
  final double width;

  /// Tool that produced this stroke.
  @override
  final StrokeTool tool;

  /// Ordered sequence of input points. At least one point is required.
  final List<StrokePoint> _points;

  /// Ordered sequence of input points. At least one point is required.
  @override
  List<StrokePoint> get points {
    if (_points is EqualUnmodifiableListView) return _points;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_points);
  }

  @override
  String toString() {
    return 'Stroke(id: $id, color: $color, width: $width, tool: $tool, points: $points)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$StrokeImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.color, color) || other.color == color) &&
            (identical(other.width, width) || other.width == width) &&
            (identical(other.tool, tool) || other.tool == tool) &&
            const DeepCollectionEquality().equals(other._points, _points));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    color,
    width,
    tool,
    const DeepCollectionEquality().hash(_points),
  );

  /// Create a copy of Stroke
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$StrokeImplCopyWith<_$StrokeImpl> get copyWith =>
      __$$StrokeImplCopyWithImpl<_$StrokeImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$StrokeImplToJson(this);
  }
}

abstract class _Stroke implements Stroke {
  const factory _Stroke({
    required final String id,
    required final String color,
    required final double width,
    required final StrokeTool tool,
    required final List<StrokePoint> points,
  }) = _$StrokeImpl;

  factory _Stroke.fromJson(Map<String, dynamic> json) = _$StrokeImpl.fromJson;

  /// Unique stroke identifier (UUID v4).
  @override
  String get id;

  /// Color in #RRGGBBAA format (e.g. "#000000FF" = opaque black).
  @override
  String get color;

  /// Base stroke width in logical pixels before pressure scaling.
  @override
  double get width;

  /// Tool that produced this stroke.
  @override
  StrokeTool get tool;

  /// Ordered sequence of input points. At least one point is required.
  @override
  List<StrokePoint> get points;

  /// Create a copy of Stroke
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$StrokeImplCopyWith<_$StrokeImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
