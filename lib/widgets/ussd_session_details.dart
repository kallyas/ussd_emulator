import 'package:flutter/material.dart';
import '../models/ussd_session.dart';
import '../utils/ussd_utils.dart';

class UssdSessionDetails extends StatelessWidget {
  final UssdSession session;

  const UssdSessionDetails({
    super.key,
    required this.session,
  });

  static void show(BuildContext context, UssdSession session) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => UssdSessionDetails(session: session),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
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
                  Icons.info_outline,
                  size: 20,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
                const SizedBox(width: 12),
                Text(
                  'Session Details',
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
                  _buildDetailCard(
                    context,
                    'Contact Information',
                    Icons.contact_phone,
                    [
                      _buildDetailRow('Phone Number', session.phoneNumber),
                      _buildDetailRow('Service Code', session.serviceCode),
                      if (session.networkCode != null)
                        _buildDetailRow('Network Code', session.networkCode!),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildDetailCard(
                    context,
                    'Session Status',
                    Icons.settings,
                    [
                      _buildDetailRow('Session ID', session.id),
                      _buildDetailRow('Status', session.isActive ? 'Active' : 'Ended'),
                      _buildDetailRow('Created', _formatDateTime(session.createdAt)),
                      if (session.endedAt != null)
                        _buildDetailRow('Ended', _formatDateTime(session.endedAt!)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildDetailCard(
                    context,
                    'Navigation Path',
                    Icons.route,
                    [
                      _buildDetailRow('Current Path', session.ussdPath.isEmpty ? 'Initial Request' : UssdUtils.formatPathForDisplay(session.ussdPath)),
                      _buildDetailRow('Path as Text', session.pathAsText.isEmpty ? '(empty)' : '"${session.pathAsText}"'),
                      _buildDetailRow('Total Requests', session.requests.length.toString()),
                      _buildDetailRow('Total Responses', session.responses.length.toString()),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailCard(BuildContext context, String title, IconData icon, List<Widget> children) {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  size: 16,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}