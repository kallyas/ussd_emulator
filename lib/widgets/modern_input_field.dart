import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../utils/design_system.dart';

/// Modern text field with enhanced styling and animations
class ModernTextField extends StatefulWidget {
  final String? label;
  final String? hint;
  final TextEditingController? controller;
  final VoidCallback? onSubmitted;
  final Widget? suffixIcon;
  final bool enabled;
  final bool isLoading;
  final TextInputType? keyboardType;
  final int? maxLines;

  const ModernTextField({
    Key? key,
    this.label,
    this.hint,
    this.controller,
    this.onSubmitted,
    this.suffixIcon,
    this.enabled = true,
    this.isLoading = false,
    this.keyboardType,
    this.maxLines = 1,
  }) : super(key: key);

  @override
  State<ModernTextField> createState() => _ModernTextFieldState();
}

class _ModernTextFieldState extends State<ModernTextField>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _focusAnimation;
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: UssdDesignSystem.animationFast,
      vsync: this,
    );
    _focusAnimation = Tween<double>(begin: 1.0, end: 1.02).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: UssdDesignSystem.curveDefault,
      ),
    );

    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });

      if (_isFocused) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AnimatedBuilder(
      animation: _focusAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _focusAnimation.value,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: UssdDesignSystem.borderRadiusMedium,
              boxShadow: _isFocused
                  ? UssdDesignSystem.getShadow(
                      UssdDesignSystem.elevationLevel2,
                      color: colorScheme.primary,
                    )
                  : UssdDesignSystem.getShadow(
                      UssdDesignSystem.elevationLevel1,
                    ),
            ),
            child: TextField(
              controller: widget.controller,
              focusNode: _focusNode,
              enabled: widget.enabled && !widget.isLoading,
              keyboardType: widget.keyboardType,
              maxLines: widget.maxLines,
              decoration: InputDecoration(
                labelText: widget.label,
                hintText: widget.hint,
                filled: true,
                fillColor: _isFocused
                    ? colorScheme.surface
                    : colorScheme.surfaceContainer,
                suffixIcon: widget.isLoading
                    ? Container(
                        width: 20,
                        height: 20,
                        padding: const EdgeInsets.all(12),
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            colorScheme.primary,
                          ),
                        ),
                      )
                    : widget.suffixIcon,
                border: OutlineInputBorder(
                  borderRadius: UssdDesignSystem.borderRadiusMedium,
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: UssdDesignSystem.borderRadiusMedium,
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: UssdDesignSystem.borderRadiusMedium,
                  borderSide: BorderSide(color: colorScheme.primary, width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 16,
                ),
                labelStyle: TextStyle(
                  color: _isFocused
                      ? colorScheme.primary
                      : colorScheme.onSurfaceVariant,
                ),
                hintStyle: TextStyle(
                  color: colorScheme.onSurfaceVariant.withOpacity(0.6),
                ),
              ),
              style: TextStyle(color: colorScheme.onSurface, fontSize: 16),
              onSubmitted: (_) => widget.onSubmitted?.call(),
            ),
          ),
        );
      },
    );
  }
}

/// Animated send button with pulse effect
class AnimatedSendButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool enabled;

  const AnimatedSendButton({
    Key? key,
    this.onPressed,
    this.isLoading = false,
    this.enabled = true,
  }) : super(key: key);

  @override
  State<AnimatedSendButton> createState() => _AnimatedSendButtonState();
}

class _AnimatedSendButtonState extends State<AnimatedSendButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: UssdDesignSystem.animationFast,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(
        parent: _controller,
        curve: UssdDesignSystem.curveDefault,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTapDown: widget.enabled && !widget.isLoading
          ? (_) => _controller.forward()
          : null,
      onTapUp: widget.enabled && !widget.isLoading
          ? (_) => _controller.reverse()
          : null,
      onTapCancel: () => _controller.reverse(),
      onTap: widget.enabled && !widget.isLoading ? widget.onPressed : null,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                gradient: widget.enabled && !widget.isLoading
                    ? UssdDesignSystem.getPrimaryGradient(colorScheme)
                    : null,
                color: widget.enabled && !widget.isLoading
                    ? null
                    : colorScheme.onSurface.withOpacity(0.12),
                borderRadius: UssdDesignSystem.borderRadiusXLarge,
                boxShadow: widget.enabled && !widget.isLoading
                    ? UssdDesignSystem.getShadow(
                        UssdDesignSystem.elevationLevel3,
                        color: colorScheme.primary,
                      )
                    : null,
              ),
              child: widget.isLoading
                  ? Padding(
                      padding: const EdgeInsets.all(16),
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          colorScheme.onPrimary,
                        ),
                      ),
                    )
                  : Icon(
                      Icons.send_rounded,
                      color: widget.enabled
                          ? colorScheme.onPrimary
                          : colorScheme.onSurface.withOpacity(0.38),
                      size: 24,
                    ),
            ),
          );
        },
      ),
    );
  }
}

/// Modern input area with enhanced styling
class ModernInputArea extends StatelessWidget {
  final TextEditingController controller;
  final String? hintText;
  final VoidCallback? onSend;
  final VoidCallback? onVoiceInput;
  final VoidCallback? onKeypad;
  final bool isLoading;
  final bool enableVoiceInput;

  const ModernInputArea({
    Key? key,
    required this.controller,
    this.hintText,
    this.onSend,
    this.onVoiceInput,
    this.onKeypad,
    this.isLoading = false,
    this.enableVoiceInput = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(UssdDesignSystem.spacingM),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: colorScheme.outline.withOpacity(0.12),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: ModernTextField(
                controller: controller,
                hint: hintText,
                enabled: !isLoading,
                isLoading: false,
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (enableVoiceInput) ...[
                      IconButton(
                        icon: Icon(
                          Icons.mic_rounded,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        onPressed: isLoading ? null : onVoiceInput,
                        tooltip: 'Voice Input',
                      ),
                    ],
                    IconButton(
                      icon: Icon(
                        Icons.dialpad_rounded,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      onPressed: isLoading ? null : onKeypad,
                      tooltip: 'Show Keypad',
                    ),
                  ],
                ),
                onSubmitted: onSend,
              ),
            ),
            const SizedBox(width: UssdDesignSystem.spacingM),
            AnimatedSendButton(
              onPressed: onSend,
              isLoading: isLoading,
              enabled: !isLoading,
            ),
          ],
        ),
      ),
    ).animate().slideY(
      begin: 1.0,
      end: 0.0,
      duration: UssdDesignSystem.animationMedium,
      curve: UssdDesignSystem.curveDefault,
    );
  }
}

/// Pulse button for micro-interactions
class PulseButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final Duration? duration;

  const PulseButton({
    Key? key,
    required this.child,
    this.onPressed,
    this.duration,
  }) : super(key: key);

  @override
  State<PulseButton> createState() => _PulseButtonState();
}

class _PulseButtonState extends State<PulseButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration ?? UssdDesignSystem.animationFast,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(
        parent: _controller,
        curve: UssdDesignSystem.curveDefault,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      onTap: widget.onPressed,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: widget.child,
          );
        },
      ),
    );
  }
}
