// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'text_element.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TextElement _$TextElementFromJson(Map<String, dynamic> json) => _TextElement(
  id: json['id'] as String,
  x: (json['x'] as num).toDouble(),
  y: (json['y'] as num).toDouble(),
  content: json['content'] as String,
  fontSize: (json['fontSize'] as num?)?.toDouble() ?? 16.0,
  color: json['color'] as String? ?? '#000000FF',
  fontFamily: json['fontFamily'] as String?,
  bold: json['bold'] as bool? ?? false,
  italic: json['italic'] as bool? ?? false,
);

Map<String, dynamic> _$TextElementToJson(_TextElement instance) =>
    <String, dynamic>{
      'id': instance.id,
      'x': instance.x,
      'y': instance.y,
      'content': instance.content,
      'fontSize': instance.fontSize,
      'color': instance.color,
      'fontFamily': instance.fontFamily,
      'bold': instance.bold,
      'italic': instance.italic,
    };
