import 'package:json_annotation/json_annotation.dart';

part 'ussd_error.g.dart';

enum ErrorType {
  network,
  validation,
  server,
  timeout,
  authentication,
  configuration,
  session,
  unknown,
}

enum ErrorSeverity {
  low,
  medium,
  high,
  critical,
}

@JsonSerializable()
class UssdError {
  final String code;
  final String message;
  final String userMessage;
  final ErrorType type;
  final ErrorSeverity severity;
  final bool isRetryable;
  final Map<String, dynamic>? context;
  final DateTime timestamp;
  final String? stackTrace;

  const UssdError({
    required this.code,
    required this.message,
    required this.userMessage,
    required this.type,
    required this.severity,
    required this.isRetryable,
    this.context,
    required this.timestamp,
    this.stackTrace,
  });

  factory UssdError.fromJson(Map<String, dynamic> json) =>
      _$UssdErrorFromJson(json);

  Map<String, dynamic> toJson() => _$UssdErrorToJson(this);

  // Factory constructors for common error types
  factory UssdError.network({
    required String message,
    String? userMessage,
    Map<String, dynamic>? context,
    String? stackTrace,
  }) {
    return UssdError(
      code: 'NETWORK_ERROR',
      message: message,
      userMessage: userMessage ?? 'Network connection failed. Please check your internet connection and try again.',
      type: ErrorType.network,
      severity: ErrorSeverity.high,
      isRetryable: true,
      context: context,
      timestamp: DateTime.now(),
      stackTrace: stackTrace,
    );
  }

  factory UssdError.timeout({
    required String message,
    String? userMessage,
    Map<String, dynamic>? context,
    String? stackTrace,
  }) {
    return UssdError(
      code: 'TIMEOUT_ERROR',
      message: message,
      userMessage: userMessage ?? 'Request timed out. Please try again.',
      type: ErrorType.timeout,
      severity: ErrorSeverity.medium,
      isRetryable: true,
      context: context,
      timestamp: DateTime.now(),
      stackTrace: stackTrace,
    );
  }

  factory UssdError.server({
    required String message,
    required int statusCode,
    String? userMessage,
    String? responseBody,
    Map<String, dynamic>? context,
    String? stackTrace,
  }) {
    final Map<String, dynamic> errorContext = {
      'statusCode': statusCode,
      if (responseBody != null) 'responseBody': responseBody,
      ...?context,
    };

    return UssdError(
      code: 'SERVER_ERROR_$statusCode',
      message: message,
      userMessage: userMessage ?? _getServerErrorMessage(statusCode),
      type: ErrorType.server,
      severity: statusCode >= 500 ? ErrorSeverity.high : ErrorSeverity.medium,
      isRetryable: statusCode >= 500 || statusCode == 429, // Retry for 5xx and rate limiting
      context: errorContext,
      timestamp: DateTime.now(),
      stackTrace: stackTrace,
    );
  }

  factory UssdError.validation({
    required String message,
    String? userMessage,
    Map<String, dynamic>? context,
    String? stackTrace,
  }) {
    return UssdError(
      code: 'VALIDATION_ERROR',
      message: message,
      userMessage: userMessage ?? 'Invalid input. Please check your data and try again.',
      type: ErrorType.validation,
      severity: ErrorSeverity.low,
      isRetryable: false,
      context: context,
      timestamp: DateTime.now(),
      stackTrace: stackTrace,
    );
  }

  factory UssdError.session({
    required String message,
    String? userMessage,
    Map<String, dynamic>? context,
    String? stackTrace,
  }) {
    return UssdError(
      code: 'SESSION_ERROR',
      message: message,
      userMessage: userMessage ?? 'Session error occurred. Please restart your session.',
      type: ErrorType.session,
      severity: ErrorSeverity.medium,
      isRetryable: false,
      context: context,
      timestamp: DateTime.now(),
      stackTrace: stackTrace,
    );
  }

  factory UssdError.configuration({
    required String message,
    String? userMessage,
    Map<String, dynamic>? context,
    String? stackTrace,
  }) {
    return UssdError(
      code: 'CONFIGURATION_ERROR',
      message: message,
      userMessage: userMessage ?? 'Configuration error. Please check your endpoint settings.',
      type: ErrorType.configuration,
      severity: ErrorSeverity.medium,
      isRetryable: false,
      context: context,
      timestamp: DateTime.now(),
      stackTrace: stackTrace,
    );
  }

  factory UssdError.unknown({
    required String message,
    String? userMessage,
    Map<String, dynamic>? context,
    String? stackTrace,
  }) {
    return UssdError(
      code: 'UNKNOWN_ERROR',
      message: message,
      userMessage: userMessage ?? 'An unexpected error occurred. Please try again.',
      type: ErrorType.unknown,
      severity: ErrorSeverity.medium,
      isRetryable: true,
      context: context,
      timestamp: DateTime.now(),
      stackTrace: stackTrace,
    );
  }

  static String _getServerErrorMessage(int statusCode) {
    switch (statusCode) {
      case 400:
        return 'Bad request. Please check your input.';
      case 401:
        return 'Authentication required. Please check your credentials.';
      case 403:
        return 'Access denied. You don\'t have permission to perform this action.';
      case 404:
        return 'Service not found. Please check your endpoint configuration.';
      case 429:
        return 'Too many requests. Please wait a moment before trying again.';
      case 500:
        return 'Server error. Please try again later.';
      case 502:
        return 'Bad gateway. The service is temporarily unavailable.';
      case 503:
        return 'Service unavailable. Please try again later.';
      case 504:
        return 'Gateway timeout. The service took too long to respond.';
      default:
        return 'Server returned an error (HTTP $statusCode). Please try again.';
    }
  }

  @override
  String toString() {
    return 'UssdError(code: $code, message: $message, type: $type, severity: $severity)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UssdError &&
        other.code == code &&
        other.message == message &&
        other.type == type &&
        other.severity == severity;
  }

  @override
  int get hashCode {
    return code.hashCode ^ message.hashCode ^ type.hashCode ^ severity.hashCode;
  }
}

class UssdException implements Exception {
  final UssdError error;

  const UssdException(this.error);

  @override
  String toString() => error.toString();
}