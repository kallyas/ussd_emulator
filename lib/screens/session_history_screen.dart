import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/ussd_provider.dart';
import '../utils/design_system.dart';
import '../widgets/ussd_session_details.dart';

class SessionHistoryScreen extends StatelessWidget {
  const SessionHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<UssdProvider>();

    if (provider.sessionHistory.isEmpty) {
      return const _EmptyHistoryView();
    }

    return _HistoryListView(provider: provider);
  }
}

class _EmptyHistoryView extends StatelessWidget {
  const _EmptyHistoryView();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
                padding: const EdgeInsets.all(UssdDesignSystem.spacingXL),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.history_rounded,
                  size: 56,
                  color: colorScheme.onSurfaceVariant,
                ),
              )
              .animate()
              .scale(
                begin: const Offset(0.5, 0.5),
                end: const Offset(1.0, 1.0),
                duration: UssdDesignSystem.animationMedium,
                curve: Curves.elasticOut,
              )
              .fadeIn(duration: UssdDesignSystem.animationMedium),
          const SizedBox(height: UssdDesignSystem.spacingL),
          Text(
                'No session history yet',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              )
              .animate(delay: const Duration(milliseconds: 150))
              .fadeIn()
              .slideY(begin: 0.3, end: 0.0),
          const SizedBox(height: UssdDesignSystem.spacingS),
          Text(
                'Your recent USSD sessions will appear here.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              )
              .animate(delay: const Duration(milliseconds: 250))
              .fadeIn()
              .slideY(begin: 0.3, end: 0.0),
        ],
      ),
    );
  }
}

class _HistoryListView extends StatelessWidget {
  final UssdProvider provider;

  const _HistoryListView({required this.provider});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      itemCount: provider.sessionHistory.length,
      separatorBuilder: (context, index) =>
          const SizedBox(height: UssdDesignSystem.spacingM),
      itemBuilder: (context, index) {
        final session = provider.sessionHistory[index];
        return _SessionCard(session: session, index: index);
      },
    );
  }
}

class _SessionCard extends StatelessWidget {
  final dynamic session;
  final int index;

  const _SessionCard({required this.session, required this.index});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isActive = session.isActive as bool;

    return Card(
          elevation: isActive ? 3 : 1,
          color: colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(UssdDesignSystem.radiusL),
            side: isActive
                ? BorderSide(color: colorScheme.primary, width: 1.5)
                : BorderSide.none,
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(UssdDesignSystem.radiusL),
            onTap: () => UssdSessionDetails.show(context, session),
            child: Padding(
              padding: const EdgeInsets.all(UssdDesignSystem.spacingL),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(
                          UssdDesignSystem.spacingS,
                        ),
                        decoration: BoxDecoration(
                          color: isActive
                              ? colorScheme.primaryContainer
                              : colorScheme.surfaceContainer,
                          borderRadius: BorderRadius.circular(
                            UssdDesignSystem.radiusM,
                          ),
                        ),
                        child: Icon(
                          isActive
                              ? Icons.phone_in_talk_rounded
                              : Icons.phone_missed_rounded,
                          size: 20,
                          color: isActive
                              ? colorScheme.onPrimaryContainer
                              : colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(width: UssdDesignSystem.spacingM),
                      Expanded(
                        child: Text(
                          session.phoneNumber as String,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onSurface,
                              ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: UssdDesignSystem.spacingS),
                      _StatusBadge(isActive: isActive),
                    ],
                  ),
                  const SizedBox(height: UssdDesignSystem.spacingM),
                  _MetaRow(
                    icon: Icons.access_time_rounded,
                    label: 'Started',
                    value: _formatDateTime(session.createdAt as DateTime),
                    colorScheme: colorScheme,
                  ),
                  if (session.endedAt != null) ...[
                    const SizedBox(height: UssdDesignSystem.spacingXS),
                    _MetaRow(
                      icon: Icons.stop_circle_outlined,
                      label: 'Ended',
                      value: _formatDateTime(session.endedAt as DateTime),
                      colorScheme: colorScheme,
                    ),
                  ],
                  const SizedBox(height: UssdDesignSystem.spacingM),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          (session.responses as List).isNotEmpty
                              ? (session.responses as List).last.text as String
                              : 'No responses',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: colorScheme.onSurfaceVariant),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),
                      ),
                      const SizedBox(width: UssdDesignSystem.spacingS),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: UssdDesignSystem.spacingM,
                          vertical: UssdDesignSystem.spacingXS,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(
                            UssdDesignSystem.radiusS,
                          ),
                        ),
                        child: Text(
                          '${(session.responses as List).length} responses',
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                                color: colorScheme.onPrimaryContainer,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        )
        .animate(delay: Duration(milliseconds: index * 60))
        .fadeIn(duration: UssdDesignSystem.animationMedium)
        .slideY(
          begin: 0.2,
          end: 0.0,
          duration: UssdDesignSystem.animationMedium,
          curve: UssdDesignSystem.curveDefault,
        );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} '
        '${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}

class _StatusBadge extends StatelessWidget {
  final bool isActive;

  const _StatusBadge({required this.isActive});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: UssdDesignSystem.spacingM,
        vertical: UssdDesignSystem.spacingXS,
      ),
      decoration: BoxDecoration(
        color: isActive ? colorScheme.primary : colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(UssdDesignSystem.radiusM),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isActive) ...[
            Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: colorScheme.onPrimary,
                    shape: BoxShape.circle,
                  ),
                )
                .animate(onPlay: (c) => c.repeat())
                .fadeIn(duration: const Duration(milliseconds: 600))
                .then()
                .fadeOut(duration: const Duration(milliseconds: 600)),
            const SizedBox(width: 4),
          ],
          Text(
            isActive ? 'ACTIVE' : 'ENDED',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: isActive
                  ? colorScheme.onPrimary
                  : colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final ColorScheme colorScheme;

  const _MetaRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: colorScheme.onSurfaceVariant),
        const SizedBox(width: UssdDesignSystem.spacingXS),
        Text(
          '$label: ',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: colorScheme.onSurface),
        ),
      ],
    );
  }
}
