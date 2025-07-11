import 'package:flutter_test/flutter_test.dart';
import 'package:ussd_emulator/services/ussd_session_service.dart';
import 'package:ussd_emulator/models/ussd_request.dart';
import 'package:ussd_emulator/utils/ussd_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('Text Payload Construction', () {
    late UssdSessionService service;

    setUp(() {
      // Mock SharedPreferences for testing
      SharedPreferences.setMockInitialValues({});
      service = UssdSessionService();
    });

    test('should build correct text payload for initial request', () {
      // Arrange
      final emptyPath = <String>[];

      // Act
      final textPayload = UssdUtils.buildTextInput(emptyPath);

      // Assert
      expect(textPayload, '');
    });

    test('should build correct text payload for single selection', () {
      // Arrange
      final path = ['1'];

      // Act
      final textPayload = UssdUtils.buildTextInput(path);

      // Assert
      expect(textPayload, '1');
    });

    test('should build correct text payload for multiple selections', () {
      // Arrange
      final path = ['1', '2', '1', '0', '1'];

      // Act
      final textPayload = UssdUtils.buildTextInput(path);

      // Assert
      expect(textPayload, '1*2*1*0*1');
    });

    test('should handle USSD flow correctly - initial request', () async {
      // Arrange
      await service.startSession(
        phoneNumber: '+256700000000',
        serviceCode: '*123#',
      );

      // Act
      final session = service.currentSession!;
      final textPayload = UssdUtils.buildTextInput(session.ussdPath);

      // Assert
      expect(session.requests.isEmpty, true); // No requests sent yet
      expect(textPayload, ''); // Empty text for initial request
    });

    test('should handle USSD flow correctly - after first input', () async {
      // Arrange
      await service.startSession(
        phoneNumber: '+256700000000',
        serviceCode: '*123#',
      );

      // Simulate sending initial request
      final initialRequest = UssdRequest(
        sessionId: service.currentSession!.id,
        phoneNumber: '+256700000000',
        serviceCode: '*123#',
        text: '',
      );
      await service.addRequest(initialRequest);

      // Act - Add first user input
      await service.addUserInputToPath('1');
      final session = service.currentSession!;
      final textPayload = UssdUtils.buildTextInput(session.ussdPath);

      // Assert
      expect(session.requests.length, 1); // Has one previous request
      expect(session.ussdPath, ['1']);
      expect(textPayload, '1');
    });

    test('should handle USSD flow correctly - multiple inputs', () async {
      // Arrange
      await service.startSession(
        phoneNumber: '+256700000000',
        serviceCode: '*123#',
      );

      // Simulate sending initial request
      final initialRequest = UssdRequest(
        sessionId: service.currentSession!.id,
        phoneNumber: '+256700000000',
        serviceCode: '*123#',
        text: '',
      );
      await service.addRequest(initialRequest);

      // Act - Add multiple user inputs
      await service.addUserInputToPath('1');
      await service.addUserInputToPath('2');
      await service.addUserInputToPath('1');
      await service.addUserInputToPath('0');
      await service.addUserInputToPath('1');

      final session = service.currentSession!;
      final textPayload = UssdUtils.buildTextInput(session.ussdPath);

      // Assert
      expect(session.ussdPath, ['1', '2', '1', '0', '1']);
      expect(textPayload, '1*2*1*0*1');
    });

    test(
      'should determine initial request correctly based on request count',
      () async {
        // Arrange
        await service.startSession(
          phoneNumber: '+256700000000',
          serviceCode: '*123#',
        );

        // Act & Assert - Before any requests
        expect(service.currentSession!.requests.isEmpty, true);

        // Add first request
        final request = UssdRequest(
          sessionId: service.currentSession!.id,
          phoneNumber: '+256700000000',
          serviceCode: '*123#',
          text: '',
        );
        await service.addRequest(request);

        // Act & Assert - After first request
        expect(service.currentSession!.requests.isEmpty, false);
        expect(service.currentSession!.requests.length, 1);
      },
    );

    test('should validate the fixed text payload bug scenario', () async {
      // This test specifically validates the bug fix where text was always empty

      // Arrange
      await service.startSession(
        phoneNumber: '+256700000000',
        serviceCode: '*123#',
      );

      // Step 1: Send initial request (empty text)
      final initialRequest = UssdRequest(
        sessionId: service.currentSession!.id,
        phoneNumber: '+256700000000',
        serviceCode: '*123#',
        text: '',
      );
      await service.addRequest(initialRequest);

      // Step 2: User selects option "1"
      await service.addUserInputToPath('1');

      // Check if this is considered initial request (should be false now)
      final isInitialRequest = service.currentSession!.requests.isEmpty;
      expect(isInitialRequest, false);

      // Build text payload for second request
      final textForSecondRequest = UssdUtils.buildTextInput(
        service.currentSession!.ussdPath,
      );
      expect(textForSecondRequest, '1'); // Should NOT be empty

      // Step 3: User selects option "2"
      await service.addUserInputToPath('2');
      final textForThirdRequest = UssdUtils.buildTextInput(
        service.currentSession!.ussdPath,
      );
      expect(textForThirdRequest, '1*2');

      // Step 4: Verify final payload format
      await service.addUserInputToPath('0');
      final finalText = UssdUtils.buildTextInput(
        service.currentSession!.ussdPath,
      );
      expect(finalText, '1*2*0');
    });
  });
}
