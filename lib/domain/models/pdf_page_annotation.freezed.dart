// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'pdf_page_annotation.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

PdfPageAnnotation _$PdfPageAnnotationFromJson(Map<String, dynamic> json) {
  return _PdfPageAnnotation.fromJson(json);
}

/// @nodoc
mixin _$PdfPageAnnotation {
  /// Zero-based index of the PDF page this annotation belongs to.
  int get pageIndex => throw _privateConstructorUsedError;

  /// Width of the page in points (pt) as reported by the PDF renderer.
  double get pageWidth => throw _privateConstructorUsedError;

  /// Height of the page in points (pt) as reported by the PDF renderer.
  double get pageHeight => throw _privateConstructorUsedError;

  /// Ink strokes drawn on this page, in draw order (painter's algorithm).
  List<Stroke> get strokes => throw _privateConstructorUsedError;

  /// Serializes this PdfPageAnnotation to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PdfPageAnnotation
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PdfPageAnnotationCopyWith<PdfPageAnnotation> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PdfPageAnnotationCopyWith<$Res> {
  factory $PdfPageAnnotationCopyWith(
    PdfPageAnnotation value,
    $Res Function(PdfPageAnnotation) then,
  ) = _$PdfPageAnnotationCopyWithImpl<$Res, PdfPageAnnotation>;
  @useResult
  $Res call({
    int pageIndex,
    double pageWidth,
    double pageHeight,
    List<Stroke> strokes,
  });
}

/// @nodoc
class _$PdfPageAnnotationCopyWithImpl<$Res, $Val extends PdfPageAnnotation>
    implements $PdfPageAnnotationCopyWith<$Res> {
  _$PdfPageAnnotationCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PdfPageAnnotation
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? pageIndex = null,
    Object? pageWidth = null,
    Object? pageHeight = null,
    Object? strokes = null,
  }) {
    return _then(
      _value.copyWith(
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
                ? _value.strokes
                : strokes // ignore: cast_nullable_to_non_nullable
                      as List<Stroke>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PdfPageAnnotationImplCopyWith<$Res>
    implements $PdfPageAnnotationCopyWith<$Res> {
  factory _$$PdfPageAnnotationImplCopyWith(
    _$PdfPageAnnotationImpl value,
    $Res Function(_$PdfPageAnnotationImpl) then,
  ) = __$$PdfPageAnnotationImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int pageIndex,
    double pageWidth,
    double pageHeight,
    List<Stroke> strokes,
  });
}

/// @nodoc
class __$$PdfPageAnnotationImplCopyWithImpl<$Res>
    extends _$PdfPageAnnotationCopyWithImpl<$Res, _$PdfPageAnnotationImpl>
    implements _$$PdfPageAnnotationImplCopyWith<$Res> {
  __$$PdfPageAnnotationImplCopyWithImpl(
    _$PdfPageAnnotationImpl _value,
    $Res Function(_$PdfPageAnnotationImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PdfPageAnnotation
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? pageIndex = null,
    Object? pageWidth = null,
    Object? pageHeight = null,
    Object? strokes = null,
  }) {
    return _then(
      _$PdfPageAnnotationImpl(
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
class _$PdfPageAnnotationImpl implements _PdfPageAnnotation {
  const _$PdfPageAnnotationImpl({
    required this.pageIndex,
    required this.pageWidth,
    required this.pageHeight,
    final List<Stroke> strokes = const [],
  }) : _strokes = strokes;

  factory _$PdfPageAnnotationImpl.fromJson(Map<String, dynamic> json) =>
      _$$PdfPageAnnotationImplFromJson(json);

  /// Zero-based index of the PDF page this annotation belongs to.
  @override
  final int pageIndex;

  /// Width of the page in points (pt) as reported by the PDF renderer.
  @override
  final double pageWidth;

  /// Height of the page in points (pt) as reported by the PDF renderer.
  @override
  final double pageHeight;

  /// Ink strokes drawn on this page, in draw order (painter's algorithm).
  final List<Stroke> _strokes;

  /// Ink strokes drawn on this page, in draw order (painter's algorithm).
  @override
  @JsonKey()
  List<Stroke> get strokes {
    if (_strokes is EqualUnmodifiableListView) return _strokes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_strokes);
  }

  @override
  String toString() {
    return 'PdfPageAnnotation(pageIndex: $pageIndex, pageWidth: $pageWidth, pageHeight: $pageHeight, strokes: $strokes)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PdfPageAnnotationImpl &&
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
    pageIndex,
    pageWidth,
    pageHeight,
    const DeepCollectionEquality().hash(_strokes),
  );

  /// Create a copy of PdfPageAnnotation
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PdfPageAnnotationImplCopyWith<_$PdfPageAnnotationImpl> get copyWith =>
      __$$PdfPageAnnotationImplCopyWithImpl<_$PdfPageAnnotationImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$PdfPageAnnotationImplToJson(this);
  }
}

abstract class _PdfPageAnnotation implements PdfPageAnnotation {
  const factory _PdfPageAnnotation({
    required final int pageIndex,
    required final double pageWidth,
    required final double pageHeight,
    final List<Stroke> strokes,
  }) = _$PdfPageAnnotationImpl;

  factory _PdfPageAnnotation.fromJson(Map<String, dynamic> json) =
      _$PdfPageAnnotationImpl.fromJson;

  /// Zero-based index of the PDF page this annotation belongs to.
  @override
  int get pageIndex;

  /// Width of the page in points (pt) as reported by the PDF renderer.
  @override
  double get pageWidth;

  /// Height of the page in points (pt) as reported by the PDF renderer.
  @override
  double get pageHeight;

  /// Ink strokes drawn on this page, in draw order (painter's algorithm).
  @override
  List<Stroke> get strokes;

  /// Create a copy of PdfPageAnnotation
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PdfPageAnnotationImplCopyWith<_$PdfPageAnnotationImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
