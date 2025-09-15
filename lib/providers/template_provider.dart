import 'package:flutter/foundation.dart';
import '../models/session_template.dart';
import '../models/automation_result.dart';
import '../services/template_service.dart';
import '../services/automation_engine.dart';
import '../providers/ussd_provider.dart';

class TemplateProvider with ChangeNotifier {
  final TemplateService _templateService = TemplateService();
  late final UssdAutomationEngine _automationEngine;

  bool _isInitialized = false;
  bool _isLoading = false;
  String? _error;
  String _searchQuery = '';
  String? _selectedCategory;
  bool _isExecuting = false;
  AutomationResult? _lastExecutionResult;
  String _automationStatus = '';

  // Getters
  bool get isInitialized => _isInitialized;
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<SessionTemplate> get templates => _getFilteredTemplates();
  List<String> get categories => _templateService.getCategories();
  String get searchQuery => _searchQuery;
  String? get selectedCategory => _selectedCategory;
  bool get isExecuting => _isExecuting;
  AutomationResult? get lastExecutionResult => _lastExecutionResult;
  String get automationStatus => _automationStatus;

  // Template counts
  int get totalTemplates => _templateService.templates.length;
  int get filteredTemplatesCount => templates.length;

  Future<void> init(UssdProvider ussdProvider) async {
    if (_isInitialized) return;

    _setLoading(true);
    try {
      await _templateService.init();
      _automationEngine = UssdAutomationEngine(ussdProvider);
      _isInitialized = true;
      _updateAutomationStatus();
      _clearError();
    } catch (e) {
      _setError('Failed to initialize templates: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  /// Create a new template
  Future<SessionTemplate?> createTemplate({
    required String name,
    required String description,
    required String serviceCode,
    String? category,
    int stepDelayMs = 2000,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final template = await _templateService.createTemplate(
        name: name,
        description: description,
        serviceCode: serviceCode,
        category: category,
        stepDelayMs: stepDelayMs,
      );
      notifyListeners();
      return template;
    } catch (e) {
      _setError('Failed to create template: ${e.toString()}');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  /// Update an existing template
  Future<bool> updateTemplate(
    String id,
    SessionTemplate updatedTemplate,
  ) async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _templateService.updateTemplate(id, updatedTemplate);
      if (result != null) {
        notifyListeners();
        return true;
      }
      _setError('Template not found');
      return false;
    } catch (e) {
      _setError('Failed to update template: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Delete a template
  Future<bool> deleteTemplate(String id) async {
    _setLoading(true);
    _clearError();

    try {
      final success = await _templateService.deleteTemplate(id);
      if (success) {
        notifyListeners();
      } else {
        _setError('Template not found');
      }
      return success;
    } catch (e) {
      _setError('Failed to delete template: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Get a template by ID
  SessionTemplate? getTemplate(String id) {
    return _templateService.getTemplate(id);
  }

  /// Duplicate a template
  Future<SessionTemplate?> duplicateTemplate(
    String id, {
    String? newName,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final duplicated = await _templateService.duplicateTemplate(
        id,
        newName: newName,
      );
      notifyListeners();
      return duplicated;
    } catch (e) {
      _setError('Failed to duplicate template: ${e.toString()}');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  /// Execute a template
  Future<AutomationResult?> executeTemplate(
    String templateId, {
    Map<String, String>? overrideVariables,
  }) async {
    final template = getTemplate(templateId);
    if (template == null) {
      _setError('Template not found');
      return null;
    }

    if (!_automationEngine.canRun()) {
      _setError('Cannot run automation: ${_automationEngine.getStatus()}');
      return null;
    }

    _setExecuting(true);
    _clearError();

    try {
      final result = await _automationEngine.runTemplate(
        template,
        overrideVariables: overrideVariables,
        onStepUpdate: (stepIndex, status) {
          _automationStatus = 'Step ${stepIndex + 1}: $status';
          notifyListeners();
        },
        onLog: (message) {
          // Could emit logs via a stream if needed
          debugPrint('Automation: $message');
        },
      );

      _lastExecutionResult = result;
      return result;
    } catch (e) {
      _setError('Failed to execute template: ${e.toString()}');
      return null;
    } finally {
      _setExecuting(false);
      _updateAutomationStatus();
    }
  }

  /// Execute multiple templates in batch
  Future<List<AutomationResult>?> executeBatch(
    List<String> templateIds, {
    Map<String, String>? globalVariables,
    bool stopOnFirstFailure = false,
  }) async {
    final templates = templateIds
        .map((id) => getTemplate(id))
        .where((t) => t != null)
        .cast<SessionTemplate>()
        .toList();

    if (templates.isEmpty) {
      _setError('No valid templates found');
      return null;
    }

    if (!_automationEngine.canRun()) {
      _setError('Cannot run automation: ${_automationEngine.getStatus()}');
      return null;
    }

    _setExecuting(true);
    _clearError();

    try {
      final results = await _automationEngine.runBatch(
        templates,
        globalVariables: globalVariables,
        stopOnFirstFailure: stopOnFirstFailure,
        onTemplateUpdate: (templateIndex, status) {
          _automationStatus = 'Template ${templateIndex + 1}: $status';
          notifyListeners();
        },
        onStepUpdate: (templateIndex, stepIndex, status) {
          _automationStatus =
              'Template ${templateIndex + 1}, Step ${stepIndex + 1}: $status';
          notifyListeners();
        },
        onLog: (message) {
          debugPrint('Batch Automation: $message');
        },
      );

      return results;
    } catch (e) {
      _setError('Failed to execute batch: ${e.toString()}');
      return null;
    } finally {
      _setExecuting(false);
      _updateAutomationStatus();
    }
  }

  /// Stop current execution
  void stopExecution() {
    if (_isExecuting) {
      _automationEngine.stopExecution();
      _setExecuting(false);
      _updateAutomationStatus();
    }
  }

  /// Import template from JSON
  Future<SessionTemplate?> importTemplate(Map<String, dynamic> json) async {
    _setLoading(true);
    _clearError();

    try {
      final template = await _templateService.importTemplate(json);
      notifyListeners();
      return template;
    } catch (e) {
      _setError('Failed to import template: ${e.toString()}');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  /// Export template to JSON
  Map<String, dynamic>? exportTemplate(String id) {
    try {
      return _templateService.exportTemplate(id);
    } catch (e) {
      _setError('Failed to export template: ${e.toString()}');
      return null;
    }
  }

  /// Search templates
  void searchTemplates(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  /// Filter by category
  void filterByCategory(String? category) {
    _selectedCategory = category;
    notifyListeners();
  }

  /// Clear search and filters
  void clearFilters() {
    _searchQuery = '';
    _selectedCategory = null;
    notifyListeners();
  }

  /// Get template statistics
  Map<String, dynamic> getStatistics() {
    return _templateService.getStatistics();
  }

  /// Validate a template
  bool validateTemplate(SessionTemplate template) {
    return _templateService.validateTemplate(template);
  }

  List<SessionTemplate> _getFilteredTemplates() {
    List<SessionTemplate> filtered = _templateService.templates;

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = _templateService.searchTemplates(_searchQuery);
    }

    // Apply category filter
    if (_selectedCategory != null) {
      filtered = filtered
          .where((t) => t.category == _selectedCategory)
          .toList();
    }

    return filtered;
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }

  void _setExecuting(bool executing) {
    _isExecuting = executing;
    notifyListeners();
  }

  void _updateAutomationStatus() {
    _automationStatus = _automationEngine.getStatus();
    notifyListeners();
  }

  void clearError() {
    _clearError();
  }

  void clearLastExecutionResult() {
    _lastExecutionResult = null;
    notifyListeners();
  }
}
