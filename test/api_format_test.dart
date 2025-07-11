import 'package:flutter_test/flutter_test.dart';
import 'package:ussd_emulator/models/ussd_session.dart';
import 'package:ussd_emulator/models/ussd_request.dart';
import 'package:ussd_emulator/utils/ussd_utils.dart';

void main() {
  group('API Request Format', () {
    test('should create initial request with empty text', () {
      // Simulate initial USSD request
      final session = UssdSession(
        id: 'ussd_1704123456789_123',
        phoneNumber: '+256700000000',
        serviceCode: '123',
        requests: [],
        responses: [],
        ussdPath: [], // Empty path for initial request
        createdAt: DateTime.now(),
        isActive: true,
      );

      final request = UssdRequest(
        sessionId: session.id,
        phoneNumber: session.phoneNumber,
        serviceCode: session.serviceCode,
        text: session.pathAsText, // Should be empty for initial
      );

      final requestJson = request.toJson();

      expect(requestJson['serviceCode'], '123');
      expect(requestJson['phoneNumber'], '+256700000000');
      expect(requestJson['text'], ''); // Empty for initial request
      expect(requestJson['sessionId'], 'ussd_1704123456789_123');
    });

    test('should build correct path for menu navigation', () {
      // Simulate user navigation: 1 → 2 → 1 → 0 → 1
      final session = UssdSession(
        id: 'ussd_1704123456789_123',
        phoneNumber: '+256700000000',
        serviceCode: '123',
        requests: [],
        responses: [],
        ussdPath: ['1', '2', '1', '0', '1'],
        createdAt: DateTime.now(),
        isActive: true,
      );

      final request = UssdRequest(
        sessionId: session.id,
        phoneNumber: session.phoneNumber,
        serviceCode: session.serviceCode,
        text: session.pathAsText,
      );

      final requestJson = request.toJson();

      expect(requestJson['serviceCode'], '123');
      expect(requestJson['phoneNumber'], '+256700000000');
      expect(requestJson['text'], '1*2*1*0*1');
      expect(requestJson['sessionId'], 'ussd_1704123456789_123');
    });

    test('should build path step by step', () {
      // Test each step of path building
      final pathSteps = <List<String>>[
        <String>[], // Initial
        <String>['1'], // First selection
        <String>['1', '2'], // Second selection
        <String>['1', '2', '1'], // Third selection
        <String>['1', '2', '1', '0'], // Fourth selection
        <String>['1', '2', '1', '0', '1'], // Fifth selection
      ];

      final expectedTexts = [
        '', // Initial request
        '1', // First menu
        '1*2', // Second menu
        '1*2*1', // Third menu
        '1*2*1*0', // Fourth menu
        '1*2*1*0*1', // Fifth menu
      ];

      for (int i = 0; i < pathSteps.length; i++) {
        final textResult = UssdUtils.buildTextInput(pathSteps[i]);
        expect(
          textResult,
          expectedTexts[i],
          reason:
              'Step $i: path ${pathSteps[i]} should produce "${expectedTexts[i]}"',
        );
      }
    });

    test('should handle service code extraction correctly', () {
      final testCases = [
        {'input': '*123#', 'expected': '123'},
        {'input': '*555#', 'expected': '555'},
        {'input': '*777*', 'expected': '777'},
        {'input': '*100', 'expected': '100'},
      ];

      for (final testCase in testCases) {
        final result = UssdUtils.extractServiceCode(testCase['input']!);
        expect(
          result,
          testCase['expected'],
          reason:
              'Input "${testCase['input']}" should extract service code "${testCase['expected']}"',
        );
      }
    });

    test('should generate proper session ID format', () {
      final sessionId = UssdUtils.generateSessionId();

      expect(sessionId, startsWith('ussd_'));
      expect(sessionId.split('_').length, 3);
      expect(sessionId.split('_')[1], matches(r'^\d+$')); // Timestamp
      expect(sessionId.split('_')[2], matches(r'^[a-z0-9]+$')); // Random part
    });

    test('should create exact API format as specified', () {
      // Test the exact format from the specification
      final sessionId = 'ussd_1704123456789_123';

      // Initial request simulation
      final initialRequest = UssdRequest(
        serviceCode: '123',
        phoneNumber: '+256700000000',
        text: '',
        sessionId: sessionId,
      );

      final initialJson = initialRequest.toJson();
      expect(initialJson, {
        'serviceCode': '123',
        'phoneNumber': '+256700000000',
        'text': '',
        'sessionId': sessionId,
      });

      // Menu path request simulation
      final menuRequest = UssdRequest(
        serviceCode: '123',
        phoneNumber: '+256700000000',
        text: '1*2*1*0*1',
        sessionId: sessionId,
      );

      final menuJson = menuRequest.toJson();
      expect(menuJson, {
        'serviceCode': '123',
        'phoneNumber': '+256700000000',
        'text': '1*2*1*0*1',
        'sessionId': sessionId,
      });
    });
  });
}
