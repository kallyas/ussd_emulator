import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ussd_emulator/models/ussd_session.dart';
import 'package:ussd_emulator/models/ussd_request.dart';
import 'package:ussd_emulator/models/ussd_response.dart';
import 'package:ussd_emulator/models/endpoint_config.dart';
import 'package:ussd_emulator/models/accessibility_settings.dart';
import 'package:ussd_emulator/providers/ussd_provider.dart';
import 'package:ussd_emulator/providers/accessibility_provider.dart';

/// Test data factory for creating consistent test objects
class TestDataFactory {
  /// Create a basic USSD session for testing
  static UssdSession createBasicSession({
    String? id,
    String? phoneNumber,
    String? serviceCode,
    bool isActive = true,
  }) {
    return UssdSession(
      id: id ?? 'test-session-${DateTime.now().millisecondsSinceEpoch}',
      phoneNumber: phoneNumber ?? '254700000000',
      serviceCode: serviceCode ?? '*123#',
      networkCode: 'safaricom',
      requests: [
        UssdRequest(
          phoneNumber: phoneNumber ?? '254700000000',
          serviceCode: serviceCode ?? '*123#',
          text: '',
          sessionId: id ?? 'test-session',
        ),
      ],
      responses: [
        UssdResponse(
          sessionId: id ?? 'test-session',
          text: 'Welcome to USSD Service\n1. Check Balance\n2. Transfer Money\n3. Buy Airtime',
          continueSession: true,
        ),
      ],
      ussdPath: [''],
      createdAt: DateTime.now(),
      isActive: isActive,
    );
  }

  /// Create a session with multiple conversation exchanges
  static UssdSession createMultiExchangeSession({
    String? id,
    int exchangeCount = 3,
  }) {
    final sessionId = id ?? 'multi-session-${DateTime.now().millisecondsSinceEpoch}';
    final requests = <UssdRequest>[];
    final responses = <UssdResponse>[];
    final path = <String>[];

    for (int i = 0; i < exchangeCount; i++) {
      requests.add(
        UssdRequest(
          phoneNumber: '254700000000',
          serviceCode: '*123#',
          text: i == 0 ? '' : '$i',
          sessionId: sessionId,
        ),
      );

      responses.add(
        UssdResponse(
          sessionId: sessionId,
          text: _getResponseText(i),
          continueSession: i < exchangeCount - 1,
        ),
      );

      path.add(i == 0 ? '' : '$i');
    }

    return UssdSession(
      id: sessionId,
      phoneNumber: '254700000000',
      serviceCode: '*123#',
      networkCode: 'safaricom',
      requests: requests,
      responses: responses,
      ussdPath: path,
      createdAt: DateTime.now().subtract(Duration(minutes: exchangeCount)),
      isActive: false,
    );
  }

  /// Create an endpoint configuration for testing
  static EndpointConfig createEndpointConfig({
    String? name,
    String? baseUrl,
    bool isActive = true,
  }) {
    return EndpointConfig(
      id: 'config-${DateTime.now().millisecondsSinceEpoch}',
      name: name ?? 'Test Endpoint',
      baseUrl: baseUrl ?? 'http://localhost:8080',
      timeout: const Duration(seconds: 30),
      isActive: isActive,
      headers: {'Content-Type': 'application/json'},
    );
  }

  /// Create accessibility settings for testing
  static AccessibilitySettings createAccessibilitySettings({
    bool accessibilityEnabled = false,
    bool useHighContrast = false,
    double textScaleFactor = 1.0,
    bool enableTextToSpeech = false,
  }) {
    return AccessibilitySettings(
      accessibilityEnabled: accessibilityEnabled,
      useHighContrast: useHighContrast,
      textScaleFactor: textScaleFactor,
      enableTextToSpeech: enableTextToSpeech,
      enableVoiceInput: false,
    );
  }

  /// Create a session with error state
  static UssdSession createErrorSession() {
    return UssdSession(
      id: 'error-session',
      phoneNumber: '254700000000',
      serviceCode: '*123#',
      networkCode: 'safaricom',
      requests: [
        UssdRequest(
          phoneNumber: '254700000000',
          serviceCode: '*123#',
          text: '',
          sessionId: 'error-session',
        ),
      ],
      responses: [],
      ussdPath: [''],
      createdAt: DateTime.now(),
      isActive: false,
    );
  }

  static String _getResponseText(int index) {
    switch (index) {
      case 0:
        return 'Welcome to Mobile Banking\n1. Account Balance\n2. Transfer Money\n3. Pay Bills\n4. Buy Airtime';
      case 1:
        return 'Account Balance\nSelect Account:\n1. Savings - *1234\n2. Current - *5678\n3. Back';
      case 2:
        return 'Savings Account Balance\nAccount: ****1234\nBalance: KES 25,750.00\nAvailable: KES 23,500.00';
      default:
        return 'Thank you for using our services.';
    }
  }
}

/// Widget test helpers for creating test environments
class TestWidgetHelpers {
  /// Create a minimal test app with providers
  static Widget createTestApp({
    required Widget child,
    UssdProvider? ussdProvider,
    AccessibilityProvider? accessibilityProvider,
    ThemeMode themeMode = ThemeMode.light,
  }) {
    return MultiProvider(
      providers: [
        if (ussdProvider != null)
          ChangeNotifierProvider<UssdProvider>.value(value: ussdProvider),
        if (accessibilityProvider != null)
          ChangeNotifierProvider<AccessibilityProvider>.value(value: accessibilityProvider),
      ],
      child: MaterialApp(
        theme: ThemeData.light(),
        darkTheme: ThemeData.dark(),
        themeMode: themeMode,
        home: Scaffold(
          body: child,
        ),
      ),
    );
  }

  /// Create a test app with material design
  static Widget createMaterialTestApp(Widget child) {
    return MaterialApp(
      home: Scaffold(
        body: child,
      ),
    );
  }

  /// Create a test app with custom theme
  static Widget createThemedTestApp({
    required Widget child,
    required ThemeData theme,
  }) {
    return MaterialApp(
      theme: theme,
      home: Scaffold(
        body: child,
      ),
    );
  }
}

/// Mock data generators for HTTP responses
class MockResponseGenerator {
  /// Generate a typical USSD CON response
  static String generateConResponse(String message) {
    return 'CON $message';
  }

  /// Generate a typical USSD END response
  static String generateEndResponse(String message) {
    return 'END $message';
  }

  /// Generate a typical mobile money menu
  static String generateMobileMoneyMenu() {
    return generateConResponse(
      'Welcome to Mobile Money\n'
      '1. Send Money\n'
      '2. Withdraw Cash\n'
      '3. Buy Airtime\n'
      '4. Pay Bills\n'
      '5. Check Balance',
    );
  }

  /// Generate a balance response
  static String generateBalanceResponse(double balance) {
    return generateEndResponse(
      'Your account balance is KES ${balance.toStringAsFixed(2)}. '
      'Thank you for using our service.',
    );
  }

  /// Generate an error response
  static String generateErrorResponse(String error) {
    return generateEndResponse('Error: $error. Please try again.');
  }
}

/// Test assertions helpers
class TestAssertions {
  /// Assert that a widget is accessible
  static void assertAccessible(
    dynamic finder, {
    String? expectedLabel,
    bool shouldBeFocusable = true,
  }) {
    // This would contain accessibility-specific assertions
    // Implementation depends on specific accessibility requirements
  }

  /// Assert that UI performance is acceptable
  static void assertPerformance(
    Duration duration, {
    Duration maxDuration = const Duration(milliseconds: 100),
  }) {
    if (duration > maxDuration) {
      throw AssertionError(
        'Performance assertion failed: operation took ${duration.inMilliseconds}ms, '
        'expected less than ${maxDuration.inMilliseconds}ms',
      );
    }
  }

  /// Assert that no memory leaks occurred
  static void assertNoMemoryLeaks() {
    // This would contain memory leak detection logic
    // Implementation depends on specific memory monitoring tools
  }
}

/// Test configuration constants
class TestConfig {
  static const Duration defaultTimeout = Duration(seconds: 10);
  static const Duration shortTimeout = Duration(seconds: 5);
  static const Duration longTimeout = Duration(seconds: 30);
  
  static const Size mobileScreenSize = Size(375, 667);
  static const Size tabletScreenSize = Size(768, 1024);
  static const Size desktopScreenSize = Size(1920, 1080);
  
  static const String testPhoneNumber = '254700000000';
  static const String testServiceCode = '*123#';
  static const String testNetworkCode = 'safaricom';
}