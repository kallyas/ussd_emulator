import 'dart:convert';
import 'dart:math';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../models/ussd_request.dart';
import '../models/ussd_response.dart';
import '../models/endpoint_config.dart';
import '../models/ussd_error.dart';
import 'connectivity_service.dart';

class EnhancedUssdApiService {
  static const int _maxRetries = 3;
  static const int _baseDelayMs = 1000; // 1 second
  static const int _maxDelayMs = 10000; // 10 seconds
  static const int _timeoutSeconds = 30;

  final Dio _dio;
  final ConnectivityService _connectivityService;

  EnhancedUssdApiService({ConnectivityService? connectivityService})
    : _connectivityService = connectivityService ?? ConnectivityService(),
      _dio = Dio() {
    _configureDio();
  }

  void _configureDio() {
    _dio.options = BaseOptions(
      connectTimeout: Duration(seconds: _timeoutSeconds),
      receiveTimeout: Duration(seconds: _timeoutSeconds),
      sendTimeout: Duration(seconds: _timeoutSeconds),
      headers: {
        'User-Agent': 'USSD-Emulator/1.0',
        'Accept': 'application/json, text/plain',
      },
    );

    // Add interceptors for logging and error handling
    if (kDebugMode) {
      _dio.interceptors.add(
        LogInterceptor(
          requestBody: true,
          responseBody: true,
          error: true,
          logPrint: (obj) => debugPrint(obj.toString()),
        ),
      );
    }

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // Add request timestamp
          options.extra['requestStartTime'] =
              DateTime.now().millisecondsSinceEpoch;
          handler.next(options);
        },
        onResponse: (response, handler) {
          // Calculate response time
          final startTime =
              response.requestOptions.extra['requestStartTime'] as int?;
          if (startTime != null) {
            final responseTime =
                DateTime.now().millisecondsSinceEpoch - startTime;
            response.extra['responseTime'] = responseTime;
            debugPrint('Response time: ${responseTime}ms');
          }
          handler.next(response);
        },
        onError: (error, handler) {
          // Enhanced error logging
          debugPrint('API Error: ${error.message}');
          if (error.response != null) {
            debugPrint('Status: ${error.response?.statusCode}');
            debugPrint('Response: ${error.response?.data}');
          }
          handler.next(error);
        },
      ),
    );
  }

  Future<UssdResponse> sendUssdRequest(
    UssdRequest request,
    EndpointConfig config,
  ) async {
    return await _executeWithRetry(() async {
      return await _performRequest(request, config);
    });
  }

  Future<UssdResponse> _performRequest(
    UssdRequest request,
    EndpointConfig config,
  ) async {
    // Check connectivity first
    if (_connectivityService.isOffline) {
      throw UssdException(
        UssdError.network(
          message: 'No internet connection',
          context: {'connectivity': _connectivityService.connectionTypeString},
        ),
      );
    }

    try {
      final headers = {'Content-Type': 'application/json', ...config.headers};

      final requestData = request.toJson();
      final requestId = _generateRequestId();

      debugPrint('Sending USSD request: $requestId');

      final response = await _dio.post(
        config.url,
        data: requestData,
        options: Options(headers: headers, extra: {'requestId': requestId}),
      );

      return _parseResponse(response);
    } on DioException catch (e) {
      throw _handleDioException(e, config);
    } catch (e, stackTrace) {
      throw UssdException(
        UssdError.unknown(
          message: 'Unexpected error: ${e.toString()}',
          context: {'endpoint': config.url},
          stackTrace: stackTrace.toString(),
        ),
      );
    }
  }

  UssdResponse _parseResponse(Response response) {
    if (response.statusCode == 200) {
      final responseBody = response.data;

      if (responseBody is String) {
        final trimmedBody = responseBody.trim();

        // Try to parse as JSON first
        try {
          final jsonData = jsonDecode(trimmedBody);
          return UssdResponse.fromJson(jsonData);
        } catch (e) {
          // If JSON parsing fails, treat as text response with CON/END format
          return UssdResponse.fromTextResponse(trimmedBody);
        }
      } else if (responseBody is Map<String, dynamic>) {
        return UssdResponse.fromJson(responseBody);
      } else {
        throw UssdException(
          UssdError.server(
            message: 'Invalid response format',
            statusCode: response.statusCode ?? 200,
            userMessage: 'Server returned an invalid response format',
          ),
        );
      }
    } else {
      throw UssdException(
        UssdError.server(
          message: 'HTTP ${response.statusCode}: ${response.statusMessage}',
          statusCode: response.statusCode ?? 500,
          responseBody: response.data?.toString(),
        ),
      );
    }
  }

  UssdException _handleDioException(DioException e, EndpointConfig config) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return UssdException(
          UssdError.timeout(
            message: 'Request timeout: ${e.message}',
            context: {
              'endpoint': config.url,
              'timeoutType': e.type.toString(),
              'connectionQuality':
                  _connectivityService.connectionQuality.displayName,
            },
          ),
        );

      case DioExceptionType.connectionError:
        return UssdException(
          UssdError.network(
            message: 'Connection error: ${e.message}',
            context: {
              'endpoint': config.url,
              'connectivity': _connectivityService.connectionTypeString,
              'isOnline': _connectivityService.isOnline,
            },
          ),
        );

      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode ?? 500;
        return UssdException(
          UssdError.server(
            message: 'Server error: ${e.message}',
            statusCode: statusCode,
            responseBody: e.response?.data?.toString(),
            context: {'endpoint': config.url},
          ),
        );

      case DioExceptionType.cancel:
        return UssdException(
          UssdError.unknown(
            message: 'Request was cancelled',
            userMessage: 'Request was cancelled. Please try again.',
            context: {'endpoint': config.url},
          ),
        );

      case DioExceptionType.badCertificate:
        return UssdException(
          UssdError.network(
            message: 'SSL certificate error: ${e.message}',
            userMessage:
                'SSL certificate verification failed. Please check the server configuration.',
            context: {'endpoint': config.url},
          ),
        );

      case DioExceptionType.unknown:
      default:
        return UssdException(
          UssdError.unknown(
            message: 'Unknown error: ${e.message}',
            context: {'endpoint': config.url},
          ),
        );
    }
  }

  Future<T> _executeWithRetry<T>(Future<T> Function() operation) async {
    int attempt = 0;
    UssdException? lastException;

    while (attempt < _maxRetries) {
      try {
        return await operation();
      } on UssdException catch (e) {
        lastException = e;
        attempt++;

        // Don't retry for non-retryable errors
        if (!e.error.isRetryable || attempt >= _maxRetries) {
          rethrow;
        }

        // Calculate delay with exponential backoff and jitter
        final delay = _calculateRetryDelay(attempt);
        debugPrint(
          'Request failed (attempt $attempt/$_maxRetries), retrying in ${delay.inMilliseconds}ms',
        );
        debugPrint('Error: ${e.error.message}');

        await Future.delayed(delay);
      }
    }

    throw lastException!;
  }

  Duration _calculateRetryDelay(int attempt) {
    // Exponential backoff: baseDelay * (2 ^ attempt)
    final exponentialDelay = _baseDelayMs * pow(2, attempt - 1);

    // Add jitter to prevent thundering herd
    final jitter = Random().nextInt(_baseDelayMs ~/ 2);

    // Cap at maximum delay
    final totalDelayMs = min(exponentialDelay + jitter, _maxDelayMs);

    return Duration(milliseconds: totalDelayMs.toInt());
  }

  Future<bool> testEndpoint(EndpointConfig config) async {
    try {
      final testRequest = UssdRequest(
        sessionId: 'test-${_generateRequestId()}',
        phoneNumber: '+1234567890',
        text: '',
        serviceCode: '*123#',
      );

      await sendUssdRequest(testRequest, config);
      return true;
    } catch (e) {
      debugPrint('Endpoint test failed: $e');
      return false;
    }
  }

  /// Test endpoint connectivity without sending a full USSD request
  Future<EndpointTestResult> testEndpointConnectivity(
    EndpointConfig config,
  ) async {
    final startTime = DateTime.now();

    try {
      final response = await _dio.get(
        config.url,
        options: Options(
          headers: config.headers,
          validateStatus: (status) => true, // Don't throw for any status
        ),
      );

      final responseTime = DateTime.now().difference(startTime);

      return EndpointTestResult(
        isReachable: true,
        responseTime: responseTime,
        statusCode: response.statusCode,
        error: null,
      );
    } on DioException catch (e) {
      final responseTime = DateTime.now().difference(startTime);

      return EndpointTestResult(
        isReachable: false,
        responseTime: responseTime,
        statusCode: e.response?.statusCode,
        error: _handleDioException(e, config).error,
      );
    }
  }

  String _generateRequestId() {
    return '${DateTime.now().millisecondsSinceEpoch}-${Random().nextInt(9999)}';
  }

  void dispose() {
    _dio.close();
  }
}

class EndpointTestResult {
  final bool isReachable;
  final Duration responseTime;
  final int? statusCode;
  final UssdError? error;

  const EndpointTestResult({
    required this.isReachable,
    required this.responseTime,
    this.statusCode,
    this.error,
  });

  bool get isHealthy =>
      isReachable && (statusCode == null || statusCode! < 400);

  String get statusDescription {
    if (error != null) {
      return error!.userMessage;
    }

    if (statusCode != null) {
      if (statusCode! >= 200 && statusCode! < 300) {
        return 'Healthy';
      } else if (statusCode! >= 400 && statusCode! < 500) {
        return 'Client Error';
      } else if (statusCode! >= 500) {
        return 'Server Error';
      }
    }

    return isReachable ? 'Reachable' : 'Unreachable';
  }
}
