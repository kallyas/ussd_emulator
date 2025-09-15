import 'package:json_annotation/json_annotation.dart';

part 'template_step.g.dart';

@JsonSerializable()
class TemplateStep {
  final String input;
  final String? expectedResponse;
  final String? description;
  final int? customDelayMs;
  final bool waitForResponse;
  final bool isCritical;

  const TemplateStep({
    required this.input,
    this.expectedResponse,
    this.description,
    this.customDelayMs,
    this.waitForResponse = true,
    this.isCritical = false,
  });

  factory TemplateStep.fromJson(Map<String, dynamic> json) =>
      _$TemplateStepFromJson(json);

  Map<String, dynamic> toJson() => _$TemplateStepToJson(this);

  TemplateStep copyWith({
    String? input,
    String? expectedResponse,
    String? description,
    Object? customDelayMs = const Object(),
    bool? waitForResponse,
    bool? isCritical,
  }) {
    return TemplateStep(
      input: input ?? this.input,
      expectedResponse: expectedResponse ?? this.expectedResponse,
      description: description ?? this.description,
      customDelayMs: customDelayMs == const Object()
          ? this.customDelayMs
          : customDelayMs as int?,
      waitForResponse: waitForResponse ?? this.waitForResponse,
      isCritical: isCritical ?? this.isCritical,
    );
  }

  /// Get the custom delay as a Duration, or null if not set
  Duration? get customDelay =>
      customDelayMs != null ? Duration(milliseconds: customDelayMs!) : null;

  /// Check if this step has a custom delay
  bool get hasCustomDelay => customDelayMs != null;

  /// Check if this step expects a response
  bool get hasExpectedResponse =>
      expectedResponse != null && expectedResponse!.isNotEmpty;
}
