import 'package:flutter/material.dart';
import '../utils/ussd_utils.dart';

class UssdKeypad extends StatelessWidget {
  final Function(String) onKeyPressed;
  final bool enabled;

  const UssdKeypad({
    super.key,
    required this.onKeyPressed,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final keys = UssdUtils.getKeypadButtons();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Title
          Text(
            'Virtual Keypad',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),

          // Keypad grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.2,
            ),
            itemCount: keys.length,
            itemBuilder: (context, index) {
              final key = keys[index];
              return _buildKeypadButton(context, key);
            },
          ),

          const SizedBox(height: 16),

          // Quick USSD codes
          Text(
            'Quick USSD Codes',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 8),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: UssdUtils.getCommonUssdCodes().map((code) {
              return _buildQuickCodeButton(context, code);
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildKeypadButton(BuildContext context, String key) {
    return Material(
      color: Theme.of(context).colorScheme.primaryContainer,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: enabled ? () => onKeyPressed(key) : null,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Theme.of(
                context,
              ).colorScheme.outline.withValues(alpha: 0.3),
            ),
          ),
          child: Center(
            child: Text(
              key,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: enabled
                    ? Theme.of(context).colorScheme.onPrimaryContainer
                    : Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.5),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickCodeButton(BuildContext context, String code) {
    return Material(
      color: Theme.of(context).colorScheme.secondaryContainer,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: enabled ? () => onKeyPressed(code) : null,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Text(
            code,
            style: TextStyle(
              color: enabled
                  ? Theme.of(context).colorScheme.onSecondaryContainer
                  : Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.5),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

class UssdKeypadBottomSheet extends StatelessWidget {
  final TextEditingController textController;
  final bool enabled;

  const UssdKeypadBottomSheet({
    super.key,
    required this.textController,
    this.enabled = true,
  });

  static void show(
    BuildContext context, {
    required TextEditingController textController,
    bool enabled = true,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => UssdKeypadBottomSheet(
        textController: textController,
        enabled: enabled,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return UssdKeypad(
      enabled: enabled,
      onKeyPressed: (key) {
        if (UssdUtils.isUssdCode(key)) {
          // Replace entire text with USSD code
          textController.text = key;
        } else {
          // Append key to current text
          textController.text += key;
        }
        textController.selection = TextSelection.fromPosition(
          TextPosition(offset: textController.text.length),
        );
      },
    );
  }
}
