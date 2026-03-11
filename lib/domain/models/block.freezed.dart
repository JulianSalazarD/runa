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
    case 'image':
      return ImageBlock.fromJson(json);
    case 'pdf_page':
      return PdfPageBlock.fromJson(json);

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
    required TResult Function(
      String id,
      double height,
      List<Stroke> strokes,
      InkBackground background,
      double backgroundSpacing,
      String? backgroundLineColor,
      String? backgroundColor,
      List<TextElement> textElements,
    )
    ink,
    required TResult Function(
      String id,
      String path,
      double naturalWidth,
      double naturalHeight,
      List<Stroke> strokes,
    )
    image,
    required TResult Function(
      String id,
      String path,
      int pageIndex,
      double pageWidth,
      double pageHeight,
      List<Stroke> strokes,
    )
    pdfPage,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String id, String content)? markdown,
    TResult? Function(
      String id,
      double height,
      List<Stroke> strokes,
      InkBackground background,
      double backgroundSpacing,
      String? backgroundLineColor,
      String? backgroundColor,
      List<TextElement> textElements,
    )?
    ink,
    TResult? Function(
      String id,
      String path,
      double naturalWidth,
      double naturalHeight,
      List<Stroke> strokes,
    )?
    image,
    TResult? Function(
      String id,
      String path,
      int pageIndex,
      double pageWidth,
      double pageHeight,
      List<Stroke> strokes,
    )?
    pdfPage,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String id, String content)? markdown,
    TResult Function(
      String id,
      double height,
      List<Stroke> strokes,
      InkBackground background,
      double backgroundSpacing,
      String? backgroundLineColor,
      String? backgroundColor,
      List<TextElement> textElements,
    )?
    ink,
    TResult Function(
      String id,
      String path,
      double naturalWidth,
      double naturalHeight,
      List<Stroke> strokes,
    )?
    image,
    TResult Function(
      String id,
      String path,
      int pageIndex,
      double pageWidth,
      double pageHeight,
      List<Stroke> strokes,
    )?
    pdfPage,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(MarkdownBlock value) markdown,
    required TResult Function(InkBlock value) ink,
    required TResult Function(ImageBlock value) image,
    required TResult Function(PdfPageBlock value) pdfPage,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(MarkdownBlock value)? markdown,
    TResult? Function(InkBlock value)? ink,
    TResult? Function(ImageBlock value)? image,
    TResult? Function(PdfPageBlock value)? pdfPage,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(MarkdownBlock value)? markdown,
    TResult Function(InkBlock value)? ink,
    TResult Function(ImageBlock value)? image,
    TResult Function(PdfPageBlock value)? pdfPage,
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
    required TResult Function(
      String id,
      double height,
      List<Stroke> strokes,
      InkBackground background,
      double backgroundSpacing,
      String? backgroundLineColor,
      String? backgroundColor,
      List<TextElement> textElements,
    )
    ink,
    required TResult Function(
      String id,
      String path,
      double naturalWidth,
      double naturalHeight,
      List<Stroke> strokes,
    )
    image,
    required TResult Function(
      String id,
      String path,
      int pageIndex,
      double pageWidth,
      double pageHeight,
      List<Stroke> strokes,
    )
    pdfPage,
  }) {
    return markdown(id, content);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String id, String content)? markdown,
    TResult? Function(
      String id,
      double height,
      List<Stroke> strokes,
      InkBackground background,
      double backgroundSpacing,
      String? backgroundLineColor,
      String? backgroundColor,
      List<TextElement> textElements,
    )?
    ink,
    TResult? Function(
      String id,
      String path,
      double naturalWidth,
      double naturalHeight,
      List<Stroke> strokes,
    )?
    image,
    TResult? Function(
      String id,
      String path,
      int pageIndex,
      double pageWidth,
      double pageHeight,
      List<Stroke> strokes,
    )?
    pdfPage,
  }) {
    return markdown?.call(id, content);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String id, String content)? markdown,
    TResult Function(
      String id,
      double height,
      List<Stroke> strokes,
      InkBackground background,
      double backgroundSpacing,
      String? backgroundLineColor,
      String? backgroundColor,
      List<TextElement> textElements,
    )?
    ink,
    TResult Function(
      String id,
      String path,
      double naturalWidth,
      double naturalHeight,
      List<Stroke> strokes,
    )?
    image,
    TResult Function(
      String id,
      String path,
      int pageIndex,
      double pageWidth,
      double pageHeight,
      List<Stroke> strokes,
    )?
    pdfPage,
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
    required TResult Function(ImageBlock value) image,
    required TResult Function(PdfPageBlock value) pdfPage,
  }) {
    return markdown(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(MarkdownBlock value)? markdown,
    TResult? Function(InkBlock value)? ink,
    TResult? Function(ImageBlock value)? image,
    TResult? Function(PdfPageBlock value)? pdfPage,
  }) {
    return markdown?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(MarkdownBlock value)? markdown,
    TResult Function(InkBlock value)? ink,
    TResult Function(ImageBlock value)? image,
    TResult Function(PdfPageBlock value)? pdfPage,
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
  $Res call({
    String id,
    double height,
    List<Stroke> strokes,
    InkBackground background,
    double backgroundSpacing,
    String? backgroundLineColor,
    String? backgroundColor,
    List<TextElement> textElements,
  });
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
    Object? background = null,
    Object? backgroundSpacing = null,
    Object? backgroundLineColor = freezed,
    Object? backgroundColor = freezed,
    Object? textElements = null,
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
        background: null == background
            ? _value.background
            : background // ignore: cast_nullable_to_non_nullable
                  as InkBackground,
        backgroundSpacing: null == backgroundSpacing
            ? _value.backgroundSpacing
            : backgroundSpacing // ignore: cast_nullable_to_non_nullable
                  as double,
        backgroundLineColor: freezed == backgroundLineColor
            ? _value.backgroundLineColor
            : backgroundLineColor // ignore: cast_nullable_to_non_nullable
                  as String?,
        backgroundColor: freezed == backgroundColor
            ? _value.backgroundColor
            : backgroundColor // ignore: cast_nullable_to_non_nullable
                  as String?,
        textElements: null == textElements
            ? _value._textElements
            : textElements // ignore: cast_nullable_to_non_nullable
                  as List<TextElement>,
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
    this.background = InkBackground.plain,
    this.backgroundSpacing = 24.0,
    this.backgroundLineColor,
    this.backgroundColor,
    final List<TextElement> textElements = const [],
    final String? $type,
  }) : _strokes = strokes,
       _textElements = textElements,
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

  /// Background pattern rendered behind the strokes.
  @override
  @JsonKey()
  final InkBackground background;

  /// Spacing between background lines/dots in logical pixels.
  @override
  @JsonKey()
  final double backgroundSpacing;

  /// Explicit line color in `#RRGGBBAA` format. When null, the theme
  /// default (outlineVariant at 20% opacity) is used.
  @override
  final String? backgroundLineColor;

  /// Canvas fill color in `#RRGGBBAA` format. When null the canvas is
  /// transparent (shows the widget background / theme surface).
  @override
  final String? backgroundColor;

  /// Typographic text elements placed on the canvas.
  final List<TextElement> _textElements;

  /// Typographic text elements placed on the canvas.
  @override
  @JsonKey()
  List<TextElement> get textElements {
    if (_textElements is EqualUnmodifiableListView) return _textElements;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_textElements);
  }

  @JsonKey(name: 'type')
  final String $type;

  @override
  String toString() {
    return 'Block.ink(id: $id, height: $height, strokes: $strokes, background: $background, backgroundSpacing: $backgroundSpacing, backgroundLineColor: $backgroundLineColor, backgroundColor: $backgroundColor, textElements: $textElements)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$InkBlockImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.height, height) || other.height == height) &&
            const DeepCollectionEquality().equals(other._strokes, _strokes) &&
            (identical(other.background, background) ||
                other.background == background) &&
            (identical(other.backgroundSpacing, backgroundSpacing) ||
                other.backgroundSpacing == backgroundSpacing) &&
            (identical(other.backgroundLineColor, backgroundLineColor) ||
                other.backgroundLineColor == backgroundLineColor) &&
            (identical(other.backgroundColor, backgroundColor) ||
                other.backgroundColor == backgroundColor) &&
            const DeepCollectionEquality().equals(
              other._textElements,
              _textElements,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    height,
    const DeepCollectionEquality().hash(_strokes),
    background,
    backgroundSpacing,
    backgroundLineColor,
    backgroundColor,
    const DeepCollectionEquality().hash(_textElements),
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
    required TResult Function(
      String id,
      double height,
      List<Stroke> strokes,
      InkBackground background,
      double backgroundSpacing,
      String? backgroundLineColor,
      String? backgroundColor,
      List<TextElement> textElements,
    )
    ink,
    required TResult Function(
      String id,
      String path,
      double naturalWidth,
      double naturalHeight,
      List<Stroke> strokes,
    )
    image,
    required TResult Function(
      String id,
      String path,
      int pageIndex,
      double pageWidth,
      double pageHeight,
      List<Stroke> strokes,
    )
    pdfPage,
  }) {
    return ink(
      id,
      height,
      strokes,
      background,
      backgroundSpacing,
      backgroundLineColor,
      backgroundColor,
      textElements,
    );
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String id, String content)? markdown,
    TResult? Function(
      String id,
      double height,
      List<Stroke> strokes,
      InkBackground background,
      double backgroundSpacing,
      String? backgroundLineColor,
      String? backgroundColor,
      List<TextElement> textElements,
    )?
    ink,
    TResult? Function(
      String id,
      String path,
      double naturalWidth,
      double naturalHeight,
      List<Stroke> strokes,
    )?
    image,
    TResult? Function(
      String id,
      String path,
      int pageIndex,
      double pageWidth,
      double pageHeight,
      List<Stroke> strokes,
    )?
    pdfPage,
  }) {
    return ink?.call(
      id,
      height,
      strokes,
      background,
      backgroundSpacing,
      backgroundLineColor,
      backgroundColor,
      textElements,
    );
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String id, String content)? markdown,
    TResult Function(
      String id,
      double height,
      List<Stroke> strokes,
      InkBackground background,
      double backgroundSpacing,
      String? backgroundLineColor,
      String? backgroundColor,
      List<TextElement> textElements,
    )?
    ink,
    TResult Function(
      String id,
      String path,
      double naturalWidth,
      double naturalHeight,
      List<Stroke> strokes,
    )?
    image,
    TResult Function(
      String id,
      String path,
      int pageIndex,
      double pageWidth,
      double pageHeight,
      List<Stroke> strokes,
    )?
    pdfPage,
    required TResult orElse(),
  }) {
    if (ink != null) {
      return ink(
        id,
        height,
        strokes,
        background,
        backgroundSpacing,
        backgroundLineColor,
        backgroundColor,
        textElements,
      );
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(MarkdownBlock value) markdown,
    required TResult Function(InkBlock value) ink,
    required TResult Function(ImageBlock value) image,
    required TResult Function(PdfPageBlock value) pdfPage,
  }) {
    return ink(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(MarkdownBlock value)? markdown,
    TResult? Function(InkBlock value)? ink,
    TResult? Function(ImageBlock value)? image,
    TResult? Function(PdfPageBlock value)? pdfPage,
  }) {
    return ink?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(MarkdownBlock value)? markdown,
    TResult Function(InkBlock value)? ink,
    TResult Function(ImageBlock value)? image,
    TResult Function(PdfPageBlock value)? pdfPage,
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
    final InkBackground background,
    final double backgroundSpacing,
    final String? backgroundLineColor,
    final String? backgroundColor,
    final List<TextElement> textElements,
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

  /// Background pattern rendered behind the strokes.
  InkBackground get background;

  /// Spacing between background lines/dots in logical pixels.
  double get backgroundSpacing;

  /// Explicit line color in `#RRGGBBAA` format. When null, the theme
  /// default (outlineVariant at 20% opacity) is used.
  String? get backgroundLineColor;

  /// Canvas fill color in `#RRGGBBAA` format. When null the canvas is
  /// transparent (shows the widget background / theme surface).
  String? get backgroundColor;

  /// Typographic text elements placed on the canvas.
  List<TextElement> get textElements;

  /// Create a copy of Block
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$InkBlockImplCopyWith<_$InkBlockImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$ImageBlockImplCopyWith<$Res> implements $BlockCopyWith<$Res> {
  factory _$$ImageBlockImplCopyWith(
    _$ImageBlockImpl value,
    $Res Function(_$ImageBlockImpl) then,
  ) = __$$ImageBlockImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String path,
    double naturalWidth,
    double naturalHeight,
    List<Stroke> strokes,
  });
}

/// @nodoc
class __$$ImageBlockImplCopyWithImpl<$Res>
    extends _$BlockCopyWithImpl<$Res, _$ImageBlockImpl>
    implements _$$ImageBlockImplCopyWith<$Res> {
  __$$ImageBlockImplCopyWithImpl(
    _$ImageBlockImpl _value,
    $Res Function(_$ImageBlockImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Block
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? path = null,
    Object? naturalWidth = null,
    Object? naturalHeight = null,
    Object? strokes = null,
  }) {
    return _then(
      _$ImageBlockImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        path: null == path
            ? _value.path
            : path // ignore: cast_nullable_to_non_nullable
                  as String,
        naturalWidth: null == naturalWidth
            ? _value.naturalWidth
            : naturalWidth // ignore: cast_nullable_to_non_nullable
                  as double,
        naturalHeight: null == naturalHeight
            ? _value.naturalHeight
            : naturalHeight // ignore: cast_nullable_to_non_nullable
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
class _$ImageBlockImpl implements ImageBlock {
  const _$ImageBlockImpl({
    required this.id,
    required this.path,
    required this.naturalWidth,
    required this.naturalHeight,
    final List<Stroke> strokes = const [],
    final String? $type,
  }) : _strokes = strokes,
       $type = $type ?? 'image';

  factory _$ImageBlockImpl.fromJson(Map<String, dynamic> json) =>
      _$$ImageBlockImplFromJson(json);

  /// Unique block identifier (UUID v4).
  @override
  final String id;

  /// Relative path to the image asset (e.g. `_assets/foto.png`).
  @override
  final String path;

  /// Original image width in logical pixels (used for coordinate normalisation).
  @override
  final double naturalWidth;

  /// Original image height in logical pixels (used for coordinate normalisation).
  @override
  final double naturalHeight;

  /// Ink annotation strokes. Coordinates normalised to [0.0, 1.0].
  final List<Stroke> _strokes;

  /// Ink annotation strokes. Coordinates normalised to [0.0, 1.0].
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
    return 'Block.image(id: $id, path: $path, naturalWidth: $naturalWidth, naturalHeight: $naturalHeight, strokes: $strokes)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ImageBlockImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.path, path) || other.path == path) &&
            (identical(other.naturalWidth, naturalWidth) ||
                other.naturalWidth == naturalWidth) &&
            (identical(other.naturalHeight, naturalHeight) ||
                other.naturalHeight == naturalHeight) &&
            const DeepCollectionEquality().equals(other._strokes, _strokes));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    path,
    naturalWidth,
    naturalHeight,
    const DeepCollectionEquality().hash(_strokes),
  );

  /// Create a copy of Block
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ImageBlockImplCopyWith<_$ImageBlockImpl> get copyWith =>
      __$$ImageBlockImplCopyWithImpl<_$ImageBlockImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String id, String content) markdown,
    required TResult Function(
      String id,
      double height,
      List<Stroke> strokes,
      InkBackground background,
      double backgroundSpacing,
      String? backgroundLineColor,
      String? backgroundColor,
      List<TextElement> textElements,
    )
    ink,
    required TResult Function(
      String id,
      String path,
      double naturalWidth,
      double naturalHeight,
      List<Stroke> strokes,
    )
    image,
    required TResult Function(
      String id,
      String path,
      int pageIndex,
      double pageWidth,
      double pageHeight,
      List<Stroke> strokes,
    )
    pdfPage,
  }) {
    return image(id, path, naturalWidth, naturalHeight, strokes);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String id, String content)? markdown,
    TResult? Function(
      String id,
      double height,
      List<Stroke> strokes,
      InkBackground background,
      double backgroundSpacing,
      String? backgroundLineColor,
      String? backgroundColor,
      List<TextElement> textElements,
    )?
    ink,
    TResult? Function(
      String id,
      String path,
      double naturalWidth,
      double naturalHeight,
      List<Stroke> strokes,
    )?
    image,
    TResult? Function(
      String id,
      String path,
      int pageIndex,
      double pageWidth,
      double pageHeight,
      List<Stroke> strokes,
    )?
    pdfPage,
  }) {
    return image?.call(id, path, naturalWidth, naturalHeight, strokes);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String id, String content)? markdown,
    TResult Function(
      String id,
      double height,
      List<Stroke> strokes,
      InkBackground background,
      double backgroundSpacing,
      String? backgroundLineColor,
      String? backgroundColor,
      List<TextElement> textElements,
    )?
    ink,
    TResult Function(
      String id,
      String path,
      double naturalWidth,
      double naturalHeight,
      List<Stroke> strokes,
    )?
    image,
    TResult Function(
      String id,
      String path,
      int pageIndex,
      double pageWidth,
      double pageHeight,
      List<Stroke> strokes,
    )?
    pdfPage,
    required TResult orElse(),
  }) {
    if (image != null) {
      return image(id, path, naturalWidth, naturalHeight, strokes);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(MarkdownBlock value) markdown,
    required TResult Function(InkBlock value) ink,
    required TResult Function(ImageBlock value) image,
    required TResult Function(PdfPageBlock value) pdfPage,
  }) {
    return image(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(MarkdownBlock value)? markdown,
    TResult? Function(InkBlock value)? ink,
    TResult? Function(ImageBlock value)? image,
    TResult? Function(PdfPageBlock value)? pdfPage,
  }) {
    return image?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(MarkdownBlock value)? markdown,
    TResult Function(InkBlock value)? ink,
    TResult Function(ImageBlock value)? image,
    TResult Function(PdfPageBlock value)? pdfPage,
    required TResult orElse(),
  }) {
    if (image != null) {
      return image(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$ImageBlockImplToJson(this);
  }
}

abstract class ImageBlock implements Block {
  const factory ImageBlock({
    required final String id,
    required final String path,
    required final double naturalWidth,
    required final double naturalHeight,
    final List<Stroke> strokes,
  }) = _$ImageBlockImpl;

  factory ImageBlock.fromJson(Map<String, dynamic> json) =
      _$ImageBlockImpl.fromJson;

  /// Unique block identifier (UUID v4).
  @override
  String get id;

  /// Relative path to the image asset (e.g. `_assets/foto.png`).
  String get path;

  /// Original image width in logical pixels (used for coordinate normalisation).
  double get naturalWidth;

  /// Original image height in logical pixels (used for coordinate normalisation).
  double get naturalHeight;

  /// Ink annotation strokes. Coordinates normalised to [0.0, 1.0].
  List<Stroke> get strokes;

  /// Create a copy of Block
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ImageBlockImplCopyWith<_$ImageBlockImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$PdfPageBlockImplCopyWith<$Res>
    implements $BlockCopyWith<$Res> {
  factory _$$PdfPageBlockImplCopyWith(
    _$PdfPageBlockImpl value,
    $Res Function(_$PdfPageBlockImpl) then,
  ) = __$$PdfPageBlockImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String path,
    int pageIndex,
    double pageWidth,
    double pageHeight,
    List<Stroke> strokes,
  });
}

/// @nodoc
class __$$PdfPageBlockImplCopyWithImpl<$Res>
    extends _$BlockCopyWithImpl<$Res, _$PdfPageBlockImpl>
    implements _$$PdfPageBlockImplCopyWith<$Res> {
  __$$PdfPageBlockImplCopyWithImpl(
    _$PdfPageBlockImpl _value,
    $Res Function(_$PdfPageBlockImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Block
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? path = null,
    Object? pageIndex = null,
    Object? pageWidth = null,
    Object? pageHeight = null,
    Object? strokes = null,
  }) {
    return _then(
      _$PdfPageBlockImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        path: null == path
            ? _value.path
            : path // ignore: cast_nullable_to_non_nullable
                  as String,
        pageIndex: null == pageIndex
            ? _value.pageIndex
            : pageIndex // ignore: cast_nullable_to_non_nullable
                  as int,
        pageWidth: null == pageWidth
            ? _value.pageWidth
            : pageWidth // ignore: cast_nullable_to_non_nullable
                  as double,
        pageHeight: null == pageHeight
            ? _value.pageHeight
            : pageHeight // ignore: cast_nullable_to_non_nullable
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
class _$PdfPageBlockImpl implements PdfPageBlock {
  const _$PdfPageBlockImpl({
    required this.id,
    required this.path,
    required this.pageIndex,
    this.pageWidth = 0.0,
    this.pageHeight = 0.0,
    final List<Stroke> strokes = const [],
    final String? $type,
  }) : _strokes = strokes,
       $type = $type ?? 'pdf_page';

  factory _$PdfPageBlockImpl.fromJson(Map<String, dynamic> json) =>
      _$$PdfPageBlockImplFromJson(json);

  /// Unique block identifier (UUID v4).
  @override
  final String id;

  /// Relative path to the PDF asset (e.g. `_assets/doc.pdf`).
  @override
  final String path;

  /// Zero-based index of the PDF page this block represents.
  @override
  final int pageIndex;

  /// Width of the page in PDF points, as reported by the renderer.
  @override
  @JsonKey()
  final double pageWidth;

  /// Height of the page in PDF points, as reported by the renderer.
  @override
  @JsonKey()
  final double pageHeight;

  /// Ink annotation strokes drawn on this page.
  final List<Stroke> _strokes;

  /// Ink annotation strokes drawn on this page.
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
    return 'Block.pdfPage(id: $id, path: $path, pageIndex: $pageIndex, pageWidth: $pageWidth, pageHeight: $pageHeight, strokes: $strokes)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PdfPageBlockImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.path, path) || other.path == path) &&
            (identical(other.pageIndex, pageIndex) ||
                other.pageIndex == pageIndex) &&
            (identical(other.pageWidth, pageWidth) ||
                other.pageWidth == pageWidth) &&
            (identical(other.pageHeight, pageHeight) ||
                other.pageHeight == pageHeight) &&
            const DeepCollectionEquality().equals(other._strokes, _strokes));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    path,
    pageIndex,
    pageWidth,
    pageHeight,
    const DeepCollectionEquality().hash(_strokes),
  );

  /// Create a copy of Block
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PdfPageBlockImplCopyWith<_$PdfPageBlockImpl> get copyWith =>
      __$$PdfPageBlockImplCopyWithImpl<_$PdfPageBlockImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String id, String content) markdown,
    required TResult Function(
      String id,
      double height,
      List<Stroke> strokes,
      InkBackground background,
      double backgroundSpacing,
      String? backgroundLineColor,
      String? backgroundColor,
      List<TextElement> textElements,
    )
    ink,
    required TResult Function(
      String id,
      String path,
      double naturalWidth,
      double naturalHeight,
      List<Stroke> strokes,
    )
    image,
    required TResult Function(
      String id,
      String path,
      int pageIndex,
      double pageWidth,
      double pageHeight,
      List<Stroke> strokes,
    )
    pdfPage,
  }) {
    return pdfPage(id, path, pageIndex, pageWidth, pageHeight, strokes);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String id, String content)? markdown,
    TResult? Function(
      String id,
      double height,
      List<Stroke> strokes,
      InkBackground background,
      double backgroundSpacing,
      String? backgroundLineColor,
      String? backgroundColor,
      List<TextElement> textElements,
    )?
    ink,
    TResult? Function(
      String id,
      String path,
      double naturalWidth,
      double naturalHeight,
      List<Stroke> strokes,
    )?
    image,
    TResult? Function(
      String id,
      String path,
      int pageIndex,
      double pageWidth,
      double pageHeight,
      List<Stroke> strokes,
    )?
    pdfPage,
  }) {
    return pdfPage?.call(id, path, pageIndex, pageWidth, pageHeight, strokes);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String id, String content)? markdown,
    TResult Function(
      String id,
      double height,
      List<Stroke> strokes,
      InkBackground background,
      double backgroundSpacing,
      String? backgroundLineColor,
      String? backgroundColor,
      List<TextElement> textElements,
    )?
    ink,
    TResult Function(
      String id,
      String path,
      double naturalWidth,
      double naturalHeight,
      List<Stroke> strokes,
    )?
    image,
    TResult Function(
      String id,
      String path,
      int pageIndex,
      double pageWidth,
      double pageHeight,
      List<Stroke> strokes,
    )?
    pdfPage,
    required TResult orElse(),
  }) {
    if (pdfPage != null) {
      return pdfPage(id, path, pageIndex, pageWidth, pageHeight, strokes);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(MarkdownBlock value) markdown,
    required TResult Function(InkBlock value) ink,
    required TResult Function(ImageBlock value) image,
    required TResult Function(PdfPageBlock value) pdfPage,
  }) {
    return pdfPage(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(MarkdownBlock value)? markdown,
    TResult? Function(InkBlock value)? ink,
    TResult? Function(ImageBlock value)? image,
    TResult? Function(PdfPageBlock value)? pdfPage,
  }) {
    return pdfPage?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(MarkdownBlock value)? markdown,
    TResult Function(InkBlock value)? ink,
    TResult Function(ImageBlock value)? image,
    TResult Function(PdfPageBlock value)? pdfPage,
    required TResult orElse(),
  }) {
    if (pdfPage != null) {
      return pdfPage(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$PdfPageBlockImplToJson(this);
  }
}

abstract class PdfPageBlock implements Block {
  const factory PdfPageBlock({
    required final String id,
    required final String path,
    required final int pageIndex,
    final double pageWidth,
    final double pageHeight,
    final List<Stroke> strokes,
  }) = _$PdfPageBlockImpl;

  factory PdfPageBlock.fromJson(Map<String, dynamic> json) =
      _$PdfPageBlockImpl.fromJson;

  /// Unique block identifier (UUID v4).
  @override
  String get id;

  /// Relative path to the PDF asset (e.g. `_assets/doc.pdf`).
  String get path;

  /// Zero-based index of the PDF page this block represents.
  int get pageIndex;

  /// Width of the page in PDF points, as reported by the renderer.
  double get pageWidth;

  /// Height of the page in PDF points, as reported by the renderer.
  double get pageHeight;

  /// Ink annotation strokes drawn on this page.
  List<Stroke> get strokes;

  /// Create a copy of Block
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PdfPageBlockImplCopyWith<_$PdfPageBlockImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
