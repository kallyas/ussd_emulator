import 'package:flutter_test/flutter_test.dart';
import 'package:ussd_emulator/models/template_step.dart';

void main() {
  group('TemplateStep', () {
    test('should create step with required fields', () {
      const step = TemplateStep(input: '1');

      expect(step.input, '1');
      expect(step.expectedResponse, null);
      expect(step.description, null);
      expect(step.customDelayMs, null);
      expect(step.waitForResponse, true); // default value
      expect(step.isCritical, false); // default value
    });

    test('should create step with all fields', () {
      const step = TemplateStep(
        input: '1',
        expectedResponse: 'Enter PIN',
        description: 'Select balance inquiry',
        customDelayMs: 5000,
        waitForResponse: false,
        isCritical: true,
      );

      expect(step.input, '1');
      expect(step.expectedResponse, 'Enter PIN');
      expect(step.description, 'Select balance inquiry');
      expect(step.customDelayMs, 5000);
      expect(step.waitForResponse, false);
      expect(step.isCritical, true);
    });

    test('should check if step has custom delay', () {
      const stepWithoutDelay = TemplateStep(input: '1');
      const stepWithDelay = TemplateStep(input: '1', customDelayMs: 3000);

      expect(stepWithoutDelay.hasCustomDelay, false);
      expect(stepWithDelay.hasCustomDelay, true);
    });

    test('should check if step has expected response', () {
      const stepWithoutResponse = TemplateStep(input: '1');
      const stepWithEmptyResponse = TemplateStep(input: '1', expectedResponse: '');
      const stepWithResponse = TemplateStep(input: '1', expectedResponse: 'Enter PIN');

      expect(stepWithoutResponse.hasExpectedResponse, false);
      expect(stepWithEmptyResponse.hasExpectedResponse, false);
      expect(stepWithResponse.hasExpectedResponse, true);
    });

    test('should convert custom delay to Duration', () {
      const stepWithoutDelay = TemplateStep(input: '1');
      const stepWithDelay = TemplateStep(input: '1', customDelayMs: 3000);

      expect(stepWithoutDelay.customDelay, null);
      expect(stepWithDelay.customDelay, const Duration(milliseconds: 3000));
    });

    test('should convert to and from JSON', () {
      const originalStep = TemplateStep(
        input: '1',
        expectedResponse: 'Enter PIN',
        description: 'Select balance inquiry',
        customDelayMs: 5000,
        waitForResponse: false,
        isCritical: true,
      );

      final json = originalStep.toJson();
      final reconstructedStep = TemplateStep.fromJson(json);

      expect(reconstructedStep.input, originalStep.input);
      expect(reconstructedStep.expectedResponse, originalStep.expectedResponse);
      expect(reconstructedStep.description, originalStep.description);
      expect(reconstructedStep.customDelayMs, originalStep.customDelayMs);
      expect(reconstructedStep.waitForResponse, originalStep.waitForResponse);
      expect(reconstructedStep.isCritical, originalStep.isCritical);
    });

    test('should copy with modifications', () {
      const originalStep = TemplateStep(
        input: '1',
        expectedResponse: 'Enter PIN',
      );

      final copiedStep = originalStep.copyWith(
        description: 'Updated description',
        isCritical: true,
      );

      expect(copiedStep.input, originalStep.input); // unchanged
      expect(copiedStep.expectedResponse, originalStep.expectedResponse); // unchanged
      expect(copiedStep.description, 'Updated description'); // changed
      expect(copiedStep.isCritical, true); // changed
      expect(copiedStep.waitForResponse, originalStep.waitForResponse); // unchanged
    });

    test('should handle null custom delay in copyWith', () {
      const originalStep = TemplateStep(input: '1', customDelayMs: 3000);

      final copiedStep = originalStep.copyWith(customDelayMs: null);

      expect(copiedStep.customDelayMs, null);
    });
  });
}