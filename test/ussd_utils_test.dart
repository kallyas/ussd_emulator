import 'package:flutter_test/flutter_test.dart';
import 'package:ussd_emulator/utils/ussd_utils.dart';

void main() {
  group('UssdUtils', () {
    group('isUssdCode', () {
      test('should recognize valid USSD codes', () {
        expect(UssdUtils.isUssdCode('*123#'), true);
        expect(UssdUtils.isUssdCode('*555#'), true);
        expect(UssdUtils.isUssdCode('*777*'), true);
        expect(UssdUtils.isUssdCode('*100'), true);
      });

      test('should reject invalid USSD codes', () {
        expect(UssdUtils.isUssdCode('123'), false);
        expect(UssdUtils.isUssdCode('abc'), false);
        expect(UssdUtils.isUssdCode(''), false);
        expect(UssdUtils.isUssdCode('*abc#'), false);
      });
    });

    group('extractServiceCode', () {
      test('should extract service code from USSD input', () {
        expect(UssdUtils.extractServiceCode('*123#'), '123');
        expect(UssdUtils.extractServiceCode('*555*'), '555');
        expect(UssdUtils.extractServiceCode('*777'), '777');
        expect(UssdUtils.extractServiceCode('100'), '100');
      });
    });

    group('isValidMenuSelection', () {
      test('should accept valid menu selections', () {
        expect(UssdUtils.isValidMenuSelection('1'), true);
        expect(UssdUtils.isValidMenuSelection('12'), true);
        expect(UssdUtils.isValidMenuSelection('1*2*3'), true);
        expect(UssdUtils.isValidMenuSelection('0'), true);
        expect(UssdUtils.isValidMenuSelection('#'), true);
        expect(UssdUtils.isValidMenuSelection('*'), true);
      });

      test('should reject invalid menu selections', () {
        expect(UssdUtils.isValidMenuSelection(''), false);
        expect(UssdUtils.isValidMenuSelection('abc'), false);
        expect(UssdUtils.isValidMenuSelection('1a2'), false);
        expect(UssdUtils.isValidMenuSelection('1 2'), false);
      });
    });

    group('buildTextInput', () {
      test('should build correct text input from path', () {
        expect(UssdUtils.buildTextInput([]), '');
        expect(UssdUtils.buildTextInput(['1']), '1');
        expect(UssdUtils.buildTextInput(['1', '2', '3']), '1*2*3');
        expect(UssdUtils.buildTextInput(['0', '1', '2']), '0*1*2');
      });
    });

    group('addToPath', () {
      test('should add input to path correctly', () {
        expect(UssdUtils.addToPath([], '1'), ['1']);
        expect(UssdUtils.addToPath(['1'], '2'), ['1', '2']);
        expect(UssdUtils.addToPath(['1', '2'], '3'), ['1', '2', '3']);
      });
    });

    group('isSessionEndResponse', () {
      test('should detect session end indicators', () {
        expect(UssdUtils.isSessionEndResponse('END Thank you'), true);
        expect(
          UssdUtils.isSessionEndResponse('Thank you for using our service'),
          true,
        );
        expect(UssdUtils.isSessionEndResponse('Session ended'), true);
        expect(UssdUtils.isSessionEndResponse('Goodbye'), true);
        expect(UssdUtils.isSessionEndResponse('Transaction completed'), true);
      });

      test('should not detect continuation responses as end', () {
        expect(UssdUtils.isSessionEndResponse('CON Welcome'), false);
        expect(
          UssdUtils.isSessionEndResponse('Please select an option'),
          false,
        );
        expect(UssdUtils.isSessionEndResponse('Enter your PIN'), false);
      });
    });

    group('formatPathForDisplay', () {
      test('should format path correctly for display', () {
        expect(UssdUtils.formatPathForDisplay([]), 'Initial Request');
        expect(UssdUtils.formatPathForDisplay(['1']), 'Path: 1');
        expect(
          UssdUtils.formatPathForDisplay(['1', '2', '3']),
          'Path: 1 → 2 → 3',
        );
      });
    });

    group('cleanUserInput', () {
      test('should clean user input correctly', () {
        expect(UssdUtils.cleanUserInput(' 123 '), '123');
        expect(UssdUtils.cleanUserInput('1 2 3'), '123');
        expect(UssdUtils.cleanUserInput('  *123#  '), '*123#');
      });
    });

    group('isValidPhoneNumber', () {
      test('should validate phone numbers correctly', () {
        expect(UssdUtils.isValidPhoneNumber('+256700000000'), true);
        expect(UssdUtils.isValidPhoneNumber('0700000000'), true);
        expect(UssdUtils.isValidPhoneNumber('+1-234-567-8900'), true);
        expect(UssdUtils.isValidPhoneNumber('+1 (234) 567-8900'), true);
      });

      test('should reject invalid phone numbers', () {
        expect(UssdUtils.isValidPhoneNumber(''), false);
        expect(UssdUtils.isValidPhoneNumber('abc'), false);
        expect(UssdUtils.isValidPhoneNumber('123'), false);
      });
    });
  });
}
