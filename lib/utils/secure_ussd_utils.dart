import '../models/validation_exception.dart';
import 'ussd_utils.dart';

/// Secure USSD utilities with enhanced input validation and sanitization
class SecureUssdUtils extends UssdUtils {
  // Security constants
  static const int MAX_INPUT_LENGTH = 160;
  static const int MAX_PHONE_LENGTH = 15;
  static const int MAX_USSD_CODE_LENGTH = 20;
  static const int MAX_SESSION_ID_LENGTH = 100;
  
  // Enhanced validation patterns
  static final RegExp USSD_PATTERN = RegExp(r'^[*#0-9]+$');
  static final RegExp PHONE_PATTERN = RegExp(r'^\+?[1-9]\d{1,14}$');
  static final RegExp MENU_SELECTION_PATTERN = RegExp(r'^[\d*#]+$');
  static final RegExp SESSION_ID_PATTERN = RegExp(r'^[a-zA-Z0-9_-]+$');
  
  // Dangerous characters that should be removed/escaped
  static final RegExp DANGEROUS_CHARS = RegExp(r'[<>"\&\'\x00-\x08\x0B\x0C\x0E-\x1F\x7F-\x9F]');
  
  /// Sanitize and validate USSD input with enhanced security
  static String sanitizeUssdInput(String input) {
    if (input.isEmpty) {
      throw const ValidationException('USSD input cannot be empty');
    }
    
    // Remove potentially malicious characters
    final sanitized = input.replaceAll(DANGEROUS_CHARS, '');
    
    // Enforce length limits
    if (sanitized.length > MAX_INPUT_LENGTH) {
      throw ValidationException(
        'Input too long: ${sanitized.length} > $MAX_INPUT_LENGTH',
        field: 'ussd_input',
        value: sanitized.length,
      );
    }
    
    // Validate USSD format for initial codes
    if (sanitized.startsWith('*') && !USSD_PATTERN.hasMatch(sanitized)) {
      throw ValidationException(
        'Invalid USSD format: must contain only digits, *, and #',
        field: 'ussd_input',
        value: sanitized,
      );
    }
    
    return sanitized;
  }
  
  /// Enhanced phone number validation with international format support
  static String validatePhoneNumber(String phone) {
    if (phone.isEmpty) {
      throw const ValidationException('Phone number cannot be empty');
    }
    
    // Remove whitespace and common separators
    final cleaned = phone.replaceAll(RegExp(r'[\s\-\(\)\.]+'), '');
    
    // Check length
    if (cleaned.length > MAX_PHONE_LENGTH) {
      throw ValidationException(
        'Phone number too long: ${cleaned.length} > $MAX_PHONE_LENGTH',
        field: 'phone_number',
        value: cleaned,
      );
    }
    
    // Validate format
    if (!PHONE_PATTERN.hasMatch(cleaned)) {
      throw ValidationException(
        'Invalid phone number format',
        field: 'phone_number',
        value: cleaned,
      );
    }
    
    return cleaned;
  }
  
  /// Validate menu selection input with enhanced security
  static String validateMenuSelection(String input) {
    if (input.isEmpty) {
      throw const ValidationException('Menu selection cannot be empty');
    }
    
    // Remove dangerous characters
    final sanitized = input.replaceAll(DANGEROUS_CHARS, '');
    
    // Check length
    if (sanitized.length > 10) { // Reasonable limit for menu selections
      throw ValidationException(
        'Menu selection too long: ${sanitized.length} > 10',
        field: 'menu_selection',
        value: sanitized,
      );
    }
    
    // Validate format
    if (!MENU_SELECTION_PATTERN.hasMatch(sanitized)) {
      throw ValidationException(
        'Invalid menu selection: must contain only digits, *, and #',
        field: 'menu_selection',
        value: sanitized,
      );
    }
    
    return sanitized;
  }
  
  /// Validate and sanitize service code
  static String validateServiceCode(String serviceCode) {
    if (serviceCode.isEmpty) {
      throw const ValidationException('Service code cannot be empty');
    }
    
    // Remove dangerous characters
    final sanitized = serviceCode.replaceAll(DANGEROUS_CHARS, '');
    
    // Check length
    if (sanitized.length > MAX_USSD_CODE_LENGTH) {
      throw ValidationException(
        'Service code too long: ${sanitized.length} > $MAX_USSD_CODE_LENGTH',
        field: 'service_code',
        value: sanitized,
      );
    }
    
    // Validate format
    if (!USSD_PATTERN.hasMatch(sanitized)) {
      throw ValidationException(
        'Invalid service code format',
        field: 'service_code',
        value: sanitized,
      );
    }
    
    return sanitized;
  }
  
  /// Validate session ID format
  static String validateSessionId(String sessionId) {
    if (sessionId.isEmpty) {
      throw const ValidationException('Session ID cannot be empty');
    }
    
    // Check length
    if (sessionId.length > MAX_SESSION_ID_LENGTH) {
      throw ValidationException(
        'Session ID too long: ${sessionId.length} > $MAX_SESSION_ID_LENGTH',
        field: 'session_id',
        value: sessionId,
      );
    }
    
    // Validate format (alphanumeric, underscore, hyphen only)
    if (!SESSION_ID_PATTERN.hasMatch(sessionId)) {
      throw ValidationException(
        'Invalid session ID format: must contain only alphanumeric characters, underscore, and hyphen',
        field: 'session_id',
        value: sessionId,
      );
    }
    
    return sessionId;
  }
  
  /// Enhanced user input cleaning with security considerations
  static String secureCleanUserInput(String input) {
    if (input.isEmpty) return input;
    
    // Remove dangerous characters first
    String cleaned = input.replaceAll(DANGEROUS_CHARS, '');
    
    // Then apply standard cleaning
    cleaned = cleaned.trim().replaceAll(RegExp(r'\s+'), '');
    
    return cleaned;
  }
  
  /// Check for potentially malicious patterns in input
  static bool containsSuspiciousPatterns(String input) {
    final suspiciousPatterns = [
      RegExp(r'(script|javascript|vbscript)', caseSensitive: false),
      RegExp(r'(\<|\>|&lt;|&gt;)'),
      RegExp(r'(union|select|insert|update|delete|drop)', caseSensitive: false),
      RegExp(r'(\|\||&&|;|\$\(|\`)', caseSensitive: false),
      RegExp(r'(\%3C|\%3E|\%22|\%27)'), // URL encoded chars
    ];
    
    return suspiciousPatterns.any((pattern) => pattern.hasMatch(input));
  }
  
  /// Rate limiting check - returns true if rate limit exceeded
  static bool checkRateLimit(String identifier, {int maxRequests = 10, Duration window = const Duration(minutes: 1)}) {
    // This is a simple in-memory implementation
    // In production, this should use persistent storage
    final now = DateTime.now();
    _rateLimitData.removeWhere((key, data) => 
        now.difference(data['timestamp'] as DateTime) > window);
    
    final currentCount = _rateLimitData[identifier]?['count'] as int? ?? 0;
    
    if (currentCount >= maxRequests) {
      return true; // Rate limit exceeded
    }
    
    _rateLimitData[identifier] = {
      'count': currentCount + 1,
      'timestamp': now,
    };
    
    return false; // Within rate limit
  }
  
  // Simple in-memory rate limiting storage
  static final Map<String, Map<String, dynamic>> _rateLimitData = {};
  
  /// Clear rate limit data (for testing or maintenance)
  static void clearRateLimitData() {
    _rateLimitData.clear();
  }
}