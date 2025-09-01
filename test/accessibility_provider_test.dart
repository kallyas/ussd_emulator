import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:ussd_emulator/providers/accessibility_provider.dart';
import 'package:ussd_emulator/models/accessibility_settings.dart';

// Mock class for testing
class MockAccessibilityService extends Mock {}

void main() {
  group('AccessibilityProvider', () {
    late AccessibilityProvider provider;

    setUp(() {
      provider = AccessibilityProvider();
    });

    tearDown(() {
      provider.dispose();
    });

    test('should have default settings initially', () {
      expect(provider.settings.useHighContrast, false);
      expect(provider.settings.enableVoiceInput, false);
      expect(provider.settings.enableTextToSpeech, false);
      expect(provider.settings.textScaleFactor, 1.0);
      expect(provider.settings.enableHapticFeedback, true);
      expect(provider.isInitialized, false);
    });

    test('should update high contrast setting', () async {
      const newSettings = AccessibilitySettings(useHighContrast: true);

      await provider.updateSettings(newSettings);

      expect(provider.settings.useHighContrast, true);
    });

    test('should toggle high contrast', () async {
      expect(provider.settings.useHighContrast, false);

      await provider.toggleHighContrast();
      expect(provider.settings.useHighContrast, true);

      await provider.toggleHighContrast();
      expect(provider.settings.useHighContrast, false);
    });

    test('should toggle voice input', () async {
      expect(provider.settings.enableVoiceInput, false);

      await provider.toggleVoiceInput();
      expect(provider.settings.enableVoiceInput, true);

      await provider.toggleVoiceInput();
      expect(provider.settings.enableVoiceInput, false);
    });

    test('should toggle text-to-speech', () async {
      expect(provider.settings.enableTextToSpeech, false);

      await provider.toggleTextToSpeech();
      expect(provider.settings.enableTextToSpeech, true);

      await provider.toggleTextToSpeech();
      expect(provider.settings.enableTextToSpeech, false);
    });

    test('should set text scale factor within bounds', () async {
      await provider.setTextScaleFactor(1.5);
      expect(provider.settings.textScaleFactor, 1.5);

      // Test upper bound
      await provider.setTextScaleFactor(3.0);
      expect(provider.settings.textScaleFactor, 2.0);

      // Test lower bound
      await provider.setTextScaleFactor(0.5);
      expect(provider.settings.textScaleFactor, 0.8);
    });

    test('should set input timeout', () async {
      const newTimeout = Duration(seconds: 60);

      await provider.setInputTimeout(newTimeout);
      expect(provider.settings.inputTimeout, newTimeout);
    });

    test('should toggle haptic feedback', () async {
      expect(provider.settings.enableHapticFeedback, true);

      await provider.toggleHapticFeedback();
      expect(provider.settings.enableHapticFeedback, false);

      await provider.toggleHapticFeedback();
      expect(provider.settings.enableHapticFeedback, true);
    });

    test('should create settings copy with changes', () {
      const original = AccessibilitySettings();
      final updated = original.copyWith(
        useHighContrast: true,
        enableVoiceInput: true,
      );

      expect(updated.useHighContrast, true);
      expect(updated.enableVoiceInput, true);
      expect(updated.enableTextToSpeech, false); // Unchanged
    });
  });
}
