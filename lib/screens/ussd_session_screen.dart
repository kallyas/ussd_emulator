import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../providers/ussd_provider.dart';
import '../widgets/ussd_session_form.dart';
import '../widgets/modern_conversation_view.dart';
import '../utils/design_system.dart';
import '../l10n/generated/app_localizations.dart';

class UssdSessionScreen extends StatelessWidget {
  const UssdSessionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<UssdProvider>();
    final l10n = AppLocalizations.of(context);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (provider.error != null)
              Card(
                color: Theme.of(context).colorScheme.errorContainer,
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 16),
                child: ListTile(
                  leading: Icon(Icons.error_rounded, color: Theme.of(context).colorScheme.error, size: 28),
                  title: Text(l10n.error, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).colorScheme.onErrorContainer, fontWeight: FontWeight.bold)),
                  subtitle: Text(provider.error!, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onErrorContainer)),
                  trailing: IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: provider.clearError,
                    color: Theme.of(context).colorScheme.onErrorContainer,
                    tooltip: l10n.dismissError,
                  ),
                ),
              ),
            if (provider.activeEndpointConfig != null)
              Card(
                color: Theme.of(context).colorScheme.secondaryContainer,
                elevation: 1,
                margin: const EdgeInsets.only(bottom: 16),
                child: ListTile(
                  leading: Icon(Icons.cloud_done_rounded, color: Theme.of(context).colorScheme.secondary, size: 28),
                  title: Text(l10n.connected, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).colorScheme.onSecondaryContainer, fontWeight: FontWeight.bold)),
                  subtitle: Text(provider.activeEndpointConfig!.name, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSecondaryContainer)),
                  trailing: AnimatedContainer(
                    duration: const Duration(milliseconds: 1000),
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondary,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            if (provider.currentSession != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.stop_circle_outlined),
                    label: Text(l10n.endSession),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.errorContainer,
                      foregroundColor: Theme.of(context).colorScheme.onErrorContainer,
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () async {
                      await provider.endSession();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(l10n.ussdSessionEnded)),
                      );
                    },
                  ),
                ),
              ),
            Expanded(
              child: AnimatedSwitcher(
                duration: UssdDesignSystem.animationMedium,
                child: provider.currentSession == null
                    ? const UssdSessionForm()
                    : const ModernUssdConversationView(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
