import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/session_template.dart';
import '../models/automation_result.dart';
import '../providers/template_provider.dart';
import '../providers/ussd_provider.dart';
import '../utils/design_system.dart';
import '../l10n/generated/app_localizations.dart';

class TemplateExecutionScreen extends StatefulWidget {
  final SessionTemplate template;

  const TemplateExecutionScreen({super.key, required this.template});

  @override
  State<TemplateExecutionScreen> createState() =>
      _TemplateExecutionScreenState();
}

class _TemplateExecutionScreenState extends State<TemplateExecutionScreen> {
  final Map<String, TextEditingController> _variableControllers = {};
  AutomationResult? _executionResult;
  bool _isExecuting = false;

  @override
  void initState() {
    super.initState();
    _initializeVariableControllers();
  }

  @override
  void dispose() {
    for (final controller in _variableControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _initializeVariableControllers() {
    for (final entry in widget.template.variables.entries) {
      _variableControllers[entry.key] = TextEditingController(
        text: entry.value,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.executeTemplate),
        subtitle: Text(widget.template.name),
      ),
      body: Consumer2<TemplateProvider, UssdProvider>(
        builder: (context, templateProvider, ussdProvider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(UssdDesignSystem.spacingL),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTemplateInfoCard(context),
                const SizedBox(height: UssdDesignSystem.spacingL),
                if (widget.template.variables.isNotEmpty) ...[
                  _buildVariablesSection(context),
                  const SizedBox(height: UssdDesignSystem.spacingL),
                ],
                _buildStepsPreview(context),
                const SizedBox(height: UssdDesignSystem.spacingL),
                _buildExecutionSection(context, templateProvider, ussdProvider),
                if (_executionResult != null) ...[
                  const SizedBox(height: UssdDesignSystem.spacingL),
                  _buildExecutionResults(context),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTemplateInfoCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(UssdDesignSystem.spacingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(UssdDesignSystem.spacingM),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(
                      UssdDesignSystem.radiusM,
                    ),
                  ),
                  child: Icon(
                    Icons.play_circle_outline,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                    size: 32,
                  ),
                ),
                const SizedBox(width: UssdDesignSystem.spacingM),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.template.name,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      if (widget.template.category != null) ...[
                        const SizedBox(height: UssdDesignSystem.spacingXS),
                        Chip(
                          label: Text(widget.template.category!),
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.secondaryContainer,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: UssdDesignSystem.spacingM),
            Text(
              widget.template.description,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: UssdDesignSystem.spacingM),
            Row(
              children: [
                _buildInfoChip(
                  context,
                  Icons.phone_in_talk_rounded,
                  widget.template.serviceCode,
                  Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: UssdDesignSystem.spacingM),
                _buildInfoChip(
                  context,
                  Icons.list_rounded,
                  '${widget.template.steps.length} steps',
                  Theme.of(context).colorScheme.secondary,
                ),
                const SizedBox(width: UssdDesignSystem.spacingM),
                _buildInfoChip(
                  context,
                  Icons.timer_outlined,
                  '${widget.template.stepDelayMs}ms delay',
                  Theme.of(context).colorScheme.tertiary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(
    BuildContext context,
    IconData icon,
    String text,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: UssdDesignSystem.spacingS,
        vertical: UssdDesignSystem.spacingXS,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(UssdDesignSystem.radiusS),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: UssdDesignSystem.spacingXS),
          Text(
            text,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.medium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVariablesSection(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(UssdDesignSystem.spacingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.settings_outlined,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: UssdDesignSystem.spacingS),
                Text(
                  'Variables',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: UssdDesignSystem.spacingM),
            Text(
              'Customize variable values for this execution:',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: UssdDesignSystem.spacingL),
            ...widget.template.variables.keys.map((key) {
              return Padding(
                padding: const EdgeInsets.only(
                  bottom: UssdDesignSystem.spacingM,
                ),
                child: TextFormField(
                  controller: _variableControllers[key],
                  decoration: InputDecoration(
                    labelText: '\${$key}',
                    hintText: 'Enter value for $key',
                    prefixIcon: const Icon(Icons.code),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildStepsPreview(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(UssdDesignSystem.spacingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.list_alt_outlined,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: UssdDesignSystem.spacingS),
                Text(
                  'Execution Steps',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: UssdDesignSystem.spacingM),
            Text(
              'The following steps will be executed:',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: UssdDesignSystem.spacingL),
            ...widget.template.steps.asMap().entries.map((entry) {
              final index = entry.key;
              final step = entry.value;
              return _buildStepPreviewItem(context, step, index);
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildStepPreviewItem(BuildContext context, step, int index) {
    return Padding(
      padding: const EdgeInsets.only(bottom: UssdDesignSystem.spacingM),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '${index + 1}',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: UssdDesignSystem.spacingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  step.description ?? 'Step ${index + 1}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: UssdDesignSystem.spacingXS),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: UssdDesignSystem.spacingS,
                    vertical: UssdDesignSystem.spacingXS,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(
                      UssdDesignSystem.radiusS,
                    ),
                  ),
                  child: Text(
                    'Input: ${_processVariablesForPreview(step.input)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontFamily: 'monospace',
                      color: Theme.of(context).colorScheme.onSecondaryContainer,
                    ),
                  ),
                ),
                if (step.hasExpectedResponse) ...[
                  const SizedBox(height: UssdDesignSystem.spacingXS),
                  Text(
                    'Expects: ${step.expectedResponse}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
                if (step.isCritical) ...[
                  const SizedBox(height: UssdDesignSystem.spacingXS),
                  Row(
                    children: [
                      Icon(
                        Icons.priority_high,
                        size: 16,
                        color: Theme.of(context).colorScheme.error,
                      ),
                      const SizedBox(width: UssdDesignSystem.spacingXS),
                      Text(
                        'Critical step',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExecutionSection(
    BuildContext context,
    TemplateProvider templateProvider,
    UssdProvider ussdProvider,
  ) {
    final canExecute =
        templateProvider.automationStatus == 'Ready' &&
        ussdProvider.activeEndpointConfig != null;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(UssdDesignSystem.spacingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.play_arrow,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: UssdDesignSystem.spacingS),
                Text(
                  'Execution',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: UssdDesignSystem.spacingM),
            if (!canExecute) ...[
              Container(
                padding: const EdgeInsets.all(UssdDesignSystem.spacingM),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(UssdDesignSystem.radiusS),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.warning_outlined,
                      color: Theme.of(context).colorScheme.onErrorContainer,
                    ),
                    const SizedBox(width: UssdDesignSystem.spacingM),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Cannot execute template',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onErrorContainer,
                                ),
                          ),
                          Text(
                            ussdProvider.activeEndpointConfig == null
                                ? 'No active endpoint configuration. Please configure an endpoint first.'
                                : templateProvider.automationStatus,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onErrorContainer,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              if (_isExecuting) ...[
                Container(
                  padding: const EdgeInsets.all(UssdDesignSystem.spacingM),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(
                      UssdDesignSystem.radiusS,
                    ),
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Theme.of(context).colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ),
                      const SizedBox(width: UssdDesignSystem.spacingM),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Executing template...',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onPrimaryContainer,
                                  ),
                            ),
                            Text(
                              templateProvider.automationStatus,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onPrimaryContainer,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          templateProvider.stopExecution();
                          setState(() {
                            _isExecuting = false;
                          });
                        },
                        child: Text(
                          'Stop',
                          style: TextStyle(
                            color: Theme.of(
                              context,
                            ).colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                Text(
                  'Ready to execute template. This will start a new USSD session and run all steps automatically.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: UssdDesignSystem.spacingL),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _executeTemplate,
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Execute Template'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(UssdDesignSystem.spacingM),
                    ),
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildExecutionResults(BuildContext context) {
    final result = _executionResult!;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(UssdDesignSystem.spacingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  result.isSuccessful ? Icons.check_circle : Icons.error,
                  color: result.isSuccessful
                      ? Colors.green
                      : Theme.of(context).colorScheme.error,
                ),
                const SizedBox(width: UssdDesignSystem.spacingS),
                Text(
                  'Execution Results',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: UssdDesignSystem.spacingM),
            _buildResultSummary(context, result),
            if (result.stepResults.isNotEmpty) ...[
              const SizedBox(height: UssdDesignSystem.spacingL),
              Text(
                'Step Results:',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: UssdDesignSystem.spacingM),
              ...result.stepResults.map(
                (stepResult) => _buildStepResult(context, stepResult),
              ),
            ],
            if (result.hasErrors) ...[
              const SizedBox(height: UssdDesignSystem.spacingL),
              Text(
                'Errors:',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
              const SizedBox(height: UssdDesignSystem.spacingM),
              ...result.allErrorMessages.map(
                (error) => Padding(
                  padding: const EdgeInsets.only(
                    bottom: UssdDesignSystem.spacingS,
                  ),
                  child: Text(
                    '• $error',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildResultSummary(BuildContext context, AutomationResult result) {
    return Container(
      padding: const EdgeInsets.all(UssdDesignSystem.spacingM),
      decoration: BoxDecoration(
        color: result.isSuccessful
            ? Colors.green.withOpacity(0.1)
            : Theme.of(context).colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(UssdDesignSystem.radiusS),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildResultStat(
                context,
                'Success Rate',
                '${result.successRate.toStringAsFixed(1)}%',
              ),
              _buildResultStat(
                context,
                'Steps',
                '${result.successfulSteps}/${result.totalSteps}',
              ),
              _buildResultStat(
                context,
                'Duration',
                result.executionDuration?.inSeconds.toString() ?? 'N/A',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildResultStat(BuildContext context, String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildStepResult(BuildContext context, stepResult) {
    return Padding(
      padding: const EdgeInsets.only(bottom: UssdDesignSystem.spacingS),
      child: Row(
        children: [
          Icon(
            stepResult.isSuccessful ? Icons.check_circle : Icons.error,
            color: stepResult.isSuccessful
                ? Colors.green
                : Theme.of(context).colorScheme.error,
            size: 20,
          ),
          const SizedBox(width: UssdDesignSystem.spacingS),
          Expanded(
            child: Text(
              'Step ${stepResult.stepIndex + 1}: ${stepResult.step.description ?? stepResult.step.input}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          if (stepResult.executionDuration != null)
            Text(
              '${stepResult.executionDuration!.inMilliseconds}ms',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
        ],
      ),
    );
  }

  String _processVariablesForPreview(String input) {
    String result = input;
    for (final entry in _variableControllers.entries) {
      final value = entry.value.text.isNotEmpty
          ? entry.value.text
          : '${entry.key}_value';
      result = result.replaceAll('\${${entry.key}}', value);
    }
    return result;
  }

  void _executeTemplate() async {
    final templateProvider = context.read<TemplateProvider>();

    setState(() {
      _isExecuting = true;
      _executionResult = null;
    });

    // Get override variables from controllers
    final overrideVariables = <String, String>{};
    for (final entry in _variableControllers.entries) {
      if (entry.value.text.isNotEmpty) {
        overrideVariables[entry.key] = entry.value.text;
      }
    }

    try {
      final result = await templateProvider.executeTemplate(
        widget.template.id,
        overrideVariables: overrideVariables,
      );

      setState(() {
        _executionResult = result;
      });

      if (result != null && result.isSuccessful && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Template executed successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } else if (result != null && !result.isSuccessful && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Template execution failed: ${result.errorMessage ?? "Unknown error"}',
            ),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error executing template: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      setState(() {
        _isExecuting = false;
      });
    }
  }
}
