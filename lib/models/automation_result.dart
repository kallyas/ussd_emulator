import 'package:json_annotation/json_annotation.dart';
import 'template_step.dart';

part 'automation_result.g.dart';

@JsonSerializable()
class AutomationResult {
  final String templateId;
  final String templateName;
  final DateTime startTime;
  final DateTime? endTime;
  final List<StepResult> stepResults;
  final bool isCompleted;
  final bool isSuccessful;
  final String? errorMessage;

  const AutomationResult({
    required this.templateId,
    required this.templateName,
    required this.startTime,
    this.endTime,
    required this.stepResults,
    required this.isCompleted,
    required this.isSuccessful,
    this.errorMessage,
  });

  factory AutomationResult.fromJson(Map<String, dynamic> json) =>
      _$AutomationResultFromJson(json);

  Map<String, dynamic> toJson() => _$AutomationResultToJson(this);

  AutomationResult copyWith({
    String? templateId,
    String? templateName,
    DateTime? startTime,
    Object? endTime = const Object(),
    List<StepResult>? stepResults,
    bool? isCompleted,
    bool? isSuccessful,
    String? errorMessage,
  }) {
    return AutomationResult(
      templateId: templateId ?? this.templateId,
      templateName: templateName ?? this.templateName,
      startTime: startTime ?? this.startTime,
      endTime: endTime == const Object() ? this.endTime : endTime as DateTime?,
      stepResults: stepResults ?? this.stepResults,
      isCompleted: isCompleted ?? this.isCompleted,
      isSuccessful: isSuccessful ?? this.isSuccessful,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  /// Get the total execution duration
  Duration? get executionDuration => endTime?.difference(startTime);

  /// Get the number of successful steps
  int get successfulSteps => stepResults.where((s) => s.isSuccessful).length;

  /// Get the number of failed steps
  int get failedSteps => stepResults.where((s) => !s.isSuccessful).length;

  /// Get the total number of steps
  int get totalSteps => stepResults.length;

  /// Get the success rate as a percentage
  double get successRate => totalSteps > 0 ? (successfulSteps / totalSteps) * 100 : 0.0;

  /// Check if the result has any errors
  bool get hasErrors => !isSuccessful || stepResults.any((s) => !s.isSuccessful);

  /// Get all error messages from failed steps
  List<String> get allErrorMessages {
    final errors = <String>[];
    if (errorMessage != null) {
      errors.add(errorMessage!);
    }
    for (final result in stepResults) {
      if (!result.isSuccessful && result.errorMessage != null) {
        errors.add('Step ${result.stepIndex + 1}: ${result.errorMessage}');
      }
    }
    return errors;
  }
}

@JsonSerializable()
class StepResult {
  final int stepIndex;
  final TemplateStep step;
  final DateTime startTime;
  final DateTime? endTime;
  final bool isSuccessful;
  final String? errorMessage;
  final String? actualResponse;
  final bool responseMatched;

  const StepResult({
    required this.stepIndex,
    required this.step,
    required this.startTime,
    this.endTime,
    required this.isSuccessful,
    this.errorMessage,
    this.actualResponse,
    this.responseMatched = true,
  });

  factory StepResult.fromJson(Map<String, dynamic> json) =>
      _$StepResultFromJson(json);

  Map<String, dynamic> toJson() => _$StepResultToJson(this);

  StepResult copyWith({
    int? stepIndex,
    TemplateStep? step,
    DateTime? startTime,
    Object? endTime = const Object(),
    bool? isSuccessful,
    String? errorMessage,
    String? actualResponse,
    bool? responseMatched,
  }) {
    return StepResult(
      stepIndex: stepIndex ?? this.stepIndex,
      step: step ?? this.step,
      startTime: startTime ?? this.startTime,
      endTime: endTime == const Object() ? this.endTime : endTime as DateTime?,
      isSuccessful: isSuccessful ?? this.isSuccessful,
      errorMessage: errorMessage ?? this.errorMessage,
      actualResponse: actualResponse ?? this.actualResponse,
      responseMatched: responseMatched ?? this.responseMatched,
    );
  }

  /// Get the execution duration for this step
  Duration? get executionDuration => endTime?.difference(startTime);

  /// Check if this step has a response validation issue
  bool get hasResponseIssue => step.hasExpectedResponse && !responseMatched;
}