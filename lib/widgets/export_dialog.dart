import 'package:flutter/material.dart';
import '../services/session_export_service.dart';
import '../models/ussd_session.dart';
import '../models/endpoint_config.dart';

class ExportDialog extends StatefulWidget {
  final UssdSession session;
  final EndpointConfig? endpointConfig;
  final List<UssdSession>? multipleSessions;

  const ExportDialog({
    super.key,
    required this.session,
    this.endpointConfig,
    this.multipleSessions,
  });

  @override
  State<ExportDialog> createState() => _ExportDialogState();
}

class _ExportDialogState extends State<ExportDialog> {
  final SessionExportService _exportService = SessionExportService();
  ExportFormat _selectedFormat = ExportFormat.json;
  bool _isExporting = false;

  final Map<ExportFormat, ExportFormatInfo> _formatInfo = {
    ExportFormat.json: ExportFormatInfo(
      icon: Icons.code,
      title: 'JSON',
      description: 'Machine-readable format for API integration',
      color: Colors.blue,
    ),
    ExportFormat.pdf: ExportFormatInfo(
      icon: Icons.picture_as_pdf,
      title: 'PDF',
      description: 'Human-readable format for documentation',
      color: Colors.red,
    ),
    ExportFormat.csv: ExportFormatInfo(
      icon: Icons.table_chart,
      title: 'CSV',
      description: 'Spreadsheet format for data analysis',
      color: Colors.green,
    ),
    ExportFormat.text: ExportFormatInfo(
      icon: Icons.text_snippet,
      title: 'Text',
      description: 'Simple plain text format',
      color: Colors.orange,
    ),
  };

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.file_download, color: Theme.of(context).primaryColor),
          const SizedBox(width: 8),
          Text(
            widget.multipleSessions != null
                ? 'Export Sessions'
                : 'Export Session',
          ),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.multipleSessions != null) ...[
              Text(
                'Exporting ${widget.multipleSessions!.length} sessions',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),
            ] else ...[
              Text(
                'Session: ${widget.session.serviceCode}',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 16),
            ],

            Text(
              'Select Format:',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),

            Column(
              children: ExportFormat.values.map((format) {
                final info = _formatInfo[format]!;
                final isSupported = _isFormatSupported(format);

                return RadioListTile<ExportFormat>(
                  value: format,
                  groupValue: _selectedFormat,
                  onChanged: isSupported
                      ? (value) {
                          setState(() {
                            _selectedFormat = value!;
                          });
                        }
                      : null,
                  title: Row(
                    children: [
                      Icon(
                        info.icon,
                        color: isSupported ? info.color : Colors.grey,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        info.title,
                        style: TextStyle(
                          color: isSupported ? null : Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  subtitle: Text(
                    info.description,
                    style: TextStyle(
                      color: isSupported ? null : Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                  contentPadding: EdgeInsets.zero,
                );
              }).toList(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isExporting ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        const SizedBox(width: 8),
        _buildExportButton(context, 'Share', Icons.share, _shareSession),
        const SizedBox(width: 8),
        _buildExportButton(context, 'Save', Icons.save, _saveSession),
      ],
    );
  }

  bool _isFormatSupported(ExportFormat format) {
    if (widget.multipleSessions != null) {
      return format == ExportFormat.csv || format == ExportFormat.json;
    }
    return true;
  }

  Widget _buildExportButton(
    BuildContext context,
    String label,
    IconData icon,
    Future<void> Function() onPressed,
  ) {
    return ElevatedButton.icon(
      onPressed: _isExporting ? null : onPressed,
      icon: _isExporting
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Icon(icon, size: 16),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
    );
  }

  Future<void> _shareSession() async {
    setState(() => _isExporting = true);

    try {
      if (widget.multipleSessions != null) {
        await _exportService.exportMultipleSessions(
          widget.multipleSessions!,
          _selectedFormat,
        );

        await _exportService.shareSession(
          widget.session, // Use first session for sharing metadata
          _selectedFormat,
          endpointConfig: widget.endpointConfig,
        );
      } else {
        await _exportService.shareSession(
          widget.session,
          _selectedFormat,
          endpointConfig: widget.endpointConfig,
        );
      }

      if (mounted) {
        Navigator.of(context).pop();
        _showSuccessMessage('Session shared successfully!');
      }
    } catch (e) {
      if (mounted) {
        _showErrorMessage('Failed to share session: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() => _isExporting = false);
      }
    }
  }

  Future<void> _saveSession() async {
    setState(() => _isExporting = true);

    try {
      String? result;

      if (widget.multipleSessions != null) {
        await _exportService.exportMultipleSessions(
          widget.multipleSessions!,
          _selectedFormat,
        );
        result = 'exported';
      } else {
        result = await _exportService.saveSessionWithDialog(
          widget.session,
          _selectedFormat,
          endpointConfig: widget.endpointConfig,
        );
      }

      if (mounted) {
        Navigator.of(context).pop();
        if (result != null) {
          _showSuccessMessage('Session saved successfully!');
        } else {
          _showErrorMessage('Save cancelled');
        }
      }
    } catch (e) {
      if (mounted) {
        _showErrorMessage('Failed to save session: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() => _isExporting = false);
      }
    }
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Text(message),
          ],
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 5),
      ),
    );
  }
}

class ExportFormatInfo {
  final IconData icon;
  final String title;
  final String description;
  final Color color;

  const ExportFormatInfo({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });
}
