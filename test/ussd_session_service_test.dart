import 'package:flutter_test/flutter_test.dart';
import 'package:ussd_emulator/services/ussd_session_service.dart';
import 'package:ussd_emulator/models/ussd_request.dart';
import 'package:ussd_emulator/models/ussd_response.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  group('UssdSessionService', () {
    late UssdSessionService service;

    setUp(() async {
      // Mock SharedPreferences for testing
      SharedPreferences.setMockInitialValues({});
      service = UssdSessionService();
    });

    test('should start a new session', () async {
      // Act
      final session = await service.startSession(
        phoneNumber: '+256700000000',
        serviceCode: '*123#',
      );

      // Assert
      expect(session.phoneNumber, '+256700000000');
      expect(session.serviceCode, '*123#');
      expect(session.isActive, true);
      expect(session.ussdPath, isEmpty);
      expect(session.requests, isEmpty);
      expect(session.responses, isEmpty);
    });

    test('should add user input to path', () async {
      // Arrange
      await service.startSession(
        phoneNumber: '+256700000000',
        serviceCode: '*123#',
      );

      // Act
      final updatedSession = await service.addUserInputToPath('1');

      // Assert
      expect(updatedSession.ussdPath, ['1']);
    });

    test('should add multiple inputs to path', () async {
      // Arrange
      await service.startSession(
        phoneNumber: '+256700000000',
        serviceCode: '*123#',
      );

      // Act
      await service.addUserInputToPath('1');
      await service.addUserInputToPath('2');
      final finalSession = await service.addUserInputToPath('3');

      // Assert
      expect(finalSession.ussdPath, ['1', '2', '3']);
    });

    test('should add request to session', () async {
      // Arrange
      await service.startSession(
        phoneNumber: '+256700000000',
        serviceCode: '*123#',
      );

      final request = UssdRequest(
        sessionId: service.currentSession!.id,
        phoneNumber: '+256700000000',
        serviceCode: '*123#',
        text: '',
      );

      // Act
      final updatedSession = await service.addRequest(request);

      // Assert
      expect(updatedSession.requests.length, 1);
      expect(updatedSession.requests.first, request);
    });

    test('should add response to session', () async {
      // Arrange
      await service.startSession(
        phoneNumber: '+256700000000',
        serviceCode: '*123#',
      );

      final response = UssdResponse(
        sessionId: service.currentSession!.id,
        text: 'Welcome to USSD service',
        continueSession: true,
      );

      // Act
      final updatedSession = await service.addResponse(response);

      // Assert
      expect(updatedSession.responses.length, 1);
      expect(updatedSession.responses.first, response);
      expect(updatedSession.isActive, true);
    });

    test('should end session when response has continueSession false', () async {
      // Arrange
      await service.startSession(
        phoneNumber: '+256700000000',
        serviceCode: '*123#',
      );

      final response = UssdResponse(
        sessionId: service.currentSession!.id,
        text: 'Thank you for using our service',
        continueSession: false,
      );

      // Act
      final updatedSession = await service.addResponse(response);

      // Assert
      expect(updatedSession.isActive, false);
      expect(updatedSession.endedAt, isNotNull);
    });

    test('should throw exception when adding input without session', () async {
      // Act & Assert
      expect(
        () => service.addUserInputToPath('1'),
        throwsA(isA<Exception>()),
      );
    });

    test('should throw exception when adding request without session', () async {
      // Arrange
      final request = UssdRequest(
        sessionId: 'non-existent',
        phoneNumber: '+256700000000',
        serviceCode: '*123#',
        text: '',
      );

      // Act & Assert
      expect(
        () => service.addRequest(request),
        throwsA(isA<Exception>()),
      );
    });

    test('should clean user input correctly', () async {
      // Arrange
      await service.startSession(
        phoneNumber: '+256700000000',
        serviceCode: '*123#',
      );

      // Act
      final updatedSession = await service.addUserInputToPath('  1  ');

      // Assert
      expect(updatedSession.ussdPath, ['1']);
    });
  });
}