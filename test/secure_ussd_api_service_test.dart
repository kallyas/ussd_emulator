import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:dio/dio.dart';
import 'package:ussd_emulator/services/secure_ussd_api_service.dart';
import 'package:ussd_emulator/models/ussd_request.dart';
import 'package:ussd_emulator/models/ussd_response.dart';
import 'package:ussd_emulator/models/endpoint_config.dart';
import 'package:ussd_emulator/services/ussd_api_service.dart';

// Generate mocks
@GenerateMocks([Dio])
import 'secure_ussd_api_service_test.mocks.dart';

void main() {
  group('SecureUssdApiService', () {
    late SecureUssdApiService service;
    late MockDio mockDio;
    late EndpointConfig testConfig;
    late UssdRequest testRequest;

    setUp(() {
      service = SecureUssdApiService();
      testConfig = EndpointConfig(
        id: 'test',
        name: 'Test Endpoint',
        url: 'https://api.example.com/ussd',
        headers: {},
        isActive: true,
      );
      testRequest = UssdRequest(
        sessionId: 'test_session_123',
        phoneNumber: '+256700000000',
        text: '1',
        serviceCode: '*123#',
      );
    });

    group('_sanitizeRequest', () {
      test('should sanitize valid request', () {
        final result = service._sanitizeRequest(testRequest);
        expect(result.sessionId, 'test_session_123');
        expect(result.phoneNumber, '+256700000000');
        expect(result.text, '1');
        expect(result.serviceCode, '*123#');
      });

      test('should throw exception for invalid session ID', () {
        final invalidRequest = UssdRequest(
          sessionId: 'invalid session id with spaces',
          phoneNumber: '+256700000000',
          text: '1',
          serviceCode: '*123#',
        );

        expect(
          () => service._sanitizeRequest(invalidRequest),
          throwsA(isA<UssdApiException>()),
        );
      });

      test('should throw exception for invalid phone number', () {
        final invalidRequest = UssdRequest(
          sessionId: 'test_session_123',
          phoneNumber: 'invalid_phone',
          text: '1',
          serviceCode: '*123#',
        );

        expect(
          () => service._sanitizeRequest(invalidRequest),
          throwsA(isA<UssdApiException>()),
        );
      });

      test('should sanitize dangerous characters in text', () {
        final maliciousRequest = UssdRequest(
          sessionId: 'test_session_123',
          phoneNumber: '+256700000000',
          text: '1<script>alert("xss")</script>',
          serviceCode: '*123#',
        );

        final result = service._sanitizeRequest(maliciousRequest);
        expect(result.text, '1');
      });
    });

    group('_generateRequestSignature', () {
      test('should generate consistent signatures', () {
        final timestamp = '1234567890';
        final signature1 = service._generateRequestSignature(
          testRequest,
          timestamp,
        );
        final signature2 = service._generateRequestSignature(
          testRequest,
          timestamp,
        );

        expect(signature1, equals(signature2));
        expect(signature1, isNotEmpty);
        expect(signature1.length, equals(64)); // SHA256 hex length
      });

      test('should generate different signatures for different requests', () {
        final timestamp = '1234567890';
        final signature1 = service._generateRequestSignature(
          testRequest,
          timestamp,
        );

        final differentRequest = UssdRequest(
          sessionId: 'different_session',
          phoneNumber: '+256700000000',
          text: '2',
          serviceCode: '*123#',
        );
        final signature2 = service._generateRequestSignature(
          differentRequest,
          timestamp,
        );

        expect(signature1, isNot(equals(signature2)));
      });
    });

    group('_prepareSecureHeaders', () {
      test('should include all required security headers', () async {
        final headers = await service._prepareSecureHeaders(
          testConfig,
          testRequest,
        );

        expect(headers['Content-Type'], 'application/json');
        expect(headers['User-Agent'], startsWith('USSD-Emulator/'));
        expect(headers['X-Request-ID'], isNotNull);
        expect(headers['X-Timestamp'], isNotNull);
        expect(headers['X-Request-Signature'], isNotNull);
        expect(headers['X-Client-Version'], isNotNull);
        expect(headers['Accept'], 'application/json');
        expect(headers['Cache-Control'], 'no-cache');
      });

      test('should include config headers', () async {
        final configWithHeaders = EndpointConfig(
          id: 'test',
          name: 'Test Endpoint',
          url: 'https://api.example.com/ussd',
          headers: {'Custom-Header': 'custom-value'},
          isActive: true,
        );

        final headers = await service._prepareSecureHeaders(
          configWithHeaders,
          testRequest,
        );
        expect(headers['Custom-Header'], 'custom-value');
      });
    });

    group('_filterSensitiveData', () {
      test('should mask phone numbers', () {
        final logString = 'Request to +256700000000 failed';
        final filtered = service._filterSensitiveData(logString);
        expect(filtered, contains('+25****00'));
        expect(filtered, isNot(contains('+256700000000')));
      });

      test('should mask passwords in JSON', () {
        final logString = '{"password":"secret123","other":"value"}';
        final filtered = service._filterSensitiveData(logString);
        expect(filtered, contains('"password":"[REDACTED]"'));
        expect(filtered, isNot(contains('secret123')));
      });

      test('should mask authorization headers', () {
        final logString = 'Authorization: Bearer abc123def456';
        final filtered = service._filterSensitiveData(logString);
        expect(filtered, contains('Authorization:[REDACTED]'));
        expect(filtered, isNot(contains('abc123def456')));
      });

      test('should preserve non-sensitive data', () {
        final logString = 'Normal log message with safe data';
        final filtered = service._filterSensitiveData(logString);
        expect(filtered, equals(logString));
      });
    });

    group('RequestSigningInterceptor', () {
      test('should add signature headers to request', () {
        final interceptor = RequestSigningInterceptor('test_secret');
        final options = RequestOptions(path: '/test');
        final handler = _MockRequestInterceptorHandler();

        interceptor.onRequest(options, handler);

        expect(options.headers['X-Timestamp'], isNotNull);
        expect(options.headers['X-Signature'], isNotNull);
        expect(options.headers['X-Signature'], hasLength(64)); // SHA256 hex
      });
    });

    group('SecurityHeadersInterceptor', () {
      test('should add security headers to request', () {
        final interceptor = SecurityHeadersInterceptor();
        final options = RequestOptions(path: '/test');
        final handler = _MockRequestInterceptorHandler();

        interceptor.onRequest(options, handler);

        expect(options.headers['X-Content-Type-Options'], 'nosniff');
        expect(options.headers['X-Frame-Options'], 'DENY');
        expect(options.headers['X-XSS-Protection'], '1; mode=block');
        expect(
          options.headers['Referrer-Policy'],
          'strict-origin-when-cross-origin',
        );
      });
    });
  });
}

// Mock handler for interceptor tests
class _MockRequestInterceptorHandler extends Mock
    implements RequestInterceptorHandler {
  @override
  void next(RequestOptions requestOptions) {
    // Mock implementation
  }
}
