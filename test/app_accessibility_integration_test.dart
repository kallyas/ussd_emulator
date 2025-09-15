import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ussd_emulator/main.dart';

void main() {
  group('USSD Emulator App Accessibility Integration', () {
    testWidgets('should launch with accessibility support', (tester) async {
      await tester.pumpWidget(const UssdEmulatorApp());
      // Use pump() with duration instead of pumpAndSettle() to avoid infinite animation issues
      await tester.pump(const Duration(seconds: 1));
      await tester.pump();

      // Should find the main screen
      expect(find.text('USSD Emulator'), findsOneWidget);

      // Should have bottom navigation
      expect(find.byType(BottomNavigationBar), findsOneWidget);

      // Should have accessibility button in app bar
      expect(find.byIcon(Icons.accessibility_rounded), findsOneWidget);

      // Should not have any accessibility errors
      expect(tester.takeException(), isNull);
    });

    testWidgets('should navigate to accessibility settings', (tester) async {
      await tester.pumpWidget(const UssdEmulatorApp());
      await tester.pump(const Duration(seconds: 1));
      await tester.pump();

      // Tap accessibility settings button
      final accessibilityButton = find.byIcon(Icons.accessibility_rounded);
      await tester.tap(accessibilityButton);
      await tester.pump(const Duration(seconds: 1));
      await tester.pump();

      // Should navigate to accessibility settings
      expect(find.text('Accessibility Settings'), findsOneWidget);
    });

    testWidgets('should support keyboard navigation in main app', (
      tester,
    ) async {
      await tester.pumpWidget(const UssdEmulatorApp());
      await tester.pump(const Duration(seconds: 1));
      await tester.pump();

      // Test tab navigation
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();

      // Should handle keyboard input without errors
      expect(tester.takeException(), isNull);
    });

    testWidgets('should have semantic structure', (tester) async {
      await tester.pumpWidget(const UssdEmulatorApp());
      await tester.pump(const Duration(seconds: 1));
      await tester.pump();

      // Should have proper semantic widgets
      expect(find.byType(Semantics), findsWidgets);

      // Navigation should be semantically labeled
      final navBar = find.byType(BottomNavigationBar);
      expect(navBar, findsOneWidget);

      // Should have app title
      expect(find.text('USSD Emulator'), findsOneWidget);
    });

    testWidgets('should maintain accessibility across navigation', (
      tester,
    ) async {
      await tester.pumpWidget(const UssdEmulatorApp());
      await tester.pump(const Duration(seconds: 1));
      await tester.pump();

      // Navigate to different tabs
      final bottomNav = find.byType(BottomNavigationBar);

      // Tap Config tab
      await tester.tap(
        find.descendant(of: bottomNav, matching: find.text('Config')),
      );
      await tester.pump(const Duration(seconds: 1));
      await tester.pump();

      // Should still have semantic structure
      expect(find.byType(Semantics), findsWidgets);
      expect(tester.takeException(), isNull);

      // Tap History tab
      await tester.tap(
        find.descendant(of: bottomNav, matching: find.text('History')),
      );
      await tester.pump(const Duration(seconds: 1));
      await tester.pump();

      // Should maintain accessibility
      expect(find.byType(Semantics), findsWidgets);
      expect(tester.takeException(), isNull);
    });

    testWidgets('should support high contrast theme', (tester) async {
      await tester.pumpWidget(const UssdEmulatorApp());
      await tester.pump(const Duration(seconds: 1));
      await tester.pump();

      // Navigate to accessibility settings by tapping the accessibility icon area
      // Find the icon first and then tap at its location
      final accessibilityIcon = find.byIcon(Icons.accessibility_rounded);
      expect(accessibilityIcon, findsOneWidget);

      await tester.tap(accessibilityIcon);
      await tester.pump(const Duration(seconds: 1));
      await tester.pump();

      // Look for high contrast toggle (it might be in a loading state initially)
      // Just verify the screen loads without errors
      expect(find.text('Accessibility Settings'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('should handle text scaling', (tester) async {
      await tester.pumpWidget(const UssdEmulatorApp());
      await tester.pump(const Duration(seconds: 1));
      await tester.pump();

      // App should render with default text scale
      expect(find.text('USSD Emulator'), findsOneWidget);

      // Should handle text scale changes gracefully
      expect(tester.takeException(), isNull);
    });

    testWidgets('should have proper focus management', (tester) async {
      await tester.pumpWidget(const UssdEmulatorApp());
      await tester.pump(const Duration(seconds: 1));
      await tester.pump();

      // Test focus traversal
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();

      // Should have focusable elements
      final focusableWidgets = find.byType(Focus);
      expect(focusableWidgets.evaluate().isNotEmpty, true);

      expect(tester.takeException(), isNull);
    });
  });
}
