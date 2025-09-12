import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:ussd_emulator/widgets/ussd_conversation_view.dart';
import 'package:ussd_emulator/providers/ussd_provider.dart';
import 'package:ussd_emulator/providers/accessibility_provider.dart';

void main() {
  group('UssdConversationView Accessibility', () {
    late UssdProvider ussdProvider;
    late AccessibilityProvider accessibilityProvider;

    setUp(() {
      ussdProvider = UssdProvider();
      accessibilityProvider = AccessibilityProvider();
    });

    Widget createTestWidget() {
      return MaterialApp(
        home: MultiProvider(
          providers: [
            ChangeNotifierProvider<UssdProvider>.value(value: ussdProvider),
            ChangeNotifierProvider<AccessibilityProvider>.value(
              value: accessibilityProvider,
            ),
          ],
          child: const Scaffold(body: UssdConversationView()),
        ),
      );
    }

    testWidgets('should display no session message when no active session', (
      tester,
    ) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text('No active session'), findsOneWidget);
    });

    testWidgets('should have semantic structure', (tester) async {
      await tester.pumpWidget(createTestWidget());

      // Check for semantic widgets
      expect(find.byType(Semantics), findsWidgets);

      // Should not throw any accessibility violations
      expect(tester.takeException(), isNull);
    });

    testWidgets('should support keyboard navigation', (tester) async {
      await tester.pumpWidget(createTestWidget());

      // Test tab navigation
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();

      // Should not throw any exceptions
      expect(tester.takeException(), isNull);
    });

    testWidgets('should handle accessibility settings changes', (tester) async {
      await tester.pumpWidget(createTestWidget());

      // Toggle accessibility settings
      await accessibilityProvider.toggleVoiceInput();
      await accessibilityProvider.toggleTextToSpeech();
      await accessibilityProvider.toggleHighContrast();

      await tester.pump();

      // Should update without errors
      expect(tester.takeException(), isNull);
      expect(accessibilityProvider.settings.enableVoiceInput, true);
      expect(accessibilityProvider.settings.enableTextToSpeech, true);
      expect(accessibilityProvider.settings.useHighContrast, true);
    });

    testWidgets('should have proper widget structure for accessibility', (
      tester,
    ) async {
      await tester.pumpWidget(createTestWidget());

      // Should have a scaffold structure
      expect(find.byType(Scaffold), findsOneWidget);

      // Should have center widget for no session state
      expect(find.byType(Center), findsOneWidget);

      // Should have accessible text
      expect(find.text('No active session'), findsOneWidget);
    });

    testWidgets('should respect text scale factor', (tester) async {
      // Set a custom text scale factor
      await accessibilityProvider.setTextScaleFactor(1.5);

      await tester.pumpWidget(createTestWidget());

      expect(accessibilityProvider.settings.textScaleFactor, 1.5);
      expect(tester.takeException(), isNull);
    });

    testWidgets('should support high contrast mode', (tester) async {
      await accessibilityProvider.toggleHighContrast();

      await tester.pumpWidget(createTestWidget());

      expect(accessibilityProvider.settings.useHighContrast, true);
      expect(tester.takeException(), isNull);
    });

    testWidgets('should maintain accessibility during loading states', (
      tester,
    ) async {
      await tester.pumpWidget(createTestWidget());

      // Verify initial state is accessible
      expect(find.byType(Semantics), findsWidgets);
      expect(tester.takeException(), isNull);
    });
  });
}
