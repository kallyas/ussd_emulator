import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../providers/ussd_provider.dart';
import '../utils/ussd_utils.dart';
import '../utils/design_system.dart';
import '../widgets/animated_message_bubble.dart';
import '../widgets/modern_input_field.dart';
import '../l10n/generated/app_localizations.dart';
import 'ussd_keypad.dart';
import 'ussd_debug_panel.dart';
import 'ussd_session_details.dart';

/// Modern conversation view with animations and enhanced UX
class ModernUssdConversationView extends StatefulWidget {
  const ModernUssdConversationView({super.key});

  @override
  State<ModernUssdConversationView> createState() =>
      _ModernUssdConversationViewState();
}

class _ModernUssdConversationViewState extends State<ModernUssdConversationView>
    with TickerProviderStateMixin {
  final _inputController = TextEditingController();
  final _scrollController = ScrollController();
  int _lastResponseCount = 0;
  bool _showTypingIndicator = false;
  late AnimationController _headerAnimationController;
  late Animation<double> _headerSlideAnimation;

  @override
  void initState() {
    super.initState();
    _headerAnimationController = AnimationController(
      duration: UssdDesignSystem.animationMedium,
      vsync: this,
    );
    _headerSlideAnimation = Tween<double>(begin: -1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _headerAnimationController,
        curve: UssdDesignSystem.curveDefault,
      ),
    );
    _headerAnimationController.forward();
  }

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    _headerAnimationController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(ModernUssdConversationView oldWidget) {
    super.didUpdateWidget(oldWidget);
    _checkForNewResponse();
  }

  void _checkForNewResponse() {
    final provider = context.read<UssdProvider>();
    final session = provider.currentSession;

    if (session != null && session.responses.length > _lastResponseCount) {
      _lastResponseCount = session.responses.length;

      // Hide typing indicator when response arrives
      if (_showTypingIndicator) {
        setState(() {
          _showTypingIndicator = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<UssdProvider>();
    final session = provider.currentSession;

    if (session == null) {
      return _buildEmptyState();
    }

    return ClipRect(
      child: Column(
        children: [
          // Animated conversation header
          _buildAnimatedHeader(session),

          // Enhanced conversation area with staggered animations
          Expanded(child: _buildConversationArea(session)),

          // Modern input area or session ended state
          if (session.isActive)
            _buildModernInputArea(provider, session)
          else
            _buildSessionEndedState(),

          // Debug panel
          _buildDebugPanel(session),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    final l10n = AppLocalizations.of(context);
    return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.phone_callback_rounded,
                size: 64,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: UssdDesignSystem.spacingM),
              Text(
                l10n.noActiveSession,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: UssdDesignSystem.spacingS),
              Text(
                l10n.startNewSessionPrompt,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        )
        .animate()
        .fadeIn(duration: UssdDesignSystem.animationMedium)
        .scale(begin: const Offset(0.8, 0.8), end: const Offset(1.0, 1.0));
  }

  Widget _buildAnimatedHeader(session) {
    return SlideTransition(
      position: _headerSlideAnimation.drive(
        Tween(begin: const Offset(0.0, -1.0), end: Offset.zero),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: UssdDesignSystem.spacingM,
          vertical: UssdDesignSystem.spacingM,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(context).colorScheme.primaryContainer,
              Theme.of(context).colorScheme.primaryContainer.withOpacity(0.8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: const BorderRadius.vertical(
            bottom: Radius.circular(24),
          ),
          boxShadow: UssdDesignSystem.getShadow(
            UssdDesignSystem.elevationLevel2,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: UssdDesignSystem.borderRadiusMedium,
              ),
              child: Icon(
                Icons.phone_rounded,
                size: 24,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
            ).animate().scale(
              begin: const Offset(0.8, 0.8),
              end: const Offset(1.0, 1.0),
              delay: const Duration(milliseconds: 200),
            ),
            const SizedBox(width: UssdDesignSystem.spacingM),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    session.serviceCode,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    session.phoneNumber,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onPrimaryContainer.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: session.isActive
                        ? Theme.of(context).colorScheme.secondary
                        : Theme.of(context).colorScheme.error,
                    borderRadius: UssdDesignSystem.borderRadiusMedium,
                    boxShadow: UssdDesignSystem.getShadow(
                      UssdDesignSystem.elevationLevel1,
                    ),
                  ),
                  child: Text(
                    session.isActive ? 'ACTIVE' : 'ENDED',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: session.isActive
                          ? Theme.of(context).colorScheme.onSecondary
                          : Theme.of(context).colorScheme.onError,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ).animate().scale(
                  begin: const Offset(0.0, 0.0),
                  end: const Offset(1.0, 1.0),
                  delay: const Duration(milliseconds: 300),
                  curve: Curves.elasticOut,
                ),
                const SizedBox(width: UssdDesignSystem.spacingS),
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: UssdDesignSystem.borderRadiusSmall,
                  ),
                  child: IconButton(
                    icon: Icon(
                      Icons.info_outline_rounded,
                      size: 20,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    tooltip: 'Session Details',
                    onPressed: () => UssdSessionDetails.show(context, session),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConversationArea(session) {
    return Semantics(
      label: 'USSD conversation history',
      hint: 'Scroll to view all messages',
      child: AnimationLimiter(
        child: ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.all(UssdDesignSystem.spacingM),
          itemCount: session.responses.length + (_showTypingIndicator ? 1 : 0),
          itemBuilder: (context, index) {
            if (_showTypingIndicator && index == session.responses.length) {
              return const TypingIndicator();
            }

            final response = session.responses[index];
            final request = index < session.requests.length
                ? session.requests[index]
                : null;
            final isLastResponse = index == session.responses.length - 1;
            final provider = context.read<UssdProvider>();
            final fromCache = isLastResponse && provider.lastResponseFromCache;

            return AnimationConfiguration.staggeredList(
              position: index,
              duration: UssdDesignSystem.animationMedium,
              delay: Duration(milliseconds: index * 50),
              child: Column(
                children: [
                  if (request != null && request.text.isNotEmpty)
                    AnimatedMessageBubble(
                      request: request,
                      isUser: true,
                      index: index * 2,
                    ),
                  const SizedBox(height: UssdDesignSystem.spacingS),
                  AnimatedMessageBubble(
                    response: response,
                    isUser: false,
                    index: index * 2 + 1,
                    fromCache: fromCache,
                  ),
                  const SizedBox(height: UssdDesignSystem.spacingM),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildModernInputArea(UssdProvider provider, session) {
    return ModernInputArea(
      controller: _inputController,
      hintText: session.requests.isEmpty
          ? 'Enter USSD code (e.g., *123#)'
          : 'Enter your menu selection...',
      isLoading: provider.isLoading,
      enableVoiceInput: false,
      onSend: _sendInput,
      onKeypad: () {
        UssdKeypadBottomSheet.show(
          context,
          textController: _inputController,
          enabled: !provider.isLoading,
        );
      },
    );
  }

  Widget _buildSessionEndedState() {
    return Container(
          padding: const EdgeInsets.all(UssdDesignSystem.spacingXL),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(UssdDesignSystem.spacingL),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.errorContainer,
                  borderRadius: UssdDesignSystem.borderRadiusLarge,
                ),
                child: Icon(
                  Icons.call_end_rounded,
                  size: 48,
                  color: Theme.of(context).colorScheme.onErrorContainer,
                ),
              ),
              const SizedBox(height: UssdDesignSystem.spacingM),
              Text(
                'Session Ended',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: UssdDesignSystem.spacingS),
              Text(
                'The USSD session has completed',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        )
        .animate()
        .fadeIn(duration: UssdDesignSystem.animationMedium)
        .slideY(
          begin: 0.3,
          end: 0.0,
          duration: UssdDesignSystem.animationMedium,
        );
  }

  Widget _buildDebugPanel(session) {
    return Container(
      padding: const EdgeInsets.only(
        left: UssdDesignSystem.spacingM,
        right: UssdDesignSystem.spacingM,
        bottom: UssdDesignSystem.spacingM,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          PulseButton(
            onPressed: () {
              UssdDebugPanel.show(
                context,
                session: session,
                lastRequest: session.requests.isNotEmpty
                    ? session.requests.last
                    : null,
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: UssdDesignSystem.spacingM,
                vertical: UssdDesignSystem.spacingS,
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: UssdDesignSystem.borderRadiusMedium,
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.bug_report_rounded,
                    size: 16,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: UssdDesignSystem.spacingS),
                  Text(
                    'API Debug',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _sendInput() {
    final input = _inputController.text.trim();
    if (input.isEmpty) return;

    final provider = context.read<UssdProvider>();
    final session = provider.currentSession;

    if (session == null) return;

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

    // Show typing indicator
    setState(() {
      _showTypingIndicator = true;
    });

    provider.sendUssdInput(input);
    _inputController.clear();

    // Auto-scroll to bottom with animation
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 100,
        duration: UssdDesignSystem.animationMedium,
        curve: UssdDesignSystem.curveDefault,
      );
    });
  }
}
