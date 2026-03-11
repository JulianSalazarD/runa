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
      background:
          $enumDecodeNullable(_$InkBackgroundEnumMap, json['background']) ??
          InkBackground.plain,
      backgroundSpacing:
          (json['backgroundSpacing'] as num?)?.toDouble() ?? 24.0,
      backgroundLineColor: json['backgroundLineColor'] as String?,
      backgroundColor: json['backgroundColor'] as String?,
      $type: json['type'] as String?,
    );

Map<String, dynamic> _$$InkBlockImplToJson(_$InkBlockImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'height': instance.height,
      'strokes': instance.strokes.map((e) => e.toJson()).toList(),
      'background': _$InkBackgroundEnumMap[instance.background]!,
      'backgroundSpacing': instance.backgroundSpacing,
      'backgroundLineColor': instance.backgroundLineColor,
      'backgroundColor': instance.backgroundColor,
      'type': instance.$type,
    };

const _$InkBackgroundEnumMap = {
  InkBackground.plain: 'plain',
  InkBackground.ruled: 'ruled',
  InkBackground.grid: 'grid',
  InkBackground.dotted: 'dotted',
  InkBackground.isometric: 'isometric',
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

_$PdfPageBlockImpl _$$PdfPageBlockImplFromJson(Map<String, dynamic> json) =>
    _$PdfPageBlockImpl(
      id: json['id'] as String,
      path: json['path'] as String,
      pageIndex: (json['pageIndex'] as num).toInt(),
      pageWidth: (json['pageWidth'] as num?)?.toDouble() ?? 0.0,
      pageHeight: (json['pageHeight'] as num?)?.toDouble() ?? 0.0,
      strokes:
          (json['strokes'] as List<dynamic>?)
              ?.map((e) => Stroke.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      $type: json['type'] as String?,
    );

Map<String, dynamic> _$$PdfPageBlockImplToJson(_$PdfPageBlockImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'path': instance.path,
      'pageIndex': instance.pageIndex,
      'pageWidth': instance.pageWidth,
      'pageHeight': instance.pageHeight,
      'strokes': instance.strokes.map((e) => e.toJson()).toList(),
      'type': instance.$type,
    };
