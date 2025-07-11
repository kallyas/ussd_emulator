// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ussd_emulator/main.dart';

void main() {
  testWidgets('USSD Emulator app starts', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const UssdEmulatorApp());
    
    // Verify that our app starts with a loading indicator
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Initializing USSD Emulator...'), findsOneWidget);
  });
}
