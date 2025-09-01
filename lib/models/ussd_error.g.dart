// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ussd_error.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UssdError _$UssdErrorFromJson(Map<String, dynamic> json) => UssdError(
  code: json['code'] as String,
  message: json['message'] as String,
  userMessage: json['userMessage'] as String,
  type: $enumDecode(_$ErrorTypeEnumMap, json['type']),
  severity: $enumDecode(_$ErrorSeverityEnumMap, json['severity']),
  isRetryable: json['isRetryable'] as bool,
  context: json['context'] as Map<String, dynamic>?,
  timestamp: DateTime.parse(json['timestamp'] as String),
  stackTrace: json['stackTrace'] as String?,
);

Map<String, dynamic> _$UssdErrorToJson(UssdError instance) => <String, dynamic>{
  'code': instance.code,
  'message': instance.message,
  'userMessage': instance.userMessage,
  'type': _$ErrorTypeEnumMap[instance.type]!,
  'severity': _$ErrorSeverityEnumMap[instance.severity]!,
  'isRetryable': instance.isRetryable,
  'context': instance.context,
  'timestamp': instance.timestamp.toIso8601String(),
  'stackTrace': instance.stackTrace,
};

const _$ErrorTypeEnumMap = {
  ErrorType.network: 'network',
  ErrorType.validation: 'validation',
  ErrorType.server: 'server',
  ErrorType.timeout: 'timeout',
  ErrorType.authentication: 'authentication',
  ErrorType.configuration: 'configuration',
  ErrorType.session: 'session',
  ErrorType.unknown: 'unknown',
};

const _$ErrorSeverityEnumMap = {
  ErrorSeverity.low: 'low',
  ErrorSeverity.medium: 'medium',
  ErrorSeverity.high: 'high',
  ErrorSeverity.critical: 'critical',
};
