import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/ussd_provider.dart';
import '../models/endpoint_config.dart';
import '../utils/design_system.dart';
import '../utils/page_transitions.dart';
import 'cache_management_screen.dart';

class EndpointConfigScreen extends StatelessWidget {
  const EndpointConfigScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<UssdProvider>();

    return SafeArea(
      child: Stack(
        children: [
          provider.endpointConfigs.isEmpty
              ? _EmptyConfigView()
              : ListView.separated(
                  padding: const EdgeInsets.only(
                    left: 16,
                    right: 16,
                    top: 24,
                    bottom: 100,
                  ),
                  itemCount: provider.endpointConfigs.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: UssdDesignSystem.spacingM),
                  itemBuilder: (context, index) {
                    final config = provider.endpointConfigs[index];
                    final isActive =
                        provider.activeEndpointConfig?.name == config.name;
                    return _EndpointCard(
                      config: config,
                      isActive: isActive,
                      index: index,
                      provider: provider,
                    );
                  },
                ),
          Positioned(
            bottom: 24,
            right: 24,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                FloatingActionButton.small(
                  heroTag: 'cache_fab',
                  onPressed: () => Navigator.push(
                    context,
                    PageTransitions.slideFromRight(
                      const CacheManagementScreen(),
                    ),
                  ),
                  backgroundColor:
                      Theme.of(context).colorScheme.secondaryContainer,
                  foregroundColor:
                      Theme.of(context).colorScheme.onSecondaryContainer,
                  tooltip: 'Offline & Cache',
                  child: const Icon(Icons.offline_bolt_rounded),
                ),
                const SizedBox(height: 12),
                FloatingActionButton.extended(
                  heroTag: 'add_endpoint_fab',
                  onPressed: () => _addEndpoint(context, provider),
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Add Endpoint'),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(UssdDesignSystem.radiusL),
                  ),
                )
                    .animate()
                    .scale(
                      begin: const Offset(0.0, 0.0),
                      end: const Offset(1.0, 1.0),
                      duration: UssdDesignSystem.animationMedium,
                      curve: Curves.elasticOut,
                      delay: const Duration(milliseconds: 300),
                    )
                    .fadeIn(delay: const Duration(milliseconds: 200)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _addEndpoint(BuildContext context, UssdProvider provider) {
    _showEndpointDialog(context, provider);
  }
}

class _EmptyConfigView extends StatelessWidget {
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
              Icons.cloud_off_rounded,
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
              .fadeIn(),
          const SizedBox(height: UssdDesignSystem.spacingL),
          Text(
            'No endpoints configured',
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
            'Add an endpoint to connect to a USSD service.',
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

class _EndpointCard extends StatelessWidget {
  final EndpointConfig config;
  final bool isActive;
  final int index;
  final UssdProvider provider;

  const _EndpointCard({
    required this.config,
    required this.isActive,
    required this.index,
    required this.provider,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: isActive ? 4 : 1,
      color: isActive ? colorScheme.primaryContainer : colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(UssdDesignSystem.radiusL),
        side: isActive
            ? BorderSide(color: colorScheme.primary, width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(UssdDesignSystem.radiusL),
        onTap: () {
          if (!isActive) provider.setActiveEndpointConfig(config);
        },
        child: Padding(
          padding: const EdgeInsets.all(UssdDesignSystem.spacingL),
          child: Row(
            children: [
              _StatusIcon(isActive: isActive),
              const SizedBox(width: UssdDesignSystem.spacingM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      config.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight:
                            isActive ? FontWeight.bold : FontWeight.normal,
                        color: isActive
                            ? colorScheme.onPrimaryContainer
                            : colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: UssdDesignSystem.spacingXS),
                    Text(
                      config.url,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: isActive
                            ? colorScheme.onPrimaryContainer.withOpacity(0.7)
                            : colorScheme.onSurfaceVariant,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (config.headers.isNotEmpty) ...[
                      const SizedBox(height: UssdDesignSystem.spacingXS),
                      Row(
                        children: [
                          Icon(
                            Icons.label_outline_rounded,
                            size: 12,
                            color: isActive
                                ? colorScheme.onPrimaryContainer.withOpacity(
                                    0.6,
                                  )
                                : colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${config.headers.length} header${config.headers.length == 1 ? '' : 's'}',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: isActive
                                  ? colorScheme.onPrimaryContainer.withOpacity(
                                      0.6,
                                    )
                                  : colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              PopupMenuButton<String>(
                icon: Icon(
                  Icons.more_vert_rounded,
                  color: isActive
                      ? colorScheme.onPrimaryContainer
                      : colorScheme.onSurfaceVariant,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(UssdDesignSystem.radiusM),
                ),
                onSelected: (value) {
                  switch (value) {
                    case 'activate':
                      provider.setActiveEndpointConfig(config);
                    case 'test':
                      _testEndpoint(context, provider, config);
                    case 'edit':
                      _editEndpoint(context, provider, config, index);
                    case 'delete':
                      _deleteEndpoint(context, provider, index);
                  }
                },
                itemBuilder: (context) => [
                  if (!isActive)
                    const PopupMenuItem(
                      value: 'activate',
                      child: ListTile(
                        leading: Icon(Icons.check_circle_outline_rounded),
                        title: Text('Activate'),
                        contentPadding: EdgeInsets.zero,
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                  const PopupMenuItem(
                    value: 'test',
                    child: ListTile(
                      leading: Icon(Icons.wifi_tethering_rounded),
                      title: Text('Test'),
                      contentPadding: EdgeInsets.zero,
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'edit',
                    child: ListTile(
                      leading: Icon(Icons.edit_rounded),
                      title: Text('Edit'),
                      contentPadding: EdgeInsets.zero,
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: ListTile(
                      leading: Icon(Icons.delete_outline_rounded),
                      title: Text('Delete'),
                      contentPadding: EdgeInsets.zero,
                      visualDensity: VisualDensity.compact,
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

  void _testEndpoint(
    BuildContext context,
    UssdProvider provider,
    EndpointConfig config,
  ) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(UssdDesignSystem.radiusL),
        ),
        content: const Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 16),
            Text('Testing endpoint...'),
          ],
        ),
      ),
    );

    final success = await provider.testEndpointConfig(config);

    if (context.mounted) {
      Navigator.of(context).pop();
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(UssdDesignSystem.radiusL),
          ),
          icon: Icon(
            success
                ? Icons.check_circle_rounded
                : Icons.error_outline_rounded,
            color: success
                ? Theme.of(context).colorScheme.secondary
                : Theme.of(context).colorScheme.error,
            size: 40,
          ),
          title: Text(success ? 'Test Successful' : 'Test Failed'),
          content: Text(
            success
                ? 'The endpoint is reachable and responding correctly.'
                : 'The endpoint is not reachable or not responding correctly.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  void _editEndpoint(
    BuildContext context,
    UssdProvider provider,
    EndpointConfig config,
    int index,
  ) {
    _showEndpointDialog(context, provider, config: config, index: index);
  }

  void _deleteEndpoint(
    BuildContext context,
    UssdProvider provider,
    int index,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(UssdDesignSystem.radiusL),
        ),
        icon: Icon(
          Icons.delete_outline_rounded,
          color: Theme.of(context).colorScheme.error,
          size: 40,
        ),
        title: const Text('Delete Endpoint'),
        content: const Text(
          'Are you sure you want to delete this endpoint configuration?',
        ),
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
              provider.deleteEndpointConfig(index);
              Navigator.of(context).pop();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _StatusIcon extends StatelessWidget {
  final bool isActive;

  const _StatusIcon({required this.isActive});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (isActive) {
      return Container(
        padding: const EdgeInsets.all(UssdDesignSystem.spacingS),
        decoration: BoxDecoration(
          color: colorScheme.primary,
          borderRadius: BorderRadius.circular(UssdDesignSystem.radiusM),
        ),
        child: Icon(
          Icons.check_rounded,
          color: colorScheme.onPrimary,
          size: 20,
        ),
      )
          .animate(onPlay: (c) => c.repeat(reverse: true))
          .shimmer(
            duration: const Duration(milliseconds: 2000),
            color: colorScheme.onPrimary.withOpacity(0.3),
          );
    }

    return Container(
      padding: const EdgeInsets.all(UssdDesignSystem.spacingS),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(UssdDesignSystem.radiusM),
      ),
      child: Icon(
        Icons.cloud_outlined,
        color: colorScheme.onSurfaceVariant,
        size: 20,
      ),
    );
  }
}

void _showEndpointDialog(
  BuildContext context,
  UssdProvider provider, {
  EndpointConfig? config,
  int? index,
}) {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController(text: config?.name ?? '');
  final urlController = TextEditingController(text: config?.url ?? '');
  final headersController = TextEditingController(
    text: config?.headers.entries
            .map((e) => '${e.key}: ${e.value}')
            .join('\n') ??
        '',
  );

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(UssdDesignSystem.radiusL),
      ),
      title: Text(config == null ? 'Add Endpoint' : 'Edit Endpoint'),
      content: SizedBox(
        width: double.maxFinite,
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Name *',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      UssdDesignSystem.radiusM,
                    ),
                  ),
                  hintText: 'Enter configuration name',
                  prefixIcon: const Icon(Icons.label_outline_rounded),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Name is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: UssdDesignSystem.spacingM),
              TextFormField(
                controller: urlController,
                decoration: InputDecoration(
                  labelText: 'URL *',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      UssdDesignSystem.radiusM,
                    ),
                  ),
                  hintText: 'https://example.com/ussd',
                  prefixIcon: const Icon(Icons.link_rounded),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'URL is required';
                  }
                  if (!value.startsWith('http://') &&
                      !value.startsWith('https://')) {
                    return 'URL must start with http:// or https://';
                  }
                  return null;
                },
              ),
              const SizedBox(height: UssdDesignSystem.spacingM),
              TextFormField(
                controller: headersController,
                decoration: InputDecoration(
                  labelText: 'Headers (key: value, one per line)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      UssdDesignSystem.radiusM,
                    ),
                  ),
                  hintText:
                      'Content-Type: application/json\nAuthorization: Bearer token',
                  prefixIcon: const Icon(Icons.code_rounded),
                  alignLabelWithHint: true,
                ),
                maxLines: 3,
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    for (final line in value.split('\n')) {
                      if (line.trim().isNotEmpty && !line.contains(':')) {
                        return 'Invalid header format. Use "key: value"';
                      }
                    }
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () async {
            if (!formKey.currentState!.validate()) return;

            final headers = <String, String>{};
            for (final line in headersController.text.split('\n')) {
              if (line.trim().isNotEmpty) {
                final parts = line.split(':');
                if (parts.length >= 2) {
                  headers[parts[0].trim()] = parts.skip(1).join(':').trim();
                }
              }
            }

            final newConfig = EndpointConfig(
              name: nameController.text.trim(),
              url: urlController.text.trim(),
              headers: headers,
              isActive: config?.isActive ?? false,
            );

            try {
              if (config == null) {
                await provider.addEndpointConfig(newConfig);
              } else {
                await provider.updateEndpointConfig(index!, newConfig);
              }
              if (context.mounted) Navigator.of(context).pop();
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(e.toString()),
                    backgroundColor: Theme.of(context).colorScheme.error,
                  ),
                );
              }
            }
          },
          child: Text(config == null ? 'Add' : 'Save'),
        ),
      ],
    ),
  );
}
