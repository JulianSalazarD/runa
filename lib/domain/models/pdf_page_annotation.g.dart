// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pdf_page_annotation.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PdfPageAnnotationImpl _$$PdfPageAnnotationImplFromJson(
  Map<String, dynamic> json,
) => _$PdfPageAnnotationImpl(
  pageIndex: (json['pageIndex'] as num).toInt(),
  pageWidth: (json['pageWidth'] as num).toDouble(),
  pageHeight: (json['pageHeight'] as num).toDouble(),
  strokes:
      (json['strokes'] as List<dynamic>?)
          ?.map((e) => Stroke.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$$PdfPageAnnotationImplToJson(
  _$PdfPageAnnotationImpl instance,
) => <String, dynamic>{
  'pageIndex': instance.pageIndex,
  'pageWidth': instance.pageWidth,
  'pageHeight': instance.pageHeight,
  'strokes': instance.strokes.map((e) => e.toJson()).toList(),
};
