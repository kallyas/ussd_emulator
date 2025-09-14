import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ussd_emulator/services/template_service.dart';
import 'package:ussd_emulator/models/session_template.dart';
import 'package:ussd_emulator/models/template_step.dart';

void main() {
  group('TemplateService', () {
    late TemplateService service;

    setUp(() {
      // Mock SharedPreferences for testing
      SharedPreferences.setMockInitialValues({});
      service = TemplateService();
    });

    test('should initialize with empty templates', () async {
      await service.init();
      expect(service.templates, isEmpty);
    });

    test('should create a new template', () async {
      await service.init();

      final template = await service.createTemplate(
        name: 'Test Template',
        description: 'Test description',
        serviceCode: '*123#',
        category: 'Banking',
      );

      expect(template.name, 'Test Template');
      expect(template.description, 'Test description');
      expect(template.serviceCode, '*123#');
      expect(template.category, 'Banking');
      expect(template.id, isNotEmpty);
      expect(service.templates.length, 1);
    });

    test('should update existing template', () async {
      await service.init();

      final original = await service.createTemplate(
        name: 'Original Template',
        description: 'Original description',
        serviceCode: '*123#',
      );

      final updated = original.copyWith(
        name: 'Updated Template',
        description: 'Updated description',
      );

      final result = await service.updateTemplate(original.id, updated);

      expect(result, isNotNull);
      expect(result!.name, 'Updated Template');
      expect(result.description, 'Updated description');
      expect(result.updatedAt, isNotNull);
      expect(service.templates.length, 1);
    });

    test('should delete template', () async {
      await service.init();

      final template = await service.createTemplate(
        name: 'Test Template',
        description: 'Test description',
        serviceCode: '*123#',
      );

      expect(service.templates.length, 1);

      final deleted = await service.deleteTemplate(template.id);

      expect(deleted, true);
      expect(service.templates, isEmpty);
    });

    test('should return false when deleting non-existent template', () async {
      await service.init();

      final deleted = await service.deleteTemplate('non-existent-id');

      expect(deleted, false);
    });

    test('should get template by ID', () async {
      await service.init();

      final created = await service.createTemplate(
        name: 'Test Template',
        description: 'Test description',
        serviceCode: '*123#',
      );

      final retrieved = service.getTemplate(created.id);

      expect(retrieved, isNotNull);
      expect(retrieved!.id, created.id);
    });

    test('should return null for non-existent template', () async {
      await service.init();

      final retrieved = service.getTemplate('non-existent-id');

      expect(retrieved, null);
    });

    test('should filter templates by category', () async {
      await service.init();

      await service.createTemplate(
        name: 'Banking Template',
        description: 'Banking description',
        serviceCode: '*123#',
        category: 'Banking',
      );

      await service.createTemplate(
        name: 'Mobile Money Template',
        description: 'Mobile money description',
        serviceCode: '*456#',
        category: 'Mobile Money',
      );

      await service.createTemplate(
        name: 'Uncategorized Template',
        description: 'Uncategorized description',
        serviceCode: '*789#',
      );

      final bankingTemplates = service.getTemplatesByCategory('Banking');
      final uncategorizedTemplates = service.getTemplatesByCategory(null);

      expect(bankingTemplates.length, 1);
      expect(bankingTemplates.first.name, 'Banking Template');
      expect(uncategorizedTemplates.length, 1);
      expect(uncategorizedTemplates.first.name, 'Uncategorized Template');
    });

    test('should get all categories', () async {
      await service.init();

      await service.createTemplate(
        name: 'Template 1',
        description: 'Description 1',
        serviceCode: '*123#',
        category: 'Banking',
      );

      await service.createTemplate(
        name: 'Template 2',
        description: 'Description 2',
        serviceCode: '*456#',
        category: 'Mobile Money',
      );

      await service.createTemplate(
        name: 'Template 3',
        description: 'Description 3',
        serviceCode: '*789#',
        category: 'Banking', // duplicate category
      );

      final categories = service.getCategories();

      expect(categories.length, 2);
      expect(categories, contains('Banking'));
      expect(categories, contains('Mobile Money'));
    });

    test('should search templates', () async {
      await service.init();

      await service.createTemplate(
        name: 'Banking Balance Check',
        description: 'Check your bank balance',
        serviceCode: '*123#',
        category: 'Banking',
      );

      await service.createTemplate(
        name: 'Mobile Money Transfer',
        description: 'Transfer money using mobile money',
        serviceCode: '*456#',
        category: 'Mobile Money',
      );

      final searchResults1 = service.searchTemplates('banking');
      final searchResults2 = service.searchTemplates('money');
      final searchResults3 = service.searchTemplates('*456#');

      expect(searchResults1.length, 1);
      expect(searchResults1.first.name, 'Banking Balance Check');

      expect(searchResults2.length, 1);
      expect(searchResults2.first.name, 'Mobile Money Transfer');

      expect(searchResults3.length, 1);
      expect(searchResults3.first.serviceCode, '*456#');
    });

    test('should duplicate template', () async {
      await service.init();

      final original = await service.createTemplate(
        name: 'Original Template',
        description: 'Original description',
        serviceCode: '*123#',
        steps: [
          const TemplateStep(input: '1'),
        ],
        variables: {'pin': '1234'},
      );

      final duplicated = await service.duplicateTemplate(original.id);

      expect(duplicated.id, isNot(original.id));
      expect(duplicated.name, 'Original Template (Copy)');
      expect(duplicated.description, original.description);
      expect(duplicated.serviceCode, original.serviceCode);
      expect(duplicated.steps.length, original.steps.length);
      expect(duplicated.variables, original.variables);
      expect(service.templates.length, 2);
    });

    test('should duplicate template with custom name', () async {
      await service.init();

      final original = await service.createTemplate(
        name: 'Original Template',
        description: 'Original description',
        serviceCode: '*123#',
      );

      final duplicated = await service.duplicateTemplate(
        original.id,
        newName: 'Custom Copy Name',
      );

      expect(duplicated.name, 'Custom Copy Name');
    });

    test('should export template to JSON', () async {
      await service.init();

      final template = await service.createTemplate(
        name: 'Test Template',
        description: 'Test description',
        serviceCode: '*123#',
      );

      final json = service.exportTemplate(template.id);

      expect(json, isA<Map<String, dynamic>>());
      expect(json['id'], template.id);
      expect(json['name'], template.name);
    });

    test('should import template from JSON', () async {
      await service.init();

      final json = {
        'id': 'imported-id',
        'name': 'Imported Template',
        'description': 'Imported description',
        'serviceCode': '*999#',
        'steps': [],
        'variables': {},
        'stepDelayMs': 2000,
        'createdAt': DateTime.now().toIso8601String(),
        'version': 1,
      };

      final imported = await service.importTemplate(json);

      expect(imported.id, isNot('imported-id')); // Should get new ID
      expect(imported.name, 'Imported Template');
      expect(imported.description, 'Imported description');
      expect(service.templates.length, 1);
    });

    test('should validate templates', () async {
      await service.init();

      final validTemplate = await service.createTemplate(
        name: 'Valid Template',
        description: 'Valid description',
        serviceCode: '*123#',
        steps: [
          const TemplateStep(input: '1'),
        ],
      );

      final invalidTemplate = SessionTemplate(
        id: 'invalid-id',
        name: '', // empty name
        description: 'Invalid description',
        serviceCode: '*123#',
        steps: [],
        variables: {},
        createdAt: DateTime.now(),
      );

      expect(service.validateTemplate(validTemplate), true);
      expect(service.validateTemplate(invalidTemplate), false);
    });

    test('should get statistics', () async {
      await service.init();

      await service.createTemplate(
        name: 'Template 1',
        description: 'Description 1',
        serviceCode: '*123#',
        category: 'Banking',
        steps: [const TemplateStep(input: '1')],
      );

      await service.createTemplate(
        name: 'Template 2',
        description: 'Description 2',
        serviceCode: '*456#',
        category: 'Mobile Money',
        steps: [
          const TemplateStep(input: '1'),
          const TemplateStep(input: '2'),
        ],
      );

      final stats = service.getStatistics();

      expect(stats['totalTemplates'], 2);
      expect(stats['validTemplates'], 2);
      expect(stats['invalidTemplates'], 0);
      expect(stats['categories'], 2);
      expect(stats['averageStepsPerTemplate'], 1.5);
    });

    test('should clear all templates', () async {
      await service.init();

      await service.createTemplate(
        name: 'Template 1',
        description: 'Description 1',
        serviceCode: '*123#',
      );

      await service.createTemplate(
        name: 'Template 2',
        description: 'Description 2',
        serviceCode: '*456#',
      );

      expect(service.templates.length, 2);

      await service.clearAllTemplates();

      expect(service.templates, isEmpty);
    });
  });
}