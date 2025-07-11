import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/ussd_provider.dart';
import '../widgets/ussd_session_form.dart';
import '../widgets/ussd_conversation_view.dart';

class UssdSessionScreen extends StatelessWidget {
  const UssdSessionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<UssdProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('USSD Emulator'),
        backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
        actions: [
          if (provider.currentSession != null)
            Container(
              margin: const EdgeInsets.only(right: 8),
              child: IconButton.filled(
                icon: const Icon(Icons.call_end),
                onPressed: () {
                  provider.endSession();
                },
                tooltip: 'End Session',
                style: IconButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          if (provider.error != null)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.errorContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.error_outline,
                    color: Theme.of(context).colorScheme.onErrorContainer,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      provider.error!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onErrorContainer,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: provider.clearError,
                    color: Theme.of(context).colorScheme.onErrorContainer,
                  ),
                ],
              ),
            ),
          if (provider.activeEndpointConfig != null)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.cloud_done,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Connected to: ${provider.activeEndpointConfig!.name}',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          if (provider.currentSession == null)
            const Expanded(child: UssdSessionForm())
          else
            const Expanded(child: UssdConversationView()),
        ],
      ),
    );
  }
}
