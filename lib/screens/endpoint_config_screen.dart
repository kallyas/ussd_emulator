import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/ussd_provider.dart';
import '../models/endpoint_config.dart';

class EndpointConfigScreen extends StatelessWidget {
  const EndpointConfigScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<UssdProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Endpoint Configuration'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: provider.endpointConfigs.length,
        itemBuilder: (context, index) {
          final config = provider.endpointConfigs[index];
          final isActive = provider.activeEndpointConfig?.name == config.name;

          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: Icon(
                isActive
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
                color: isActive ? Colors.green : null,
              ),
              title: Text(
                config.name,
                style: TextStyle(
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(config.url),
                  if (config.headers.isNotEmpty)
                    Text(
                      'Headers: ${config.headers.length}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                ],
              ),
              trailing: PopupMenuButton<String>(
                onSelected: (value) {
                  switch (value) {
                    case 'activate':
                      provider.setActiveEndpointConfig(config);
                      break;
                    case 'test':
                      _testEndpoint(context, provider, config);
                      break;
                    case 'edit':
                      _editEndpoint(context, provider, config, index);
                      break;
                    case 'delete':
                      _deleteEndpoint(context, provider, index);
                      break;
                  }
                },
                itemBuilder: (context) => [
                  if (!isActive)
                    const PopupMenuItem(
                      value: 'activate',
                      child: Text('Activate'),
                    ),
                  const PopupMenuItem(value: 'test', child: Text('Test')),
                  const PopupMenuItem(value: 'edit', child: Text('Edit')),
                  const PopupMenuItem(value: 'delete', child: Text('Delete')),
                ],
              ),
              onTap: () {
                if (!isActive) {
                  provider.setActiveEndpointConfig(config);
                }
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addEndpoint(context, provider),
        child: const Icon(Icons.add),
      ),
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
      builder: (context) => const AlertDialog(
        content: Row(
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

  void _addEndpoint(BuildContext context, UssdProvider provider) {
    _showEndpointDialog(context, provider);
  }

  void _editEndpoint(
    BuildContext context,
    UssdProvider provider,
    EndpointConfig config,
    int index,
  ) {
    _showEndpointDialog(context, provider, config: config, index: index);
  }

  void _deleteEndpoint(BuildContext context, UssdProvider provider, int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Endpoint'),
        content: const Text(
          'Are you sure you want to delete this endpoint configuration?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
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
      text:
          config?.headers.entries
              .map((e) => '${e.key}: ${e.value}')
              .join('\n') ??
          '',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
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
                  decoration: const InputDecoration(
                    labelText: 'Name *',
                    border: OutlineInputBorder(),
                    hintText: 'Enter configuration name',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Name is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: urlController,
                  decoration: const InputDecoration(
                    labelText: 'URL *',
                    border: OutlineInputBorder(),
                    hintText: 'https://example.com/ussd',
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
                const SizedBox(height: 16),
                TextFormField(
                  controller: headersController,
                  decoration: const InputDecoration(
                    labelText: 'Headers (key: value, one per line)',
                    border: OutlineInputBorder(),
                    hintText:
                        'Content-Type: application/json\nAuthorization: Bearer token',
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
          TextButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) {
                return;
              }

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

                if (context.mounted) {
                  Navigator.of(context).pop();
                }
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
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
