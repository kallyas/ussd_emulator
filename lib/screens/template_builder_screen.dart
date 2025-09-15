import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/session_template.dart';
import '../models/template_step.dart';
import '../providers/template_provider.dart';
import '../utils/design_system.dart';
import '../l10n/generated/app_localizations.dart';

class TemplateBuilderScreen extends StatefulWidget {
  final SessionTemplate? template;

  const TemplateBuilderScreen({super.key, this.template});

  @override
  State<TemplateBuilderScreen> createState() => _TemplateBuilderScreenState();
}

class _TemplateBuilderScreenState extends State<TemplateBuilderScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _serviceCodeController = TextEditingController();
  final _categoryController = TextEditingController();
  
  List<TemplateStep> _steps = [];
  Map<String, String> _variables = {};
  int _stepDelayMs = 2000;

  bool get isEditing => widget.template != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      _nameController.text = widget.template!.name;
      _descriptionController.text = widget.template!.description;
      _serviceCodeController.text = widget.template!.serviceCode;
      _categoryController.text = widget.template!.category ?? '';
      _steps = List.from(widget.template!.steps);
      _variables = Map.from(widget.template!.variables);
      _stepDelayMs = widget.template!.stepDelayMs;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _serviceCodeController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? l10n.editTemplate : l10n.createTemplate),
        actions: [
          TextButton(
            onPressed: _saveTemplate,
            child: Text(l10n.save),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(UssdDesignSystem.spacingL),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTemplateDetailsSection(l10n),
              const SizedBox(height: UssdDesignSystem.spacingXL),
              _buildVariablesSection(l10n),
              const SizedBox(height: UssdDesignSystem.spacingXL),
              _buildStepsSection(l10n),
              const SizedBox(height: UssdDesignSystem.spacingXL),
              _buildSettingsSection(l10n),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTemplateDetailsSection(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.templateDetails,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: UssdDesignSystem.spacingL),
        TextFormField(
          controller: _nameController,
          decoration: InputDecoration(
            labelText: l10n.templateName,
            hintText: l10n.enterTemplateName,
            prefixIcon: const Icon(Icons.label_outline),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return l10n.templateNameRequired;
            }
            return null;
          },
        ),
        const SizedBox(height: UssdDesignSystem.spacingM),
        TextFormField(
          controller: _descriptionController,
          decoration: InputDecoration(
            labelText: l10n.description,
            hintText: l10n.enterTemplateDescription,
            prefixIcon: const Icon(Icons.description_outlined),
          ),
          maxLines: 3,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return l10n.descriptionRequired;
            }
            return null;
          },
        ),
        const SizedBox(height: UssdDesignSystem.spacingM),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: TextFormField(
                controller: _serviceCodeController,
                decoration: InputDecoration(
                  labelText: l10n.serviceCode,
                  hintText: '*123#',
                  prefixIcon: const Icon(Icons.phone_in_talk_outlined),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return l10n.serviceCodeRequired;
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: UssdDesignSystem.spacingM),
            Expanded(
              child: TextFormField(
                controller: _categoryController,
                decoration: InputDecoration(
                  labelText: l10n.category,
                  hintText: l10n.enterCategory,
                  prefixIcon: const Icon(Icons.category_outlined),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildVariablesSection(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Variables',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const Spacer(),
            ElevatedButton.icon(
              onPressed: _addVariable,
              icon: const Icon(Icons.add),
              label: const Text('Add Variable'),
            ),
          ],
        ),
        const SizedBox(height: UssdDesignSystem.spacingM),
        if (_variables.isEmpty)
          Container(
            padding: const EdgeInsets.all(UssdDesignSystem.spacingL),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
              borderRadius: BorderRadius.circular(UssdDesignSystem.radiusM),
              border: Border.all(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: UssdDesignSystem.spacingM),
                Expanded(
                  child: Text(
                    'Variables allow you to use placeholders like \${pin} in your template steps. Add variables here to make your templates reusable.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          )
        else
          ...Map.entries(_variables).map((entry) => _buildVariableItem(entry.key, entry.value)),
      ],
    );
  }

  Widget _buildVariableItem(String key, String value) {
    return Card(
      margin: const EdgeInsets.only(bottom: UssdDesignSystem.spacingS),
      child: Padding(
        padding: const EdgeInsets.all(UssdDesignSystem.spacingM),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: UssdDesignSystem.spacingS,
                vertical: UssdDesignSystem.spacingXS,
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(UssdDesignSystem.radiusS),
              ),
              child: Text(
                '\${$key}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontFamily: 'monospace',
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
            ),
            const SizedBox(width: UssdDesignSystem.spacingM),
            Expanded(
              child: Text(
                value,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => _editVariable(key, value),
              tooltip: 'Edit variable',
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => _removeVariable(key),
              tooltip: 'Remove variable',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepsSection(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              l10n.templateSteps,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const Spacer(),
            ElevatedButton.icon(
              onPressed: _addStep,
              icon: const Icon(Icons.add),
              label: Text(l10n.addStep),
            ),
          ],
        ),
        const SizedBox(height: UssdDesignSystem.spacingM),
        if (_steps.isEmpty)
          Container(
            padding: const EdgeInsets.all(UssdDesignSystem.spacingL),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
              borderRadius: BorderRadius.circular(UssdDesignSystem.radiusM),
              border: Border.all(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
              ),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.list_alt_outlined,
                  size: 48,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(height: UssdDesignSystem.spacingM),
                Text(
                  'No steps added yet',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: UssdDesignSystem.spacingS),
                Text(
                  'Add steps to define the sequence of inputs for your USSD template',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          )
        else
          ReorderableListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _steps.length,
            onReorder: _reorderSteps,
            itemBuilder: (context, index) {
              final step = _steps[index];
              return _buildStepItem(step, index, key: ValueKey(index));
            },
          ),
      ],
    );
  }

  Widget _buildStepItem(TemplateStep step, int index, {required Key key}) {
    return Card(
      key: key,
      margin: const EdgeInsets.only(bottom: UssdDesignSystem.spacingS),
      child: Padding(
        padding: const EdgeInsets.all(UssdDesignSystem.spacingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
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
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: UssdDesignSystem.spacingS,
                              vertical: UssdDesignSystem.spacingXS,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.secondaryContainer,
                              borderRadius: BorderRadius.circular(UssdDesignSystem.radiusS),
                            ),
                            child: Text(
                              'Input: ${step.input}',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                fontFamily: 'monospace',
                                color: Theme.of(context).colorScheme.onSecondaryContainer,
                              ),
                            ),
                          ),
                          if (step.hasExpectedResponse) ...[
                            const SizedBox(width: UssdDesignSystem.spacingS),
                            Icon(
                              Icons.check_circle_outline,
                              size: 16,
                              color: Colors.green,
                            ),
                          ],
                          if (step.isCritical) ...[
                            const SizedBox(width: UssdDesignSystem.spacingS),
                            Icon(
                              Icons.priority_high,
                              size: 16,
                              color: Theme.of(context).colorScheme.error,
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => _editStep(index),
                  tooltip: 'Edit step',
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => _removeStep(index),
                  tooltip: 'Remove step',
                ),
                Icon(
                  Icons.drag_handle,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsSection(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Settings',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: UssdDesignSystem.spacingL),
        Row(
          children: [
            Icon(
              Icons.timer_outlined,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: UssdDesignSystem.spacingM),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Step Delay: ${_stepDelayMs}ms',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                    'Default delay between steps during execution',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: UssdDesignSystem.spacingM),
        Slider(
          value: _stepDelayMs.toDouble(),
          min: 500,
          max: 10000,
          divisions: 19,
          label: '${_stepDelayMs}ms',
          onChanged: (value) {
            setState(() {
              _stepDelayMs = value.round();
            });
          },
        ),
      ],
    );
  }

  void _addVariable() {
    _showVariableDialog();
  }

  void _editVariable(String key, String value) {
    _showVariableDialog(key: key, value: value);
  }

  void _removeVariable(String key) {
    setState(() {
      _variables.remove(key);
    });
  }

  void _showVariableDialog({String? key, String? value}) {
    final keyController = TextEditingController(text: key ?? '');
    final valueController = TextEditingController(text: value ?? '');
    final isEditing = key != null;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEditing ? 'Edit Variable' : 'Add Variable'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: keyController,
              decoration: const InputDecoration(
                labelText: 'Variable Name',
                hintText: 'e.g., pin',
              ),
              enabled: !isEditing,
            ),
            const SizedBox(height: UssdDesignSystem.spacingM),
            TextField(
              controller: valueController,
              decoration: const InputDecoration(
                labelText: 'Default Value',
                hintText: 'e.g., 1234',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final varKey = keyController.text.trim();
              final varValue = valueController.text.trim();
              
              if (varKey.isNotEmpty && varValue.isNotEmpty) {
                setState(() {
                  if (isEditing && key != varKey) {
                    _variables.remove(key);
                  }
                  _variables[varKey] = varValue;
                });
                Navigator.pop(context);
              }
            },
            child: Text(isEditing ? 'Update' : 'Add'),
          ),
        ],
      ),
    );
  }

  void _addStep() {
    _showStepDialog();
  }

  void _editStep(int index) {
    _showStepDialog(step: _steps[index], index: index);
  }

  void _removeStep(int index) {
    setState(() {
      _steps.removeAt(index);
    });
  }

  void _reorderSteps(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final item = _steps.removeAt(oldIndex);
      _steps.insert(newIndex, item);
    });
  }

  void _showStepDialog({TemplateStep? step, int? index}) {
    final inputController = TextEditingController(text: step?.input ?? '');
    final descriptionController = TextEditingController(text: step?.description ?? '');
    final expectedResponseController = TextEditingController(text: step?.expectedResponse ?? '');
    bool waitForResponse = step?.waitForResponse ?? true;
    bool isCritical = step?.isCritical ?? false;
    int? customDelayMs = step?.customDelayMs;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(step != null ? 'Edit Step' : 'Add Step'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: inputController,
                  decoration: const InputDecoration(
                    labelText: 'Input',
                    hintText: 'e.g., 1 or \${pin}',
                  ),
                ),
                const SizedBox(height: UssdDesignSystem.spacingM),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description (optional)',
                    hintText: 'e.g., Select balance inquiry',
                  ),
                ),
                const SizedBox(height: UssdDesignSystem.spacingM),
                TextField(
                  controller: expectedResponseController,
                  decoration: const InputDecoration(
                    labelText: 'Expected Response (optional)',
                    hintText: 'e.g., Enter your PIN',
                  ),
                ),
                const SizedBox(height: UssdDesignSystem.spacingM),
                CheckboxListTile(
                  title: const Text('Wait for response'),
                  subtitle: const Text('Should wait for USSD response before continuing'),
                  value: waitForResponse,
                  onChanged: (value) {
                    setDialogState(() {
                      waitForResponse = value ?? true;
                    });
                  },
                ),
                CheckboxListTile(
                  title: const Text('Critical step'),
                  subtitle: const Text('Stop execution if this step fails'),
                  value: isCritical,
                  onChanged: (value) {
                    setDialogState(() {
                      isCritical = value ?? false;
                    });
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final input = inputController.text.trim();
                
                if (input.isNotEmpty) {
                  final newStep = TemplateStep(
                    input: input,
                    description: descriptionController.text.trim().isEmpty 
                        ? null 
                        : descriptionController.text.trim(),
                    expectedResponse: expectedResponseController.text.trim().isEmpty 
                        ? null 
                        : expectedResponseController.text.trim(),
                    waitForResponse: waitForResponse,
                    isCritical: isCritical,
                    customDelayMs: customDelayMs,
                  );

                  setState(() {
                    if (index != null) {
                      _steps[index] = newStep;
                    } else {
                      _steps.add(newStep);
                    }
                  });
                  Navigator.pop(context);
                }
              },
              child: Text(step != null ? 'Update' : 'Add'),
            ),
          ],
        ),
      ),
    );
  }

  void _saveTemplate() async {
    if (_formKey.currentState!.validate()) {
      final templateProvider = context.read<TemplateProvider>();
      
      SessionTemplate? result;
      
      if (isEditing) {
        final updatedTemplate = widget.template!.copyWith(
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim(),
          serviceCode: _serviceCodeController.text.trim(),
          category: _categoryController.text.trim().isEmpty 
              ? null 
              : _categoryController.text.trim(),
          steps: _steps,
          variables: _variables,
          stepDelayMs: _stepDelayMs,
        );
        
        final success = await templateProvider.updateTemplate(
          widget.template!.id,
          updatedTemplate,
        );
        
        if (success) {
          result = updatedTemplate;
        }
      } else {
        result = await templateProvider.createTemplate(
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim(),
          serviceCode: _serviceCodeController.text.trim(),
          category: _categoryController.text.trim().isEmpty 
              ? null 
              : _categoryController.text.trim(),
          stepDelayMs: _stepDelayMs,
        );
        
        if (result != null) {
          // Update the created template with steps and variables
          final updatedTemplate = result.copyWith(
            steps: _steps,
            variables: _variables,
          );
          
          await templateProvider.updateTemplate(result.id, updatedTemplate);
        }
      }

      if (result != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isEditing 
                ? 'Template updated successfully' 
                : 'Template created successfully'),
          ),
        );
        Navigator.pop(context);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(templateProvider.error ?? 'Failed to save template'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }
}