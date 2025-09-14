import 'package:flutter/material.dart';
import '../models/session_template.dart';
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

  bool get isEditing => widget.template != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      _nameController.text = widget.template!.name;
      _descriptionController.text = widget.template!.description;
      _serviceCodeController.text = widget.template!.serviceCode;
      _categoryController.text = widget.template!.category ?? '';
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
              TextFormField(
                controller: _serviceCodeController,
                decoration: InputDecoration(
                  labelText: l10n.serviceCode,
                  hintText: '*123#',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return l10n.serviceCodeRequired;
                  }
                  return null;
                },
              ),
              const SizedBox(height: UssdDesignSystem.spacingM),
              TextFormField(
                controller: _categoryController,
                decoration: InputDecoration(
                  labelText: l10n.category,
                  hintText: l10n.enterCategory,
                ),
              ),
              const SizedBox(height: UssdDesignSystem.spacingXL),
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
              Container(
                padding: const EdgeInsets.all(UssdDesignSystem.spacingL),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(UssdDesignSystem.radiusM),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.construction,
                      size: 48,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(height: UssdDesignSystem.spacingM),
                    Text(
                      l10n.templateBuilderComingSoon,
                      style: Theme.of(context).textTheme.titleMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: UssdDesignSystem.spacingS),
                    Text(
                      l10n.templateBuilderDescription,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _addStep() {
    // TODO: Implement step builder
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context).featureComingSoon),
      ),
    );
  }

  void _saveTemplate() {
    if (_formKey.currentState!.validate()) {
      // TODO: Implement template saving
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).featureComingSoon),
        ),
      );
    }
  }
}