import 'package:json_annotation/json_annotation.dart';
import 'template_step.dart';

part 'session_template.g.dart';

@JsonSerializable()
class SessionTemplate {
  final String id;
  final String name;
  final String description;
  final String serviceCode;
  final List<TemplateStep> steps;
  final Map<String, String> variables;
  final int stepDelayMs;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? category;
  final int version;

  const SessionTemplate({
    required this.id,
    required this.name,
    required this.description,
    required this.serviceCode,
    required this.steps,
    required this.variables,
    this.stepDelayMs = 2000,
    required this.createdAt,
    this.updatedAt,
    this.category,
    this.version = 1,
  });

  factory SessionTemplate.fromJson(Map<String, dynamic> json) =>
      _$SessionTemplateFromJson(json);

  Map<String, dynamic> toJson() => _$SessionTemplateToJson(this);

  SessionTemplate copyWith({
    String? id,
    String? name,
    String? description,
    String? serviceCode,
    List<TemplateStep>? steps,
    Map<String, String>? variables,
    int? stepDelayMs,
    DateTime? createdAt,
    Object? updatedAt = const Object(),
    String? category,
    int? version,
  }) {
    return SessionTemplate(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      serviceCode: serviceCode ?? this.serviceCode,
      steps: steps ?? this.steps,
      variables: variables ?? this.variables,
      stepDelayMs: stepDelayMs ?? this.stepDelayMs,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt == const Object() ? this.updatedAt : updatedAt as DateTime?,
      category: category ?? this.category,
      version: version ?? this.version,
    );
  }

  /// Get the step delay as a Duration
  Duration get stepDelay => Duration(milliseconds: stepDelayMs);

  /// Process variables in a string, replacing ${variable} with actual values
  String processVariables(String input) {
    String result = input;
    for (final entry in variables.entries) {
      result = result.replaceAll('\${${entry.key}}', entry.value);
    }
    return result;
  }

  /// Check if the template is valid for execution
  bool get isValid {
    if (name.trim().isEmpty || serviceCode.trim().isEmpty) {
      return false;
    }
    if (steps.isEmpty) {
      return false;
    }
    // Check if all variables referenced in steps are defined
    final allInputs = steps.map((s) => s.input).join(' ');
    final variableReferences = RegExp(r'\$\{(\w+)\}').allMatches(allInputs);
    for (final match in variableReferences) {
      final variableName = match.group(1);
      if (variableName != null && !variables.containsKey(variableName)) {
        return false;
      }
    }
    return true;
  }

  /// Get all variable references used in the template
  Set<String> get usedVariables {
    final Set<String> used = {};
    for (final step in steps) {
      final matches = RegExp(r'\$\{(\w+)\}').allMatches(step.input);
      for (final match in matches) {
        final variableName = match.group(1);
        if (variableName != null) {
          used.add(variableName);
        }
      }
    }
    return used;
  }
}