// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shape_element.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ShapeElementImpl _$$ShapeElementImplFromJson(Map<String, dynamic> json) =>
    _$ShapeElementImpl(
      id: json['id'] as String,
      type: $enumDecode(_$ShapeTypeEnumMap, json['type']),
      x1: (json['x1'] as num).toDouble(),
      y1: (json['y1'] as num).toDouble(),
      x2: (json['x2'] as num).toDouble(),
      y2: (json['y2'] as num).toDouble(),
      color: json['color'] as String? ?? '#000000FF',
      strokeWidth: (json['strokeWidth'] as num?)?.toDouble() ?? 2.0,
      filled: json['filled'] as bool? ?? false,
      fillColor: json['fillColor'] as String?,
    );

Map<String, dynamic> _$$ShapeElementImplToJson(_$ShapeElementImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': _$ShapeTypeEnumMap[instance.type]!,
      'x1': instance.x1,
      'y1': instance.y1,
      'x2': instance.x2,
      'y2': instance.y2,
      'color': instance.color,
      'strokeWidth': instance.strokeWidth,
      'filled': instance.filled,
      'fillColor': instance.fillColor,
    };

const _$ShapeTypeEnumMap = {
  ShapeType.line: 'line',
  ShapeType.rect: 'rect',
  ShapeType.oval: 'oval',
  ShapeType.triangle: 'triangle',
  ShapeType.arrow: 'arrow',
};
