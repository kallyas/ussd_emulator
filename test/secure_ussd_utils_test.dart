import 'package:flutter_test/flutter_test.dart';
import 'package:ussd_emulator/utils/secure_ussd_utils.dart';
import 'package:ussd_emulator/models/validation_exception.dart';

void main() {
  group('SecureUssdUtils', () {
    group('sanitizeUssdInput', () {
      test('should sanitize valid USSD codes', () {
        expect(SecureUssdUtils.sanitizeUssdInput('*123#'), '*123#');
        expect(SecureUssdUtils.sanitizeUssdInput('*555*'), '*555*');
        expect(SecureUssdUtils.sanitizeUssdInput('*777'), '*777');
      });

      test('should remove dangerous characters', () {
        expect(SecureUssdUtils.sanitizeUssdInput('*123<script>#'), '*123#');
        expect(SecureUssdUtils.sanitizeUssdInput('*555&lt;test&gt;*'), '*555*');
      });

      test('should enforce length limits', () {
        final longInput = '*${'1' * 200}#';
        expect(
          () => SecureUssdUtils.sanitizeUssdInput(longInput),
          throwsA(isA<ValidationException>()),
        );
      });

      test('should reject empty input', () {
        expect(
          () => SecureUssdUtils.sanitizeUssdInput(''),
          throwsA(isA<ValidationException>()),
        );
      });

      test('should validate USSD format', () {
        expect(
          () => SecureUssdUtils.sanitizeUssdInput('*abc#'),
          throwsA(isA<ValidationException>()),
        );
      });
    });

    group('validatePhoneNumber', () {
      test('should validate correct phone numbers', () {
        expect(SecureUssdUtils.validatePhoneNumber('+256700000000'), '+256700000000');
        expect(SecureUssdUtils.validatePhoneNumber('+1234567890'), '+1234567890');
        expect(SecureUssdUtils.validatePhoneNumber('256700000000'), '256700000000');
      });

      test('should clean phone number formatting', () {
        expect(SecureUssdUtils.validatePhoneNumber('+256 700 000 000'), '+256700000000');
        expect(SecureUssdUtils.validatePhoneNumber('+256-700-000-000'), '+256700000000');
        expect(SecureUssdUtils.validatePhoneNumber('+256(700)000.000'), '+256700000000');
      });

      test('should reject invalid phone numbers', () {
        expect(
          () => SecureUssdUtils.validatePhoneNumber(''),
          throwsA(isA<ValidationException>()),
        );
        expect(
          () => SecureUssdUtils.validatePhoneNumber('abc'),
          throwsA(isA<ValidationException>()),
        );
        expect(
          () => SecureUssdUtils.validatePhoneNumber('123'),
          throwsA(isA<ValidationException>()),
        );
      });

      test('should enforce length limits', () {
        final longPhone = '+${'1' * 20}';
        expect(
          () => SecureUssdUtils.validatePhoneNumber(longPhone),
          throwsA(isA<ValidationException>()),
        );
      });
    });

    group('validateMenuSelection', () {
      test('should validate correct menu selections', () {
        expect(SecureUssdUtils.validateMenuSelection('1'), '1');
        expect(SecureUssdUtils.validateMenuSelection('12'), '12');
        expect(SecureUssdUtils.validateMenuSelection('*'), '*');
        expect(SecureUssdUtils.validateMenuSelection('#'), '#');
        expect(SecureUssdUtils.validateMenuSelection('1*2'), '1*2');
      });

      test('should remove dangerous characters', () {
        expect(SecureUssdUtils.validateMenuSelection('1<script>2'), '12');
        expect(SecureUssdUtils.validateMenuSelection('1&amp;2'), '12');
      });

      test('should reject invalid selections', () {
        expect(
          () => SecureUssdUtils.validateMenuSelection(''),
          throwsA(isA<ValidationException>()),
        );
        expect(
          () => SecureUssdUtils.validateMenuSelection('abc'),
          throwsA(isA<ValidationException>()),
        );
        expect(
          () => SecureUssdUtils.validateMenuSelection('1a2'),
          throwsA(isA<ValidationException>()),
        );
      });

      test('should enforce length limits', () {
        final longSelection = '1' * 15;
        expect(
          () => SecureUssdUtils.validateMenuSelection(longSelection),
          throwsA(isA<ValidationException>()),
        );
      });
    });

    group('validateServiceCode', () {
      test('should validate correct service codes', () {
        expect(SecureUssdUtils.validateServiceCode('*123#'), '*123#');
        expect(SecureUssdUtils.validateServiceCode('*555*'), '*555*');
      });

      test('should reject invalid service codes', () {
        expect(
          () => SecureUssdUtils.validateServiceCode(''),
          throwsA(isA<ValidationException>()),
        );
        expect(
          () => SecureUssdUtils.validateServiceCode('abc'),
          throwsA(isA<ValidationException>()),
        );
      });
    });

    group('validateSessionId', () {
      test('should validate correct session IDs', () {
        expect(SecureUssdUtils.validateSessionId('session_123'), 'session_123');
        expect(SecureUssdUtils.validateSessionId('ussd-456'), 'ussd-456');
        expect(SecureUssdUtils.validateSessionId('test123'), 'test123');
      });

      test('should reject invalid session IDs', () {
        expect(
          () => SecureUssdUtils.validateSessionId(''),
          throwsA(isA<ValidationException>()),
        );
        expect(
          () => SecureUssdUtils.validateSessionId('session with spaces'),
          throwsA(isA<ValidationException>()),
        );
        expect(
          () => SecureUssdUtils.validateSessionId('session@123'),
          throwsA(isA<ValidationException>()),
        );
      });
    });

    group('secureCleanUserInput', () {
      test('should clean input securely', () {
        expect(SecureUssdUtils.secureCleanUserInput(' 123 '), '123');
        expect(SecureUssdUtils.secureCleanUserInput('1<script>2'), '12');
        expect(SecureUssdUtils.secureCleanUserInput('1   2   3'), '123');
      });

      test('should handle empty input', () {
        expect(SecureUssdUtils.secureCleanUserInput(''), '');
      });
    });

    group('containsSuspiciousPatterns', () {
      test('should detect suspicious patterns', () {
        expect(SecureUssdUtils.containsSuspiciousPatterns('<script>'), true);
        expect(SecureUssdUtils.containsSuspiciousPatterns('SELECT * FROM'), true);
        expect(SecureUssdUtils.containsSuspiciousPatterns('javascript:'), true);
        expect(SecureUssdUtils.containsSuspiciousPatterns('$(curl'), true);
        expect(SecureUssdUtils.containsSuspiciousPatterns('%3Cscript%3E'), true);
      });

      test('should not flag normal input', () {
        expect(SecureUssdUtils.containsSuspiciousPatterns('*123#'), false);
        expect(SecureUssdUtils.containsSuspiciousPatterns('1'), false);
        expect(SecureUssdUtils.containsSuspiciousPatterns('menu option'), false);
      });
    });

    group('checkRateLimit', () {
      setUp(() {
        // Clear rate limit data before each test
        SecureUssdUtils.clearRateLimitData();
      });

      test('should allow requests within rate limit', () {
        expect(SecureUssdUtils.checkRateLimit('user1'), false);
        expect(SecureUssdUtils.checkRateLimit('user1'), false);
        expect(SecureUssdUtils.checkRateLimit('user1'), false);
      });

      test('should enforce rate limits', () {
        // Make requests up to the limit
        for (int i = 0; i < 10; i++) {
          expect(SecureUssdUtils.checkRateLimit('user2'), false);
        }
        // Next request should be rate limited
        expect(SecureUssdUtils.checkRateLimit('user2'), true);
      });

      test('should track different users separately', () {
        // User1 hits rate limit
        for (int i = 0; i < 10; i++) {
          SecureUssdUtils.checkRateLimit('user1');
        }
        expect(SecureUssdUtils.checkRateLimit('user1'), true);
        
        // User2 should still be allowed
        expect(SecureUssdUtils.checkRateLimit('user2'), false);
      });
    });
  });
}