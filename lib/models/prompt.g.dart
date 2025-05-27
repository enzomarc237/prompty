// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'prompt.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Prompt _$PromptFromJson(Map<String, dynamic> json) => Prompt(
  id: json['id'] as String,
  originalText: json['originalText'] as String,
  professionalVersion: json['professionalVersion'] as String?,
  creativeVersion: json['creativeVersion'] as String?,
  technicalVersion: json['technicalVersion'] as String?,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt:
      json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
  isFavorite: json['isFavorite'] as bool? ?? false,
  tags:
      (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  category: json['category'] as String?,
);

Map<String, dynamic> _$PromptToJson(Prompt instance) => <String, dynamic>{
  'id': instance.id,
  'originalText': instance.originalText,
  'professionalVersion': instance.professionalVersion,
  'creativeVersion': instance.creativeVersion,
  'technicalVersion': instance.technicalVersion,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt?.toIso8601String(),
  'isFavorite': instance.isFavorite,
  'tags': instance.tags,
  'category': instance.category,
};
