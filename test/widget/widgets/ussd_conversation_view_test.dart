import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:provider/provider.dart';
import 'package:ussd_emulator/providers/ussd_provider.dart';
import 'package:ussd_emulator/widgets/ussd_conversation_view.dart';
import 'package:ussd_emulator/models/ussd_session.dart';
import 'package:ussd_emulator/models/ussd_request.dart';
import 'package:ussd_emulator/models/ussd_response.dart';

@GenerateMocks([UssdProvider])
import 'ussd_conversation_view_test.mocks.dart';

void main() {
  group('UssdConversationView Widget Tests', () {
    late MockUssdProvider mockUssdProvider;
    late UssdSession testSession;

    setUp(() {
      mockUssdProvider = MockUssdProvider();

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
            text:
                'Welcome to USSD Service\n1. Check Balance\n2. Transfer Money\n3. Buy Airtime',
            continueSession: true,
          ),
        ],
        ussdPath: [''],
        createdAt: DateTime.now(),
        isActive: true,
      );

      when(mockUssdProvider.currentSession).thenReturn(testSession);
      when(mockUssdProvider.isLoading).thenReturn(false);
      when(mockUssdProvider.error).thenReturn(null);
    });

    Widget createTestWidget({ThemeMode themeMode = ThemeMode.light}) {
      return MultiProvider(
        providers: [
          ChangeNotifierProvider<UssdProvider>.value(value: mockUssdProvider),
        ],
        child: MaterialApp(
          theme: ThemeData.light(),
          darkTheme: ThemeData.dark(),
          themeMode: themeMode,
          home: const Scaffold(body: UssdConversationView()),
        ),
      );
    }

    testWidgets('should display conversation correctly', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text('*123#'), findsOneWidget);
      expect(find.textContaining('Welcome to USSD Service'), findsOneWidget);
      expect(find.textContaining('1. Check Balance'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('should handle user input and send USSD command', (
      tester,
    ) async {
      await tester.pumpWidget(createTestWidget());

      final inputField = find.byType(TextField);
      await tester.enterText(inputField, '1');
      await tester.pump();

      expect(find.text('1'), findsOneWidget);

      final sendButton = find.byIcon(Icons.send);
      expect(sendButton, findsOneWidget);

      await tester.tap(sendButton);
      await tester.pump();

      verify(mockUssdProvider.sendUssdInput('1')).called(1);
    });

    testWidgets('should handle keyboard enter key for sending input', (
      tester,
    ) async {
      await tester.pumpWidget(createTestWidget());

      final inputField = find.byType(TextField);
      await tester.enterText(inputField, '2');
      await tester.pump();

      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();

      verify(mockUssdProvider.sendUssdInput('2')).called(1);
    });

    testWidgets('should clear input field after sending', (tester) async {
      await tester.pumpWidget(createTestWidget());

      final inputField = find.byType(TextField);
      await tester.enterText(inputField, '1');
      await tester.pump();

      await tester.tap(find.byIcon(Icons.send));
      await tester.pump();

      final textField = tester.widget<TextField>(inputField);
      expect(textField.controller?.text, isEmpty);
    });

    testWidgets('should display multiple conversation exchanges', (
      tester,
    ) async {
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

      expect(find.textContaining('Welcome'), findsOneWidget);
      expect(
        find.textContaining('Your balance is KES 1,000.00'),
        findsOneWidget,
      );
    });

    testWidgets('should support dark theme', (tester) async {
      await tester.pumpWidget(createTestWidget(themeMode: ThemeMode.dark));

      expect(find.byType(UssdConversationView), findsOneWidget);
      expect(find.text('*123#'), findsOneWidget);
    });

    testWidgets('should handle long response text with scrolling', (
      tester,
    ) async {
      final longResponseSession = testSession.copyWith(
        responses: [
          UssdResponse(
            sessionId: 'test-session-1',
            text: 'This is a very long USSD response ' * 20,
            continueSession: true,
          ),
        ],
      );

      when(mockUssdProvider.currentSession).thenReturn(longResponseSession);

      await tester.pumpWidget(createTestWidget());

      expect(find.byType(ListView), findsOneWidget);
      expect(find.textContaining('This is a very long'), findsOneWidget);
    });
  });
}
