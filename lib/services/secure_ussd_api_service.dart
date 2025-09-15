import 'dart:convert';
import 'dart:math';
import 'package:dio/dio.dart';
import 'package:crypto/crypto.dart';
import '../models/ussd_request.dart';
import '../models/ussd_response.dart';
import '../models/endpoint_config.dart';
import '../models/validation_exception.dart';
import '../utils/secure_ussd_utils.dart';
import 'ussd_api_service.dart';

/// Secure API service with enhanced security features
class SecureUssdApiService extends UssdApiService {
  late final Dio _dio;
  static const String _appSecret =
      'ussd_emulator_secret_key'; // Should be from secure storage
  static const int _timeoutSeconds = 30;

  SecureUssdApiService() {
    _initializeDio();
  }

  void _initializeDio() {
    _dio = Dio(
      BaseOptions(
        connectTimeout: Duration(seconds: _timeoutSeconds),
        receiveTimeout: Duration(seconds: _timeoutSeconds),
        sendTimeout: Duration(seconds: _timeoutSeconds),
      ),
    );

    // Add security interceptors
    _dio.interceptors.addAll([
      LogInterceptor(
        requestBody: false, // Don't log sensitive request data
        responseBody: false, // Don't log sensitive response data
        logPrint: _secureLog,
        error: true,
        request: true,
        requestHeader: false, // Don't log headers that might contain auth
        responseHeader: false,
      ),
      RequestSigningInterceptor(_appSecret),
      SecurityHeadersInterceptor(),
    ]);
  }

  @override
  Future<UssdResponse> sendUssdRequest(
    UssdRequest request,
    EndpointConfig config,
  ) async {
    try {
      // Validate and sanitize request
      final sanitizedRequest = _sanitizeRequest(request);

      // Check rate limits
      if (SecureUssdUtils.checkRateLimit(sanitizedRequest.phoneNumber)) {
        throw UssdApiException('Rate limit exceeded', 429, null);
      }

      // Prepare secure headers
      final headers = await _prepareSecureHeaders(config, sanitizedRequest);

      final response = await _dio.post(
        config.url,
        data: sanitizedRequest.toJson(),
        options: Options(
          headers: headers,
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      return _validateAndParseResponse(response);
    } on DioException catch (e) {
      _logSecurityEvent('request_failed', {
        'endpoint': config.url,
        'error_type': e.type.toString(),
        'status_code': e.response?.statusCode,
      });

      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw UssdApiException('Request timeout', 408, null);
      } else if (e.response != null) {
        throw UssdApiException(
          'HTTP ${e.response!.statusCode}: ${e.response!.statusMessage}',
          e.response!.statusCode!,
          e.response!.data?.toString(),
        );
      } else {
        throw UssdApiException('Network error: ${e.message}', 0, null);
      }
    } catch (e) {
      if (e is UssdApiException) {
        rethrow;
      }
      throw UssdApiException('Unexpected error: ${e.toString()}', 0, null);
    }
  }

  /// Sanitize and validate request data
  UssdRequest _sanitizeRequest(UssdRequest request) {
    try {
      final sanitizedSessionId = SecureUssdUtils.validateSessionId(
        request.sessionId,
      );
      final sanitizedPhoneNumber = SecureUssdUtils.validatePhoneNumber(
        request.phoneNumber,
      );
      final sanitizedServiceCode = SecureUssdUtils.validateServiceCode(
        request.serviceCode,
      );
      final sanitizedText = request.text.isEmpty
          ? request.text
          : SecureUssdUtils.sanitizeUssdInput(request.text);

      // Check for suspicious patterns
      if (SecureUssdUtils.containsSuspiciousPatterns(sanitizedText)) {
        _logSecurityEvent('suspicious_request', {
          'session_id': sanitizedSessionId,
          'phone_number': sanitizedPhoneNumber,
          'text_length': sanitizedText.length,
        });
      }

      return UssdRequest(
        sessionId: sanitizedSessionId,
        phoneNumber: sanitizedPhoneNumber,
        text: sanitizedText,
        serviceCode: sanitizedServiceCode,
      );
    } on ValidationException catch (e) {
      throw UssdApiException('Invalid request data: ${e.message}', 400, null);
    }
  }

  /// Prepare secure headers for request
  Future<Map<String, dynamic>> _prepareSecureHeaders(
    EndpointConfig config,
    UssdRequest request,
  ) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final requestId = _generateRequestId();
    final appVersion = await _getAppVersion();

    return {
      'Content-Type': 'application/json',
      'User-Agent': 'USSD-Emulator/$appVersion',
      'X-Request-ID': requestId,
      'X-Timestamp': timestamp,
      'X-Request-Signature': _generateRequestSignature(request, timestamp),
      'X-Client-Version': appVersion,
      'Accept': 'application/json',
      'Cache-Control': 'no-cache',
      ...config.headers,
    };
  }

  /// Generate secure request signature
  String _generateRequestSignature(UssdRequest request, String timestamp) {
    final message =
        '${request.sessionId}:${request.phoneNumber}:${request.text}:$timestamp';
    final hmac = Hmac(sha256, utf8.encode(_appSecret));
    final digest = hmac.convert(utf8.encode(message));
    return digest.toString();
  }

  /// Generate unique request ID
  String _generateRequestId() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (i) => random.nextInt(256));
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }

  /// Get app version (placeholder implementation)
  Future<String> _getAppVersion() async {
    return '1.0.1'; // This should come from package info
  }

  /// Validate and parse API response
  UssdResponse _validateAndParseResponse(Response response) {
    if (response.statusCode == 200) {
      final responseBody = response.data.toString().trim();

      if (responseBody.isEmpty) {
        throw UssdApiException('Empty response body', 200, responseBody);
      }

      try {
        // Try to parse as JSON first
        if (response.data is Map) {
          return UssdResponse.fromJson(response.data);
        } else {
          final responseData = jsonDecode(responseBody);
          return UssdResponse.fromJson(responseData);
        }
      } catch (e) {
        // If JSON parsing fails, treat as text response
        if (responseBody.startsWith('CON ') ||
            responseBody.startsWith('END ')) {
          return UssdResponse.fromTextResponse(responseBody);
        } else {
          throw UssdApiException('Invalid response format', 200, responseBody);
        }
      }
    } else {
      throw UssdApiException(
        'HTTP ${response.statusCode}: ${response.statusMessage}',
        response.statusCode!,
        response.data?.toString(),
      );
    }
  }

  /// Secure logging that filters sensitive data
  void _secureLog(Object object) {
    final logString = object.toString();
    final filtered = _filterSensitiveData(logString);
    print('[SECURE_API] $filtered');
  }

  /// Filter sensitive data from log messages
  String _filterSensitiveData(String logString) {
    String filtered = logString;

    // Remove phone numbers (basic pattern)
    filtered = filtered.replaceAllMapped(
      RegExp(r'\+?\d{10,15}'),
      (match) =>
          '${match.group(0)!.substring(0, 3)}****${match.group(0)!.substring(match.group(0)!.length - 2)}',
    );

    // Remove potential passwords or tokens
    filtered = filtered.replaceAllMapped(
      RegExp(
        r'("password"|"token"|"key"|"secret")\s*:\s*"[^"]*"',
        caseSensitive: false,
      ),
      (match) => '${match.group(1)}":"[REDACTED]"',
    );

    // Remove signatures
    filtered = filtered.replaceAllMapped(
      RegExp(
        r'(signature|auth|authorization):\s*[a-fA-F0-9]{32,}',
        caseSensitive: false,
      ),
      (match) => '${match.group(1)}:[REDACTED]',
    );

    return filtered;
  }

  /// Log security events
  void _logSecurityEvent(String event, Map<String, dynamic> context) {
    final sanitizedContext = _sanitizeLogContext(context);
    print('SECURITY_EVENT: $event - ${jsonEncode(sanitizedContext)}');
  }

  /// Sanitize log context
  Map<String, dynamic> _sanitizeLogContext(Map<String, dynamic> context) {
    final sanitized = <String, dynamic>{};

    for (final entry in context.entries) {
      if (entry.key.toLowerCase().contains('phone')) {
        sanitized[entry.key] = _maskPhoneNumber(entry.value.toString());
      } else if (entry.key.toLowerCase().contains('session')) {
        sanitized[entry.key] = entry.value.toString().length > 8
            ? '${entry.value.toString().substring(0, 8)}...'
            : entry.value;
      } else {
        sanitized[entry.key] = entry.value;
      }
    }

    return sanitized;
  }

  /// Mask phone number for logging
  String _maskPhoneNumber(String phone) {
    if (phone.length <= 4) return '****';
    return '${phone.substring(0, 2)}****${phone.substring(phone.length - 2)}';
  }
}

/// Interceptor for request signing
class RequestSigningInterceptor extends Interceptor {
  final String _secretKey;

  RequestSigningInterceptor(this._secretKey);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final body = options.data?.toString() ?? '';
    final signature = _generateSignature(timestamp, body);

    options.headers['X-Timestamp'] = timestamp;
    options.headers['X-Signature'] = signature;

    super.onRequest(options, handler);
  }

  String _generateSignature(String timestamp, String body) {
    final message = '$timestamp:$body';
    final hmac = Hmac(sha256, utf8.encode(_secretKey));
    final digest = hmac.convert(utf8.encode(message));
    return digest.toString();
  }
}

/// Interceptor for security headers
class SecurityHeadersInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Add security headers
    options.headers.addAll({
      'X-Content-Type-Options': 'nosniff',
      'X-Frame-Options': 'DENY',
      'X-XSS-Protection': '1; mode=block',
      'Referrer-Policy': 'strict-origin-when-cross-origin',
    });

    super.onRequest(options, handler);
  }
}
