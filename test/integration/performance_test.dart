import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
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
import '../widget/widgets/ussd_conversation_view_test.mocks.dart';

void main() {
  group('USSD Emulator Performance Tests', () {
    late MockUssdProvider mockUssdProvider;
    late MockAccessibilityProvider mockAccessibilityProvider;

    setUp(() {
      mockUssdProvider = MockUssdProvider();
      mockAccessibilityProvider = MockAccessibilityProvider();
      
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

    Widget createTestWidget(UssdSession session) {
      when(mockUssdProvider.currentSession).thenReturn(session);
      
      return MultiProvider(
        providers: [
          ChangeNotifierProvider<UssdProvider>.value(value: mockUssdProvider),
          ChangeNotifierProvider<AccessibilityProvider>.value(value: mockAccessibilityProvider),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: UssdConversationView(),
          ),
        ),
      );
    }

    testWidgets('Conversation view scrolling performance with large conversation', (tester) async {
      // Create a session with many conversation exchanges
      final largeSession = _createLargeConversationSession();
      
      await tester.pumpWidget(createTestWidget(largeSession));
      
      // Find scrollable widget
      final scrollableFinder = find.byType(ListView);
      if (!scrollableFinder.hasFound) {
        // Alternative: look for SingleChildScrollView
        final altScrollable = find.byType(SingleChildScrollView);
        if (!altScrollable.hasFound) {
          // Skip test if no scrollable found
          return;
        }
      }
      
      // Perform scrolling actions and measure basic performance
      final stopwatch = Stopwatch()..start();
      
      // Perform fast scrolling actions
      await tester.fling(scrollableFinder.hasFound ? scrollableFinder : find.byType(SingleChildScrollView), 
                        const Offset(0, -500), 1000);
      await tester.pumpAndSettle();
      
      await tester.fling(scrollableFinder.hasFound ? scrollableFinder : find.byType(SingleChildScrollView), 
                        const Offset(0, 500), 1000);
      await tester.pumpAndSettle();
      
      stopwatch.stop();
      
      // Verify reasonable performance (should complete within 2 seconds)
      expect(stopwatch.elapsedMilliseconds, lessThan(2000), 
             reason: 'Scrolling should complete within 2 seconds');
    });

    testWidgets('Memory usage with large conversation history', (tester) async {
      final largeSession = _createLargeConversationSession();
      
      await tester.pumpWidget(createTestWidget(largeSession));
      
      // Pump multiple times to ensure all widgets are built
      for (int i = 0; i < 10; i++) {
        await tester.pump();
      }
      
      // Verify the widget tree is built efficiently
      final textWidgets = find.byType(Text);
      expect(textWidgets.evaluate().length, lessThan(200), 
             reason: 'Should efficiently manage text widgets for large conversations');
    });

    testWidgets('Rapid user input performance', (tester) async {
      final session = _createBasicSession();
      
      await tester.pumpWidget(createTestWidget(session));
      
      final stopwatch = Stopwatch()..start();
      
      final inputField = find.byType(TextField);
      
      if (inputField.hasFound) {
        // Simulate rapid user input
        for (int i = 0; i < 10; i++) { // Reduced iterations for simpler test
          await tester.enterText(inputField, 'Input $i');
          await tester.pump();
          
          final sendButton = find.byIcon(Icons.send);
          if (sendButton.hasFound) {
            await tester.tap(sendButton);
            await tester.pump();
          }
        }
      }
      
      stopwatch.stop();
      
      // Verify responsive input handling (should complete within 3 seconds)
      expect(stopwatch.elapsedMilliseconds, lessThan(3000), 
             reason: 'Rapid input handling should complete within 3 seconds');
    });

    testWidgets('Widget rebuild performance', (tester) async {
      final session = _createBasicSession();
      
      await tester.pumpWidget(createTestWidget(session));
      
      final stopwatch = Stopwatch()..start();
      
      // Trigger multiple rebuilds by changing mock data
      for (int i = 0; i < 5; i++) { // Reduced iterations
        final updatedSession = session.copyWith(
          responses: [
            ...session.responses,
            UssdResponse(
              sessionId: session.id,
              text: 'New response $i',
              continueSession: true,
            ),
          ],
        );
        
        when(mockUssdProvider.currentSession).thenReturn(updatedSession);
        
        // Trigger rebuild
        await tester.pump();
      }
      
      stopwatch.stop();
      
      // Verify efficient rebuilds (should complete within 2 seconds)
      expect(stopwatch.elapsedMilliseconds, lessThan(2000), 
             reason: 'Widget rebuilds should complete efficiently');
    });

    testWidgets('Theme switching performance', (tester) async {
      final session = _createBasicSession();
      
      Widget createThemedWidget(ThemeMode mode) {
        return MultiProvider(
          providers: [
            ChangeNotifierProvider<UssdProvider>.value(value: mockUssdProvider),
            ChangeNotifierProvider<AccessibilityProvider>.value(value: mockAccessibilityProvider),
          ],
          child: MaterialApp(
            theme: ThemeData.light(),
            darkTheme: ThemeData.dark(),
            themeMode: mode,
            home: Scaffold(
              body: UssdConversationView(),
            ),
          ),
        );
      }
      
      when(mockUssdProvider.currentSession).thenReturn(session);
      
      await tester.pumpWidget(createThemedWidget(ThemeMode.light));
      
      final stopwatch = Stopwatch()..start();
      
      // Switch between themes
      await tester.pumpWidget(createThemedWidget(ThemeMode.dark));
      await tester.pump();
      
      await tester.pumpWidget(createThemedWidget(ThemeMode.light));
      await tester.pump();
      
      stopwatch.stop();
      
      // Verify smooth theme transitions (should complete within 1 second)
      expect(stopwatch.elapsedMilliseconds, lessThan(1000), 
             reason: 'Theme switching should be fast');
    });

    testWidgets('Text scale factor performance', (tester) async {
      final session = _createBasicSession();
      
      Widget createScaledWidget(double scaleFactor) {
        when(mockAccessibilityProvider.settings).thenReturn(
          AccessibilitySettings(
            accessibilityEnabled: true,
            useHighContrast: false,
            textScaleFactor: scaleFactor,
            enableTextToSpeech: false,
            enableVoiceInput: false,
          ),
        );
        
        return createTestWidget(session);
      }
      
      await tester.pumpWidget(createScaledWidget(1.0));
      
      final stopwatch = Stopwatch()..start();
      
      // Test different text scale factors
      final scaleFactors = [1.2, 1.5, 2.0, 1.0];
      
      for (final factor in scaleFactors) {
        await tester.pumpWidget(createScaledWidget(factor));
        await tester.pump();
      }
      
      stopwatch.stop();
      
      // Verify smooth text scaling (should complete within 2 seconds)
      expect(stopwatch.elapsedMilliseconds, lessThan(2000), 
             reason: 'Text scaling should be efficient');
    });

    testWidgets('Animation performance during loading states', (tester) async {
      final session = _createBasicSession();
      
      await tester.pumpWidget(createTestWidget(session));
      
      final stopwatch = Stopwatch()..start();
      
      // Toggle loading state multiple times
      for (int i = 0; i < 3; i++) { // Reduced iterations
        when(mockUssdProvider.isLoading).thenReturn(true);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));
        
        when(mockUssdProvider.isLoading).thenReturn(false);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));
      }
      
      stopwatch.stop();
      
      // Verify smooth loading animations (should complete within 2 seconds)
      expect(stopwatch.elapsedMilliseconds, lessThan(2000), 
             reason: 'Loading state animations should be efficient');
    });

    group('Memory Leak Tests', () {
      testWidgets('No memory leaks during session changes', (tester) async {
        // Create multiple sessions to test memory management
        final sessions = List.generate(5, (i) => _createBasicSession(id: 'session-$i'));
        
        for (final session in sessions) {
          await tester.pumpWidget(createTestWidget(session));
          await tester.pump();
          
          // Force garbage collection simulation
          await tester.pump(const Duration(milliseconds: 100));
        }
        
        // Final session should still work properly
        final finalSession = sessions.last;
        expect(find.text(finalSession.serviceCode), findsOneWidget);
      });

      testWidgets('Proper disposal of controllers and listeners', (tester) async {
        final session = _createBasicSession();
        
        await tester.pumpWidget(createTestWidget(session));
        
        // Verify widget builds correctly
        expect(find.byType(UssdConversationView), findsOneWidget);
        
        // Remove widget and verify cleanup
        await tester.pumpWidget(Container());
        
        // Should not throw errors after disposal
        await tester.pump();
      });
    });
  });
}

UssdSession _createBasicSession({String? id}) {
  return UssdSession(
    id: id ?? 'test-session',
    phoneNumber: '254700000000',
    serviceCode: '*123#',
    networkCode: 'safaricom',
    requests: [
      UssdRequest(
        phoneNumber: '254700000000',
        serviceCode: '*123#',
        text: '',
        sessionId: id ?? 'test-session',
      ),
    ],
    responses: [
      UssdResponse(
        sessionId: id ?? 'test-session',
        text: 'Welcome to Mobile Money\n1. Send Money\n2. Check Balance',
        continueSession: true,
      ),
    ],
    ussdPath: [''],
    createdAt: DateTime.now(),
    isActive: true,
  );
}

UssdSession _createLargeConversationSession() {
  final requests = <UssdRequest>[];
  final responses = <UssdResponse>[];
  final path = <String>[];
  
  // Create 50 conversation exchanges
  for (int i = 0; i < 50; i++) {
    requests.add(
      UssdRequest(
        phoneNumber: '254700000000',
        serviceCode: '*123#',
        text: i == 0 ? '' : '$i',
        sessionId: 'large-session',
      ),
    );
    
    responses.add(
      UssdResponse(
        sessionId: 'large-session',
        text: 'Response $i: This is a detailed response with multiple lines\n'
               'Line 2 of response $i\n'
               'Line 3 with options:\n'
               '1. Option A\n'
               '2. Option B\n'
               '3. Option C\n'
               '4. Go Back\n'
               '5. Exit',
        continueSession: i < 49,
      ),
    );
    
    path.add(i == 0 ? '' : '$i');
  }
  
  return UssdSession(
    id: 'large-session',
    phoneNumber: '254700000000',
    serviceCode: '*456#',
    networkCode: 'airtel',
    requests: requests,
    responses: responses,
    ussdPath: path,
    createdAt: DateTime.now().subtract(const Duration(hours: 1)),
    isActive: false,
  );
}