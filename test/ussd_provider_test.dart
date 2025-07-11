import 'package:flutter_test/flutter_test.dart';
import 'package:ussd_emulator/providers/ussd_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('UssdProvider', () {
    late UssdProvider provider;

    setUp(() {
      // Mock SharedPreferences for testing
      SharedPreferences.setMockInitialValues({});
      provider = UssdProvider();
    });

    test('should initialize with default values', () {
      expect(provider.isLoading, false);
      expect(provider.error, null);
      expect(provider.currentSession, null);
      expect(provider.isInitialized, false);
    });

    test(
      'should handle error when no active session for sendUssdInput',
      () async {
        // Act
        await provider.sendUssdInput('1');

        // Assert
        expect(provider.error, 'No active session');
      },
    );

    test('should validate empty input', () async {
      // Act
      await provider.sendUssdInput('');

      // Assert - Should fail due to no active session (checked first)
      expect(provider.error, 'No active session');
    });

    test('should validate whitespace-only input', () async {
      // Act
      await provider.sendUssdInput('   ');

      // Assert - Should fail due to no active session (checked first)
      expect(provider.error, 'No active session');
    });

    test(
      'should handle error when no active endpoint for sendUssdInput',
      () async {
        // Arrange - Start a session first
        await provider.startSession(
          phoneNumber: '+256700000000',
          serviceCode: '*123#',
        );

        // Clear any error from session start
        provider.clearError();

        // Act
        await provider.sendUssdInput('1');

        // Assert - Should error due to no active endpoint
        expect(provider.error, 'No active endpoint configuration');
      },
    );

    test('should handle initialization', () async {
      // Act
      await provider.init();

      // Assert - With mocked SharedPreferences, initialization should succeed
      expect(provider.isLoading, false);
      expect(provider.isInitialized, true);
    });

    test(
      'should validate empty input when session exists but no endpoint',
      () async {
        // Arrange - Start a session first (but no endpoint configured)
        await provider.startSession(
          phoneNumber: '+256700000000',
          serviceCode: '*123#',
        );
        provider.clearError(); // Clear any startup errors

        // Act
        await provider.sendUssdInput('');

        // Assert - Should fail due to no active endpoint (checked before input validation)
        expect(provider.error, 'No active endpoint configuration');
      },
    );

    test(
      'should validate whitespace-only input when session exists but no endpoint',
      () async {
        // Arrange - Start a session first (but no endpoint configured)
        await provider.startSession(
          phoneNumber: '+256700000000',
          serviceCode: '*123#',
        );
        provider.clearError(); // Clear any startup errors

        // Act
        await provider.sendUssdInput('   ');

        // Assert - Should fail due to no active endpoint (checked before input validation)
        expect(provider.error, 'No active endpoint configuration');
      },
    );
  });
}
