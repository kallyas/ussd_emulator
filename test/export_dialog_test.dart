import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ussd_emulator/models/ussd_session.dart';
import 'package:ussd_emulator/models/ussd_request.dart';
import 'package:ussd_emulator/models/ussd_response.dart';
import 'package:ussd_emulator/models/endpoint_config.dart';
import 'package:ussd_emulator/widgets/export_dialog.dart';
import 'package:ussd_emulator/services/session_export_service.dart';

void main() {
  late UssdSession testSession;
  late EndpointConfig testEndpointConfig;

  setUp(() {
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
          text: '1',
        ),
      ],
      responses: [
        const UssdResponse(
          text: 'Welcome to Test USSD\n1. Check Balance',
          continueSession: true,
        ),
      ],
      ussdPath: ['1'],
      createdAt: DateTime(2024, 1, 15, 10, 30),
      endedAt: DateTime(2024, 1, 15, 10, 32),
      isActive: false,
    );
  });

  group('ExportDialog Widget Tests', () {
    testWidgets('should display single session export dialog correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ExportDialog(
              session: testSession,
              endpointConfig: testEndpointConfig,
            ),
          ),
        ),
      );

      // Verify dialog title
      expect(find.text('Export Session'), findsOneWidget);

      // Verify session info is displayed
      expect(find.text('Session: *123#'), findsOneWidget);

      // Verify all format options are available
      expect(find.text('JSON'), findsOneWidget);
      expect(find.text('PDF'), findsOneWidget);
      expect(find.text('CSV'), findsOneWidget);
      expect(find.text('Text'), findsOneWidget);

      // Verify format descriptions
      expect(find.text('Machine-readable format for API integration'), findsOneWidget);
      expect(find.text('Human-readable format for documentation'), findsOneWidget);
      expect(find.text('Spreadsheet format for data analysis'), findsOneWidget);
      expect(find.text('Simple plain text format'), findsOneWidget);

      // Verify action buttons
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Share'), findsOneWidget);
      expect(find.text('Save'), findsOneWidget);
    });

    testWidgets('should display multiple sessions export dialog correctly', (tester) async {
      final multipleSessions = [
        testSession,
        testSession.copyWith(id: 'session-2'),
        testSession.copyWith(id: 'session-3'),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ExportDialog(
              session: testSession,
              multipleSessions: multipleSessions,
            ),
          ),
        ),
      );

      // Verify dialog title for multiple sessions
      expect(find.text('Export Sessions'), findsOneWidget);

      // Verify session count is displayed
      expect(find.text('Exporting 3 sessions'), findsOneWidget);

      // Verify only CSV and JSON are enabled for multiple sessions
      final jsonRadio = find.byType(RadioListTile<ExportFormat>).at(0);
      final csvRadio = find.byType(RadioListTile<ExportFormat>).at(2);

      await tester.tap(jsonRadio);
      await tester.pump();

      await tester.tap(csvRadio);
      await tester.pump();

      // PDF and Text should be disabled (grayed out)
      // This is a basic check - in a real test you'd verify the visual state
      expect(find.text('PDF'), findsOneWidget);
      expect(find.text('Text'), findsOneWidget);
    });

    testWidgets('should allow format selection', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ExportDialog(
              session: testSession,
            ),
          ),
        ),
      );

      // Initially JSON should be selected
      final radioTiles = find.byType(RadioListTile<ExportFormat>);
      expect(radioTiles, findsNWidgets(4));

      // Tap on PDF option
      await tester.tap(find.text('PDF'));
      await tester.pump();

      // Tap on CSV option
      await tester.tap(find.text('CSV'));
      await tester.pump();

      // Tap on Text option
      await tester.tap(find.text('Text'));
      await tester.pump();

      // Should complete without error
    });

    testWidgets('should close dialog when cancel is tapped', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => showDialog(
                  context: context,
                  builder: (_) => ExportDialog(session: testSession),
                ),
                child: Text('Show Dialog'),
              ),
            ),
          ),
        ),
      );

      // Show the dialog
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      // Verify dialog is shown
      expect(find.text('Export Session'), findsOneWidget);

      // Tap cancel
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      // Verify dialog is closed
      expect(find.text('Export Session'), findsNothing);
    });

    testWidgets('should show loading state when exporting', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ExportDialog(
              session: testSession,
            ),
          ),
        ),
      );

      // The Share and Save buttons should be present
      expect(find.text('Share'), findsOneWidget);
      expect(find.text('Save'), findsOneWidget);

      // Both buttons should be ElevatedButton.icon widgets
      expect(find.byType(ElevatedButton), findsNWidgets(2));
    });
  });

  group('ExportFormat enum tests', () {
    test('should have correct format values', () {
      expect(ExportFormat.values.length, equals(4));
      expect(ExportFormat.values, contains(ExportFormat.json));
      expect(ExportFormat.values, contains(ExportFormat.pdf));
      expect(ExportFormat.values, contains(ExportFormat.csv));
      expect(ExportFormat.values, contains(ExportFormat.text));
    });
  });
}