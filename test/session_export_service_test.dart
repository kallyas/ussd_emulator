import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:ussd_emulator/models/ussd_session.dart';
import 'package:ussd_emulator/models/ussd_request.dart';
import 'package:ussd_emulator/models/ussd_response.dart';
import 'package:ussd_emulator/models/endpoint_config.dart';
import 'package:ussd_emulator/services/session_export_service.dart';

class MockPathProviderPlatform extends Fake
    with MockPlatformInterfaceMixin
    implements PathProviderPlatform {
  @override
  Future<String?> getApplicationDocumentsPath() async {
    return Directory.systemTemp.path;
  }
}

void main() {
  late SessionExportService exportService;
  late UssdSession testSession;
  late EndpointConfig testEndpointConfig;

  setUpAll(() {
    PathProviderPlatform.instance = MockPathProviderPlatform();
  });

  setUp(() {
    exportService = SessionExportService();
    
    testEndpointConfig = const EndpointConfig(
      name: 'Test Endpoint',
      url: 'https://test.example.com/ussd',
      headers: {'Content-Type': 'application/json'},
      isActive: true,
    );

    testSession = UssdSession(
      id: 'test-session-123',
      phoneNumber: '+256700000000',
      serviceCode: '*123#',
      networkCode: 'MTN',
      requests: [
        const UssdRequest(
          sessionId: 'test-session-123',
          phoneNumber: '+256700000000',
          serviceCode: '*123#',
          text: '',
        ),
        const UssdRequest(
          sessionId: 'test-session-123',
          phoneNumber: '+256700000000',
          serviceCode: '*123#',
          text: '1',
        ),
      ],
      responses: [
        const UssdResponse(
          text: 'Welcome to Test USSD\n1. Check Balance\n2. Transfer Money',
          continueSession: true,
        ),
        const UssdResponse(
          text: 'Your balance is UGX 50,000',
          continueSession: false,
        ),
      ],
      ussdPath: ['1'],
      createdAt: DateTime(2024, 1, 15, 10, 30),
      endedAt: DateTime(2024, 1, 15, 10, 32),
      isActive: false,
    );
  });

  group('SessionExportService', () {
    test('should export session to JSON format', () async {
      final file = await exportService.exportSession(
        testSession,
        ExportFormat.json,
        endpointConfig: testEndpointConfig,
      );

      expect(file.existsSync(), isTrue);
      expect(file.path.endsWith('.json'), isTrue);

      final content = await file.readAsString();
      expect(content, contains('"sessionId": "test-session-123"'));
      expect(content, contains('"phoneNumber": "+256700000000"'));
      expect(content, contains('"serviceCode": "*123#"'));
      expect(content, contains('Test Endpoint'));
      expect(content, contains('exportedBy'));
      
      await file.delete();
    });

    test('should export session to PDF format', () async {
      final file = await exportService.exportSession(
        testSession,
        ExportFormat.pdf,
        endpointConfig: testEndpointConfig,
      );

      expect(file.existsSync(), isTrue);
      expect(file.path.endsWith('.pdf'), isTrue);
      
      // Check that file has content (PDF header)
      final bytes = await file.readAsBytes();
      expect(bytes.length, greaterThan(0));
      expect(bytes.take(4), equals([37, 80, 68, 70])); // %PDF header
      
      await file.delete();
    });

    test('should export session to CSV format', () async {
      final file = await exportService.exportSession(
        testSession,
        ExportFormat.csv,
        endpointConfig: testEndpointConfig,
      );

      expect(file.existsSync(), isTrue);
      expect(file.path.endsWith('.csv'), isTrue);

      final content = await file.readAsString();
      expect(content, contains('Session ID'));
      expect(content, contains('Phone Number'));
      expect(content, contains('Service Code'));
      expect(content, contains('test-session-123'));
      expect(content, contains('+256700000000'));
      expect(content, contains('*123#'));
      
      await file.delete();
    });

    test('should export session to text format', () async {
      final file = await exportService.exportSession(
        testSession,
        ExportFormat.text,
        endpointConfig: testEndpointConfig,
      );

      expect(file.existsSync(), isTrue);
      expect(file.path.endsWith('.txt'), isTrue);

      final content = await file.readAsString();
      expect(content, contains('USSD SESSION EXPORT'));
      expect(content, contains('Service Code: *123#'));
      expect(content, contains('Phone Number: +256700000000'));
      expect(content, contains('CONVERSATION HISTORY'));
      expect(content, contains('USER: 1'));
      expect(content, contains('USSD: Welcome to Test USSD'));
      
      await file.delete();
    });

    test('should export multiple sessions to JSON', () async {
      final sessions = [testSession, testSession.copyWith(id: 'session-2')];
      
      final file = await exportService.exportMultipleSessions(
        sessions,
        ExportFormat.json,
      );

      expect(file.existsSync(), isTrue);
      expect(file.path.endsWith('.json'), isTrue);

      final content = await file.readAsString();
      expect(content, contains('"sessionCount": 2'));
      expect(content, contains('test-session-123'));
      expect(content, contains('session-2'));
      
      await file.delete();
    });

    test('should export multiple sessions to CSV', () async {
      final sessions = [testSession, testSession.copyWith(id: 'session-2')];
      
      final file = await exportService.exportMultipleSessions(
        sessions,
        ExportFormat.csv,
      );

      expect(file.existsSync(), isTrue);
      expect(file.path.endsWith('.csv'), isTrue);

      final content = await file.readAsString();
      final lines = content.split('\n');
      expect(lines.length, greaterThanOrEqualTo(3)); // Header + 2 data rows + possible empty line
      expect(lines[0], contains('Session ID')); // Header
      expect(lines[1], contains('test-session-123')); // First session
      expect(lines[2], contains('session-2')); // Second session
      
      await file.delete();
    });

    test('should handle sessions without end date', () async {
      final activeSession = testSession.copyWith(
        endedAt: null,
        isActive: true,
      );
      
      final file = await exportService.exportSession(
        activeSession,
        ExportFormat.json,
      );

      expect(file.existsSync(), isTrue);
      
      final content = await file.readAsString();
      expect(content, contains('"isActive": true'));
      expect(content, contains('"endedAt": null'));
      
      await file.delete();
    });

    test('should handle sessions with empty responses', () async {
      final emptySession = testSession.copyWith(
        requests: [],
        responses: [],
        ussdPath: [],
      );
      
      final file = await exportService.exportSession(
        emptySession,
        ExportFormat.text,
      );

      expect(file.existsSync(), isTrue);
      
      final content = await file.readAsString();
      expect(content, contains('USSD SESSION EXPORT'));
      expect(content, contains('CONVERSATION HISTORY'));
      
      await file.delete();
    });

    test('should generate correct file names', () async {
      final file1 = await exportService.exportSession(
        testSession,
        ExportFormat.json,
      );
      
      final file2 = await exportService.exportSession(
        testSession.copyWith(serviceCode: '*256*4#'),
        ExportFormat.pdf,
      );

      expect(file1.path, contains('ussd_session_123'));
      expect(file1.path, endsWith('.json'));
      expect(file2.path, contains('ussd_session_2564'));
      expect(file2.path, endsWith('.pdf'));
      
      await file1.delete();
      await file2.delete();
    });

    test('should include statistics in JSON export', () async {
      final file = await exportService.exportSession(
        testSession,
        ExportFormat.json,
      );

      final content = await file.readAsString();
      expect(content, contains('"statistics"'));
      expect(content, contains('"totalRequests": 2'));
      expect(content, contains('"totalResponses": 2'));
      expect(content, contains('"sessionDuration": 120')); // 2 minutes
      expect(content, contains('"ussdPath": "1"'));
      
      await file.delete();
    });

    test('should throw UnsupportedError for unsupported bulk export formats', () async {
      final sessions = [testSession];
      
      expect(
        () => exportService.exportMultipleSessions(sessions, ExportFormat.pdf),
        throwsA(isA<UnsupportedError>()),
      );
      
      expect(
        () => exportService.exportMultipleSessions(sessions, ExportFormat.text),
        throwsA(isA<UnsupportedError>()),
      );
    });
  });

  group('File Extension Utils', () {
    test('should return correct file extensions', () async {
      final jsonFile = await exportService.exportSession(testSession, ExportFormat.json);
      final pdfFile = await exportService.exportSession(testSession, ExportFormat.pdf);
      final csvFile = await exportService.exportSession(testSession, ExportFormat.csv);
      final textFile = await exportService.exportSession(testSession, ExportFormat.text);

      expect(jsonFile.path.endsWith('.json'), isTrue);
      expect(pdfFile.path.endsWith('.pdf'), isTrue);
      expect(csvFile.path.endsWith('.csv'), isTrue);
      expect(textFile.path.endsWith('.txt'), isTrue);
      
      await jsonFile.delete();
      await pdfFile.delete();
      await csvFile.delete();
      await textFile.delete();
    });
  });
}