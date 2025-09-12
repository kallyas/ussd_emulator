import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/ussd_response.dart';
import '../models/ussd_request.dart';
import '../utils/design_system.dart';

/// Enhanced animated message bubble with slide and fade transitions
class AnimatedMessageBubble extends StatelessWidget {
  final UssdResponse? response;
  final UssdRequest? request;
  final bool isUser;
  final int index;
  final VoidCallback? onTap;

  const AnimatedMessageBubble({
    Key? key,
    this.response,
    this.request,
    required this.isUser,
    required this.index,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    
    final messageText = isUser ? (request?.text ?? '') : (response?.text ?? '');
    
    if (messageText.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(
        vertical: UssdDesignSystem.spacingXS,
        horizontal: UssdDesignSystem.spacingM,
      ),
      child: Row(
        mainAxisAlignment: isUser 
            ? MainAxisAlignment.end 
            : MainAxisAlignment.start,
        children: [
          Flexible(
            child: GestureDetector(
              onTap: onTap,
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.8,
                ),
                child: _buildMessageContainer(context, colorScheme, textTheme, messageText),
              ),
            ),
          ),
        ],
      ),
    )
    .animate(delay: Duration(milliseconds: index * 100))
    .slideX(
      begin: isUser ? 1.0 : -1.0,
      end: 0.0,
      duration: UssdDesignSystem.animationMedium,
      curve: UssdDesignSystem.curveDefault,
    )
    .fadeIn(
      duration: UssdDesignSystem.animationMedium,
      curve: UssdDesignSystem.curveDefault,
    );
  }

  Widget _buildMessageContainer(
    BuildContext context,
    ColorScheme colorScheme, 
    TextTheme textTheme,
    String messageText,
  ) {
    if (isUser) {
      return _buildUserMessage(context, colorScheme, textTheme, messageText);
    } else {
      return _buildSystemMessage(context, colorScheme, textTheme, messageText);
    }
  }

  Widget _buildUserMessage(
    BuildContext context,
    ColorScheme colorScheme, 
    TextTheme textTheme,
    String messageText,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 12,
        horizontal: 16,
      ),
      decoration: BoxDecoration(
        gradient: UssdDesignSystem.getPrimaryGradient(colorScheme),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(18),
          topRight: Radius.circular(18),
          bottomLeft: Radius.circular(18),
          bottomRight: Radius.circular(4),
        ),
        boxShadow: UssdDesignSystem.getShadow(
          UssdDesignSystem.elevationLevel2,
          color: colorScheme.primary,
        ),
      ),
      child: Text(
        messageText,
        style: textTheme.bodyMedium?.copyWith(
          color: colorScheme.onPrimary,
          height: 1.4,
        ),
      ),
    );
  }

  Widget _buildSystemMessage(
    BuildContext context,
    ColorScheme colorScheme, 
    TextTheme textTheme,
    String messageText,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(18),
          topRight: Radius.circular(18),
          bottomLeft: Radius.circular(4),
          bottomRight: Radius.circular(18),
        ),
        boxShadow: UssdDesignSystem.getShadow(
          UssdDesignSystem.elevationLevel1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (response != null) ...[
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: response!.continueSession 
                        ? colorScheme.secondary 
                        : colorScheme.error,
                    borderRadius: UssdDesignSystem.borderRadiusSmall,
                  ),
                  child: Text(
                    response!.continueSession ? 'CON' : 'END',
                    style: textTheme.labelSmall?.copyWith(
                      color: response!.continueSession 
                          ? colorScheme.onSecondary 
                          : colorScheme.onError,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
                .animate()
                .scale(
                  begin: const Offset(0.8, 0.8),
                  end: const Offset(1.0, 1.0),
                  duration: UssdDesignSystem.animationFast,
                  delay: UssdDesignSystem.animationMedium,
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],
          Text(
            messageText,
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

/// Loading indicator for typing animation
class TypingIndicator extends StatefulWidget {
  const TypingIndicator({Key? key}) : super(key: key);

  @override
  State<TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator>
    with TickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      margin: const EdgeInsets.symmetric(
        vertical: UssdDesignSystem.spacingXS,
        horizontal: UssdDesignSystem.spacingM,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(18),
                topRight: Radius.circular(18),
                bottomLeft: Radius.circular(4),
                bottomRight: Radius.circular(18),
              ),
              boxShadow: UssdDesignSystem.getShadow(
                UssdDesignSystem.elevationLevel1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'USSD service is typing',
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(width: 8),
                Row(
                  children: List.generate(3, (index) => _buildDot(index, colorScheme)),
                ),
              ],
            ),
          ),
        ],
      ),
    )
    .animate()
    .slideX(
      begin: -1.0,
      end: 0.0,
      duration: UssdDesignSystem.animationMedium,
      curve: UssdDesignSystem.curveDefault,
    )
    .fadeIn(
      duration: UssdDesignSystem.animationMedium,
    );
  }

  Widget _buildDot(int index, ColorScheme colorScheme) {
    final animation = Tween(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(
          index * 0.2,
          (index * 0.2) + 0.4,
          curve: Curves.easeInOut,
        ),
      ),
    );

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 2),
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: colorScheme.primary.withOpacity(animation.value),
            shape: BoxShape.circle,
          ),
        );
      },
    );
  }
}

/// Skeleton loading bubble for message placeholders
class SkeletonMessageBubble extends StatelessWidget {
  final bool isUser;

  const SkeletonMessageBubble({
    Key? key,
    this.isUser = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Container(
      margin: const EdgeInsets.symmetric(
        vertical: UssdDesignSystem.spacingXS,
        horizontal: UssdDesignSystem.spacingM,
      ),
      child: Row(
        mainAxisAlignment: isUser 
            ? MainAxisAlignment.end 
            : MainAxisAlignment.start,
        children: [
          Container(
            width: 200,
            height: 48,
            decoration: BoxDecoration(
              color: colorScheme.surfaceVariant,
              borderRadius: BorderRadius.circular(18),
            ),
          )
          .animate(onPlay: (controller) => controller.repeat())
          .shimmer(
            duration: const Duration(milliseconds: 1200),
            color: colorScheme.surface,
          ),
        ],
      ),
    );
  }
}