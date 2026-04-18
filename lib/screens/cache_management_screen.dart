import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/ussd_provider.dart';
import '../services/ussd_cache_service.dart';
import '../services/offline_queue_service.dart';
import '../utils/design_system.dart';

class CacheManagementScreen extends StatelessWidget {
  const CacheManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Offline & Cache'),
        backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
        elevation: 0,
      ),
      body: Consumer<UssdProvider>(
        builder: (context, provider, _) {
          final cache = provider.cacheService;
          final queue = provider.queueService;

          return ListView(
            padding: const EdgeInsets.all(UssdDesignSystem.spacingM),
            children: [
              _StatsCard(cache: cache, queue: queue)
                  .animate()
                  .fadeIn(duration: UssdDesignSystem.animationMedium)
                  .slideY(begin: 0.2, end: 0.0),
              const SizedBox(height: UssdDesignSystem.spacingM),
              _QueueSection(queue: queue, provider: provider)
                  .animate(delay: const Duration(milliseconds: 100))
                  .fadeIn(duration: UssdDesignSystem.animationMedium)
                  .slideY(begin: 0.2, end: 0.0),
              const SizedBox(height: UssdDesignSystem.spacingM),
              _CacheSection(cache: cache)
                  .animate(delay: const Duration(milliseconds: 200))
                  .fadeIn(duration: UssdDesignSystem.animationMedium)
                  .slideY(begin: 0.2, end: 0.0),
              const SizedBox(height: UssdDesignSystem.spacingM),
              _ActionsSection(cache: cache, queue: queue)
                  .animate(delay: const Duration(milliseconds: 300))
                  .fadeIn(duration: UssdDesignSystem.animationMedium)
                  .slideY(begin: 0.2, end: 0.0),
            ],
          );
        },
      ),
    );
  }
}

class _StatsCard extends StatelessWidget {
  final UssdCacheService cache;
  final OfflineQueueService queue;

  const _StatsCard({required this.cache, required this.queue});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(UssdDesignSystem.radiusL),
      ),
      child: Padding(
        padding: const EdgeInsets.all(UssdDesignSystem.spacingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Statistics',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: UssdDesignSystem.spacingM),
            Row(
              children: [
                Expanded(
                  child: _StatTile(
                    icon: Icons.storage_rounded,
                    label: 'Cached',
                    value: '${cache.entryCount}',
                    color: colorScheme.primary,
                  ),
                ),
                Expanded(
                  child: _StatTile(
                    icon: Icons.offline_bolt_rounded,
                    label: 'Hit rate',
                    value: '${cache.hitRate.toStringAsFixed(0)}%',
                    color: colorScheme.secondary,
                  ),
                ),
                Expanded(
                  child: _StatTile(
                    icon: Icons.queue_rounded,
                    label: 'Queued',
                    value: '${queue.length}',
                    color: queue.isEmpty
                        ? colorScheme.onSurfaceVariant
                        : colorScheme.error,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: UssdDesignSystem.spacingXS),
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _QueueSection extends StatelessWidget {
  final OfflineQueueService queue;
  final UssdProvider provider;

  const _QueueSection({required this.queue, required this.provider});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(UssdDesignSystem.radiusL),
      ),
      child: Padding(
        padding: const EdgeInsets.all(UssdDesignSystem.spacingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.queue_rounded, color: colorScheme.primary, size: 20),
                const SizedBox(width: UssdDesignSystem.spacingS),
                Text(
                  'Offline Queue',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: UssdDesignSystem.spacingM),
            if (queue.isEmpty)
              Text(
                'No requests queued.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              )
            else
              ...queue.items.map(
                (item) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    Icons.pending_rounded,
                    color: colorScheme.error,
                    size: 20,
                  ),
                  title: Text(
                    item.request.serviceCode,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  subtitle: Text(
                    '${item.request.phoneNumber} · retries: ${item.retryCount}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.close_rounded, size: 18),
                    onPressed: () => queue.remove(item.id),
                    tooltip: 'Remove from queue',
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _CacheSection extends StatelessWidget {
  final UssdCacheService cache;

  const _CacheSection({required this.cache});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final entries = cache.entries;

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(UssdDesignSystem.radiusL),
      ),
      child: Padding(
        padding: const EdgeInsets.all(UssdDesignSystem.spacingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.storage_rounded,
                  color: colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: UssdDesignSystem.spacingS),
                Text(
                  'Cached Responses',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: UssdDesignSystem.spacingM),
            if (entries.isEmpty)
              Text(
                'No cached responses.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              )
            else
              ...entries.map(
                (entry) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    Icons.offline_bolt_rounded,
                    color: colorScheme.secondary,
                    size: 20,
                  ),
                  title: Text(
                    entry.key.split(':').first,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    'hits: ${entry.value.hitCount} · '
                    'expires: ${_formatExpiry(entry.value)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _formatExpiry(CacheEntry entry) {
    final remaining = entry.ttl - DateTime.now().difference(entry.timestamp);
    if (remaining.inHours > 0) return '${remaining.inHours}h';
    if (remaining.inMinutes > 0) return '${remaining.inMinutes}m';
    return 'soon';
  }
}

class _ActionsSection extends StatelessWidget {
  final UssdCacheService cache;
  final OfflineQueueService queue;

  const _ActionsSection({required this.cache, required this.queue});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(UssdDesignSystem.radiusL),
      ),
      child: Padding(
        padding: const EdgeInsets.all(UssdDesignSystem.spacingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Actions',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: UssdDesignSystem.spacingM),
            OutlinedButton.icon(
              onPressed: () async {
                await cache.evictExpired();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Expired entries removed.')),
                  );
                }
              },
              icon: const Icon(Icons.cleaning_services_rounded),
              label: const Text('Evict expired entries'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
              ),
            ),
            const SizedBox(height: UssdDesignSystem.spacingS),
            FilledButton.icon(
              onPressed: cache.entryCount == 0
                  ? null
                  : () => _confirmClear(
                        context,
                        title: 'Clear cache',
                        message:
                            'Remove all ${cache.entryCount} cached responses?',
                        onConfirm: () => cache.clearAll(),
                      ),
              icon: const Icon(Icons.delete_sweep_rounded),
              label: const Text('Clear all cache'),
              style: FilledButton.styleFrom(
                backgroundColor: colorScheme.error,
                foregroundColor: colorScheme.onError,
                minimumSize: const Size(double.infinity, 48),
              ),
            ),
            const SizedBox(height: UssdDesignSystem.spacingS),
            FilledButton.icon(
              onPressed: queue.isEmpty
                  ? null
                  : () => _confirmClear(
                        context,
                        title: 'Clear queue',
                        message:
                            'Discard all ${queue.length} queued requests?',
                        onConfirm: () => queue.clearAll(),
                      ),
              icon: const Icon(Icons.clear_all_rounded),
              label: const Text('Clear offline queue'),
              style: FilledButton.styleFrom(
                backgroundColor: colorScheme.error,
                foregroundColor: colorScheme.onError,
                minimumSize: const Size(double.infinity, 48),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmClear(
    BuildContext context, {
    required String title,
    required String message,
    required VoidCallback onConfirm,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(UssdDesignSystem.radiusL),
        ),
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            onPressed: () {
              onConfirm();
              Navigator.of(context).pop();
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }
}
