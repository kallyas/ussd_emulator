// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session_template.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SessionTemplate _$SessionTemplateFromJson(Map<String, dynamic> json) =>
    SessionTemplate(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      serviceCode: json['serviceCode'] as String,
      steps: (json['steps'] as List<dynamic>)
          .map((e) => TemplateStep.fromJson(e as Map<String, dynamic>))
          .toList(),
      variables: Map<String, String>.from(json['variables'] as Map),
      stepDelayMs: (json['stepDelayMs'] as num?)?.toInt() ?? 2000,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
      category: json['category'] as String?,
      version: (json['version'] as num?)?.toInt() ?? 1,
    );

Map<String, dynamic> _$SessionTemplateToJson(SessionTemplate instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'serviceCode': instance.serviceCode,
      'steps': instance.steps,
      'variables': instance.variables,
      'stepDelayMs': instance.stepDelayMs,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'category': instance.category,
      'version': instance.version,
    };
