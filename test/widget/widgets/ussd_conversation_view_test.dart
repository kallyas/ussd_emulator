import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:provider/provider.dart';
import 'package:ussd_emulator/providers/ussd_provider.dart';
import 'package:ussd_emulator/providers/accessibility_provider.dart';
import 'package:ussd_emulator/widgets/ussd_conversation_view.dart';
import 'package:ussd_emulator/models/ussd_session.dart';
import 'package:ussd_emulator/models/ussd_request.dart';
import 'package:ussd_emulator/models/ussd_response.dart';
import 'package:ussd_emulator/models/accessibility_settings.dart';

// Generate mocks
@GenerateMocks([UssdProvider, AccessibilityProvider])
import 'ussd_conversation_view_test.mocks.dart';

void main() {
  group('UssdConversationView Widget Tests', () {
    late MockUssdProvider mockUssdProvider;
    late MockAccessibilityProvider mockAccessibilityProvider;
    late UssdSession testSession;

    setUp(() {
      mockUssdProvider = MockUssdProvider();
      mockAccessibilityProvider = MockAccessibilityProvider();
      
      // Create test session with sample data
      testSession = UssdSession(
        id: 'test-session-1',
        phoneNumber: '254700000000',
        serviceCode: '*123#',
        networkCode: 'safaricom',
        requests: [
          UssdRequest(
            phoneNumber: '254700000000',
            serviceCode: '*123#',
            text: '',
            sessionId: 'test-session-1',
          ),
        ],
        responses: [
          UssdResponse(
            sessionId: 'test-session-1',
            text: 'Welcome to USSD Service\n1. Check Balance\n2. Transfer Money\n3. Buy Airtime',
            continueSession: true,
          ),
        ],
        ussdPath: [''],
        createdAt: DateTime.now(),
        isActive: true,
      );

      // Default mock behaviors
      when(mockUssdProvider.currentSession).thenReturn(testSession);
      when(mockUssdProvider.isLoading).thenReturn(false);
      when(mockUssdProvider.error).thenReturn(null);
      when(mockAccessibilityProvider.settings).thenReturn(
        const AccessibilitySettings(
          accessibilityEnabled: false,
          useHighContrast: false,
          textScaleFactor: 1.0,
          enableTextToSpeech: false,
          enableVoiceInput: false,
        ),
      );
    });

    Widget createTestWidget({ThemeMode themeMode = ThemeMode.light}) {
      return MultiProvider(
        providers: [
          ChangeNotifierProvider<UssdProvider>.value(value: mockUssdProvider),
          ChangeNotifierProvider<AccessibilityProvider>.value(value: mockAccessibilityProvider),
        ],
        child: MaterialApp(
          theme: ThemeData.light(),
          darkTheme: ThemeData.dark(),
          themeMode: themeMode,
          home: const Scaffold(
            body: UssdConversationView(),
          ),
        ),
      );
    }

    testWidgets('should display conversation correctly', (tester) async {
      await tester.pumpWidget(createTestWidget());

      // Verify service code is displayed
      expect(find.text('*123#'), findsOneWidget);
      
      // Verify response text is displayed
      expect(find.textContaining('Welcome to USSD Service'), findsOneWidget);
      expect(find.textContaining('1. Check Balance'), findsOneWidget);
      expect(find.textContaining('2. Transfer Money'), findsOneWidget);
      expect(find.textContaining('3. Buy Airtime'), findsOneWidget);

      // Verify input field is present
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('should handle user input and send USSD command', (tester) async {
      await tester.pumpWidget(createTestWidget());

      // Find the input field and enter text
      final inputField = find.byType(TextField);
      await tester.enterText(inputField, '1');
      await tester.pump();

      // Verify text was entered
      expect(find.text('1'), findsOneWidget);

      // Find and tap the send button
      final sendButton = find.byIcon(Icons.send);
      expect(sendButton, findsOneWidget);
      
      await tester.tap(sendButton);
      await tester.pump();

      // Verify that sendUssdInput was called with the correct input
      verify(mockUssdProvider.sendUssdInput('1')).called(1);
    });

    testWidgets('should handle keyboard enter key for sending input', (tester) async {
      await tester.pumpWidget(createTestWidget());

      // Enter text in the input field
      final inputField = find.byType(TextField);
      await tester.enterText(inputField, '2');
      await tester.pump();

      // Simulate pressing Enter key
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();

      // Verify that sendUssdInput was called
      verify(mockUssdProvider.sendUssdInput('2')).called(1);
    });

    testWidgets('should display loading state correctly', (tester) async {
      when(mockUssdProvider.isLoading).thenReturn(true);
      
      await tester.pumpWidget(createTestWidget());

      // Should display loading indicator
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      
      // Input should be disabled during loading
      final inputField = find.byType(TextField);
      final textField = tester.widget<TextField>(inputField);
      expect(textField.enabled, isFalse);
    });

    testWidgets('should display error state correctly', (tester) async {
      when(mockUssdProvider.error).thenReturn('Network error occurred');
      
      await tester.pumpWidget(createTestWidget());

      // Should display error message
      expect(find.textContaining('Network error occurred'), findsOneWidget);
      expect(find.byIcon(Icons.error), findsOneWidget);
    });

    testWidgets('should clear input field after sending', (tester) async {
      await tester.pumpWidget(createTestWidget());

      // Enter text and send
      final inputField = find.byType(TextField);
      await tester.enterText(inputField, '1');
      await tester.pump();
      
      await tester.tap(find.byIcon(Icons.send));
      await tester.pump();

      // Input field should be cleared
      final textField = tester.widget<TextField>(inputField);
      expect(textField.controller?.text, isEmpty);
    });

    testWidgets('should display multiple conversation exchanges', (tester) async {
      // Create session with multiple exchanges
      final multiExchangeSession = UssdSession(
        id: 'test-session-2',
        phoneNumber: '254700000000',
        serviceCode: '*123#',
        networkCode: 'safaricom',
        requests: [
          UssdRequest(
            phoneNumber: '254700000000',
            serviceCode: '*123#',
            text: '',
            sessionId: 'test-session-2',
          ),
          UssdRequest(
            phoneNumber: '254700000000',
            serviceCode: '*123#',
            text: '1',
            sessionId: 'test-session-2',
          ),
        ],
        responses: [
          UssdResponse(
            sessionId: 'test-session-2',
            text: 'Welcome\n1. Balance\n2. Transfer',
            continueSession: true,
          ),
          UssdResponse(
            sessionId: 'test-session-2',
            text: 'Your balance is KES 1,000.00',
            continueSession: false,
          ),
        ],
        ussdPath: ['', '1'],
        createdAt: DateTime.now().subtract(const Duration(minutes: 2)),
        isActive: false,
      );

      when(mockUssdProvider.currentSession).thenReturn(multiExchangeSession);
      
      await tester.pumpWidget(createTestWidget());

      // Should display both responses
      expect(find.textContaining('Welcome'), findsOneWidget);
      expect(find.textContaining('Your balance is KES 1,000.00'), findsOneWidget);
      
      // Should show user input history
      expect(find.textContaining('1'), findsWidgets);
    });

    testWidgets('should handle empty session state', (tester) async {
      when(mockUssdProvider.currentSession).thenReturn(null);
      
      await tester.pumpWidget(createTestWidget());

      // Should display appropriate message for no session
      expect(find.textContaining('No active session'), findsOneWidget);
      
      // Input should be disabled when no session
      final inputField = find.byType(TextField);
      final textField = tester.widget<TextField>(inputField);
      expect(textField.enabled, isFalse);
    });

    testWidgets('should validate accessibility semantics', (tester) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      
      await tester.pumpWidget(createTestWidget());

      // Check semantic labels exist
      expect(
        tester.getSemantics(find.byType(UssdConversationView)),
        matchesSemantics(
          hasImplicitScrolling: true,
        ),
      );

      // Input field should have appropriate semantics
      expect(
        tester.getSemantics(find.byType(TextField)),
        matchesSemantics(
          label: 'Enter USSD input',
          hasEnabledState: true,
          isEnabled: true,
          isFocusable: true,
          isTextField: true,
        ),
      );

      handle.dispose();
    });

    testWidgets('should support dark theme', (tester) async {
      await tester.pumpWidget(createTestWidget(themeMode: ThemeMode.dark));

      // Should render without errors in dark theme
      expect(find.byType(UssdConversationView), findsOneWidget);
      expect(find.text('*123#'), findsOneWidget);
    });

    testWidgets('should handle long response text with scrolling', (tester) async {
      // Create session with very long response
      final longResponseSession = testSession.copyWith(
        responses: [
          UssdResponse(
            sessionId: 'test-session-1',
            text: 'This is a very long USSD response ' * 20 + 
                  '\n1. Option 1\n2. Option 2\n3. Option 3\n4. Option 4\n5. Option 5',
            continueSession: true,
          ),
        ],
      );

      when(mockUssdProvider.currentSession).thenReturn(longResponseSession);
      
      await tester.pumpWidget(createTestWidget());

      // Should display the response in a scrollable view
      expect(find.byType(ListView), findsOneWidget);
      expect(find.textContaining('This is a very long'), findsOneWidget);
    });

    testWidgets('should prevent input when session is not active', (tester) async {
      final inactiveSession = testSession.copyWith(
        isActive: false,
        responses: [
          ...testSession.responses,
          UssdResponse(
            sessionId: 'test-session-1',
            text: 'Session ended. Thank you.',
            continueSession: false,
          ),
        ],
      );

      when(mockUssdProvider.currentSession).thenReturn(inactiveSession);
      
      await tester.pumpWidget(createTestWidget());

      // Input should be disabled for inactive session
      final inputField = find.byType(TextField);
      final textField = tester.widget<TextField>(inputField);
      expect(textField.enabled, isFalse);
      
      // Should show session ended message
      expect(find.textContaining('Session ended'), findsOneWidget);
    });
  });
}