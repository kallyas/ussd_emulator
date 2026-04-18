import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../services/analytics_service.dart';
import '../models/analytics_models.dart';
import '../utils/design_system.dart';

class AnalyticsDashboardScreen extends StatelessWidget {
  const AnalyticsDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final analytics = context.watch<AnalyticsService>();
    final summary = analytics.computeSummary();

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.symmetric(
          horizontal: UssdDesignSystem.spacingM,
          vertical: UssdDesignSystem.spacingM,
        ),
        children: [
          _SummaryRow(summary: summary)
              .animate()
              .fadeIn(duration: UssdDesignSystem.animationMedium)
              .slideY(begin: 0.2, end: 0.0),
          const SizedBox(height: UssdDesignSystem.spacingM),
          _ResponseTimeCard(summary: summary, metrics: analytics.metrics)
              .animate(delay: const Duration(milliseconds: 80))
              .fadeIn(duration: UssdDesignSystem.animationMedium)
              .slideY(begin: 0.2, end: 0.0),
          const SizedBox(height: UssdDesignSystem.spacingM),
          _TopServiceCodesCard(summary: summary)
              .animate(delay: const Duration(milliseconds: 160))
              .fadeIn(duration: UssdDesignSystem.animationMedium)
              .slideY(begin: 0.2, end: 0.0),
          const SizedBox(height: UssdDesignSystem.spacingM),
          _EndpointPerformanceCard(summary: summary)
              .animate(delay: const Duration(milliseconds: 240))
              .fadeIn(duration: UssdDesignSystem.animationMedium)
              .slideY(begin: 0.2, end: 0.0),
          const SizedBox(height: UssdDesignSystem.spacingM),
          _RecentErrorsCard(events: analytics.events)
              .animate(delay: const Duration(milliseconds: 320))
              .fadeIn(duration: UssdDesignSystem.animationMedium)
              .slideY(begin: 0.2, end: 0.0),
          const SizedBox(height: UssdDesignSystem.spacingM),
          _ActionsCard(analytics: analytics)
              .animate(delay: const Duration(milliseconds: 400))
              .fadeIn(duration: UssdDesignSystem.animationMedium)
              .slideY(begin: 0.2, end: 0.0),
          const SizedBox(height: UssdDesignSystem.spacingXXL),
        ],
      ),
    );
  }
}

// ── Summary row ──────────────────────────────────────────────────────────────

class _SummaryRow extends StatelessWidget {
  final AnalyticsSummary summary;
  const _SummaryRow({required this.summary});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: Icons.phone_in_talk_rounded,
            label: 'Sessions',
            value: '${summary.totalSessions}',
            color: colorScheme.primary,
          ),
        ),
        const SizedBox(width: UssdDesignSystem.spacingS),
        Expanded(
          child: _StatCard(
            icon: Icons.send_rounded,
            label: 'Requests',
            value: '${summary.totalRequests}',
            color: colorScheme.secondary,
          ),
        ),
        const SizedBox(width: UssdDesignSystem.spacingS),
        Expanded(
          child: _StatCard(
            icon: Icons.error_outline_rounded,
            label: 'Errors',
            value: '${summary.totalErrors}',
            color: summary.totalErrors > 0
                ? colorScheme.error
                : colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(width: UssdDesignSystem.spacingS),
        Expanded(
          child: _StatCard(
            icon: Icons.timer_outlined,
            label: 'Avg ms',
            value: summary.avgResponseTimeMs == 0
                ? '—'
                : '${summary.avgResponseTimeMs.round()}',
            color: colorScheme.tertiary,
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(UssdDesignSystem.radiusL),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: UssdDesignSystem.spacingM,
          horizontal: UssdDesignSystem.spacingS,
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: UssdDesignSystem.spacingXS),
            Text(
              value,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Response time card ───────────────────────────────────────────────────────

class _ResponseTimeCard extends StatelessWidget {
  final AnalyticsSummary summary;
  final List<ResponseMetric> metrics;

  const _ResponseTimeCard({required this.summary, required this.metrics});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final recent = metrics.reversed.take(20).toList().reversed.toList();

    return _DashCard(
      icon: Icons.speed_rounded,
      title: 'Response Times',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _MetricPill(
                label: 'Avg',
                value: summary.avgResponseTimeMs == 0
                    ? '—'
                    : '${summary.avgResponseTimeMs.round()} ms',
                color: colorScheme.primary,
              ),
              const SizedBox(width: UssdDesignSystem.spacingS),
              _MetricPill(
                label: 'Error rate',
                value: '${summary.errorRate.toStringAsFixed(1)}%',
                color: summary.errorRate > 10
                    ? colorScheme.error
                    : colorScheme.secondary,
              ),
              const SizedBox(width: UssdDesignSystem.spacingS),
              _MetricPill(
                label: 'Total time',
                value: _formatDuration(summary.totalSessionDuration),
                color: colorScheme.tertiary,
              ),
            ],
          ),
          if (recent.isNotEmpty) ...[
            const SizedBox(height: UssdDesignSystem.spacingM),
            Text(
              'Last ${recent.length} requests',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: UssdDesignSystem.spacingS),
            _ResponseTimeBar(metrics: recent),
          ] else
            Padding(
              padding: const EdgeInsets.only(top: UssdDesignSystem.spacingM),
              child: Text(
                'No requests recorded yet.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _formatDuration(Duration d) {
    if (d.inHours > 0) return '${d.inHours}h ${d.inMinutes.remainder(60)}m';
    if (d.inMinutes > 0) return '${d.inMinutes}m ${d.inSeconds.remainder(60)}s';
    return '${d.inSeconds}s';
  }
}

class _ResponseTimeBar extends StatelessWidget {
  final List<ResponseMetric> metrics;
  const _ResponseTimeBar({required this.metrics});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final maxMs = metrics.map((m) => m.responseTimeMs).fold(1, (a, b) => a > b ? a : b);

    return SizedBox(
      height: 48,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: metrics.map((m) {
          final frac = maxMs == 0 ? 0.0 : m.responseTimeMs / maxMs;
          return Expanded(
            child: Tooltip(
              message: '${m.responseTimeMs} ms\n${m.serviceCode}',
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 1),
                height: 8 + (40 * frac),
                decoration: BoxDecoration(
                  color: m.success ? colorScheme.primary : colorScheme.error,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ── Top service codes ────────────────────────────────────────────────────────

class _TopServiceCodesCard extends StatelessWidget {
  final AnalyticsSummary summary;
  const _TopServiceCodesCard({required this.summary});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final sorted = summary.sessionsByServiceCode.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final top = sorted.take(5).toList();
    final total = summary.totalSessions == 0 ? 1 : summary.totalSessions;

    return _DashCard(
      icon: Icons.dialpad_rounded,
      title: 'Top Service Codes',
      child: top.isEmpty
          ? Text(
              'No sessions recorded yet.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            )
          : Column(
              children: top.map((entry) {
                final frac = entry.value / total;
                return Padding(
                  padding: const EdgeInsets.only(bottom: UssdDesignSystem.spacingS),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              entry.key,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(fontWeight: FontWeight.w600),
                            ),
                          ),
                          Text(
                            '${entry.value} session${entry.value == 1 ? '' : 's'}',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: colorScheme.onSurfaceVariant),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: frac,
                          minHeight: 6,
                          backgroundColor: colorScheme.surfaceContainerHighest,
                          valueColor: AlwaysStoppedAnimation(colorScheme.primary),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
    );
  }
}

// ── Endpoint performance ─────────────────────────────────────────────────────

class _EndpointPerformanceCard extends StatelessWidget {
  final AnalyticsSummary summary;
  const _EndpointPerformanceCard({required this.summary});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final endpoints = summary.avgResponseTimeByEndpoint.entries.toList()
      ..sort((a, b) => a.value.compareTo(b.value));

    return _DashCard(
      icon: Icons.cloud_rounded,
      title: 'Endpoint Performance',
      child: endpoints.isEmpty
          ? Text(
              'No endpoint data yet.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            )
          : Column(
              children: endpoints.map((entry) {
                final errors = summary.errorsByEndpoint[entry.key] ?? 0;
                final avgMs = entry.value.round();
                final isSlowish = avgMs > 2000;
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  leading: Icon(
                    Icons.circle,
                    size: 10,
                    color: isSlowish ? colorScheme.error : colorScheme.secondary,
                  ),
                  title: Text(
                    entry.key,
                    style: Theme.of(context).textTheme.bodyMedium
                        ?.copyWith(fontWeight: FontWeight.w500),
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '$avgMs ms',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: isSlowish
                              ? colorScheme.error
                              : colorScheme.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (errors > 0) ...[
                        const SizedBox(width: UssdDesignSystem.spacingS),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: colorScheme.errorContainer,
                            borderRadius: BorderRadius.circular(
                              UssdDesignSystem.radiusS,
                            ),
                          ),
                          child: Text(
                            '$errors err',
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(color: colorScheme.onErrorContainer),
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              }).toList(),
            ),
    );
  }
}

// ── Recent errors ────────────────────────────────────────────────────────────

class _RecentErrorsCard extends StatelessWidget {
  final List<SessionEvent> events;
  const _RecentErrorsCard({required this.events});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final errors = events
        .where((e) => e.type == SessionEventType.error)
        .toList()
        .reversed
        .take(5)
        .toList();

    return _DashCard(
      icon: Icons.warning_amber_rounded,
      title: 'Recent Errors',
      child: errors.isEmpty
          ? Row(
              children: [
                Icon(
                  Icons.check_circle_outline_rounded,
                  size: 16,
                  color: colorScheme.secondary,
                ),
                const SizedBox(width: UssdDesignSystem.spacingS),
                Text(
                  'No errors recorded.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.secondary,
                  ),
                ),
              ],
            )
          : Column(
              children: errors.map((e) {
                final msg = e.metadata['error'] as String? ?? 'Unknown error';
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  leading: Icon(
                    Icons.error_outline_rounded,
                    size: 16,
                    color: colorScheme.error,
                  ),
                  title: Text(
                    msg,
                    style: Theme.of(context).textTheme.bodySmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    '${e.serviceCode} · ${_formatTime(e.timestamp)}',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                );
              }).toList(),
            ),
    );
  }

  String _formatTime(DateTime dt) =>
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')} '
      '${dt.day}/${dt.month}';
}

// ── Actions card (export + clear) ────────────────────────────────────────────

class _ActionsCard extends StatelessWidget {
  final AnalyticsService analytics;
  const _ActionsCard({required this.analytics});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return _DashCard(
      icon: Icons.settings_rounded,
      title: 'Data & Settings',
      child: Column(
        children: [
          // Analytics toggle
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            dense: true,
            title: Text(
              'Enable analytics',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            subtitle: Text(
              'Track session events and response times',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            value: analytics.enabled,
            onChanged: analytics.setEnabled,
          ),
          const Divider(height: UssdDesignSystem.spacingL),
          // Export buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: analytics.metrics.isEmpty
                      ? null
                      : () => _export(context, 'csv'),
                  icon: const Icon(Icons.table_chart_rounded, size: 18),
                  label: const Text('CSV'),
                ),
              ),
              const SizedBox(width: UssdDesignSystem.spacingS),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: analytics.events.isEmpty && analytics.metrics.isEmpty
                      ? null
                      : () => _export(context, 'json'),
                  icon: const Icon(Icons.data_object_rounded, size: 18),
                  label: const Text('JSON'),
                ),
              ),
            ],
          ),
          const SizedBox(height: UssdDesignSystem.spacingS),
          FilledButton.icon(
            onPressed: analytics.events.isEmpty && analytics.metrics.isEmpty
                ? null
                : () => _confirmClear(context),
            icon: const Icon(Icons.delete_sweep_rounded, size: 18),
            label: const Text('Clear all analytics data'),
            style: FilledButton.styleFrom(
              backgroundColor: colorScheme.error,
              foregroundColor: colorScheme.onError,
              minimumSize: const Size(double.infinity, 44),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _export(BuildContext context, String format) async {
    try {
      final content = format == 'csv'
          ? analytics.exportCsv()
          : analytics.exportJson();
      final ext = format == 'csv' ? 'csv' : 'json';
      final dir = await getTemporaryDirectory();
      final file = File(
        '${dir.path}/ussd_analytics_${DateTime.now().millisecondsSinceEpoch}.$ext',
      );
      await file.writeAsString(content);
      await Share.shareXFiles(
        [XFile(file.path)],
        subject: 'USSD Analytics Export',
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export failed: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  void _confirmClear(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(UssdDesignSystem.radiusL),
        ),
        title: const Text('Clear analytics data'),
        content: const Text(
          'This will permanently delete all recorded events and metrics.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
              foregroundColor: Theme.of(ctx).colorScheme.onError,
            ),
            onPressed: () {
              analytics.clearAll();
              Navigator.of(ctx).pop();
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }
}

// ── Shared card shell ────────────────────────────────────────────────────────

class _DashCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget child;

  const _DashCard({
    required this.icon,
    required this.title,
    required this.child,
  });

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
                Icon(icon, size: 18, color: colorScheme.primary),
                const SizedBox(width: UssdDesignSystem.spacingS),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: UssdDesignSystem.spacingM),
            child,
          ],
        ),
      ),
    );
  }
}

class _MetricPill extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _MetricPill({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: UssdDesignSystem.spacingM,
        vertical: UssdDesignSystem.spacingXS,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(UssdDesignSystem.radiusM),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }
}
