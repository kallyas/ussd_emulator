import 'dart:io';
import 'dart:convert';
import 'package:csv/csv.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import '../models/ussd_session.dart';
import '../models/endpoint_config.dart';

enum ExportFormat {
  json,
  pdf,
  csv,
  text,
}

class SessionExportService {
  static const String _appName = 'USSD Emulator';
  
  /// Export a single session to the specified format
  Future<File> exportSession(
    UssdSession session,
    ExportFormat format, {
    EndpointConfig? endpointConfig,
    String? customFileName,
  }) async {
    final directory = await getApplicationDocumentsDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final fileName = customFileName ?? 
        'ussd_session_${session.serviceCode.replaceAll('*', '').replaceAll('#', '')}_$timestamp';
    
    switch (format) {
      case ExportFormat.json:
        return _exportToJson(session, directory, fileName, endpointConfig);
      case ExportFormat.pdf:
        return _exportToPdf(session, directory, fileName, endpointConfig);
      case ExportFormat.csv:
        return _exportToCsv([session], directory, fileName, endpointConfig);
      case ExportFormat.text:
        return _exportToText(session, directory, fileName, endpointConfig);
    }
  }
  
  /// Export multiple sessions to CSV format
  Future<File> exportMultipleSessions(
    List<UssdSession> sessions,
    ExportFormat format, {
    String? customFileName,
  }) async {
    final directory = await getApplicationDocumentsDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final fileName = customFileName ?? 'ussd_sessions_bulk_$timestamp';
    
    switch (format) {
      case ExportFormat.csv:
        return _exportToCsv(sessions, directory, fileName);
      case ExportFormat.json:
        return _exportMultipleToJson(sessions, directory, fileName);
      default:
        throw UnsupportedError('Bulk export not supported for ${format.name}');
    }
  }
  
  /// Share a session using the native sharing interface
  Future<void> shareSession(
    UssdSession session,
    ExportFormat format, {
    EndpointConfig? endpointConfig,
  }) async {
    final file = await exportSession(session, format, endpointConfig: endpointConfig);
    
    await Share.shareXFiles(
      [XFile(file.path)],
      text: 'USSD Session Export - ${session.serviceCode}',
      subject: 'USSD Session from $_appName',
    );
  }
  
  /// Let user choose where to save the exported file
  Future<String?> saveSessionWithDialog(
    UssdSession session,
    ExportFormat format, {
    EndpointConfig? endpointConfig,
  }) async {
    await exportSession(session, format, endpointConfig: endpointConfig);
    
    final result = await FilePicker.platform.saveFile(
      dialogTitle: 'Save USSD Session Export',
      fileName: _getFileName(session, format),
    );
    
    return result;
  }
  
  String _getFileName(UssdSession session, ExportFormat format) {
    final serviceCode = session.serviceCode.replaceAll('*', '').replaceAll('#', '');
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final extension = _getFileExtension(format);
    return 'ussd_session_${serviceCode}_$timestamp.$extension';
  }
  
  String _getFileExtension(ExportFormat format) {
    switch (format) {
      case ExportFormat.json:
        return 'json';
      case ExportFormat.pdf:
        return 'pdf';
      case ExportFormat.csv:
        return 'csv';
      case ExportFormat.text:
        return 'txt';
    }
  }
  
  Future<File> _exportToJson(
    UssdSession session,
    Directory directory,
    String fileName,
    EndpointConfig? endpointConfig,
  ) async {
    final file = File('${directory.path}/$fileName.json');
    
    final exportData = {
      'metadata': {
        'exportedAt': DateTime.now().toIso8601String(),
        'exportedBy': _appName,
        'version': '1.0',
        'format': 'json',
      },
      'endpointConfig': endpointConfig?.toJson(),
      'session': session.toJson(),
      'statistics': {
        'totalRequests': session.requests.length,
        'totalResponses': session.responses.length,
        'sessionDuration': session.endedAt?.difference(session.createdAt).inSeconds,
        'ussdPath': session.pathAsText,
      },
    };
    
    await file.writeAsString(
      const JsonEncoder.withIndent('  ').convert(exportData),
    );
    
    return file;
  }
  
  Future<File> _exportMultipleToJson(
    List<UssdSession> sessions,
    Directory directory,
    String fileName,
  ) async {
    final file = File('${directory.path}/$fileName.json');
    
    final exportData = {
      'metadata': {
        'exportedAt': DateTime.now().toIso8601String(),
        'exportedBy': _appName,
        'version': '1.0',
        'format': 'json',
        'sessionCount': sessions.length,
      },
      'sessions': sessions.map((s) => s.toJson()).toList(),
      'statistics': {
        'totalSessions': sessions.length,
        'totalRequests': sessions.fold(0, (sum, s) => sum + s.requests.length),
        'totalResponses': sessions.fold(0, (sum, s) => sum + s.responses.length),
        'serviceCodes': sessions.map((s) => s.serviceCode).toSet().toList(),
      },
    };
    
    await file.writeAsString(
      const JsonEncoder.withIndent('  ').convert(exportData),
    );
    
    return file;
  }
  
  Future<File> _exportToPdf(
    UssdSession session,
    Directory directory,
    String fileName,
    EndpointConfig? endpointConfig,
  ) async {
    final pdf = pw.Document();
    
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return [
            // Header
            pw.Header(
              level: 0,
              child: pw.Text(
                'USSD Session Report',
                style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
              ),
            ),
            
            pw.SizedBox(height: 20),
            
            // Session Info
            pw.Container(
              padding: const pw.EdgeInsets.all(10),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey300),
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(5)),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('Session Information', 
                      style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
                  pw.SizedBox(height: 10),
                  pw.Text('Service Code: ${session.serviceCode}'),
                  pw.Text('Phone Number: ${session.phoneNumber}'),
                  pw.Text('Session ID: ${session.id}'),
                  pw.Text('Started: ${_formatDateTime(session.createdAt)}'),
                  if (session.endedAt != null)
                    pw.Text('Ended: ${_formatDateTime(session.endedAt!)}'),
                  pw.Text('USSD Path: ${session.pathAsText}'),
                  if (endpointConfig != null)
                    pw.Text('Endpoint: ${endpointConfig.name} (${endpointConfig.url})'),
                ],
              ),
            ),
            
            pw.SizedBox(height: 20),
            
            // Conversation History
            pw.Text('Conversation History', 
                style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
            
            pw.SizedBox(height: 10),
            
            ...session.responses.asMap().entries.map<pw.Widget>((entry) {
              final index = entry.key;
              final response = entry.value;
              final request = index < session.requests.length 
                  ? session.requests[index] 
                  : null;
              
              return pw.Container(
                margin: const pw.EdgeInsets.only(bottom: 15),
                padding: const pw.EdgeInsets.all(8),
                decoration: pw.BoxDecoration(
                  color: PdfColors.grey50,
                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(5)),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    if (request != null) ...[
                      pw.Row(
                        children: [
                          pw.Container(
                            width: 50,
                            child: pw.Text('USER:', 
                                style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                          ),
                          pw.Expanded(child: pw.Text(request.text)),
                        ],
                      ),
                      pw.SizedBox(height: 5),
                    ],
                    pw.Row(
                      children: [
                        pw.Container(
                          width: 50,
                          child: pw.Text('USSD:', 
                              style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        ),
                        pw.Expanded(child: pw.Text(response.text)),
                      ],
                    ),
                  ],
                ),
              );
            }),
          ];
        },
      ),
    );
    
    final file = File('${directory.path}/$fileName.pdf');
    await file.writeAsBytes(await pdf.save());
    
    return file;
  }
  
  Future<File> _exportToCsv(
    List<UssdSession> sessions,
    Directory directory,
    String fileName, [
    EndpointConfig? endpointConfig,
  ]) async {
    final file = File('${directory.path}/$fileName.csv');
    
    final List<List<dynamic>> csvData = [
      // Header row
      [
        'Session ID',
        'Phone Number',
        'Service Code',
        'Network Code',
        'USSD Path',
        'Started At',
        'Ended At',
        'Duration (seconds)',
        'Total Requests',
        'Total Responses',
        'Final Response',
        'Endpoint Name',
        'Endpoint URL',
      ],
    ];
    
    // Data rows
    for (final session in sessions) {
      csvData.add([
        session.id,
        session.phoneNumber,
        session.serviceCode,
        session.networkCode ?? '',
        session.pathAsText,
        session.createdAt.toIso8601String(),
        session.endedAt?.toIso8601String() ?? '',
        session.endedAt != null 
            ? session.endedAt!.difference(session.createdAt).inSeconds
            : '',
        session.requests.length,
        session.responses.length,
        session.responses.isNotEmpty ? session.responses.last.text : '',
        endpointConfig?.name ?? '',
        endpointConfig?.url ?? '',
      ]);
    }
    
    final csvContent = const ListToCsvConverter().convert(csvData);
    await file.writeAsString(csvContent);
    
    return file;
  }
  
  Future<File> _exportToText(
    UssdSession session,
    Directory directory,
    String fileName,
    EndpointConfig? endpointConfig,
  ) async {
    final file = File('${directory.path}/$fileName.txt');
    
    final buffer = StringBuffer();
    
    // Header
    buffer.writeln('USSD SESSION EXPORT');
    buffer.writeln('=' * 50);
    buffer.writeln();
    
    // Session details
    buffer.writeln('SESSION INFORMATION:');
    buffer.writeln('Service Code: ${session.serviceCode}');
    buffer.writeln('Phone Number: ${session.phoneNumber}');
    buffer.writeln('Session ID: ${session.id}');
    buffer.writeln('Started: ${_formatDateTime(session.createdAt)}');
    if (session.endedAt != null) {
      buffer.writeln('Ended: ${_formatDateTime(session.endedAt!)}');
      final duration = session.endedAt!.difference(session.createdAt);
      buffer.writeln('Duration: ${duration.inSeconds} seconds');
    }
    buffer.writeln('USSD Path: ${session.pathAsText}');
    if (endpointConfig != null) {
      buffer.writeln('Endpoint: ${endpointConfig.name}');
      buffer.writeln('URL: ${endpointConfig.url}');
    }
    buffer.writeln();
    
    // Conversation
    buffer.writeln('CONVERSATION HISTORY:');
    buffer.writeln('-' * 30);
    
    for (int i = 0; i < session.responses.length; i++) {
      final response = session.responses[i];
      final request = i < session.requests.length ? session.requests[i] : null;
      
      if (request != null) {
        buffer.writeln('USER: ${request.text}');
      }
      buffer.writeln('USSD: ${response.text}');
      buffer.writeln();
    }
    
    // Footer
    buffer.writeln();
    buffer.writeln('=' * 50);
    buffer.writeln('Exported by $_appName');
    buffer.writeln('Export Date: ${DateTime.now()}');
    
    await file.writeAsString(buffer.toString());
    
    return file;
  }
  
  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} '
           '${dateTime.hour.toString().padLeft(2, '0')}:'
           '${dateTime.minute.toString().padLeft(2, '0')}:'
           '${dateTime.second.toString().padLeft(2, '0')}';
  }
}