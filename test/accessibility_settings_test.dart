import 'package:flutter_test/flutter_test.dart';
import 'package:ussd_emulator/models/accessibility_settings.dart';

void main() {
  group('AccessibilitySettings', () {
    test('should create with default values', () {
      const settings = AccessibilitySettings();

      expect(settings.useHighContrast, false);
      expect(settings.enableVoiceInput, false);
      expect(settings.enableTextToSpeech, false);
      expect(settings.textScaleFactor, 1.0);
      expect(settings.inputTimeout, const Duration(seconds: 30));
      expect(settings.enableHapticFeedback, true);
      expect(settings.enableKeyboardNavigation, true);
      expect(settings.enableLiveRegions, true);
    });

    test('should create with custom values', () {
      const settings = AccessibilitySettings(
        useHighContrast: true,
        enableVoiceInput: true,
        enableTextToSpeech: true,
        textScaleFactor: 1.5,
        inputTimeout: Duration(seconds: 60),
        enableHapticFeedback: false,
        enableKeyboardNavigation: false,
        enableLiveRegions: false,
      );

      expect(settings.useHighContrast, true);
      expect(settings.enableVoiceInput, true);
      expect(settings.enableTextToSpeech, true);
      expect(settings.textScaleFactor, 1.5);
      expect(settings.inputTimeout, const Duration(seconds: 60));
      expect(settings.enableHapticFeedback, false);
      expect(settings.enableKeyboardNavigation, false);
      expect(settings.enableLiveRegions, false);
    });

    test('should copy with changes', () {
      const original = AccessibilitySettings();
      final updated = original.copyWith(
        useHighContrast: true,
        textScaleFactor: 1.2,
      );

      expect(updated.useHighContrast, true);
      expect(updated.textScaleFactor, 1.2);
      expect(updated.enableVoiceInput, false); // Unchanged
      expect(updated.enableTextToSpeech, false); // Unchanged
    });

    test('should serialize to and from JSON', () {
      const original = AccessibilitySettings(
        useHighContrast: true,
        enableVoiceInput: true,
        enableTextToSpeech: true,
        textScaleFactor: 1.5,
        inputTimeout: Duration(seconds: 45),
        enableHapticFeedback: false,
      );

      final json = original.toJson();
      final restored = AccessibilitySettings.fromJson(json);

      expect(restored.useHighContrast, original.useHighContrast);
      expect(restored.enableVoiceInput, original.enableVoiceInput);
      expect(restored.enableTextToSpeech, original.enableTextToSpeech);
      expect(restored.textScaleFactor, original.textScaleFactor);
      expect(restored.inputTimeout, original.inputTimeout);
      expect(restored.enableHapticFeedback, original.enableHapticFeedback);
      expect(
        restored.enableKeyboardNavigation,
        original.enableKeyboardNavigation,
      );
      expect(restored.enableLiveRegions, original.enableLiveRegions);
    });

    test('should handle missing fields in JSON gracefully', () {
      final json = <String, dynamic>{
        'useHighContrast': true,
        'textScaleFactor': 1.2,
      };

      final settings = AccessibilitySettings.fromJson(json);

      expect(settings.useHighContrast, true);
      expect(settings.textScaleFactor, 1.2);
      expect(settings.enableVoiceInput, false); // Default
      expect(settings.enableTextToSpeech, false); // Default
      expect(settings.inputTimeout, const Duration(seconds: 30)); // Default
    });

    test('should validate text scale factor bounds', () {
      const settings1 = AccessibilitySettings(textScaleFactor: 0.8);
      const settings2 = AccessibilitySettings(textScaleFactor: 2.0);

      expect(settings1.textScaleFactor, 0.8);
      expect(settings2.textScaleFactor, 2.0);
    });
  });
}
