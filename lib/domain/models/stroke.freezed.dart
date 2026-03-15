// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'stroke.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Stroke {

/// Unique stroke identifier (UUID v4).
 String get id;/// Color in #RRGGBBAA format (e.g. "#000000FF" = opaque black).
 String get color;/// Base stroke width in logical pixels before pressure scaling.
 double get width;/// Tool that produced this stroke.
 StrokeTool get tool;/// Ordered sequence of input points. At least one point is required.
 List<StrokePoint> get points;
/// Create a copy of Stroke
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StrokeCopyWith<Stroke> get copyWith => _$StrokeCopyWithImpl<Stroke>(this as Stroke, _$identity);

  /// Serializes this Stroke to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Stroke&&(identical(other.id, id) || other.id == id)&&(identical(other.color, color) || other.color == color)&&(identical(other.width, width) || other.width == width)&&(identical(other.tool, tool) || other.tool == tool)&&const DeepCollectionEquality().equals(other.points, points));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,color,width,tool,const DeepCollectionEquality().hash(points));

@override
String toString() {
  return 'Stroke(id: $id, color: $color, width: $width, tool: $tool, points: $points)';
}


}

/// @nodoc
abstract mixin class $StrokeCopyWith<$Res>  {
  factory $StrokeCopyWith(Stroke value, $Res Function(Stroke) _then) = _$StrokeCopyWithImpl;
@useResult
$Res call({
 String id, String color, double width, StrokeTool tool, List<StrokePoint> points
});




}
/// @nodoc
class _$StrokeCopyWithImpl<$Res>
    implements $StrokeCopyWith<$Res> {
  _$StrokeCopyWithImpl(this._self, this._then);

  final Stroke _self;
  final $Res Function(Stroke) _then;

/// Create a copy of Stroke
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? color = null,Object? width = null,Object? tool = null,Object? points = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,color: null == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as String,width: null == width ? _self.width : width // ignore: cast_nullable_to_non_nullable
as double,tool: null == tool ? _self.tool : tool // ignore: cast_nullable_to_non_nullable
as StrokeTool,points: null == points ? _self.points : points // ignore: cast_nullable_to_non_nullable
as List<StrokePoint>,
  ));
}

}


/// Adds pattern-matching-related methods to [Stroke].
extension StrokePatterns on Stroke {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Stroke value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Stroke() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Stroke value)  $default,){
final _that = this;
switch (_that) {
case _Stroke():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Stroke value)?  $default,){
final _that = this;
switch (_that) {
case _Stroke() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String color,  double width,  StrokeTool tool,  List<StrokePoint> points)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Stroke() when $default != null:
return $default(_that.id,_that.color,_that.width,_that.tool,_that.points);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String color,  double width,  StrokeTool tool,  List<StrokePoint> points)  $default,) {final _that = this;
switch (_that) {
case _Stroke():
return $default(_that.id,_that.color,_that.width,_that.tool,_that.points);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String color,  double width,  StrokeTool tool,  List<StrokePoint> points)?  $default,) {final _that = this;
switch (_that) {
case _Stroke() when $default != null:
return $default(_that.id,_that.color,_that.width,_that.tool,_that.points);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _Stroke implements Stroke {
  const _Stroke({required this.id, required this.color, required this.width, required this.tool, required final  List<StrokePoint> points}): _points = points;
  factory _Stroke.fromJson(Map<String, dynamic> json) => _$StrokeFromJson(json);

/// Unique stroke identifier (UUID v4).
@override final  String id;
/// Color in #RRGGBBAA format (e.g. "#000000FF" = opaque black).
@override final  String color;
/// Base stroke width in logical pixels before pressure scaling.
@override final  double width;
/// Tool that produced this stroke.
@override final  StrokeTool tool;
/// Ordered sequence of input points. At least one point is required.
 final  List<StrokePoint> _points;
/// Ordered sequence of input points. At least one point is required.
@override List<StrokePoint> get points {
  if (_points is EqualUnmodifiableListView) return _points;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_points);
}


/// Create a copy of Stroke
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StrokeCopyWith<_Stroke> get copyWith => __$StrokeCopyWithImpl<_Stroke>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$StrokeToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Stroke&&(identical(other.id, id) || other.id == id)&&(identical(other.color, color) || other.color == color)&&(identical(other.width, width) || other.width == width)&&(identical(other.tool, tool) || other.tool == tool)&&const DeepCollectionEquality().equals(other._points, _points));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,color,width,tool,const DeepCollectionEquality().hash(_points));

@override
String toString() {
  return 'Stroke(id: $id, color: $color, width: $width, tool: $tool, points: $points)';
}


}

/// @nodoc
abstract mixin class _$StrokeCopyWith<$Res> implements $StrokeCopyWith<$Res> {
  factory _$StrokeCopyWith(_Stroke value, $Res Function(_Stroke) _then) = __$StrokeCopyWithImpl;
@override @useResult
$Res call({
 String id, String color, double width, StrokeTool tool, List<StrokePoint> points
});




}
/// @nodoc
class __$StrokeCopyWithImpl<$Res>
    implements _$StrokeCopyWith<$Res> {
  __$StrokeCopyWithImpl(this._self, this._then);

  final _Stroke _self;
  final $Res Function(_Stroke) _then;

/// Create a copy of Stroke
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? color = null,Object? width = null,Object? tool = null,Object? points = null,}) {
  return _then(_Stroke(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,color: null == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as String,width: null == width ? _self.width : width // ignore: cast_nullable_to_non_nullable
as double,tool: null == tool ? _self.tool : tool // ignore: cast_nullable_to_non_nullable
as StrokeTool,points: null == points ? _self._points : points // ignore: cast_nullable_to_non_nullable
as List<StrokePoint>,
  ));
}


}

// dart format on
