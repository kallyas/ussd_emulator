import 'package:flutter/material.dart';
import '../models/session_template.dart';
import '../utils/design_system.dart';
import '../l10n/generated/app_localizations.dart';

class TemplateExecutionScreen extends StatefulWidget {
  final SessionTemplate template;

  const TemplateExecutionScreen({super.key, required this.template});

  @override
  State<TemplateExecutionScreen> createState() => _TemplateExecutionScreenState();
}

class _TemplateExecutionScreenState extends State<TemplateExecutionScreen> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.executeTemplate),
        subtitle: Text(widget.template.name),
      ),
      body: Padding(
        padding: const EdgeInsets.all(UssdDesignSystem.spacingL),
        child: Column(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(UssdDesignSystem.spacingL),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.template.name,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: UssdDesignSystem.spacingS),
                    Text(
                      widget.template.description,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: UssdDesignSystem.spacingM),
                    Row(
                      children: [
                        Icon(
                          Icons.phone_in_talk_rounded,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: UssdDesignSystem.spacingS),
                        Text(
                          widget.template.serviceCode,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontFamily: 'monospace',
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        const SizedBox(width: UssdDesignSystem.spacingM),
                        Icon(
                          Icons.list_rounded,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: UssdDesignSystem.spacingS),
                        Text(
                          l10n.stepCount(widget.template.steps.length),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: UssdDesignSystem.spacingL),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(UssdDesignSystem.spacingL),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(UssdDesignSystem.radiusM),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.construction,
                      size: 64,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(height: UssdDesignSystem.spacingL),
                    Text(
                      l10n.templateExecutionComingSoon,
                      style: Theme.of(context).textTheme.titleLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: UssdDesignSystem.spacingM),
                    Text(
                      l10n.templateExecutionDescription,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}