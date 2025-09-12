import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/ussd_provider.dart';
import '../widgets/ussd_session_form.dart';
import '../widgets/modern_conversation_view.dart';
import '../utils/design_system.dart';

class UssdSessionScreen extends StatelessWidget {
  const UssdSessionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<UssdProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: UssdDesignSystem.borderRadiusSmall,
              ),
              child: Icon(
                Icons.phone_in_talk_rounded,
                size: 20,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
            ),
            const SizedBox(width: UssdDesignSystem.spacingS),
            const Text('USSD Emulator'),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        actions: [
          if (provider.currentSession != null)
            Container(
              margin: const EdgeInsets.only(right: UssdDesignSystem.spacingS),
              child: FilledButton.tonalIcon(
                onPressed: () {
                  provider.endSession();
                },
                icon: const Icon(Icons.call_end_rounded),
                label: const Text('End'),
                style: FilledButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.errorContainer,
                  foregroundColor: Theme.of(context).colorScheme.onErrorContainer,
                ),
              ),
            )
            .animate()
            .scale(
              begin: const Offset(0.0, 0.0),
              end: const Offset(1.0, 1.0),
              curve: Curves.elasticOut,
            ),
        ],
      ),
      body: Column(
        children: [
          if (provider.error != null)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.all(UssdDesignSystem.spacingM),
              padding: const EdgeInsets.all(UssdDesignSystem.spacingM),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.errorContainer,
                borderRadius: UssdDesignSystem.borderRadiusMedium,
                boxShadow: UssdDesignSystem.getShadow(
                  UssdDesignSystem.elevationLevel2,
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.error,
                      borderRadius: UssdDesignSystem.borderRadiusSmall,
                    ),
                    child: Icon(
                      Icons.error_rounded,
                      color: Theme.of(context).colorScheme.onError,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: UssdDesignSystem.spacingM),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Error',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: Theme.of(context).colorScheme.onErrorContainer,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          provider.error!,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onErrorContainer,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: provider.clearError,
                    color: Theme.of(context).colorScheme.onErrorContainer,
                    tooltip: 'Dismiss error',
                  ),
                ],
              ),
            )
            .animate()
            .slideY(begin: -1.0, end: 0.0)
            .fadeIn(),
          if (provider.activeEndpointConfig != null)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(
                left: UssdDesignSystem.spacingM,
                right: UssdDesignSystem.spacingM,
                bottom: UssdDesignSystem.spacingM,
              ),
              padding: const EdgeInsets.all(UssdDesignSystem.spacingM),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.secondaryContainer,
                    Theme.of(context).colorScheme.secondaryContainer.withOpacity(0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: UssdDesignSystem.borderRadiusMedium,
                boxShadow: UssdDesignSystem.getShadow(
                  UssdDesignSystem.elevationLevel1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondary,
                      borderRadius: UssdDesignSystem.borderRadiusSmall,
                    ),
                    child: Icon(
                      Icons.cloud_done_rounded,
                      color: Theme.of(context).colorScheme.onSecondary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: UssdDesignSystem.spacingM),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Connected',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSecondaryContainer,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          provider.activeEndpointConfig!.name,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSecondaryContainer,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondary,
                      shape: BoxShape.circle,
                    ),
                  )
                  .animate(onPlay: (controller) => controller.repeat())
                  .scale(
                    begin: const Offset(1.0, 1.0),
                    end: const Offset(1.2, 1.2),
                    duration: const Duration(milliseconds: 1000),
                  )
                  .then()
                  .scale(
                    begin: const Offset(1.2, 1.2),
                    end: const Offset(1.0, 1.0),
                    duration: const Duration(milliseconds: 1000),
                  ),
                ],
              ),
            )
            .animate()
            .slideY(begin: -1.0, end: 0.0)
            .fadeIn(delay: const Duration(milliseconds: 200)),
          if (provider.currentSession == null)
            const Expanded(child: UssdSessionForm())
          else
            const Expanded(child: ModernUssdConversationView()),
        ],
      ),
    );
  }
}
