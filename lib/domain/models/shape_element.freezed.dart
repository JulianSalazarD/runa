// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'shape_element.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ShapeElement {

 String get id; ShapeType get type; double get x1; double get y1; double get x2; double get y2; String get color; double get strokeWidth; bool get filled; String? get fillColor;
/// Create a copy of ShapeElement
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ShapeElementCopyWith<ShapeElement> get copyWith => _$ShapeElementCopyWithImpl<ShapeElement>(this as ShapeElement, _$identity);

  /// Serializes this ShapeElement to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ShapeElement&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&(identical(other.x1, x1) || other.x1 == x1)&&(identical(other.y1, y1) || other.y1 == y1)&&(identical(other.x2, x2) || other.x2 == x2)&&(identical(other.y2, y2) || other.y2 == y2)&&(identical(other.color, color) || other.color == color)&&(identical(other.strokeWidth, strokeWidth) || other.strokeWidth == strokeWidth)&&(identical(other.filled, filled) || other.filled == filled)&&(identical(other.fillColor, fillColor) || other.fillColor == fillColor));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,type,x1,y1,x2,y2,color,strokeWidth,filled,fillColor);

@override
String toString() {
  return 'ShapeElement(id: $id, type: $type, x1: $x1, y1: $y1, x2: $x2, y2: $y2, color: $color, strokeWidth: $strokeWidth, filled: $filled, fillColor: $fillColor)';
}


}

/// @nodoc
abstract mixin class $ShapeElementCopyWith<$Res>  {
  factory $ShapeElementCopyWith(ShapeElement value, $Res Function(ShapeElement) _then) = _$ShapeElementCopyWithImpl;
@useResult
$Res call({
 String id, ShapeType type, double x1, double y1, double x2, double y2, String color, double strokeWidth, bool filled, String? fillColor
});




}
/// @nodoc
class _$ShapeElementCopyWithImpl<$Res>
    implements $ShapeElementCopyWith<$Res> {
  _$ShapeElementCopyWithImpl(this._self, this._then);

  final ShapeElement _self;
  final $Res Function(ShapeElement) _then;

/// Create a copy of ShapeElement
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? type = null,Object? x1 = null,Object? y1 = null,Object? x2 = null,Object? y2 = null,Object? color = null,Object? strokeWidth = null,Object? filled = null,Object? fillColor = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as ShapeType,x1: null == x1 ? _self.x1 : x1 // ignore: cast_nullable_to_non_nullable
as double,y1: null == y1 ? _self.y1 : y1 // ignore: cast_nullable_to_non_nullable
as double,x2: null == x2 ? _self.x2 : x2 // ignore: cast_nullable_to_non_nullable
as double,y2: null == y2 ? _self.y2 : y2 // ignore: cast_nullable_to_non_nullable
as double,color: null == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as String,strokeWidth: null == strokeWidth ? _self.strokeWidth : strokeWidth // ignore: cast_nullable_to_non_nullable
as double,filled: null == filled ? _self.filled : filled // ignore: cast_nullable_to_non_nullable
as bool,fillColor: freezed == fillColor ? _self.fillColor : fillColor // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ShapeElement].
extension ShapeElementPatterns on ShapeElement {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ShapeElement value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ShapeElement() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ShapeElement value)  $default,){
final _that = this;
switch (_that) {
case _ShapeElement():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ShapeElement value)?  $default,){
final _that = this;
switch (_that) {
case _ShapeElement() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  ShapeType type,  double x1,  double y1,  double x2,  double y2,  String color,  double strokeWidth,  bool filled,  String? fillColor)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ShapeElement() when $default != null:
return $default(_that.id,_that.type,_that.x1,_that.y1,_that.x2,_that.y2,_that.color,_that.strokeWidth,_that.filled,_that.fillColor);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  ShapeType type,  double x1,  double y1,  double x2,  double y2,  String color,  double strokeWidth,  bool filled,  String? fillColor)  $default,) {final _that = this;
switch (_that) {
case _ShapeElement():
return $default(_that.id,_that.type,_that.x1,_that.y1,_that.x2,_that.y2,_that.color,_that.strokeWidth,_that.filled,_that.fillColor);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  ShapeType type,  double x1,  double y1,  double x2,  double y2,  String color,  double strokeWidth,  bool filled,  String? fillColor)?  $default,) {final _that = this;
switch (_that) {
case _ShapeElement() when $default != null:
return $default(_that.id,_that.type,_that.x1,_that.y1,_that.x2,_that.y2,_that.color,_that.strokeWidth,_that.filled,_that.fillColor);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ShapeElement implements ShapeElement {
  const _ShapeElement({required this.id, required this.type, required this.x1, required this.y1, required this.x2, required this.y2, this.color = '#000000FF', this.strokeWidth = 2.0, this.filled = false, this.fillColor});
  factory _ShapeElement.fromJson(Map<String, dynamic> json) => _$ShapeElementFromJson(json);

@override final  String id;
@override final  ShapeType type;
@override final  double x1;
@override final  double y1;
@override final  double x2;
@override final  double y2;
@override@JsonKey() final  String color;
@override@JsonKey() final  double strokeWidth;
@override@JsonKey() final  bool filled;
@override final  String? fillColor;

/// Create a copy of ShapeElement
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ShapeElementCopyWith<_ShapeElement> get copyWith => __$ShapeElementCopyWithImpl<_ShapeElement>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ShapeElementToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ShapeElement&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&(identical(other.x1, x1) || other.x1 == x1)&&(identical(other.y1, y1) || other.y1 == y1)&&(identical(other.x2, x2) || other.x2 == x2)&&(identical(other.y2, y2) || other.y2 == y2)&&(identical(other.color, color) || other.color == color)&&(identical(other.strokeWidth, strokeWidth) || other.strokeWidth == strokeWidth)&&(identical(other.filled, filled) || other.filled == filled)&&(identical(other.fillColor, fillColor) || other.fillColor == fillColor));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,type,x1,y1,x2,y2,color,strokeWidth,filled,fillColor);

@override
String toString() {
  return 'ShapeElement(id: $id, type: $type, x1: $x1, y1: $y1, x2: $x2, y2: $y2, color: $color, strokeWidth: $strokeWidth, filled: $filled, fillColor: $fillColor)';
}


}

/// @nodoc
abstract mixin class _$ShapeElementCopyWith<$Res> implements $ShapeElementCopyWith<$Res> {
  factory _$ShapeElementCopyWith(_ShapeElement value, $Res Function(_ShapeElement) _then) = __$ShapeElementCopyWithImpl;
@override @useResult
$Res call({
 String id, ShapeType type, double x1, double y1, double x2, double y2, String color, double strokeWidth, bool filled, String? fillColor
});




}
/// @nodoc
class __$ShapeElementCopyWithImpl<$Res>
    implements _$ShapeElementCopyWith<$Res> {
  __$ShapeElementCopyWithImpl(this._self, this._then);

  final _ShapeElement _self;
  final $Res Function(_ShapeElement) _then;

/// Create a copy of ShapeElement
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? type = null,Object? x1 = null,Object? y1 = null,Object? x2 = null,Object? y2 = null,Object? color = null,Object? strokeWidth = null,Object? filled = null,Object? fillColor = freezed,}) {
  return _then(_ShapeElement(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as ShapeType,x1: null == x1 ? _self.x1 : x1 // ignore: cast_nullable_to_non_nullable
as double,y1: null == y1 ? _self.y1 : y1 // ignore: cast_nullable_to_non_nullable
as double,x2: null == x2 ? _self.x2 : x2 // ignore: cast_nullable_to_non_nullable
as double,y2: null == y2 ? _self.y2 : y2 // ignore: cast_nullable_to_non_nullable
as double,color: null == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as String,strokeWidth: null == strokeWidth ? _self.strokeWidth : strokeWidth // ignore: cast_nullable_to_non_nullable
as double,filled: null == filled ? _self.filled : filled // ignore: cast_nullable_to_non_nullable
as bool,fillColor: freezed == fillColor ? _self.fillColor : fillColor // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
