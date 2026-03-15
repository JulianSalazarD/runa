// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'stroke_point.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$StrokePoint {

/// X coordinate in logical pixels relative to the [InkBlock] canvas origin.
 double get x;/// Y coordinate in logical pixels relative to the [InkBlock] canvas origin.
 double get y;/// Normalised stylus/touch pressure in [0.0, 1.0].
/// Use 0.5 when the device does not report pressure.
 double get pressure;/// Milliseconds since Unix epoch when this point was sampled.
 int get timestamp;
/// Create a copy of StrokePoint
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StrokePointCopyWith<StrokePoint> get copyWith => _$StrokePointCopyWithImpl<StrokePoint>(this as StrokePoint, _$identity);

  /// Serializes this StrokePoint to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StrokePoint&&(identical(other.x, x) || other.x == x)&&(identical(other.y, y) || other.y == y)&&(identical(other.pressure, pressure) || other.pressure == pressure)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,x,y,pressure,timestamp);

@override
String toString() {
  return 'StrokePoint(x: $x, y: $y, pressure: $pressure, timestamp: $timestamp)';
}


}

/// @nodoc
abstract mixin class $StrokePointCopyWith<$Res>  {
  factory $StrokePointCopyWith(StrokePoint value, $Res Function(StrokePoint) _then) = _$StrokePointCopyWithImpl;
@useResult
$Res call({
 double x, double y, double pressure, int timestamp
});




}
/// @nodoc
class _$StrokePointCopyWithImpl<$Res>
    implements $StrokePointCopyWith<$Res> {
  _$StrokePointCopyWithImpl(this._self, this._then);

  final StrokePoint _self;
  final $Res Function(StrokePoint) _then;

/// Create a copy of StrokePoint
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? x = null,Object? y = null,Object? pressure = null,Object? timestamp = null,}) {
  return _then(_self.copyWith(
x: null == x ? _self.x : x // ignore: cast_nullable_to_non_nullable
as double,y: null == y ? _self.y : y // ignore: cast_nullable_to_non_nullable
as double,pressure: null == pressure ? _self.pressure : pressure // ignore: cast_nullable_to_non_nullable
as double,timestamp: null == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [StrokePoint].
extension StrokePointPatterns on StrokePoint {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _StrokePoint value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _StrokePoint() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _StrokePoint value)  $default,){
final _that = this;
switch (_that) {
case _StrokePoint():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _StrokePoint value)?  $default,){
final _that = this;
switch (_that) {
case _StrokePoint() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double x,  double y,  double pressure,  int timestamp)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _StrokePoint() when $default != null:
return $default(_that.x,_that.y,_that.pressure,_that.timestamp);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double x,  double y,  double pressure,  int timestamp)  $default,) {final _that = this;
switch (_that) {
case _StrokePoint():
return $default(_that.x,_that.y,_that.pressure,_that.timestamp);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double x,  double y,  double pressure,  int timestamp)?  $default,) {final _that = this;
switch (_that) {
case _StrokePoint() when $default != null:
return $default(_that.x,_that.y,_that.pressure,_that.timestamp);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _StrokePoint implements StrokePoint {
  const _StrokePoint({required this.x, required this.y, required this.pressure, required this.timestamp});
  factory _StrokePoint.fromJson(Map<String, dynamic> json) => _$StrokePointFromJson(json);

/// X coordinate in logical pixels relative to the [InkBlock] canvas origin.
@override final  double x;
/// Y coordinate in logical pixels relative to the [InkBlock] canvas origin.
@override final  double y;
/// Normalised stylus/touch pressure in [0.0, 1.0].
/// Use 0.5 when the device does not report pressure.
@override final  double pressure;
/// Milliseconds since Unix epoch when this point was sampled.
@override final  int timestamp;

/// Create a copy of StrokePoint
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StrokePointCopyWith<_StrokePoint> get copyWith => __$StrokePointCopyWithImpl<_StrokePoint>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$StrokePointToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _StrokePoint&&(identical(other.x, x) || other.x == x)&&(identical(other.y, y) || other.y == y)&&(identical(other.pressure, pressure) || other.pressure == pressure)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,x,y,pressure,timestamp);

@override
String toString() {
  return 'StrokePoint(x: $x, y: $y, pressure: $pressure, timestamp: $timestamp)';
}


}

/// @nodoc
abstract mixin class _$StrokePointCopyWith<$Res> implements $StrokePointCopyWith<$Res> {
  factory _$StrokePointCopyWith(_StrokePoint value, $Res Function(_StrokePoint) _then) = __$StrokePointCopyWithImpl;
@override @useResult
$Res call({
 double x, double y, double pressure, int timestamp
});




}
/// @nodoc
class __$StrokePointCopyWithImpl<$Res>
    implements _$StrokePointCopyWith<$Res> {
  __$StrokePointCopyWithImpl(this._self, this._then);

  final _StrokePoint _self;
  final $Res Function(_StrokePoint) _then;

/// Create a copy of StrokePoint
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? x = null,Object? y = null,Object? pressure = null,Object? timestamp = null,}) {
  return _then(_StrokePoint(
x: null == x ? _self.x : x // ignore: cast_nullable_to_non_nullable
as double,y: null == y ? _self.y : y // ignore: cast_nullable_to_non_nullable
as double,pressure: null == pressure ? _self.pressure : pressure // ignore: cast_nullable_to_non_nullable
as double,timestamp: null == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
