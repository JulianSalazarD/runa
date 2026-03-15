// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stroke_point.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_StrokePoint _$StrokePointFromJson(Map<String, dynamic> json) => _StrokePoint(
  x: (json['x'] as num).toDouble(),
  y: (json['y'] as num).toDouble(),
  pressure: (json['pressure'] as num).toDouble(),
  timestamp: (json['timestamp'] as num).toInt(),
);

Map<String, dynamic> _$StrokePointToJson(_StrokePoint instance) =>
    <String, dynamic>{
      'x': instance.x,
      'y': instance.y,
      'pressure': instance.pressure,
      'timestamp': instance.timestamp,
    };
