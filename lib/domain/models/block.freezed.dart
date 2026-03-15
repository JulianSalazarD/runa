// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'block.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
Block _$BlockFromJson(
  Map<String, dynamic> json
) {
        switch (json['type']) {
                  case 'markdown':
          return MarkdownBlock.fromJson(
            json
          );
                case 'ink':
          return InkBlock.fromJson(
            json
          );
                case 'image':
          return ImageBlock.fromJson(
            json
          );
                case 'pdf_page':
          return PdfPageBlock.fromJson(
            json
          );
        
          default:
            throw CheckedFromJsonException(
  json,
  'type',
  'Block',
  'Invalid union type "${json['type']}"!'
);
        }
      
}

/// @nodoc
mixin _$Block {

/// Unique block identifier (UUID v4).
 String get id;
/// Create a copy of Block
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BlockCopyWith<Block> get copyWith => _$BlockCopyWithImpl<Block>(this as Block, _$identity);

  /// Serializes this Block to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Block&&(identical(other.id, id) || other.id == id));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id);

@override
String toString() {
  return 'Block(id: $id)';
}


}

/// @nodoc
abstract mixin class $BlockCopyWith<$Res>  {
  factory $BlockCopyWith(Block value, $Res Function(Block) _then) = _$BlockCopyWithImpl;
@useResult
$Res call({
 String id
});




}
/// @nodoc
class _$BlockCopyWithImpl<$Res>
    implements $BlockCopyWith<$Res> {
  _$BlockCopyWithImpl(this._self, this._then);

  final Block _self;
  final $Res Function(Block) _then;

/// Create a copy of Block
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [Block].
extension BlockPatterns on Block {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( MarkdownBlock value)?  markdown,TResult Function( InkBlock value)?  ink,TResult Function( ImageBlock value)?  image,TResult Function( PdfPageBlock value)?  pdfPage,required TResult orElse(),}){
final _that = this;
switch (_that) {
case MarkdownBlock() when markdown != null:
return markdown(_that);case InkBlock() when ink != null:
return ink(_that);case ImageBlock() when image != null:
return image(_that);case PdfPageBlock() when pdfPage != null:
return pdfPage(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( MarkdownBlock value)  markdown,required TResult Function( InkBlock value)  ink,required TResult Function( ImageBlock value)  image,required TResult Function( PdfPageBlock value)  pdfPage,}){
final _that = this;
switch (_that) {
case MarkdownBlock():
return markdown(_that);case InkBlock():
return ink(_that);case ImageBlock():
return image(_that);case PdfPageBlock():
return pdfPage(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( MarkdownBlock value)?  markdown,TResult? Function( InkBlock value)?  ink,TResult? Function( ImageBlock value)?  image,TResult? Function( PdfPageBlock value)?  pdfPage,}){
final _that = this;
switch (_that) {
case MarkdownBlock() when markdown != null:
return markdown(_that);case InkBlock() when ink != null:
return ink(_that);case ImageBlock() when image != null:
return image(_that);case PdfPageBlock() when pdfPage != null:
return pdfPage(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( String id,  String content)?  markdown,TResult Function( String id,  double height,  List<Stroke> strokes,  InkBackground background,  double backgroundSpacing,  String? backgroundLineColor,  String? backgroundColor,  List<TextElement> textElements,  List<ShapeElement> shapes)?  ink,TResult Function( String id,  String path,  double naturalWidth,  double naturalHeight,  List<Stroke> strokes)?  image,TResult Function( String id,  String path,  int pageIndex,  double pageWidth,  double pageHeight,  List<Stroke> strokes)?  pdfPage,required TResult orElse(),}) {final _that = this;
switch (_that) {
case MarkdownBlock() when markdown != null:
return markdown(_that.id,_that.content);case InkBlock() when ink != null:
return ink(_that.id,_that.height,_that.strokes,_that.background,_that.backgroundSpacing,_that.backgroundLineColor,_that.backgroundColor,_that.textElements,_that.shapes);case ImageBlock() when image != null:
return image(_that.id,_that.path,_that.naturalWidth,_that.naturalHeight,_that.strokes);case PdfPageBlock() when pdfPage != null:
return pdfPage(_that.id,_that.path,_that.pageIndex,_that.pageWidth,_that.pageHeight,_that.strokes);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( String id,  String content)  markdown,required TResult Function( String id,  double height,  List<Stroke> strokes,  InkBackground background,  double backgroundSpacing,  String? backgroundLineColor,  String? backgroundColor,  List<TextElement> textElements,  List<ShapeElement> shapes)  ink,required TResult Function( String id,  String path,  double naturalWidth,  double naturalHeight,  List<Stroke> strokes)  image,required TResult Function( String id,  String path,  int pageIndex,  double pageWidth,  double pageHeight,  List<Stroke> strokes)  pdfPage,}) {final _that = this;
switch (_that) {
case MarkdownBlock():
return markdown(_that.id,_that.content);case InkBlock():
return ink(_that.id,_that.height,_that.strokes,_that.background,_that.backgroundSpacing,_that.backgroundLineColor,_that.backgroundColor,_that.textElements,_that.shapes);case ImageBlock():
return image(_that.id,_that.path,_that.naturalWidth,_that.naturalHeight,_that.strokes);case PdfPageBlock():
return pdfPage(_that.id,_that.path,_that.pageIndex,_that.pageWidth,_that.pageHeight,_that.strokes);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( String id,  String content)?  markdown,TResult? Function( String id,  double height,  List<Stroke> strokes,  InkBackground background,  double backgroundSpacing,  String? backgroundLineColor,  String? backgroundColor,  List<TextElement> textElements,  List<ShapeElement> shapes)?  ink,TResult? Function( String id,  String path,  double naturalWidth,  double naturalHeight,  List<Stroke> strokes)?  image,TResult? Function( String id,  String path,  int pageIndex,  double pageWidth,  double pageHeight,  List<Stroke> strokes)?  pdfPage,}) {final _that = this;
switch (_that) {
case MarkdownBlock() when markdown != null:
return markdown(_that.id,_that.content);case InkBlock() when ink != null:
return ink(_that.id,_that.height,_that.strokes,_that.background,_that.backgroundSpacing,_that.backgroundLineColor,_that.backgroundColor,_that.textElements,_that.shapes);case ImageBlock() when image != null:
return image(_that.id,_that.path,_that.naturalWidth,_that.naturalHeight,_that.strokes);case PdfPageBlock() when pdfPage != null:
return pdfPage(_that.id,_that.path,_that.pageIndex,_that.pageWidth,_that.pageHeight,_that.strokes);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class MarkdownBlock implements Block {
  const MarkdownBlock({required this.id, required this.content, final  String? $type}): $type = $type ?? 'markdown';
  factory MarkdownBlock.fromJson(Map<String, dynamic> json) => _$MarkdownBlockFromJson(json);

/// Unique block identifier (UUID v4).
@override final  String id;
/// Raw Markdown content. Empty string is valid (new empty block).
 final  String content;

@JsonKey(name: 'type')
final String $type;


/// Create a copy of Block
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MarkdownBlockCopyWith<MarkdownBlock> get copyWith => _$MarkdownBlockCopyWithImpl<MarkdownBlock>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MarkdownBlockToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MarkdownBlock&&(identical(other.id, id) || other.id == id)&&(identical(other.content, content) || other.content == content));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,content);

@override
String toString() {
  return 'Block.markdown(id: $id, content: $content)';
}


}

/// @nodoc
abstract mixin class $MarkdownBlockCopyWith<$Res> implements $BlockCopyWith<$Res> {
  factory $MarkdownBlockCopyWith(MarkdownBlock value, $Res Function(MarkdownBlock) _then) = _$MarkdownBlockCopyWithImpl;
@override @useResult
$Res call({
 String id, String content
});




}
/// @nodoc
class _$MarkdownBlockCopyWithImpl<$Res>
    implements $MarkdownBlockCopyWith<$Res> {
  _$MarkdownBlockCopyWithImpl(this._self, this._then);

  final MarkdownBlock _self;
  final $Res Function(MarkdownBlock) _then;

/// Create a copy of Block
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? content = null,}) {
  return _then(MarkdownBlock(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class InkBlock implements Block {
  const InkBlock({required this.id, required this.height, final  List<Stroke> strokes = const [], this.background = InkBackground.plain, this.backgroundSpacing = 24.0, this.backgroundLineColor, this.backgroundColor, final  List<TextElement> textElements = const [], final  List<ShapeElement> shapes = const [], final  String? $type}): _strokes = strokes,_textElements = textElements,_shapes = shapes,$type = $type ?? 'ink';
  factory InkBlock.fromJson(Map<String, dynamic> json) => _$InkBlockFromJson(json);

/// Unique block identifier (UUID v4).
@override final  String id;
/// Canvas height in logical pixels. Must be positive.
 final  double height;
/// Ink strokes in draw order (painter's algorithm). May be empty.
 final  List<Stroke> _strokes;
/// Ink strokes in draw order (painter's algorithm). May be empty.
@JsonKey() List<Stroke> get strokes {
  if (_strokes is EqualUnmodifiableListView) return _strokes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_strokes);
}

/// Background pattern rendered behind the strokes.
@JsonKey() final  InkBackground background;
/// Spacing between background lines/dots in logical pixels.
@JsonKey() final  double backgroundSpacing;
/// Explicit line color in `#RRGGBBAA` format. When null, the theme
/// default (outlineVariant at 20% opacity) is used.
 final  String? backgroundLineColor;
/// Canvas fill color in `#RRGGBBAA` format. When null the canvas is
/// transparent (shows the widget background / theme surface).
 final  String? backgroundColor;
/// Typographic text elements placed on the canvas.
 final  List<TextElement> _textElements;
/// Typographic text elements placed on the canvas.
@JsonKey() List<TextElement> get textElements {
  if (_textElements is EqualUnmodifiableListView) return _textElements;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_textElements);
}

/// Geometric shapes placed on the canvas.
 final  List<ShapeElement> _shapes;
/// Geometric shapes placed on the canvas.
@JsonKey() List<ShapeElement> get shapes {
  if (_shapes is EqualUnmodifiableListView) return _shapes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_shapes);
}


@JsonKey(name: 'type')
final String $type;


/// Create a copy of Block
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$InkBlockCopyWith<InkBlock> get copyWith => _$InkBlockCopyWithImpl<InkBlock>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$InkBlockToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is InkBlock&&(identical(other.id, id) || other.id == id)&&(identical(other.height, height) || other.height == height)&&const DeepCollectionEquality().equals(other._strokes, _strokes)&&(identical(other.background, background) || other.background == background)&&(identical(other.backgroundSpacing, backgroundSpacing) || other.backgroundSpacing == backgroundSpacing)&&(identical(other.backgroundLineColor, backgroundLineColor) || other.backgroundLineColor == backgroundLineColor)&&(identical(other.backgroundColor, backgroundColor) || other.backgroundColor == backgroundColor)&&const DeepCollectionEquality().equals(other._textElements, _textElements)&&const DeepCollectionEquality().equals(other._shapes, _shapes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,height,const DeepCollectionEquality().hash(_strokes),background,backgroundSpacing,backgroundLineColor,backgroundColor,const DeepCollectionEquality().hash(_textElements),const DeepCollectionEquality().hash(_shapes));

@override
String toString() {
  return 'Block.ink(id: $id, height: $height, strokes: $strokes, background: $background, backgroundSpacing: $backgroundSpacing, backgroundLineColor: $backgroundLineColor, backgroundColor: $backgroundColor, textElements: $textElements, shapes: $shapes)';
}


}

/// @nodoc
abstract mixin class $InkBlockCopyWith<$Res> implements $BlockCopyWith<$Res> {
  factory $InkBlockCopyWith(InkBlock value, $Res Function(InkBlock) _then) = _$InkBlockCopyWithImpl;
@override @useResult
$Res call({
 String id, double height, List<Stroke> strokes, InkBackground background, double backgroundSpacing, String? backgroundLineColor, String? backgroundColor, List<TextElement> textElements, List<ShapeElement> shapes
});




}
/// @nodoc
class _$InkBlockCopyWithImpl<$Res>
    implements $InkBlockCopyWith<$Res> {
  _$InkBlockCopyWithImpl(this._self, this._then);

  final InkBlock _self;
  final $Res Function(InkBlock) _then;

/// Create a copy of Block
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? height = null,Object? strokes = null,Object? background = null,Object? backgroundSpacing = null,Object? backgroundLineColor = freezed,Object? backgroundColor = freezed,Object? textElements = null,Object? shapes = null,}) {
  return _then(InkBlock(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,height: null == height ? _self.height : height // ignore: cast_nullable_to_non_nullable
as double,strokes: null == strokes ? _self._strokes : strokes // ignore: cast_nullable_to_non_nullable
as List<Stroke>,background: null == background ? _self.background : background // ignore: cast_nullable_to_non_nullable
as InkBackground,backgroundSpacing: null == backgroundSpacing ? _self.backgroundSpacing : backgroundSpacing // ignore: cast_nullable_to_non_nullable
as double,backgroundLineColor: freezed == backgroundLineColor ? _self.backgroundLineColor : backgroundLineColor // ignore: cast_nullable_to_non_nullable
as String?,backgroundColor: freezed == backgroundColor ? _self.backgroundColor : backgroundColor // ignore: cast_nullable_to_non_nullable
as String?,textElements: null == textElements ? _self._textElements : textElements // ignore: cast_nullable_to_non_nullable
as List<TextElement>,shapes: null == shapes ? _self._shapes : shapes // ignore: cast_nullable_to_non_nullable
as List<ShapeElement>,
  ));
}


}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class ImageBlock implements Block {
  const ImageBlock({required this.id, required this.path, required this.naturalWidth, required this.naturalHeight, final  List<Stroke> strokes = const [], final  String? $type}): _strokes = strokes,$type = $type ?? 'image';
  factory ImageBlock.fromJson(Map<String, dynamic> json) => _$ImageBlockFromJson(json);

/// Unique block identifier (UUID v4).
@override final  String id;
/// Relative path to the image asset (e.g. `_assets/foto.png`).
 final  String path;
/// Original image width in logical pixels (used for coordinate normalisation).
 final  double naturalWidth;
/// Original image height in logical pixels (used for coordinate normalisation).
 final  double naturalHeight;
/// Ink annotation strokes. Coordinates normalised to [0.0, 1.0].
 final  List<Stroke> _strokes;
/// Ink annotation strokes. Coordinates normalised to [0.0, 1.0].
@JsonKey() List<Stroke> get strokes {
  if (_strokes is EqualUnmodifiableListView) return _strokes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_strokes);
}


@JsonKey(name: 'type')
final String $type;


/// Create a copy of Block
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ImageBlockCopyWith<ImageBlock> get copyWith => _$ImageBlockCopyWithImpl<ImageBlock>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ImageBlockToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ImageBlock&&(identical(other.id, id) || other.id == id)&&(identical(other.path, path) || other.path == path)&&(identical(other.naturalWidth, naturalWidth) || other.naturalWidth == naturalWidth)&&(identical(other.naturalHeight, naturalHeight) || other.naturalHeight == naturalHeight)&&const DeepCollectionEquality().equals(other._strokes, _strokes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,path,naturalWidth,naturalHeight,const DeepCollectionEquality().hash(_strokes));

@override
String toString() {
  return 'Block.image(id: $id, path: $path, naturalWidth: $naturalWidth, naturalHeight: $naturalHeight, strokes: $strokes)';
}


}

/// @nodoc
abstract mixin class $ImageBlockCopyWith<$Res> implements $BlockCopyWith<$Res> {
  factory $ImageBlockCopyWith(ImageBlock value, $Res Function(ImageBlock) _then) = _$ImageBlockCopyWithImpl;
@override @useResult
$Res call({
 String id, String path, double naturalWidth, double naturalHeight, List<Stroke> strokes
});




}
/// @nodoc
class _$ImageBlockCopyWithImpl<$Res>
    implements $ImageBlockCopyWith<$Res> {
  _$ImageBlockCopyWithImpl(this._self, this._then);

  final ImageBlock _self;
  final $Res Function(ImageBlock) _then;

/// Create a copy of Block
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? path = null,Object? naturalWidth = null,Object? naturalHeight = null,Object? strokes = null,}) {
  return _then(ImageBlock(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,path: null == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as String,naturalWidth: null == naturalWidth ? _self.naturalWidth : naturalWidth // ignore: cast_nullable_to_non_nullable
as double,naturalHeight: null == naturalHeight ? _self.naturalHeight : naturalHeight // ignore: cast_nullable_to_non_nullable
as double,strokes: null == strokes ? _self._strokes : strokes // ignore: cast_nullable_to_non_nullable
as List<Stroke>,
  ));
}


}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class PdfPageBlock implements Block {
  const PdfPageBlock({required this.id, required this.path, required this.pageIndex, this.pageWidth = 0.0, this.pageHeight = 0.0, final  List<Stroke> strokes = const [], final  String? $type}): _strokes = strokes,$type = $type ?? 'pdf_page';
  factory PdfPageBlock.fromJson(Map<String, dynamic> json) => _$PdfPageBlockFromJson(json);

/// Unique block identifier (UUID v4).
@override final  String id;
/// Relative path to the PDF asset (e.g. `_assets/doc.pdf`).
 final  String path;
/// Zero-based index of the PDF page this block represents.
 final  int pageIndex;
/// Width of the page in PDF points, as reported by the renderer.
@JsonKey() final  double pageWidth;
/// Height of the page in PDF points, as reported by the renderer.
@JsonKey() final  double pageHeight;
/// Ink annotation strokes drawn on this page.
 final  List<Stroke> _strokes;
/// Ink annotation strokes drawn on this page.
@JsonKey() List<Stroke> get strokes {
  if (_strokes is EqualUnmodifiableListView) return _strokes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_strokes);
}


@JsonKey(name: 'type')
final String $type;


/// Create a copy of Block
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PdfPageBlockCopyWith<PdfPageBlock> get copyWith => _$PdfPageBlockCopyWithImpl<PdfPageBlock>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PdfPageBlockToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PdfPageBlock&&(identical(other.id, id) || other.id == id)&&(identical(other.path, path) || other.path == path)&&(identical(other.pageIndex, pageIndex) || other.pageIndex == pageIndex)&&(identical(other.pageWidth, pageWidth) || other.pageWidth == pageWidth)&&(identical(other.pageHeight, pageHeight) || other.pageHeight == pageHeight)&&const DeepCollectionEquality().equals(other._strokes, _strokes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,path,pageIndex,pageWidth,pageHeight,const DeepCollectionEquality().hash(_strokes));

@override
String toString() {
  return 'Block.pdfPage(id: $id, path: $path, pageIndex: $pageIndex, pageWidth: $pageWidth, pageHeight: $pageHeight, strokes: $strokes)';
}


}

/// @nodoc
abstract mixin class $PdfPageBlockCopyWith<$Res> implements $BlockCopyWith<$Res> {
  factory $PdfPageBlockCopyWith(PdfPageBlock value, $Res Function(PdfPageBlock) _then) = _$PdfPageBlockCopyWithImpl;
@override @useResult
$Res call({
 String id, String path, int pageIndex, double pageWidth, double pageHeight, List<Stroke> strokes
});




}
/// @nodoc
class _$PdfPageBlockCopyWithImpl<$Res>
    implements $PdfPageBlockCopyWith<$Res> {
  _$PdfPageBlockCopyWithImpl(this._self, this._then);

  final PdfPageBlock _self;
  final $Res Function(PdfPageBlock) _then;

/// Create a copy of Block
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? path = null,Object? pageIndex = null,Object? pageWidth = null,Object? pageHeight = null,Object? strokes = null,}) {
  return _then(PdfPageBlock(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,path: null == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as String,pageIndex: null == pageIndex ? _self.pageIndex : pageIndex // ignore: cast_nullable_to_non_nullable
as int,pageWidth: null == pageWidth ? _self.pageWidth : pageWidth // ignore: cast_nullable_to_non_nullable
as double,pageHeight: null == pageHeight ? _self.pageHeight : pageHeight // ignore: cast_nullable_to_non_nullable
as double,strokes: null == strokes ? _self._strokes : strokes // ignore: cast_nullable_to_non_nullable
as List<Stroke>,
  ));
}


}

// dart format on
