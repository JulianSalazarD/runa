// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'text_element.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TextElement {

 String get id; double get x; double get y; String get content; double get fontSize; String get color; String? get fontFamily; bool get bold; bool get italic;
/// Create a copy of TextElement
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TextElementCopyWith<TextElement> get copyWith => _$TextElementCopyWithImpl<TextElement>(this as TextElement, _$identity);

  /// Serializes this TextElement to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TextElement&&(identical(other.id, id) || other.id == id)&&(identical(other.x, x) || other.x == x)&&(identical(other.y, y) || other.y == y)&&(identical(other.content, content) || other.content == content)&&(identical(other.fontSize, fontSize) || other.fontSize == fontSize)&&(identical(other.color, color) || other.color == color)&&(identical(other.fontFamily, fontFamily) || other.fontFamily == fontFamily)&&(identical(other.bold, bold) || other.bold == bold)&&(identical(other.italic, italic) || other.italic == italic));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,x,y,content,fontSize,color,fontFamily,bold,italic);

@override
String toString() {
  return 'TextElement(id: $id, x: $x, y: $y, content: $content, fontSize: $fontSize, color: $color, fontFamily: $fontFamily, bold: $bold, italic: $italic)';
}


}

/// @nodoc
abstract mixin class $TextElementCopyWith<$Res>  {
  factory $TextElementCopyWith(TextElement value, $Res Function(TextElement) _then) = _$TextElementCopyWithImpl;
@useResult
$Res call({
 String id, double x, double y, String content, double fontSize, String color, String? fontFamily, bool bold, bool italic
});




}
/// @nodoc
class _$TextElementCopyWithImpl<$Res>
    implements $TextElementCopyWith<$Res> {
  _$TextElementCopyWithImpl(this._self, this._then);

  final TextElement _self;
  final $Res Function(TextElement) _then;

/// Create a copy of TextElement
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? x = null,Object? y = null,Object? content = null,Object? fontSize = null,Object? color = null,Object? fontFamily = freezed,Object? bold = null,Object? italic = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,x: null == x ? _self.x : x // ignore: cast_nullable_to_non_nullable
as double,y: null == y ? _self.y : y // ignore: cast_nullable_to_non_nullable
as double,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,fontSize: null == fontSize ? _self.fontSize : fontSize // ignore: cast_nullable_to_non_nullable
as double,color: null == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as String,fontFamily: freezed == fontFamily ? _self.fontFamily : fontFamily // ignore: cast_nullable_to_non_nullable
as String?,bold: null == bold ? _self.bold : bold // ignore: cast_nullable_to_non_nullable
as bool,italic: null == italic ? _self.italic : italic // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [TextElement].
extension TextElementPatterns on TextElement {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TextElement value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TextElement() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TextElement value)  $default,){
final _that = this;
switch (_that) {
case _TextElement():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TextElement value)?  $default,){
final _that = this;
switch (_that) {
case _TextElement() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  double x,  double y,  String content,  double fontSize,  String color,  String? fontFamily,  bool bold,  bool italic)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TextElement() when $default != null:
return $default(_that.id,_that.x,_that.y,_that.content,_that.fontSize,_that.color,_that.fontFamily,_that.bold,_that.italic);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  double x,  double y,  String content,  double fontSize,  String color,  String? fontFamily,  bool bold,  bool italic)  $default,) {final _that = this;
switch (_that) {
case _TextElement():
return $default(_that.id,_that.x,_that.y,_that.content,_that.fontSize,_that.color,_that.fontFamily,_that.bold,_that.italic);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  double x,  double y,  String content,  double fontSize,  String color,  String? fontFamily,  bool bold,  bool italic)?  $default,) {final _that = this;
switch (_that) {
case _TextElement() when $default != null:
return $default(_that.id,_that.x,_that.y,_that.content,_that.fontSize,_that.color,_that.fontFamily,_that.bold,_that.italic);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TextElement implements TextElement {
  const _TextElement({required this.id, required this.x, required this.y, required this.content, this.fontSize = 16.0, this.color = '#000000FF', this.fontFamily, this.bold = false, this.italic = false});
  factory _TextElement.fromJson(Map<String, dynamic> json) => _$TextElementFromJson(json);

@override final  String id;
@override final  double x;
@override final  double y;
@override final  String content;
@override@JsonKey() final  double fontSize;
@override@JsonKey() final  String color;
@override final  String? fontFamily;
@override@JsonKey() final  bool bold;
@override@JsonKey() final  bool italic;

/// Create a copy of TextElement
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TextElementCopyWith<_TextElement> get copyWith => __$TextElementCopyWithImpl<_TextElement>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TextElementToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TextElement&&(identical(other.id, id) || other.id == id)&&(identical(other.x, x) || other.x == x)&&(identical(other.y, y) || other.y == y)&&(identical(other.content, content) || other.content == content)&&(identical(other.fontSize, fontSize) || other.fontSize == fontSize)&&(identical(other.color, color) || other.color == color)&&(identical(other.fontFamily, fontFamily) || other.fontFamily == fontFamily)&&(identical(other.bold, bold) || other.bold == bold)&&(identical(other.italic, italic) || other.italic == italic));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,x,y,content,fontSize,color,fontFamily,bold,italic);

@override
String toString() {
  return 'TextElement(id: $id, x: $x, y: $y, content: $content, fontSize: $fontSize, color: $color, fontFamily: $fontFamily, bold: $bold, italic: $italic)';
}


}

/// @nodoc
abstract mixin class _$TextElementCopyWith<$Res> implements $TextElementCopyWith<$Res> {
  factory _$TextElementCopyWith(_TextElement value, $Res Function(_TextElement) _then) = __$TextElementCopyWithImpl;
@override @useResult
$Res call({
 String id, double x, double y, String content, double fontSize, String color, String? fontFamily, bool bold, bool italic
});




}
/// @nodoc
class __$TextElementCopyWithImpl<$Res>
    implements _$TextElementCopyWith<$Res> {
  __$TextElementCopyWithImpl(this._self, this._then);

  final _TextElement _self;
  final $Res Function(_TextElement) _then;

/// Create a copy of TextElement
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? x = null,Object? y = null,Object? content = null,Object? fontSize = null,Object? color = null,Object? fontFamily = freezed,Object? bold = null,Object? italic = null,}) {
  return _then(_TextElement(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,x: null == x ? _self.x : x // ignore: cast_nullable_to_non_nullable
as double,y: null == y ? _self.y : y // ignore: cast_nullable_to_non_nullable
as double,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,fontSize: null == fontSize ? _self.fontSize : fontSize // ignore: cast_nullable_to_non_nullable
as double,color: null == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as String,fontFamily: freezed == fontFamily ? _self.fontFamily : fontFamily // ignore: cast_nullable_to_non_nullable
as String?,bold: null == bold ? _self.bold : bold // ignore: cast_nullable_to_non_nullable
as bool,italic: null == italic ? _self.italic : italic // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
