// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'document.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Document _$DocumentFromJson(Map<String, dynamic> json) => _Document(
  version: json['version'] as String,
  id: json['id'] as String,
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
  blocks: (json['blocks'] as List<dynamic>)
      .map((e) => Block.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$DocumentToJson(_Document instance) => <String, dynamic>{
  'version': instance.version,
  'id': instance.id,
  'created_at': instance.createdAt.toIso8601String(),
  'updated_at': instance.updatedAt.toIso8601String(),
  'blocks': instance.blocks.map((e) => e.toJson()).toList(),
};
