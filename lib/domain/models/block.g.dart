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
