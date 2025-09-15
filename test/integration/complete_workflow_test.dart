import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:ussd_emulator/main.dart' as app;
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('USSD Emulator Integration Tests', () {
    setUp(() async {
      // Clear shared preferences before each test
      SharedPreferences.setMockInitialValues({});
    });

    testWidgets('Complete USSD session workflow', (tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Verify app starts with home screen
      expect(find.text('USSD Emulator'), findsAtLeastOneWidget);
      
      // Look for start session button or similar
      await tester.pump(const Duration(seconds: 1));
      
      // Navigate to configuration if needed
      final settingsButton = find.byIcon(Icons.settings);
      if (settingsButton.hasFound) {
        await tester.tap(settingsButton);
        await tester.pumpAndSettle();
        
        // Add endpoint configuration
        final addButton = find.byIcon(Icons.add);
        if (addButton.hasFound) {
          await tester.tap(addButton);
          await tester.pumpAndSettle();
          
          // Fill in endpoint details
          final nameField = find.byType(TextField).first;
          await tester.enterText(nameField, 'Test Endpoint');
          await tester.pumpAndSettle();
          
          // Look for URL field and fill it
          final textFields = find.byType(TextField);
          if (textFields.evaluate().length > 1) {
            await tester.enterText(textFields.at(1), 'http://localhost:8080/ussd');
            await tester.pumpAndSettle();
          }
          
          // Save configuration
          final saveButton = find.textContaining('Save').or(find.byIcon(Icons.check));
          if (saveButton.hasFound) {
            await tester.tap(saveButton);
            await tester.pumpAndSettle();
          }
        }
        
        // Navigate back to home
        final backButton = find.byIcon(Icons.arrow_back);
        if (backButton.hasFound) {
          await tester.tap(backButton);
          await tester.pumpAndSettle();
        }
      }

      // Test starting a new USSD session
      await _testNewUssdSession(tester);
      
      // Test USSD conversation flow
      await _testUssdConversationFlow(tester);
      
      // Test session history
      await _testSessionHistory(tester);
    });

    testWidgets('Accessibility features workflow', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigate to accessibility settings
      await _navigateToAccessibilitySettings(tester);
      
      // Test enabling accessibility features
      await _testAccessibilitySettings(tester);
      
      // Return to main app and test accessibility features
      await _testAccessibilityInConversation(tester);
    });

    testWidgets('Template system workflow', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigate to template builder
      await _navigateToTemplateBuilder(tester);
      
      // Create a new template
      await _testTemplateCreation(tester);
      
      // Execute the template
      await _testTemplateExecution(tester);
    });

    testWidgets('Session export functionality', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Start a session to have data to export
      await _createSampleSession(tester);
      
      // Navigate to session history
      await _navigateToSessionHistory(tester);
      
      // Test export functionality
      await _testSessionExport(tester);
    });

    testWidgets('Error handling and recovery', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Test network error handling
      await _testNetworkErrorHandling(tester);
      
      // Test invalid input handling
      await _testInvalidInputHandling(tester);
      
      // Test session timeout handling
      await _testSessionTimeoutHandling(tester);
    });
  });
}

Future<void> _testNewUssdSession(WidgetTester tester) async {
  // Look for new session button
  final newSessionButton = find.textContaining('New Session')
      .or(find.byIcon(Icons.add))
      .or(find.textContaining('Start'));
  
  if (newSessionButton.hasFound) {
    await tester.tap(newSessionButton);
    await tester.pumpAndSettle();
    
    // Fill in session details
    final phoneField = find.byType(TextField).first;
    await tester.enterText(phoneField, '254700000000');
    await tester.pumpAndSettle();
    
    // Look for service code field
    final textFields = find.byType(TextField);
    if (textFields.evaluate().length > 1) {
      await tester.enterText(textFields.at(1), '*123#');
      await tester.pumpAndSettle();
    }
    
    // Start the session
    final startButton = find.textContaining('Start')
        .or(find.byIcon(Icons.play_arrow))
        .or(find.textContaining('Begin'));
    
    if (startButton.hasFound) {
      await tester.tap(startButton);
      await tester.pumpAndSettle();
    }
  }
}

Future<void> _testUssdConversationFlow(WidgetTester tester) async {
  // Look for input field in conversation
  final inputField = find.byType(TextField);
  if (inputField.hasFound) {
    // Test sending user input
    await tester.enterText(inputField, '1');
    await tester.pumpAndSettle();
    
    // Send the input
    final sendButton = find.byIcon(Icons.send);
    if (sendButton.hasFound) {
      await tester.tap(sendButton);
      await tester.pumpAndSettle(const Duration(seconds: 2));
    }
    
    // Test multiple inputs in sequence
    const inputs = ['2', '254700000001', '1000', '1234'];
    for (final input in inputs) {
      final currentInput = find.byType(TextField);
      if (currentInput.hasFound) {
        await tester.enterText(currentInput, input);
        await tester.pumpAndSettle();
        
        final currentSend = find.byIcon(Icons.send);
        if (currentSend.hasFound) {
          await tester.tap(currentSend);
          await tester.pumpAndSettle(const Duration(seconds: 1));
        }
      }
    }
  }
}

Future<void> _testSessionHistory(WidgetTester tester) async {
  // Navigate to session history
  final historyButton = find.textContaining('History')
      .or(find.byIcon(Icons.history))
      .or(find.textContaining('Sessions'));
  
  if (historyButton.hasFound) {
    await tester.tap(historyButton);
    await tester.pumpAndSettle();
    
    // Verify history is displayed
    expect(find.byType(ListView), findsAtLeastOneWidget);
    
    // Test tapping on a session
    final sessionTile = find.byType(ListTile);
    if (sessionTile.hasFound) {
      await tester.tap(sessionTile.first);
      await tester.pumpAndSettle();
    }
  }
}

Future<void> _navigateToAccessibilitySettings(WidgetTester tester) async {
  // Look for settings or accessibility menu
  final settingsButton = find.byIcon(Icons.settings)
      .or(find.textContaining('Settings'))
      .or(find.byIcon(Icons.accessibility));
  
  if (settingsButton.hasFound) {
    await tester.tap(settingsButton);
    await tester.pumpAndSettle();
    
    // Look for accessibility specific settings
    final accessibilityButton = find.textContaining('Accessibility')
        .or(find.byIcon(Icons.accessibility));
    
    if (accessibilityButton.hasFound) {
      await tester.tap(accessibilityButton);
      await tester.pumpAndSettle();
    }
  }
}

Future<void> _testAccessibilitySettings(WidgetTester tester) async {
  // Test enabling high contrast
  final highContrastSwitch = find.textContaining('High Contrast')
      .or(find.textContaining('Contrast'));
  
  if (highContrastSwitch.hasFound) {
    await tester.tap(highContrastSwitch);
    await tester.pumpAndSettle();
  }
  
  // Test text scaling
  final textScaleSlider = find.byType(Slider);
  if (textScaleSlider.hasFound) {
    await tester.drag(textScaleSlider, const Offset(50, 0));
    await tester.pumpAndSettle();
  }
  
  // Test enabling TTS
  final ttsSwitch = find.textContaining('Text to Speech')
      .or(find.textContaining('TTS'))
      .or(find.textContaining('Speech'));
  
  if (ttsSwitch.hasFound) {
    await tester.tap(ttsSwitch);
    await tester.pumpAndSettle();
  }
}

Future<void> _testAccessibilityInConversation(WidgetTester tester) async {
  // Navigate back to conversation
  final backButton = find.byIcon(Icons.arrow_back);
  if (backButton.hasFound) {
    await tester.tap(backButton);
    await tester.pumpAndSettle();
  }
  
  // Test that accessibility features are working
  // This would include checking for semantic labels, focus management, etc.
  final SemanticsHandle handle = tester.ensureSemantics();
  
  // Check for semantic accessibility features
  expect(tester.semantics, hasSemantics());
  
  handle.dispose();
}

Future<void> _navigateToTemplateBuilder(WidgetTester tester) async {
  final templateButton = find.textContaining('Template')
      .or(find.byIcon(Icons.build))
      .or(find.textContaining('Builder'));
  
  if (templateButton.hasFound) {
    await tester.tap(templateButton);
    await tester.pumpAndSettle();
  }
}

Future<void> _testTemplateCreation(WidgetTester tester) async {
  // Create new template
  final newTemplateButton = find.byIcon(Icons.add)
      .or(find.textContaining('New'));
  
  if (newTemplateButton.hasFound) {
    await tester.tap(newTemplateButton);
    await tester.pumpAndSettle();
    
    // Fill template name
    final nameField = find.byType(TextField).first;
    await tester.enterText(nameField, 'Test Template');
    await tester.pumpAndSettle();
    
    // Add template steps
    final addStepButton = find.textContaining('Add Step')
        .or(find.byIcon(Icons.add_circle));
    
    if (addStepButton.hasFound) {
      await tester.tap(addStepButton);
      await tester.pumpAndSettle();
      
      // Configure step
      final stepFields = find.byType(TextField);
      if (stepFields.evaluate().length > 1) {
        await tester.enterText(stepFields.at(1), '1');
        await tester.pumpAndSettle();
      }
    }
    
    // Save template
    final saveButton = find.textContaining('Save')
        .or(find.byIcon(Icons.check));
    
    if (saveButton.hasFound) {
      await tester.tap(saveButton);
      await tester.pumpAndSettle();
    }
  }
}

Future<void> _testTemplateExecution(WidgetTester tester) async {
  // Execute the created template
  final executeButton = find.textContaining('Execute')
      .or(find.byIcon(Icons.play_arrow))
      .or(find.textContaining('Run'));
  
  if (executeButton.hasFound) {
    await tester.tap(executeButton);
    await tester.pumpAndSettle();
    
    // Watch execution progress
    await tester.pump(const Duration(seconds: 3));
  }
}

Future<void> _createSampleSession(WidgetTester tester) async {
  // Create a sample session for testing export
  await _testNewUssdSession(tester);
  await _testUssdConversationFlow(tester);
}

Future<void> _navigateToSessionHistory(WidgetTester tester) async {
  final historyButton = find.textContaining('History')
      .or(find.byIcon(Icons.history));
  
  if (historyButton.hasFound) {
    await tester.tap(historyButton);
    await tester.pumpAndSettle();
  }
}

Future<void> _testSessionExport(WidgetTester tester) async {
  // Look for export button
  final exportButton = find.textContaining('Export')
      .or(find.byIcon(Icons.file_download))
      .or(find.byIcon(Icons.share));
  
  if (exportButton.hasFound) {
    await tester.tap(exportButton);
    await tester.pumpAndSettle();
    
    // Select export format
    final formatOption = find.textContaining('CSV')
        .or(find.textContaining('PDF'))
        .or(find.textContaining('JSON'));
    
    if (formatOption.hasFound) {
      await tester.tap(formatOption);
      await tester.pumpAndSettle();
    }
    
    // Confirm export
    final confirmButton = find.textContaining('Export')
        .or(find.textContaining('Confirm'));
    
    if (confirmButton.hasFound) {
      await tester.tap(confirmButton);
      await tester.pumpAndSettle();
    }
  }
}

Future<void> _testNetworkErrorHandling(WidgetTester tester) async {
  // Test behavior with invalid endpoint
  await _testNewUssdSession(tester);
  
  // The app should handle network errors gracefully
  await tester.pump(const Duration(seconds: 5));
  
  // Look for error messages
  expect(find.textContaining('Error').or(find.textContaining('Failed')), 
         findsNothing, reason: 'App should handle errors gracefully');
}

Future<void> _testInvalidInputHandling(WidgetTester tester) async {
  // Test invalid phone number input
  final inputField = find.byType(TextField);
  if (inputField.hasFound) {
    await tester.enterText(inputField, 'invalid-phone');
    await tester.pumpAndSettle();
    
    // Try to submit
    final submitButton = find.textContaining('Start')
        .or(find.byIcon(Icons.send));
    
    if (submitButton.hasFound) {
      await tester.tap(submitButton);
      await tester.pumpAndSettle();
      
      // Should show validation error
      expect(find.textContaining('valid'), findsOneWidget, 
             reason: 'Should show validation message for invalid input');
    }
  }
}

Future<void> _testSessionTimeoutHandling(WidgetTester tester) async {
  // Test session timeout scenarios
  await _testNewUssdSession(tester);
  
  // Wait for potential timeout
  await tester.pump(const Duration(seconds: 10));
  
  // App should handle timeout gracefully
  expect(find.byType(TextField), findsWidgets, 
         reason: 'App should remain functional after timeout');
}