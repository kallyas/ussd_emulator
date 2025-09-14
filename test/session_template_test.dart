import 'package:flutter_test/flutter_test.dart';
import 'package:ussd_emulator/models/session_template.dart';
import 'package:ussd_emulator/models/template_step.dart';

void main() {
  group('SessionTemplate', () {
    test('should create template with required fields', () {
      final template = SessionTemplate(
        id: 'test-id',
        name: 'Test Template',
        description: 'Test description',
        serviceCode: '*123#',
        steps: [],
        variables: {},
        createdAt: DateTime.now(),
      );

      expect(template.id, 'test-id');
      expect(template.name, 'Test Template');
      expect(template.description, 'Test description');
      expect(template.serviceCode, '*123#');
      expect(template.steps, isEmpty);
      expect(template.variables, isEmpty);
      expect(template.stepDelayMs, 2000); // default value
      expect(template.version, 1); // default value
    });

    test('should process variables correctly', () {
      final template = SessionTemplate(
        id: 'test-id',
        name: 'Test Template',
        description: 'Test description',
        serviceCode: '*123#',
        steps: [],
        variables: {
          'pin': '1234',
          'account': 'savings',
        },
        createdAt: DateTime.now(),
      );

      const input = 'Enter PIN: \${pin} for \${account} account';
      final result = template.processVariables(input);
      
      expect(result, 'Enter PIN: 1234 for savings account');
    });

    test('should validate template correctly', () {
      // Valid template
      final validTemplate = SessionTemplate(
        id: 'test-id',
        name: 'Test Template',
        description: 'Test description',
        serviceCode: '*123#',
        steps: [
          const TemplateStep(input: '1'),
        ],
        variables: {},
        createdAt: DateTime.now(),
      );

      expect(validTemplate.isValid, true);

      // Invalid template - empty name
      final invalidTemplate1 = SessionTemplate(
        id: 'test-id',
        name: '',
        description: 'Test description',
        serviceCode: '*123#',
        steps: [
          const TemplateStep(input: '1'),
        ],
        variables: {},
        createdAt: DateTime.now(),
      );

      expect(invalidTemplate1.isValid, false);

      // Invalid template - no steps
      final invalidTemplate2 = SessionTemplate(
        id: 'test-id',
        name: 'Test Template',
        description: 'Test description',
        serviceCode: '*123#',
        steps: [],
        variables: {},
        createdAt: DateTime.now(),
      );

      expect(invalidTemplate2.isValid, false);

      // Invalid template - undefined variable
      final invalidTemplate3 = SessionTemplate(
        id: 'test-id',
        name: 'Test Template',
        description: 'Test description',
        serviceCode: '*123#',
        steps: [
          const TemplateStep(input: '\${pin}'), // pin not defined
        ],
        variables: {},
        createdAt: DateTime.now(),
      );

      expect(invalidTemplate3.isValid, false);
    });

    test('should identify used variables', () {
      final template = SessionTemplate(
        id: 'test-id',
        name: 'Test Template',
        description: 'Test description',
        serviceCode: '*123#',
        steps: [
          const TemplateStep(input: '\${pin}'),
          const TemplateStep(input: 'Select \${account}'),
          const TemplateStep(input: '1'), // no variables
        ],
        variables: {
          'pin': '1234',
          'account': 'savings',
          'unused': 'value', // not used in steps
        },
        createdAt: DateTime.now(),
      );

      final usedVariables = template.usedVariables;
      
      expect(usedVariables, contains('pin'));
      expect(usedVariables, contains('account'));
      expect(usedVariables, isNot(contains('unused')));
      expect(usedVariables.length, 2);
    });

    test('should convert to and from JSON', () {
      final originalTemplate = SessionTemplate(
        id: 'test-id',
        name: 'Test Template',
        description: 'Test description',
        serviceCode: '*123#',
        steps: [
          const TemplateStep(
            input: '1',
            description: 'First step',
            expectedResponse: 'Enter PIN',
          ),
        ],
        variables: {
          'pin': '1234',
        },
        stepDelayMs: 3000,
        createdAt: DateTime(2024, 1, 1),
        category: 'Banking',
        version: 2,
      );

      final json = originalTemplate.toJson();
      final reconstructedTemplate = SessionTemplate.fromJson(json);

      expect(reconstructedTemplate.id, originalTemplate.id);
      expect(reconstructedTemplate.name, originalTemplate.name);
      expect(reconstructedTemplate.description, originalTemplate.description);
      expect(reconstructedTemplate.serviceCode, originalTemplate.serviceCode);
      expect(reconstructedTemplate.steps.length, originalTemplate.steps.length);
      expect(reconstructedTemplate.variables, originalTemplate.variables);
      expect(reconstructedTemplate.stepDelayMs, originalTemplate.stepDelayMs);
      expect(reconstructedTemplate.createdAt, originalTemplate.createdAt);
      expect(reconstructedTemplate.category, originalTemplate.category);
      expect(reconstructedTemplate.version, originalTemplate.version);
    });

    test('should copy with modifications', () {
      final originalTemplate = SessionTemplate(
        id: 'test-id',
        name: 'Test Template',
        description: 'Test description',
        serviceCode: '*123#',
        steps: [],
        variables: {},
        createdAt: DateTime.now(),
      );

      final copiedTemplate = originalTemplate.copyWith(
        name: 'Updated Template',
        stepDelayMs: 5000,
      );

      expect(copiedTemplate.id, originalTemplate.id); // unchanged
      expect(copiedTemplate.name, 'Updated Template'); // changed
      expect(copiedTemplate.stepDelayMs, 5000); // changed
      expect(copiedTemplate.description, originalTemplate.description); // unchanged
    });

    test('should convert step delay to Duration', () {
      final template = SessionTemplate(
        id: 'test-id',
        name: 'Test Template',
        description: 'Test description',
        serviceCode: '*123#',
        steps: [],
        variables: {},
        stepDelayMs: 3000,
        createdAt: DateTime.now(),
      );

      expect(template.stepDelay, const Duration(milliseconds: 3000));
    });
  });
}