// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stroke.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$StrokeImpl _$$StrokeImplFromJson(Map<String, dynamic> json) => _$StrokeImpl(
  id: json['id'] as String,
  color: json['color'] as String,
  width: (json['width'] as num).toDouble(),
  tool: $enumDecode(_$StrokeToolEnumMap, json['tool']),
  points: (json['points'] as List<dynamic>)
      .map((e) => StrokePoint.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$$StrokeImplToJson(_$StrokeImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'color': instance.color,
      'width': instance.width,
      'tool': _$StrokeToolEnumMap[instance.tool]!,
      'points': instance.points.map((e) => e.toJson()).toList(),
    };

const _$StrokeToolEnumMap = {
  StrokeTool.pen: 'pen',
  StrokeTool.pencil: 'pencil',
  StrokeTool.marker: 'marker',
  StrokeTool.eraser: 'eraser',
};
