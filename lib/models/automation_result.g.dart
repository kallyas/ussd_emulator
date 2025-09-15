// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'automation_result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AutomationResult _$AutomationResultFromJson(Map<String, dynamic> json) =>
    AutomationResult(
      templateId: json['templateId'] as String,
      templateName: json['templateName'] as String,
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: json['endTime'] == null
          ? null
          : DateTime.parse(json['endTime'] as String),
      stepResults: (json['stepResults'] as List<dynamic>)
          .map((e) => StepResult.fromJson(e as Map<String, dynamic>))
          .toList(),
      isCompleted: json['isCompleted'] as bool,
      isSuccessful: json['isSuccessful'] as bool,
      errorMessage: json['errorMessage'] as String?,
    );

Map<String, dynamic> _$AutomationResultToJson(AutomationResult instance) =>
    <String, dynamic>{
      'templateId': instance.templateId,
      'templateName': instance.templateName,
      'startTime': instance.startTime.toIso8601String(),
      'endTime': instance.endTime?.toIso8601String(),
      'stepResults': instance.stepResults,
      'isCompleted': instance.isCompleted,
      'isSuccessful': instance.isSuccessful,
      'errorMessage': instance.errorMessage,
    };

StepResult _$StepResultFromJson(Map<String, dynamic> json) => StepResult(
  stepIndex: (json['stepIndex'] as num).toInt(),
  step: TemplateStep.fromJson(json['step'] as Map<String, dynamic>),
  startTime: DateTime.parse(json['startTime'] as String),
  endTime: json['endTime'] == null
      ? null
      : DateTime.parse(json['endTime'] as String),
  isSuccessful: json['isSuccessful'] as bool,
  errorMessage: json['errorMessage'] as String?,
  actualResponse: json['actualResponse'] as String?,
  responseMatched: json['responseMatched'] as bool? ?? true,
);

Map<String, dynamic> _$StepResultToJson(StepResult instance) =>
    <String, dynamic>{
      'stepIndex': instance.stepIndex,
      'step': instance.step,
      'startTime': instance.startTime.toIso8601String(),
      'endTime': instance.endTime?.toIso8601String(),
      'isSuccessful': instance.isSuccessful,
      'errorMessage': instance.errorMessage,
      'actualResponse': instance.actualResponse,
      'responseMatched': instance.responseMatched,
    };
