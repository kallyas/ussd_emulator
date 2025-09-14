import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import '../models/session_template.dart';
import '../models/template_step.dart';

class TemplateService {
  static const String _templatesKey = 'session_templates';
  static const String _templatesFolderName = 'templates';
  
  final Uuid _uuid = const Uuid();
  List<SessionTemplate> _templates = [];

  List<SessionTemplate> get templates => List.unmodifiable(_templates);

  Future<void> init() async {
    await _loadTemplates();
  }

  /// Create a new template
  Future<SessionTemplate> createTemplate({
    required String name,
    required String description,
    required String serviceCode,
    List<TemplateStep>? steps,
    Map<String, String>? variables,
    int stepDelayMs = 2000,
    String? category,
  }) async {
    final template = SessionTemplate(
      id: _uuid.v4(),
      name: name,
      description: description,
      serviceCode: serviceCode,
      steps: steps ?? [],
      variables: variables ?? {},
      stepDelayMs: stepDelayMs,
      createdAt: DateTime.now(),
      category: category,
    );

    _templates.add(template);
    await _saveTemplates();
    return template;
  }

  /// Update an existing template
  Future<SessionTemplate?> updateTemplate(String id, SessionTemplate updatedTemplate) async {
    final index = _templates.indexWhere((t) => t.id == id);
    if (index == -1) return null;

    final template = updatedTemplate.copyWith(
      id: id,
      updatedAt: DateTime.now(),
    );

    _templates[index] = template;
    await _saveTemplates();
    return template;
  }

  /// Delete a template
  Future<bool> deleteTemplate(String id) async {
    final index = _templates.indexWhere((t) => t.id == id);
    if (index == -1) return false;

    _templates.removeAt(index);
    await _saveTemplates();
    return true;
  }

  /// Get a template by ID
  SessionTemplate? getTemplate(String id) {
    try {
      return _templates.firstWhere((t) => t.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get templates by category
  List<SessionTemplate> getTemplatesByCategory(String? category) {
    if (category == null) {
      return _templates.where((t) => t.category == null).toList();
    }
    return _templates.where((t) => t.category == category).toList();
  }

  /// Get all unique categories
  List<String> getCategories() {
    final categories = _templates
        .where((t) => t.category != null)
        .map((t) => t.category!)
        .toSet()
        .toList();
    categories.sort();
    return categories;
  }

  /// Search templates by name or description
  List<SessionTemplate> searchTemplates(String query) {
    if (query.isEmpty) return templates;
    
    final lowerQuery = query.toLowerCase();
    return _templates.where((template) {
      return template.name.toLowerCase().contains(lowerQuery) ||
             template.description.toLowerCase().contains(lowerQuery) ||
             template.serviceCode.toLowerCase().contains(lowerQuery) ||
             (template.category?.toLowerCase().contains(lowerQuery) ?? false);
    }).toList();
  }

  /// Duplicate a template with a new ID and name
  Future<SessionTemplate> duplicateTemplate(String id, {String? newName}) async {
    final original = getTemplate(id);
    if (original == null) {
      throw Exception('Template not found');
    }

    final duplicated = original.copyWith(
      id: _uuid.v4(),
      name: newName ?? '${original.name} (Copy)',
      createdAt: DateTime.now(),
      updatedAt: null,
      version: 1,
    );

    _templates.add(duplicated);
    await _saveTemplates();
    return duplicated;
  }

  /// Export a template to JSON
  Map<String, dynamic> exportTemplate(String id) {
    final template = getTemplate(id);
    if (template == null) {
      throw Exception('Template not found');
    }
    return template.toJson();
  }

  /// Import a template from JSON
  Future<SessionTemplate> importTemplate(Map<String, dynamic> json) async {
    try {
      final template = SessionTemplate.fromJson(json).copyWith(
        id: _uuid.v4(), // Generate new ID to avoid conflicts
        createdAt: DateTime.now(),
        updatedAt: null,
      );

      if (!template.isValid) {
        throw Exception('Invalid template data');
      }

      _templates.add(template);
      await _saveTemplates();
      return template;
    } catch (e) {
      throw Exception('Failed to import template: $e');
    }
  }

  /// Export all templates to a file
  Future<File> exportAllTemplates() async {
    final directory = await getApplicationDocumentsDirectory();
    final templatesDir = Directory('${directory.path}/$_templatesFolderName');
    if (!await templatesDir.exists()) {
      await templatesDir.create(recursive: true);
    }

    final file = File('${templatesDir.path}/templates_export_${DateTime.now().millisecondsSinceEpoch}.json');
    final exportData = {
      'version': '1.0',
      'exportDate': DateTime.now().toIso8601String(),
      'templates': _templates.map((t) => t.toJson()).toList(),
    };

    await file.writeAsString(jsonEncode(exportData));
    return file;
  }

  /// Import templates from a file
  Future<List<SessionTemplate>> importTemplatesFromFile(File file) async {
    try {
      final content = await file.readAsString();
      final data = jsonDecode(content);

      if (data is! Map<String, dynamic> || !data.containsKey('templates')) {
        throw Exception('Invalid file format');
      }

      final templatesData = data['templates'] as List<dynamic>;
      final importedTemplates = <SessionTemplate>[];

      for (final templateData in templatesData) {
        try {
          final template = SessionTemplate.fromJson(templateData).copyWith(
            id: _uuid.v4(), // Generate new ID
            createdAt: DateTime.now(),
            updatedAt: null,
          );

          if (template.isValid) {
            _templates.add(template);
            importedTemplates.add(template);
          }
        } catch (e) {
          // Skip invalid templates but continue with others
          continue;
        }
      }

      if (importedTemplates.isNotEmpty) {
        await _saveTemplates();
      }

      return importedTemplates;
    } catch (e) {
      throw Exception('Failed to import templates from file: $e');
    }
  }

  /// Validate a template
  bool validateTemplate(SessionTemplate template) {
    return template.isValid;
  }

  /// Get template statistics
  Map<String, dynamic> getStatistics() {
    final categories = getCategories();
    final totalTemplates = _templates.length;
    final validTemplates = _templates.where((t) => t.isValid).length;
    final averageSteps = totalTemplates > 0 
        ? _templates.map((t) => t.steps.length).reduce((a, b) => a + b) / totalTemplates
        : 0.0;

    return {
      'totalTemplates': totalTemplates,
      'validTemplates': validTemplates,
      'invalidTemplates': totalTemplates - validTemplates,
      'categories': categories.length,
      'averageStepsPerTemplate': averageSteps,
      'categoriesBreakdown': {
        for (final category in categories)
          category: getTemplatesByCategory(category).length,
        'uncategorized': getTemplatesByCategory(null).length,
      },
    };
  }

  /// Clear all templates
  Future<void> clearAllTemplates() async {
    _templates.clear();
    await _saveTemplates();
  }

  Future<void> _saveTemplates() async {
    final prefs = await SharedPreferences.getInstance();
    final templatesJson = jsonEncode(
      _templates.map((t) => t.toJson()).toList(),
    );
    await prefs.setString(_templatesKey, templatesJson);
  }

  Future<void> _loadTemplates() async {
    final prefs = await SharedPreferences.getInstance();
    final templatesJson = prefs.getString(_templatesKey);

    if (templatesJson != null) {
      try {
        final List<dynamic> templatesData = jsonDecode(templatesJson);
        _templates = templatesData
            .map((data) => SessionTemplate.fromJson(data))
            .toList();
      } catch (e) {
        _templates = [];
      }
    }
  }
}