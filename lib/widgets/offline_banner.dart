import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/ussd_provider.dart';
import '../utils/design_system.dart';

/// A slim banner shown at the top of the screen when the device is offline.
/// Displays the number of queued requests and disappears when back online.
class OfflineBanner extends StatelessWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<UssdProvider>();

    if (!provider.isOffline) return const SizedBox.shrink();

    final colorScheme = Theme.of(context).colorScheme;
    final queueCount = provider.queuedRequestCount;

    return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            vertical: UssdDesignSystem.spacingS,
            horizontal: UssdDesignSystem.spacingM,
          ),
          decoration: BoxDecoration(
            color: colorScheme.errorContainer,
            border: Border(
              bottom: BorderSide(
                color: colorScheme.error.withOpacity(0.3),
                width: 1,
              ),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.cloud_off_rounded,
                size: 16,
                color: colorScheme.onErrorContainer,
              ),
              const SizedBox(width: UssdDesignSystem.spacingS),
              Expanded(
                child: Text(
                  queueCount > 0
                      ? 'Offline — $queueCount request${queueCount == 1 ? '' : 's'} queued'
                      : 'Offline — requests will be queued until reconnected',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onErrorContainer,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              if (queueCount > 0)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: UssdDesignSystem.spacingS,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.error,
                    borderRadius: BorderRadius.circular(
                      UssdDesignSystem.radiusM,
                    ),
                  ),
                  child: Text(
                    '$queueCount',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: colorScheme.onError,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
        )
        .animate()
        .slideY(
          begin: -1.0,
          end: 0.0,
          duration: UssdDesignSystem.animationMedium,
          curve: UssdDesignSystem.curveDefault,
        )
        .fadeIn(duration: UssdDesignSystem.animationMedium);
  }
}

/// A small chip shown on a cached response bubble to indicate it came from
/// the local cache rather than a live network call.
class CacheHitChip extends StatelessWidget {
  const CacheHitChip({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: UssdDesignSystem.spacingS,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: colorScheme.tertiaryContainer,
        borderRadius: BorderRadius.circular(UssdDesignSystem.radiusS),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.offline_bolt_rounded,
            size: 10,
            color: colorScheme.onTertiaryContainer,
          ),
          const SizedBox(width: 3),
          Text(
            'cached',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: colorScheme.onTertiaryContainer,
              fontSize: 9,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
