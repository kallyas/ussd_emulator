import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ussd_emulator/providers/template_provider.dart';
import 'package:ussd_emulator/providers/ussd_provider.dart';
import 'package:ussd_emulator/models/session_template.dart';
import 'package:ussd_emulator/models/template_step.dart';

void main() {
  group('TemplateProvider', () {
    late TemplateProvider templateProvider;
    late UssdProvider ussdProvider;

    setUp(() {
      // Mock SharedPreferences for testing
      SharedPreferences.setMockInitialValues({});
      templateProvider = TemplateProvider();
      ussdProvider = UssdProvider();
    });

    test('should initialize with default values', () {
      expect(templateProvider.isLoading, false);
      expect(templateProvider.error, null);
      expect(templateProvider.templates, isEmpty);
      expect(templateProvider.isInitialized, false);
      expect(templateProvider.isExecuting, false);
    });

    test('should initialize successfully', () async {
      await ussdProvider.init();
      await templateProvider.init(ussdProvider);

      expect(templateProvider.isInitialized, true);
      expect(templateProvider.isLoading, false);
      expect(templateProvider.error, null);
    });

    test('should create template successfully', () async {
      await ussdProvider.init();
      await templateProvider.init(ussdProvider);

      final template = await templateProvider.createTemplate(
        name: 'Test Template',
        description: 'Test description',
        serviceCode: '*123#',
        category: 'Banking',
      );

      expect(template, isNotNull);
      expect(template!.name, 'Test Template');
      expect(template.category, 'Banking');
      expect(templateProvider.templates.length, greaterThan(0));
    });

    test('should update template successfully', () async {
      await ussdProvider.init();
      await templateProvider.init(ussdProvider);

      final created = await templateProvider.createTemplate(
        name: 'Original Template',
        description: 'Original description',
        serviceCode: '*123#',
      );

      expect(created, isNotNull);

      final updated = created!.copyWith(
        name: 'Updated Template',
        description: 'Updated description',
      );

      final success = await templateProvider.updateTemplate(
        created.id,
        updated,
      );

      expect(success, true);
      final retrieved = templateProvider.getTemplate(created.id);
      expect(retrieved, isNotNull);
      expect(retrieved!.name, 'Updated Template');
      expect(retrieved.description, 'Updated description');
    });

    test('should delete template successfully', () async {
      await ussdProvider.init();
      await templateProvider.init(ussdProvider);

      final created = await templateProvider.createTemplate(
        name: 'Test Template',
        description: 'Test description',
        serviceCode: '*123#',
      );

      expect(created, isNotNull);

      final initialCount = templateProvider.templates.length;
      final success = await templateProvider.deleteTemplate(created!.id);

      expect(success, true);
      expect(templateProvider.templates.length, initialCount - 1);
      expect(templateProvider.getTemplate(created.id), null);
    });

    test('should duplicate template successfully', () async {
      await ussdProvider.init();
      await templateProvider.init(ussdProvider);

      final original = await templateProvider.createTemplate(
        name: 'Original Template',
        description: 'Original description',
        serviceCode: '*123#',
      );

      expect(original, isNotNull);

      final duplicated = await templateProvider.duplicateTemplate(original!.id);

      expect(duplicated, isNotNull);
      expect(duplicated!.id, isNot(original.id));
      expect(duplicated.name, 'Original Template (Copy)');
      expect(duplicated.description, original.description);
      expect(duplicated.serviceCode, original.serviceCode);
    });

    test('should search templates correctly', () async {
      await ussdProvider.init();
      await templateProvider.init(ussdProvider);

      await templateProvider.createTemplate(
        name: 'Banking Template',
        description: 'Banking operations',
        serviceCode: '*123#',
        category: 'Banking',
      );

      await templateProvider.createTemplate(
        name: 'Mobile Money Template',
        description: 'Mobile money operations',
        serviceCode: '*456#',
        category: 'Mobile Money',
      );

      // Search by name
      templateProvider.searchTemplates('banking');
      expect(templateProvider.templates.length, 1);
      expect(templateProvider.templates.first.name, contains('Banking'));

      // Search by service code
      templateProvider.searchTemplates('*456');
      expect(templateProvider.templates.length, 1);
      expect(templateProvider.templates.first.serviceCode, contains('*456'));

      // Clear search
      templateProvider.searchTemplates('');
      expect(templateProvider.templates.length, greaterThan(1));
    });

    test('should filter by category correctly', () async {
      await ussdProvider.init();
      await templateProvider.init(ussdProvider);

      await templateProvider.createTemplate(
        name: 'Banking Template',
        description: 'Banking operations',
        serviceCode: '*123#',
        category: 'Banking',
      );

      await templateProvider.createTemplate(
        name: 'Mobile Money Template',
        description: 'Mobile money operations',
        serviceCode: '*456#',
        category: 'Mobile Money',
      );

      await templateProvider.createTemplate(
        name: 'Uncategorized Template',
        description: 'No category',
        serviceCode: '*789#',
      );

      // Filter by Banking category
      templateProvider.filterByCategory('Banking');
      expect(templateProvider.templates.length, 1);
      expect(templateProvider.templates.first.category, 'Banking');

      // Filter by null category (uncategorized)
      templateProvider.filterByCategory(null);
      expect(templateProvider.templates.length, 1);
      expect(templateProvider.templates.first.category, null);

      // Clear filters
      templateProvider.clearFilters();
      expect(templateProvider.templates.length, greaterThan(2));
    });

    test('should validate templates correctly', () async {
      await ussdProvider.init();
      await templateProvider.init(ussdProvider);

      final validTemplate = SessionTemplate(
        id: 'valid-id',
        name: 'Valid Template',
        description: 'Valid description',
        serviceCode: '*123#',
        steps: [const TemplateStep(input: '1')],
        variables: {},
        createdAt: DateTime.now(),
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

      expect(templateProvider.validateTemplate(validTemplate), true);
      expect(templateProvider.validateTemplate(invalidTemplate), false);
    });

    test('should export template to JSON', () async {
      await ussdProvider.init();
      await templateProvider.init(ussdProvider);

      final template = await templateProvider.createTemplate(
        name: 'Export Template',
        description: 'Template for export',
        serviceCode: '*123#',
      );

      expect(template, isNotNull);

      final json = templateProvider.exportTemplate(template!.id);

      expect(json, isNotNull);
      expect(json!['id'], template.id);
      expect(json['name'], template.name);
      expect(json['serviceCode'], template.serviceCode);
    });

    test('should import template from JSON', () async {
      await ussdProvider.init();
      await templateProvider.init(ussdProvider);

      final json = {
        'id': 'imported-id',
        'name': 'Imported Template',
        'description': 'Imported description',
        'serviceCode': '*999#',
        'steps': [
          {
            'input': '1',
            'description': 'First step',
            'expectedResponse': null,
            'customDelayMs': null,
            'waitForResponse': true,
            'isCritical': false,
          },
        ],
        'variables': {'pin': '1234'},
        'stepDelayMs': 2000,
        'createdAt': DateTime.now().toIso8601String(),
        'version': 1,
      };

      final initialCount = templateProvider.templates.length;
      final imported = await templateProvider.importTemplate(json);

      expect(imported, isNotNull);
      expect(imported!.name, 'Imported Template');
      expect(imported.serviceCode, '*999#');
      expect(imported.steps.length, 1);
      expect(imported.variables['pin'], '1234');
      expect(templateProvider.templates.length, initialCount + 1);
    });

    test('should get template statistics', () async {
      await ussdProvider.init();
      await templateProvider.init(ussdProvider);

      await templateProvider.createTemplate(
        name: 'Template 1',
        description: 'Description 1',
        serviceCode: '*123#',
        category: 'Banking',
      );

      await templateProvider.createTemplate(
        name: 'Template 2',
        description: 'Description 2',
        serviceCode: '*456#',
        category: 'Mobile Money',
      );

      final stats = templateProvider.getStatistics();

      expect(stats['totalTemplates'], greaterThanOrEqualTo(2));
      expect(stats['categories'], greaterThanOrEqualTo(2));
      expect(stats, containsKey('validTemplates'));
      expect(stats, containsKey('averageStepsPerTemplate'));
    });

    test('should handle errors gracefully', () async {
      await ussdProvider.init();
      await templateProvider.init(ussdProvider);

      // Try to update non-existent template
      final nonExistentTemplate = SessionTemplate(
        id: 'non-existent',
        name: 'Non-existent',
        description: 'Does not exist',
        serviceCode: '*999#',
        steps: [],
        variables: {},
        createdAt: DateTime.now(),
      );

      final success = await templateProvider.updateTemplate(
        'non-existent',
        nonExistentTemplate,
      );

      expect(success, false);
      expect(templateProvider.error, isNotNull);

      // Clear error
      templateProvider.clearError();
      expect(templateProvider.error, null);
    });

    test('should clear filters correctly', () async {
      await ussdProvider.init();
      await templateProvider.init(ussdProvider);

      // Set search and category filters
      templateProvider.searchTemplates('test');
      templateProvider.filterByCategory('Banking');

      expect(templateProvider.searchQuery, 'test');
      expect(templateProvider.selectedCategory, 'Banking');

      // Clear filters
      templateProvider.clearFilters();

      expect(templateProvider.searchQuery, '');
      expect(templateProvider.selectedCategory, null);
    });
  });
}
