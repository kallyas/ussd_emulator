/// Analytics data models — no code generation needed, plain JSON serialization.

enum SessionEventType {
  sessionStart,
  sessionEnd,
  requestSent,
  responseReceived,
  error,
}

class SessionEvent {
  final String id;
  final SessionEventType type;
  final DateTime timestamp;
  final String sessionId;
  final String serviceCode;
  final String endpointName;
  final Map<String, dynamic> metadata;

  const SessionEvent({
    required this.id,
    required this.type,
    required this.timestamp,
    required this.sessionId,
    required this.serviceCode,
    required this.endpointName,
    this.metadata = const {},
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type.name,
    'timestamp': timestamp.toIso8601String(),
    'sessionId': sessionId,
    'serviceCode': serviceCode,
    'endpointName': endpointName,
    'metadata': metadata,
  };

  factory SessionEvent.fromJson(Map<String, dynamic> json) => SessionEvent(
    id: json['id'] as String,
    type: SessionEventType.values.firstWhere(
      (e) => e.name == json['type'],
      orElse: () => SessionEventType.error,
    ),
    timestamp: DateTime.parse(json['timestamp'] as String),
    sessionId: json['sessionId'] as String,
    serviceCode: json['serviceCode'] as String,
    endpointName: json['endpointName'] as String,
    metadata: Map<String, dynamic>.from(
      (json['metadata'] as Map?)?.cast<String, dynamic>() ?? {},
    ),
  );
}

class ResponseMetric {
  final String id;
  final String sessionId;
  final String endpointName;
  final String serviceCode;
  final int responseTimeMs;
  final bool success;
  final String? errorMessage;
  final DateTime timestamp;

  const ResponseMetric({
    required this.id,
    required this.sessionId,
    required this.endpointName,
    required this.serviceCode,
    required this.responseTimeMs,
    required this.success,
    this.errorMessage,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'sessionId': sessionId,
    'endpointName': endpointName,
    'serviceCode': serviceCode,
    'responseTimeMs': responseTimeMs,
    'success': success,
    'errorMessage': errorMessage,
    'timestamp': timestamp.toIso8601String(),
  };

  factory ResponseMetric.fromJson(Map<String, dynamic> json) => ResponseMetric(
    id: json['id'] as String,
    sessionId: json['sessionId'] as String,
    endpointName: json['endpointName'] as String,
    serviceCode: json['serviceCode'] as String,
    responseTimeMs: json['responseTimeMs'] as int,
    success: json['success'] as bool,
    errorMessage: json['errorMessage'] as String?,
    timestamp: DateTime.parse(json['timestamp'] as String),
  );
}

/// Computed summary derived from raw events and metrics.
class AnalyticsSummary {
  final int totalSessions;
  final int totalRequests;
  final int totalErrors;
  final double avgResponseTimeMs;
  final double errorRate;
  final Map<String, int> sessionsByServiceCode;
  final Map<String, double> avgResponseTimeByEndpoint;
  final Map<String, int> errorsByEndpoint;
  final Duration totalSessionDuration;

  const AnalyticsSummary({
    required this.totalSessions,
    required this.totalRequests,
    required this.totalErrors,
    required this.avgResponseTimeMs,
    required this.errorRate,
    required this.sessionsByServiceCode,
    required this.avgResponseTimeByEndpoint,
    required this.errorsByEndpoint,
    required this.totalSessionDuration,
  });

  static AnalyticsSummary empty() => const AnalyticsSummary(
    totalSessions: 0,
    totalRequests: 0,
    totalErrors: 0,
    avgResponseTimeMs: 0,
    errorRate: 0,
    sessionsByServiceCode: {},
    avgResponseTimeByEndpoint: {},
    errorsByEndpoint: {},
    totalSessionDuration: Duration.zero,
  );
}
