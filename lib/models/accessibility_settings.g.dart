// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'accessibility_settings.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AccessibilitySettings _$AccessibilitySettingsFromJson(
  Map<String, dynamic> json,
) => AccessibilitySettings(
  useHighContrast: json['useHighContrast'] as bool? ?? false,
  enableVoiceInput: json['enableVoiceInput'] as bool? ?? false,
  enableTextToSpeech: json['enableTextToSpeech'] as bool? ?? false,
  textScaleFactor: (json['textScaleFactor'] as num?)?.toDouble() ?? 1.0,
  inputTimeout: json['inputTimeout'] == null
      ? const Duration(seconds: 30)
      : Duration(milliseconds: json['inputTimeout'] as int),
  enableHapticFeedback: json['enableHapticFeedback'] as bool? ?? true,
  enableKeyboardNavigation: json['enableKeyboardNavigation'] as bool? ?? true,
  enableLiveRegions: json['enableLiveRegions'] as bool? ?? true,
);

Map<String, dynamic> _$AccessibilitySettingsToJson(
  AccessibilitySettings instance,
) => <String, dynamic>{
  'useHighContrast': instance.useHighContrast,
  'enableVoiceInput': instance.enableVoiceInput,
  'enableTextToSpeech': instance.enableTextToSpeech,
  'textScaleFactor': instance.textScaleFactor,
  'inputTimeout': instance.inputTimeout.inMilliseconds,
  'enableHapticFeedback': instance.enableHapticFeedback,
  'enableKeyboardNavigation': instance.enableKeyboardNavigation,
  'enableLiveRegions': instance.enableLiveRegions,
};
