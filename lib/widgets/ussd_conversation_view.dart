import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import '../providers/ussd_provider.dart';
import '../providers/accessibility_provider.dart';
import '../utils/ussd_utils.dart';
import 'ussd_keypad.dart';
import 'ussd_debug_panel.dart';
import 'ussd_session_details.dart';

class UssdConversationView extends StatefulWidget {
  const UssdConversationView({super.key});

  @override
  State<UssdConversationView> createState() => _UssdConversationViewState();
}

class _UssdConversationViewState extends State<UssdConversationView> {
  final _inputController = TextEditingController();
  final _scrollController = ScrollController();
  int _lastResponseCount = 0;

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(UssdConversationView oldWidget) {
    super.didUpdateWidget(oldWidget);
    _checkForNewResponse();
  }

  void _checkForNewResponse() {
    final provider = context.read<UssdProvider>();
    final accessibilityProvider = context.read<AccessibilityProvider>();
    final session = provider.currentSession;

    if (session != null && session.responses.length > _lastResponseCount) {
      _lastResponseCount = session.responses.length;

      // Speak the latest response if TTS is enabled
      if (session.responses.isNotEmpty) {
        final latestResponse = session.responses.last;
        accessibilityProvider.speak(latestResponse.text);

        // Also announce the session status
        String statusMessage = latestResponse.continueSession
            ? 'Session continues, input required'
            : 'Session ended';
        accessibilityProvider.announceForScreenReader(statusMessage);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<UssdProvider>();
    final accessibilityProvider = context.watch<AccessibilityProvider>();
    final session = provider.currentSession;

    if (session == null) {
      return const Center(child: Text('No active session'));
    }

    return Column(
      children: [
        // App Bar with session info and actions
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(16),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.phone,
                size: 20,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      session.serviceCode,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                    Text(
                      session.phoneNumber,
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(
                          context,
                        ).colorScheme.onPrimaryContainer.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: session.isActive ? Colors.green : Colors.red,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      session.isActive ? 'ACTIVE' : 'ENDED',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () => UssdSessionDetails.show(context, session),
                    icon: Icon(
                      Icons.info_outline,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                    tooltip: 'Session Details',
                  ),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: Semantics(
            label: 'USSD conversation history',
            hint: 'Scroll to view all messages',
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: session.responses.length,
              itemBuilder: (context, index) {
                final response = session.responses[index];
                final request = index < session.requests.length
                    ? session.requests[index]
                    : null;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (request != null && request.text.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Flexible(
                              child: Semantics(
                                label: 'Your input: ${request.text}',
                                hint: 'Message sent to USSD service',
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.primary,
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(16),
                                      topRight: Radius.circular(16),
                                      bottomLeft: Radius.circular(16),
                                      bottomRight: Radius.circular(4),
                                    ),
                                  ),
                                  child: Text(
                                    request.text,
                                    style: TextStyle(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onPrimary,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Flexible(
                          child: Semantics(
                            label: 'USSD response: ${response.text}',
                            hint: response.continueSession
                                ? 'Session continues, input required'
                                : 'Session ended, no input required',
                            onTap: () {
                              // Speak the response when tapped (if TTS is enabled)
                              accessibilityProvider.speak(response.text);
                            },
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Theme.of(
                                  context,
                                ).colorScheme.surfaceContainerHighest,
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(16),
                                  topRight: Radius.circular(16),
                                  bottomLeft: Radius.circular(4),
                                  bottomRight: Radius.circular(16),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Semantics(
                                        label: response.continueSession ? 'Continue session' : 'End session',
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: response.continueSession
                                                ? Colors.green
                                                : Colors.red,
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            response.continueSession ? 'CON' : 'END',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    response.text,
                                    style: TextStyle(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurface,
                                      fontSize: 16,
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                );
              },
            ),
          ),
        ),
        if (session.isActive) ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              border: Border(
                top: BorderSide(
                  color: Theme.of(
                    context,
                  ).colorScheme.outline.withValues(alpha: 0.2),
                ),
              ),
            ),
            child: Semantics(
              label: 'USSD input area',
              hint: 'Enter your response or use voice input',
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Semantics(
                        label: session.requests.isEmpty
                            ? 'Enter USSD code input field'
                            : 'Enter menu selection input field',
                        hint: session.requests.isEmpty
                            ? 'Type USSD code like *123#'
                            : 'Enter your menu choice',
                        child: TextField(
                          controller: _inputController,
                          decoration: InputDecoration(
                            hintText: session.requests.isEmpty
                                ? 'Enter USSD code (e.g., *123#)'
                                : 'Enter your menu selection...',
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                            suffixIcon: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (accessibilityProvider.settings.enableVoiceInput)
                                  Semantics(
                                    label: 'Voice input button',
                                    hint: 'Tap to use voice input for USSD command',
                                    child: IconButton(
                                      icon: const Icon(Icons.mic),
                                      onPressed: provider.isLoading ? null : () => _startVoiceInput(accessibilityProvider),
                                      tooltip: 'Voice Input',
                                    ),
                                  ),
                                Semantics(
                                  label: 'Keypad button',
                                  hint: 'Open on-screen keypad',
                                  child: IconButton(
                                    icon: const Icon(Icons.dialpad),
                                    onPressed: () {
                                      accessibilityProvider.hapticFeedback();
                                      UssdKeypadBottomSheet.show(
                                        context,
                                        textController: _inputController,
                                        enabled: !provider.isLoading,
                                      );
                                    },
                                    tooltip: 'Show Keypad',
                                  ),
                                ),
                              ],
                            ),
                          ),
                          onSubmitted: (_) => _sendInput(),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Semantics(
                    label: 'Send USSD input',
                    hint: provider.isLoading ? 'Sending...' : 'Tap to send input',
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: IconButton(
                        onPressed: provider.isLoading ? null : _sendInput,
                        icon: provider.isLoading
                            ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Theme.of(context).colorScheme.onPrimary,
                                  ),
                                ),
                              )
                            : Icon(
                                Icons.send,
                                color: Theme.of(context).colorScheme.onPrimary,
                              ),
                        tooltip: 'Send Input',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ] else
          Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Icon(
                  Icons.call_end,
                  size: 48,
                  color: Theme.of(context).colorScheme.outline,
                ),
                const SizedBox(height: 16),
                Text(
                  'Session Ended',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'The USSD session has completed',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ),
              ],
            ),
          ),

        // Debug Button
        Container(
          padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              OutlinedButton.icon(
                onPressed: () {
                  UssdDebugPanel.show(
                    context,
                    session: session,
                    lastRequest: session.requests.isNotEmpty
                        ? session.requests.last
                        : null,
                  );
                },
                icon: const Icon(Icons.bug_report, size: 16),
                label: const Text('API Debug'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _sendInput() {
    final input = _inputController.text.trim();
    if (input.isEmpty) return;

    final provider = context.read<UssdProvider>();
    final accessibilityProvider = context.read<AccessibilityProvider>();
    final session = provider.currentSession;

    if (session == null) return;

    // Provide haptic feedback
    accessibilityProvider.hapticFeedback();

    // Validate input based on session state
    if (session.isInitialRequest) {
      // For initial request, expect USSD code or allow any input
      if (!UssdUtils.isUssdCode(input) &&
          !UssdUtils.isValidMenuSelection(input)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Please enter a valid USSD code (e.g., *123#) or menu selection',
            ),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
        return;
      }
    } else {
      // For subsequent requests, validate menu selection
      if (!UssdUtils.isValidMenuSelection(input)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Please enter a valid menu selection (numbers, *, #)',
            ),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
        return;
      }
    }

    // Announce the input for screen readers
    accessibilityProvider.announceForScreenReader('Sending input: $input');

    provider.sendUssdInput(input);
    _inputController.clear();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> _startVoiceInput(AccessibilityProvider accessibilityProvider) async {
    accessibilityProvider.hapticFeedback();

    // Announce that voice input is starting
    accessibilityProvider.announceForScreenReader('Starting voice input. Please speak now.');

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            Icon(Icons.mic, color: Colors.white),
            SizedBox(width: 8),
            Text('Listening... Speak your USSD command'),
          ],
        ),
        duration: Duration(seconds: 3),
      ),
    );

    try {
      final result = await accessibilityProvider.startVoiceInput();

      if (result != null && result.isNotEmpty) {
        _inputController.text = result;

        // Announce successful recognition
        accessibilityProvider.announceForScreenReader('Voice input recognized: $result');

        // Provide success feedback
        accessibilityProvider.hapticFeedback();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Voice input: "$result"'),
              backgroundColor: Theme.of(context).colorScheme.primary,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } else {
        // Announce failure
        accessibilityProvider.announceForScreenReader('Voice input failed. No speech detected.');

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No speech detected. Please try again.'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Voice input error: $e');

      accessibilityProvider.announceForScreenReader('Voice input error occurred.');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Voice input failed. Please try again.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }
}
