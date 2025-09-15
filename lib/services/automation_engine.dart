import 'dart:async';
import '../models/session_template.dart';
import '../models/template_step.dart';
import '../models/automation_result.dart';
import '../providers/ussd_provider.dart';

class UssdAutomationEngine {
  final UssdProvider _ussdProvider;
  bool _isRunning = false;
  bool _shouldStop = false;

  UssdAutomationEngine(this._ussdProvider);

  bool get isRunning => _isRunning;

  /// Execute a single template
  Future<AutomationResult> runTemplate(
    SessionTemplate template, {
    Map<String, String>? overrideVariables,
    Function(int stepIndex, String status)? onStepUpdate,
    Function(String message)? onLog,
  }) async {
    if (_isRunning) {
      throw Exception('Automation is already running');
    }

    _isRunning = true;
    _shouldStop = false;

    final startTime = DateTime.now();
    final stepResults = <StepResult>[];
    AutomationResult? result;

    try {
      onLog?.call('Starting template execution: ${template.name}');

      // Validate template before execution
      if (!template.isValid) {
        throw Exception('Template validation failed');
      }

      // Merge override variables with template variables
      final effectiveVariables = Map<String, String>.from(template.variables);
      if (overrideVariables != null) {
        effectiveVariables.addAll(overrideVariables);
      }

      // Start the USSD session
      onLog?.call('Starting USSD session with ${template.serviceCode}');
      await _ussdProvider.startSession(
        phoneNumber: '+256700000000', // Default for automation
        serviceCode: template.serviceCode,
      );

      // Wait for session to be ready
      await Future.delayed(const Duration(milliseconds: 500));

      if (_ussdProvider.currentSession == null) {
        throw Exception('Failed to start USSD session');
      }

      // Execute each step
      for (int i = 0; i < template.steps.length && !_shouldStop; i++) {
        final step = template.steps[i];
        onStepUpdate?.call(i, 'executing');
        onLog?.call('Executing step ${i + 1}: ${step.description ?? step.input}');

        final stepResult = await _executeStep(
          step, 
          effectiveVariables, 
          i,
          template.stepDelay,
        );
        
        stepResults.add(stepResult);

        if (!stepResult.isSuccessful && step.isCritical) {
          onLog?.call('Critical step failed, stopping execution');
          break;
        }

        onStepUpdate?.call(i, stepResult.isSuccessful ? 'success' : 'failed');
      }

      final endTime = DateTime.now();
      final isSuccessful = stepResults.isNotEmpty && 
                          stepResults.every((r) => r.isSuccessful || !r.step.isCritical);

      result = AutomationResult(
        templateId: template.id,
        templateName: template.name,
        startTime: startTime,
        endTime: endTime,
        stepResults: stepResults,
        isCompleted: !_shouldStop,
        isSuccessful: isSuccessful,
      );

      onLog?.call('Template execution completed. Success: $isSuccessful');

    } catch (e) {
      final endTime = DateTime.now();
      result = AutomationResult(
        templateId: template.id,
        templateName: template.name,
        startTime: startTime,
        endTime: endTime,
        stepResults: stepResults,
        isCompleted: false,
        isSuccessful: false,
        errorMessage: e.toString(),
      );

      onLog?.call('Template execution failed: $e');
    } finally {
      _isRunning = false;
      _shouldStop = false;

      // End the session if it's still active
      if (_ussdProvider.currentSession?.isActive == true) {
        try {
          await _ussdProvider.endSession();
        } catch (e) {
          onLog?.call('Warning: Failed to end session: $e');
        }
      }
    }

    return result!;
  }

  /// Execute multiple templates in sequence
  Future<List<AutomationResult>> runBatch(
    List<SessionTemplate> templates, {
    Map<String, String>? globalVariables,
    bool stopOnFirstFailure = false,
    Function(int templateIndex, String status)? onTemplateUpdate,
    Function(int templateIndex, int stepIndex, String status)? onStepUpdate,
    Function(String message)? onLog,
  }) async {
    if (_isRunning) {
      throw Exception('Automation is already running');
    }

    final results = <AutomationResult>[];
    onLog?.call('Starting batch execution of ${templates.length} templates');

    for (int i = 0; i < templates.length && !_shouldStop; i++) {
      final template = templates[i];
      onTemplateUpdate?.call(i, 'executing');
      onLog?.call('Executing template ${i + 1}/${templates.length}: ${template.name}');

      try {
        final result = await runTemplate(
          template,
          overrideVariables: globalVariables,
          onStepUpdate: (stepIndex, status) => onStepUpdate?.call(i, stepIndex, status),
          onLog: onLog,
        );

        results.add(result);
        onTemplateUpdate?.call(i, result.isSuccessful ? 'success' : 'failed');

        if (!result.isSuccessful && stopOnFirstFailure) {
          onLog?.call('Template failed and stopOnFirstFailure is enabled, stopping batch');
          break;
        }

        // Brief pause between templates
        await Future.delayed(const Duration(milliseconds: 1000));

      } catch (e) {
        onLog?.call('Template execution error: $e');
        onTemplateUpdate?.call(i, 'error');
        
        if (stopOnFirstFailure) {
          break;
        }
      }
    }

    onLog?.call('Batch execution completed. ${results.length} templates executed');
    return results;
  }

  /// Stop the current automation
  void stopExecution() {
    if (_isRunning) {
      _shouldStop = true;
    }
  }

  /// Execute a single step
  Future<StepResult> _executeStep(
    TemplateStep step, 
    Map<String, String> variables,
    int stepIndex,
    Duration defaultDelay,
  ) async {
    final stepStartTime = DateTime.now();
    
    try {
      // Process variables in the input
      final processedInput = _processVariables(step.input, variables);
      
      // Send the input
      await _ussdProvider.sendUssdInput(processedInput);

      // Wait for response
      if (step.waitForResponse) {
        await _waitForResponse();
      }

      // Apply delay
      final delay = step.customDelay ?? defaultDelay;
      await Future.delayed(delay);

      // Check for errors
      if (_ussdProvider.error != null) {
        return StepResult(
          stepIndex: stepIndex,
          step: step,
          startTime: stepStartTime,
          endTime: DateTime.now(),
          isSuccessful: false,
          errorMessage: _ussdProvider.error,
        );
      }

      // Validate response if expected
      bool responseMatched = true;
      String? actualResponse;
      
      if (step.hasExpectedResponse) {
        actualResponse = _getLastResponse();
        if (actualResponse != null) {
          final expectedResponse = _processVariables(step.expectedResponse!, variables);
          responseMatched = _validateResponse(actualResponse, expectedResponse);
        } else {
          responseMatched = false;
        }
      }

      return StepResult(
        stepIndex: stepIndex,
        step: step,
        startTime: stepStartTime,
        endTime: DateTime.now(),
        isSuccessful: true,
        actualResponse: actualResponse,
        responseMatched: responseMatched,
      );

    } catch (e) {
      return StepResult(
        stepIndex: stepIndex,
        step: step,
        startTime: stepStartTime,
        endTime: DateTime.now(),
        isSuccessful: false,
        errorMessage: e.toString(),
      );
    }
  }

  /// Process variables in a string
  String _processVariables(String input, Map<String, String> variables) {
    String result = input;
    for (final entry in variables.entries) {
      result = result.replaceAll('\${${entry.key}}', entry.value);
    }
    return result;
  }

  /// Wait for USSD response
  Future<void> _waitForResponse() async {
    const maxWaitTime = Duration(seconds: 30);
    const pollInterval = Duration(milliseconds: 100);
    
    final startTime = DateTime.now();
    int initialResponseCount = _ussdProvider.currentSession?.responses.length ?? 0;

    while (DateTime.now().difference(startTime) < maxWaitTime) {
      if (_shouldStop) {
        throw Exception('Execution stopped by user');
      }

      // Check if we got a new response
      final currentResponseCount = _ussdProvider.currentSession?.responses.length ?? 0;
      if (currentResponseCount > initialResponseCount) {
        return;
      }

      // Check for errors
      if (_ussdProvider.error != null) {
        throw Exception(_ussdProvider.error!);
      }

      await Future.delayed(pollInterval);
    }

    throw Exception('Timeout waiting for response');
  }

  /// Get the last response text
  String? _getLastResponse() {
    final session = _ussdProvider.currentSession;
    if (session == null || session.responses.isEmpty) {
      return null;
    }
    return session.responses.last.message;
  }

  /// Validate response against expected text
  bool _validateResponse(String actualResponse, String expectedResponse) {
    // Simple contains check - can be enhanced with regex or fuzzy matching
    return actualResponse.toLowerCase().contains(expectedResponse.toLowerCase());
  }

  /// Check if automation can run
  bool canRun() {
    return !_isRunning && 
           _ussdProvider.isInitialized && 
           _ussdProvider.activeEndpointConfig != null;
  }

  /// Get current automation status
  String getStatus() {
    if (!_ussdProvider.isInitialized) {
      return 'Provider not initialized';
    }
    if (_ussdProvider.activeEndpointConfig == null) {
      return 'No active endpoint configured';
    }
    if (_isRunning) {
      return 'Running';
    }
    return 'Ready';
  }
}