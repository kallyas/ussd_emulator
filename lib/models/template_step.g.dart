// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'template_step.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TemplateStep _$TemplateStepFromJson(Map<String, dynamic> json) => TemplateStep(
  input: json['input'] as String,
  expectedResponse: json['expectedResponse'] as String?,
  description: json['description'] as String?,
  customDelayMs: (json['customDelayMs'] as num?)?.toInt(),
  waitForResponse: json['waitForResponse'] as bool? ?? true,
  isCritical: json['isCritical'] as bool? ?? false,
);

Map<String, dynamic> _$TemplateStepToJson(TemplateStep instance) =>
    <String, dynamic>{
      'input': instance.input,
      'expectedResponse': instance.expectedResponse,
      'description': instance.description,
      'customDelayMs': instance.customDelayMs,
      'waitForResponse': instance.waitForResponse,
      'isCritical': instance.isCritical,
    };
