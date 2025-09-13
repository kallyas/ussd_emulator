import 'package:json_annotation/json_annotation.dart';

part 'accessibility_settings.g.dart';

@JsonSerializable()

class AccessibilitySettings {
  final bool accessibilityEnabled;
  final bool useHighContrast;
  final bool enableVoiceInput;
  final bool enableTextToSpeech;
  final double textScaleFactor;
  final Duration inputTimeout;
  final bool enableHapticFeedback;
  final bool enableKeyboardNavigation;
  final bool enableLiveRegions;

  const AccessibilitySettings({
    this.accessibilityEnabled = true,
    this.useHighContrast = false,
    this.enableVoiceInput = false,
    this.enableTextToSpeech = false,
    this.textScaleFactor = 1.0,
    this.inputTimeout = const Duration(seconds: 30),
    this.enableHapticFeedback = true,
    this.enableKeyboardNavigation = true,
    this.enableLiveRegions = true,
  });

  AccessibilitySettings copyWith({
    bool? accessibilityEnabled,
    bool? useHighContrast,
    bool? enableVoiceInput,
    bool? enableTextToSpeech,
    double? textScaleFactor,
    Duration? inputTimeout,
    bool? enableHapticFeedback,
    bool? enableKeyboardNavigation,
    bool? enableLiveRegions,
  }) {
    return AccessibilitySettings(
      accessibilityEnabled: accessibilityEnabled ?? this.accessibilityEnabled,
      useHighContrast: useHighContrast ?? this.useHighContrast,
      enableVoiceInput: enableVoiceInput ?? this.enableVoiceInput,
      enableTextToSpeech: enableTextToSpeech ?? this.enableTextToSpeech,
      textScaleFactor: textScaleFactor ?? this.textScaleFactor,
      inputTimeout: inputTimeout ?? this.inputTimeout,
      enableHapticFeedback: enableHapticFeedback ?? this.enableHapticFeedback,
      enableKeyboardNavigation:
          enableKeyboardNavigation ?? this.enableKeyboardNavigation,
      enableLiveRegions: enableLiveRegions ?? this.enableLiveRegions,
    );
  }

  factory AccessibilitySettings.fromJson(Map<String, dynamic> json) =>
      _$AccessibilitySettingsFromJson(json);

  Map<String, dynamic> toJson() => _$AccessibilitySettingsToJson(this);
}
