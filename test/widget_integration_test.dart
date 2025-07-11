import 'package:flutter_test/flutter_test.dart';
import 'package:ussd_emulator/models/ussd_session.dart';
import 'package:ussd_emulator/models/ussd_request.dart';
import 'package:ussd_emulator/models/ussd_response.dart';
import 'package:ussd_emulator/utils/ussd_utils.dart';

void main() {
  group('Core Integration Tests', () {
    test('should handle complete USSD session flow correctly', () {
      // Test the complete flow of USSD session management
      
      // Create initial session
      final session = UssdSession(
        id: 'test-session',
        phoneNumber: '+256700000000',
        serviceCode: '*123#',
        requests: [],
        responses: [],
        ussdPath: [],
        createdAt: DateTime.now(),
        isActive: true,
      );

      // Verify initial state
      expect(session.isActive, true);
      expect(session.ussdPath, isEmpty);
      expect(session.pathAsText, '');
      expect(session.isInitialRequest, true);

      // Add some path elements
      final updatedPath = ['1', '2', '1'];
      final updatedSession = session.copyWith(ussdPath: updatedPath);
      
      expect(updatedSession.pathAsText, '1*2*1');
      expect(updatedSession.isInitialRequest, false);
    });

    test('should build correct text payload for requests', () {
      // Test the critical text payload building logic
      
      expect(UssdUtils.buildTextInput([]), '');
      expect(UssdUtils.buildTextInput(['1']), '1');
      expect(UssdUtils.buildTextInput(['1', '2']), '1*2');
      expect(UssdUtils.buildTextInput(['1', '2', '1', '0', '1']), '1*2*1*0*1');
    });

    test('should validate USSD codes correctly', () {
      // Test USSD validation
      
      expect(UssdUtils.isUssdCode('*123#'), true);
      expect(UssdUtils.isUssdCode('*555#'), true);
      expect(UssdUtils.isUssdCode('123'), false);
      expect(UssdUtils.isUssdCode(''), false);
    });

    test('should extract service codes correctly', () {
      // Test service code extraction
      
      expect(UssdUtils.extractServiceCode('*123#'), '123');
      expect(UssdUtils.extractServiceCode('*555#'), '555');
      expect(UssdUtils.extractServiceCode('*777*'), '777');
    });

    test('should handle USSD responses correctly', () {
      // Test response parsing
      
      final conResponse = UssdResponse.fromTextResponse('CON Welcome to service');
      expect(conResponse.continueSession, true);
      expect(conResponse.text, 'Welcome to service');

      final endResponse = UssdResponse.fromTextResponse('END Thank you');
      expect(endResponse.continueSession, false);
      expect(endResponse.text, 'Thank you');
    });

    test('should create proper request objects', () {
      // Test request creation
      
      final request = UssdRequest(
        sessionId: 'test-session',
        phoneNumber: '+256700000000',
        serviceCode: '*123#',
        text: '1*2*1',
      );

      expect(request.sessionId, 'test-session');
      expect(request.phoneNumber, '+256700000000');
      expect(request.serviceCode, '*123#');
      expect(request.text, '1*2*1');

      final json = request.toJson();
      expect(json['sessionId'], 'test-session');
      expect(json['phoneNumber'], '+256700000000');
      expect(json['serviceCode'], '*123#');
      expect(json['text'], '1*2*1');
    });
  });
}