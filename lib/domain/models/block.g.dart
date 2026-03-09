// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'block.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MarkdownBlockImpl _$$MarkdownBlockImplFromJson(Map<String, dynamic> json) =>
    _$MarkdownBlockImpl(
      id: json['id'] as String,
      content: json['content'] as String,
      $type: json['type'] as String?,
    );

Map<String, dynamic> _$$MarkdownBlockImplToJson(_$MarkdownBlockImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'content': instance.content,
      'type': instance.$type,
    };

_$InkBlockImpl _$$InkBlockImplFromJson(Map<String, dynamic> json) =>
    _$InkBlockImpl(
      id: json['id'] as String,
      height: (json['height'] as num).toDouble(),
      strokes:
          (json['strokes'] as List<dynamic>?)
              ?.map((e) => Stroke.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      $type: json['type'] as String?,
    );

Map<String, dynamic> _$$InkBlockImplToJson(_$InkBlockImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'height': instance.height,
      'strokes': instance.strokes.map((e) => e.toJson()).toList(),
      'type': instance.$type,
    };

_$ImageBlockImpl _$$ImageBlockImplFromJson(Map<String, dynamic> json) =>
    _$ImageBlockImpl(
      id: json['id'] as String,
      path: json['path'] as String,
      naturalWidth: (json['naturalWidth'] as num).toDouble(),
      naturalHeight: (json['naturalHeight'] as num).toDouble(),
      strokes:
          (json['strokes'] as List<dynamic>?)
              ?.map((e) => Stroke.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      $type: json['type'] as String?,
    );

Map<String, dynamic> _$$ImageBlockImplToJson(_$ImageBlockImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'path': instance.path,
      'naturalWidth': instance.naturalWidth,
      'naturalHeight': instance.naturalHeight,
      'strokes': instance.strokes.map((e) => e.toJson()).toList(),
      'type': instance.$type,
    };

_$PdfBlockImpl _$$PdfBlockImplFromJson(Map<String, dynamic> json) =>
    _$PdfBlockImpl(
      id: json['id'] as String,
      path: json['path'] as String,
      pages:
          (json['pages'] as List<dynamic>?)
              ?.map(
                (e) => PdfPageAnnotation.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          const [],
      $type: json['type'] as String?,
    );

Map<String, dynamic> _$$PdfBlockImplToJson(_$PdfBlockImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'path': instance.path,
      'pages': instance.pages.map((e) => e.toJson()).toList(),
      'type': instance.$type,
    };
