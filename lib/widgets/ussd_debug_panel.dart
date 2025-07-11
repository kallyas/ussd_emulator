import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/ussd_request.dart';
import '../models/ussd_session.dart';
import 'dart:convert';

class UssdDebugPanel extends StatelessWidget {
  final UssdSession? session;
  final UssdRequest? lastRequest;

  const UssdDebugPanel({
    super.key,
    this.session,
    this.lastRequest,
  });

  static void show(BuildContext context, {UssdSession? session, UssdRequest? lastRequest}) {
    if (session == null && lastRequest == null) return;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => UssdDebugPanel(session: session, lastRequest: lastRequest),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (session == null && lastRequest == null) {
      return const SizedBox.shrink();
    }

    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.bug_report,
                  size: 20,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
                const SizedBox(width: 12),
                Text(
                  'API Request Debug',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: Icon(
                    Icons.close,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (session != null) ...[
                    _buildSessionInfo(context),
                    const SizedBox(height: 24),
                  ],
                  if (lastRequest != null) ...[
                    _buildRequestFormat(context),
                    const SizedBox(height: 24),
                    _buildPathEvolution(context),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionInfo(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Session Information',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        _buildInfoRow('Session ID', session!.id),
        _buildInfoRow('Service Code', session!.serviceCode),
        _buildInfoRow('Phone Number', session!.phoneNumber),
        _buildInfoRow('Current Path', session!.ussdPath.join(' → ')),
        _buildInfoRow('Path as Text', '"${session!.pathAsText}"'),
        _buildInfoRow('Is Initial Request', session!.isInitialRequest.toString()),
      ],
    );
  }

  Widget _buildRequestFormat(BuildContext context) {
    final requestJson = JsonEncoder.withIndent('  ').convert(lastRequest!.toJson());
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'API Request Format',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.copy, size: 16),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: requestJson));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Request JSON copied to clipboard')),
                );
              },
              tooltip: 'Copy to clipboard',
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            requestJson,
            style: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPathEvolution(BuildContext context) {
    if (session == null || session!.ussdPath.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Path Evolution',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Initial Request: {"text": ""}',
                style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
              ),
              const SizedBox(height: 4),
              ...session!.ussdPath.asMap().entries.map((entry) {
                final index = entry.key;
                final pathSoFar = session!.ussdPath.take(index + 1).join('*');
                return Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(
                    'Selection ${index + 1}: {"text": "$pathSoFar"}',
                    style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? '(empty)' : value,
              style: const TextStyle(fontFamily: 'monospace'),
            ),
          ),
        ],
      ),
    );
  }
}