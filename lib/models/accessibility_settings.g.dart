// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'accessibility_settings.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AccessibilitySettings _$AccessibilitySettingsFromJson(
  Map<String, dynamic> json,
) => AccessibilitySettings(
  accessibilityEnabled: json['accessibilityEnabled'] as bool? ?? true,
  useHighContrast: json['useHighContrast'] as bool? ?? false,
  enableVoiceInput: json['enableVoiceInput'] as bool? ?? false,
  enableTextToSpeech: json['enableTextToSpeech'] as bool? ?? false,
  textScaleFactor: (json['textScaleFactor'] as num?)?.toDouble() ?? 1.0,
  inputTimeout: json['inputTimeout'] == null
      ? const Duration(seconds: 30)
      : Duration(microseconds: (json['inputTimeout'] as num).toInt()),
  enableHapticFeedback: json['enableHapticFeedback'] as bool? ?? true,
  enableKeyboardNavigation: json['enableKeyboardNavigation'] as bool? ?? true,
  enableLiveRegions: json['enableLiveRegions'] as bool? ?? true,
);

Map<String, dynamic> _$AccessibilitySettingsToJson(
  AccessibilitySettings instance,
) => <String, dynamic>{
  'accessibilityEnabled': instance.accessibilityEnabled,
  'useHighContrast': instance.useHighContrast,
  'enableVoiceInput': instance.enableVoiceInput,
  'enableTextToSpeech': instance.enableTextToSpeech,
  'textScaleFactor': instance.textScaleFactor,
  'inputTimeout': instance.inputTimeout.inMicroseconds,
  'enableHapticFeedback': instance.enableHapticFeedback,
  'enableKeyboardNavigation': instance.enableKeyboardNavigation,
  'enableLiveRegions': instance.enableLiveRegions,
};
