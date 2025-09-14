import 'dart:convert';
import 'dart:collection';
import '../models/ussd_request.dart';
import '../utils/secure_ussd_utils.dart';

/// Security severity levels
enum SecuritySeverity { low, medium, high, critical }

/// Security log entry
class SecurityLog {
  final String event;
  final DateTime timestamp;
  final Map<String, dynamic> context;
  final SecuritySeverity severity;
  final String? userId;

  SecurityLog({
    required this.event,
    required this.timestamp,
    required this.context,
    required this.severity,
    this.userId,
  });

  Map<String, dynamic> toJson() => {
        'event': event,
        'timestamp': timestamp.toIso8601String(),
        'context': context,
        'severity': severity.name,
        'user_id': userId,
      };
}

/// Security monitoring service for detecting and logging security events
class SecurityMonitor {
  static final SecurityMonitor _instance = SecurityMonitor._internal();
  factory SecurityMonitor() => _instance;
  SecurityMonitor._internal();

  final Queue<SecurityLog> _securityLogs = Queue<SecurityLog>();
  final Map<String, List<DateTime>> _requestHistory = {};
  final Map<String, int> _suspiciousActivityCount = {};

  // Configuration
  static const int MAX_REQUESTS_PER_MINUTE = 10;
  static const int MAX_REQUESTS_PER_HOUR = 100;
  static const int MAX_LOG_ENTRIES = 1000;
  static const int SUSPICIOUS_ACTIVITY_THRESHOLD = 5;

  /// Log a security event
  void logSecurityEvent(
    String event,
    Map<String, dynamic> context, {
    String? userId,
    SecuritySeverity? severity,
  }) {
    final securityLog = SecurityLog(
      event: event,
      timestamp: DateTime.now(),
      context: _sanitizeContext(context),
      severity: severity ?? _determineSeverity(event),
      userId: userId,
    );

    _addToLog(securityLog);

    // Handle critical events immediately
    if (securityLog.severity == SecuritySeverity.critical) {
      _handleCriticalEvent(securityLog);
    }

    // Print to console (in production, this would go to proper logging system)
    print('SECURITY_EVENT: ${jsonEncode(securityLog.toJson())}');
  }

  /// Detect anomalous activity in USSD requests
  void detectAnomalousActivity(UssdRequest request) {
    final phoneNumber = request.phoneNumber;
    final now = DateTime.now();

    // Rate limiting checks
    if (_isRateLimitExceeded(phoneNumber, now)) {
      logSecurityEvent('rate_limit_exceeded', {
        'phone_number': phoneNumber,
        'session_id': request.sessionId,
        'service_code': request.serviceCode,
      }, severity: SecuritySeverity.high);
      
      _incrementSuspiciousActivity(phoneNumber);
      throw SecurityException('Rate limit exceeded for $phoneNumber');
    }

    // Check for suspicious input patterns
    if (SecureUssdUtils.containsSuspiciousPatterns(request.text)) {
      logSecurityEvent('suspicious_input_pattern', {
        'phone_number': phoneNumber,
        'session_id': request.sessionId,
        'input_length': request.text.length,
        'service_code': request.serviceCode,
      }, severity: SecuritySeverity.medium);
      
      _incrementSuspiciousActivity(phoneNumber);
    }

    // Check for unusual session patterns
    _detectUnusualSessionPatterns(request);

    // Record request for future analysis
    _recordRequest(phoneNumber, now);
  }

  /// Check if rate limit is exceeded
  bool _isRateLimitExceeded(String phoneNumber, DateTime now) {
    final history = _requestHistory[phoneNumber] ?? [];
    
    // Clean old entries
    history.removeWhere((time) => now.difference(time) > Duration(hours: 1));
    
    // Check minute-based rate limit
    final recentRequests = history.where(
      (time) => now.difference(time) <= Duration(minutes: 1),
    ).length;
    
    if (recentRequests >= MAX_REQUESTS_PER_MINUTE) {
      return true;
    }
    
    // Check hour-based rate limit
    if (history.length >= MAX_REQUESTS_PER_HOUR) {
      return true;
    }
    
    return false;
  }

  /// Record request for rate limiting
  void _recordRequest(String phoneNumber, DateTime timestamp) {
    _requestHistory.putIfAbsent(phoneNumber, () => []);
    _requestHistory[phoneNumber]!.add(timestamp);
    
    // Clean old entries to prevent memory leaks
    final cutoff = timestamp.subtract(Duration(hours: 1));
    _requestHistory[phoneNumber]!.removeWhere((time) => time.isBefore(cutoff));
  }

  /// Detect unusual session patterns
  void _detectUnusualSessionPatterns(UssdRequest request) {
    // Check for very long session IDs (possible attack)
    if (request.sessionId.length > 100) {
      logSecurityEvent('unusual_session_id', {
        'phone_number': request.phoneNumber,
        'session_id_length': request.sessionId.length,
      }, severity: SecuritySeverity.medium);
    }

    // Check for unusual service codes
    if (!_isCommonServiceCode(request.serviceCode)) {
      logSecurityEvent('unusual_service_code', {
        'phone_number': request.phoneNumber,
        'service_code': request.serviceCode,
        'session_id': request.sessionId,
      }, severity: SecuritySeverity.low);
    }

    // Check for very long text inputs
    if (request.text.length > 50) {
      logSecurityEvent('unusual_text_length', {
        'phone_number': request.phoneNumber,
        'text_length': request.text.length,
        'session_id': request.sessionId,
      }, severity: SecuritySeverity.medium);
    }
  }

  /// Check if service code is commonly used
  bool _isCommonServiceCode(String serviceCode) {
    final commonCodes = [
      '*123#', '*124#', '*125#', '*555#', '*777#', '*144#', '*100#',
      '*111#', '*222#', '*333#', '*444#', '*666#', '*888#', '*999#'
    ];
    return commonCodes.contains(serviceCode);
  }

  /// Increment suspicious activity counter
  void _incrementSuspiciousActivity(String phoneNumber) {
    _suspiciousActivityCount[phoneNumber] = 
        (_suspiciousActivityCount[phoneNumber] ?? 0) + 1;
    
    final count = _suspiciousActivityCount[phoneNumber]!;
    
    if (count >= SUSPICIOUS_ACTIVITY_THRESHOLD) {
      logSecurityEvent('repeated_suspicious_activity', {
        'phone_number': phoneNumber,
        'suspicious_count': count,
      }, severity: SecuritySeverity.critical);
    }
  }

  /// Determine security severity based on event type
  SecuritySeverity _determineSeverity(String event) {
    final criticalEvents = [
      'rate_limit_exceeded',
      'repeated_suspicious_activity',
      'potential_attack',
      'authentication_failure',
    ];
    
    final highEvents = [
      'suspicious_input_pattern',
      'unusual_session_pattern',
      'invalid_request_format',
    ];
    
    final mediumEvents = [
      'unusual_service_code',
      'unusual_text_length',
      'validation_error',
    ];
    
    if (criticalEvents.contains(event)) {
      return SecuritySeverity.critical;
    } else if (highEvents.contains(event)) {
      return SecuritySeverity.high;
    } else if (mediumEvents.contains(event)) {
      return SecuritySeverity.medium;
    } else {
      return SecuritySeverity.low;
    }
  }

  /// Sanitize context to remove sensitive data
  Map<String, dynamic> _sanitizeContext(Map<String, dynamic> context) {
    final sanitized = <String, dynamic>{};
    
    for (final entry in context.entries) {
      final key = entry.key.toLowerCase();
      final value = entry.value;
      
      if (key.contains('phone')) {
        sanitized[entry.key] = _maskPhoneNumber(value.toString());
      } else if (key.contains('session')) {
        sanitized[entry.key] = _truncateSessionId(value.toString());
      } else if (key.contains('password') || key.contains('secret') || key.contains('token')) {
        sanitized[entry.key] = '[REDACTED]';
      } else {
        sanitized[entry.key] = value;
      }
    }
    
    return sanitized;
  }

  /// Mask phone number for logging
  String _maskPhoneNumber(String phone) {
    if (phone.length <= 4) return '****';
    return '${phone.substring(0, 2)}****${phone.substring(phone.length - 2)}';
  }

  /// Truncate session ID for logging
  String _truncateSessionId(String sessionId) {
    if (sessionId.length <= 12) return sessionId;
    return '${sessionId.substring(0, 8)}...';
  }

  /// Add log entry to the queue
  void _addToLog(SecurityLog log) {
    _securityLogs.addLast(log);
    
    // Maintain log size limit
    while (_securityLogs.length > MAX_LOG_ENTRIES) {
      _securityLogs.removeFirst();
    }
  }

  /// Handle critical security events
  void _handleCriticalEvent(SecurityLog log) {
    print('CRITICAL_SECURITY_EVENT: ${log.event}');
    
    // In a production environment, this might:
    // - Send alerts to security team
    // - Temporarily block the user
    // - Trigger additional monitoring
    // - Log to external security system
  }

  /// Get recent security events
  List<SecurityLog> getRecentEvents({
    int limit = 50,
    SecuritySeverity? minSeverity,
    String? eventType,
  }) {
    var events = _securityLogs.toList();
    
    // Filter by severity
    if (minSeverity != null) {
      final minIndex = SecuritySeverity.values.indexOf(minSeverity);
      events = events.where((log) => 
          SecuritySeverity.values.indexOf(log.severity) >= minIndex).toList();
    }
    
    // Filter by event type
    if (eventType != null) {
      events = events.where((log) => log.event == eventType).toList();
    }
    
    // Sort by timestamp (newest first) and limit
    events.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return events.take(limit).toList();
  }

  /// Get security statistics
  Map<String, dynamic> getSecurityStats() {
    final now = DateTime.now();
    final last24Hours = now.subtract(Duration(hours: 24));
    final recentEvents = _securityLogs.where(
      (log) => log.timestamp.isAfter(last24Hours),
    ).toList();
    
    final eventCounts = <String, int>{};
    final severityCounts = <String, int>{};
    
    for (final event in recentEvents) {
      eventCounts[event.event] = (eventCounts[event.event] ?? 0) + 1;
      severityCounts[event.severity.name] = (severityCounts[event.severity.name] ?? 0) + 1;
    }
    
    return {
      'total_events_24h': recentEvents.length,
      'event_counts': eventCounts,
      'severity_counts': severityCounts,
      'suspicious_users': _suspiciousActivityCount.length,
      'rate_limited_users': _requestHistory.length,
    };
  }

  /// Clear all security data (for testing or maintenance)
  void clearAll() {
    _securityLogs.clear();
    _requestHistory.clear();
    _suspiciousActivityCount.clear();
  }

  /// Check if user is currently rate limited
  bool isUserRateLimited(String phoneNumber) {
    return _isRateLimitExceeded(phoneNumber, DateTime.now());
  }

  /// Get suspicious activity count for user
  int getSuspiciousActivityCount(String phoneNumber) {
    return _suspiciousActivityCount[phoneNumber] ?? 0;
  }
}

/// Security exception for security-related errors
class SecurityException implements Exception {
  final String message;
  final String? code;
  
  const SecurityException(this.message, {this.code});
  
  @override
  String toString() => 'SecurityException: $message';
}