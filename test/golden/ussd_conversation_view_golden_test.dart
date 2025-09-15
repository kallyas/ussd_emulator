import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:ussd_emulator/providers/ussd_provider.dart';
import 'package:ussd_emulator/providers/accessibility_provider.dart';
import 'package:ussd_emulator/widgets/ussd_conversation_view.dart';
import 'package:ussd_emulator/models/ussd_session.dart';
import 'package:ussd_emulator/models/ussd_request.dart';
import 'package:ussd_emulator/models/ussd_response.dart';
import 'package:ussd_emulator/models/accessibility_settings.dart';

// Import the generated mocks
import '../widgets/ussd_conversation_view_test.mocks.dart';

void main() {
  group('UssdConversationView Golden Tests', () {
    late MockUssdProvider mockUssdProvider;
    late MockAccessibilityProvider mockAccessibilityProvider;
    late UssdSession testSession;

    setUp(() {
      mockUssdProvider = MockUssdProvider();
      mockAccessibilityProvider = MockAccessibilityProvider();

      // Create test session with sample USSD conversation
      testSession = UssdSession(
        id: 'test-session-golden',
        phoneNumber: '254700000000',
        serviceCode: '*123#',
        networkCode: 'safaricom',
        requests: [
          UssdRequest(
            phoneNumber: '254700000000',
            serviceCode: '*123#',
            text: '',
            sessionId: 'test-session-golden',
          ),
          UssdRequest(
            phoneNumber: '254700000000',
            serviceCode: '*123#',
            text: '1',
            sessionId: 'test-session-golden',
          ),
        ],
        responses: [
          UssdResponse(
            sessionId: 'test-session-golden',
            text:
                'Welcome to Mobile Money\n1. Send Money\n2. Withdraw Cash\n3. Buy Airtime\n4. Pay Bills\n5. Check Balance',
            continueSession: true,
          ),
          UssdResponse(
            sessionId: 'test-session-golden',
            text: 'Send Money\nEnter phone number:',
            continueSession: true,
          ),
        ],
        ussdPath: ['', '1'],
        createdAt: DateTime.now(),
        isActive: true,
      );

      // Setup default mocks
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
          ChangeNotifierProvider<AccessibilityProvider>.value(
            value: mockAccessibilityProvider,
          ),
        ],
        child: MaterialApp(
          theme: ThemeData.light(),
          darkTheme: ThemeData.dark(),
          themeMode: themeMode,
          home: Scaffold(
            appBar: AppBar(title: const Text('USSD Emulator')),
            body: const UssdConversationView(),
          ),
        ),
      );
    }

    testGoldens('UssdConversationView - Light Theme', (tester) async {
      await loadAppFonts();

      await tester.pumpWidgetBuilder(
        createTestWidget(themeMode: ThemeMode.light),
        surfaceSize: const Size(400, 600),
      );

      await screenMatchesGolden(tester, 'conversation_view_light');
    });

    testGoldens('UssdConversationView - Dark Theme', (tester) async {
      await loadAppFonts();

      await tester.pumpWidgetBuilder(
        createTestWidget(themeMode: ThemeMode.dark),
        surfaceSize: const Size(400, 600),
      );

      await screenMatchesGolden(tester, 'conversation_view_dark');
    });

    testGoldens('UssdConversationView - Loading State', (tester) async {
      await loadAppFonts();

      // Setup loading state
      when(mockUssdProvider.isLoading).thenReturn(true);

      await tester.pumpWidgetBuilder(
        createTestWidget(themeMode: ThemeMode.light),
        surfaceSize: const Size(400, 600),
      );

      await screenMatchesGolden(tester, 'conversation_view_loading');
    });

    testGoldens('UssdConversationView - Error State', (tester) async {
      await loadAppFonts();

      // Setup error state
      when(mockUssdProvider.error).thenReturn('Network connection failed');

      await tester.pumpWidgetBuilder(
        createTestWidget(themeMode: ThemeMode.light),
        surfaceSize: const Size(400, 600),
      );

      await screenMatchesGolden(tester, 'conversation_view_error');
    });

    testGoldens('UssdConversationView - No Session', (tester) async {
      await loadAppFonts();

      // Setup no session state
      when(mockUssdProvider.currentSession).thenReturn(null);

      await tester.pumpWidgetBuilder(
        createTestWidget(themeMode: ThemeMode.light),
        surfaceSize: const Size(400, 600),
      );

      await screenMatchesGolden(tester, 'conversation_view_no_session');
    });

    testGoldens('UssdConversationView - Long Conversation', (tester) async {
      await loadAppFonts();

      // Create a session with a long conversation
      final longSession = UssdSession(
        id: 'long-session',
        phoneNumber: '254700000000',
        serviceCode: '*456#',
        networkCode: 'airtel',
        requests: List.generate(
          5,
          (i) => UssdRequest(
            phoneNumber: '254700000000',
            serviceCode: '*456#',
            text: i == 0 ? '' : '$i',
            sessionId: 'long-session',
          ),
        ),
        responses: [
          UssdResponse(
            sessionId: 'long-session',
            text:
                'Welcome to Banking\n1. Account Balance\n2. Mini Statement\n3. Transfer Funds\n4. Pay Bills\n5. Mobile Banking\n6. Loan Services\n7. Customer Care',
            continueSession: true,
          ),
          UssdResponse(
            sessionId: 'long-session',
            text:
                'Account Balance\nSelect Account:\n1. Savings Account\n2. Current Account\n3. Fixed Deposit',
            continueSession: true,
          ),
          UssdResponse(
            sessionId: 'long-session',
            text:
                'Savings Account Balance\nAccount: 1234567890\nBalance: KES 50,000.00\nAvailable: KES 48,500.00\nLast Transaction: 15-Nov-2024',
            continueSession: true,
          ),
          UssdResponse(
            sessionId: 'long-session',
            text:
                'Transaction Options\n1. Send Money\n2. View Transactions\n3. Back to Main Menu\n4. Exit',
            continueSession: true,
          ),
          UssdResponse(
            sessionId: 'long-session',
            text: 'Thank you for using our services',
            continueSession: false,
          ),
        ],
        ussdPath: ['', '1', '1', '4', '4'],
        createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
        isActive: false,
      );

      when(mockUssdProvider.currentSession).thenReturn(longSession);

      await tester.pumpWidgetBuilder(
        createTestWidget(themeMode: ThemeMode.light),
        surfaceSize: const Size(400, 800),
      );

      await screenMatchesGolden(tester, 'conversation_view_long_conversation');
    });

    testGoldens('UssdConversationView - High Contrast Theme', (tester) async {
      await loadAppFonts();

      // Setup high contrast accessibility settings
      when(mockAccessibilityProvider.settings).thenReturn(
        const AccessibilitySettings(
          accessibilityEnabled: true,
          useHighContrast: true,
          textScaleFactor: 1.2,
          enableTextToSpeech: true,
          enableVoiceInput: false,
        ),
      );

      await tester.pumpWidgetBuilder(
        createTestWidget(themeMode: ThemeMode.light),
        surfaceSize: const Size(400, 600),
      );

      await screenMatchesGolden(tester, 'conversation_view_high_contrast');
    });

    testGoldens('UssdConversationView - Large Text Scale', (tester) async {
      await loadAppFonts();

      // Setup large text scale accessibility settings
      when(mockAccessibilityProvider.settings).thenReturn(
        const AccessibilitySettings(
          accessibilityEnabled: true,
          useHighContrast: false,
          textScaleFactor: 1.5,
          enableTextToSpeech: false,
          enableVoiceInput: false,
        ),
      );

      await tester.pumpWidgetBuilder(
        createTestWidget(themeMode: ThemeMode.light),
        surfaceSize: const Size(400, 700),
      );

      await screenMatchesGolden(tester, 'conversation_view_large_text');
    });
  });
}
