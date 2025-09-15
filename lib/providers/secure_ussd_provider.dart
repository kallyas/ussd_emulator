import '../services/secure_ussd_session_service.dart';
import '../services/secure_ussd_api_service.dart';
import '../services/security_monitor.dart';
import '../models/ussd_request.dart';
import '../models/ussd_response.dart';
import '../models/ussd_session.dart';
import '../models/endpoint_config.dart';
import '../utils/secure_ussd_utils.dart';

/// Secure USSD provider that integrates all security features
class SecureUssdProvider {
  final SecureUssdSessionService _sessionService;
  final SecureUssdApiService _apiService;
  final SecurityMonitor _securityMonitor;
  
  SecureUssdProvider()
      : _sessionService = SecureUssdSessionService(),
        _apiService = SecureUssdApiService(),
        _securityMonitor = SecurityMonitor();
  
  /// Initialize all security services
  Future<void> initialize() async {
    await _sessionService.init();
    _securityMonitor.logSecurityEvent('security_services_initialized', {
      'timestamp': DateTime.now().toIso8601String(),
    });
  }
  
  /// Start a new secure USSD session
  Future<UssdSession> startSecureSession({
    required String phoneNumber,
    required String serviceCode,
    String? networkCode,
  }) async {
    try {
      // Security monitoring
      _securityMonitor.logSecurityEvent('session_start_attempt', {
        'phone_number': phoneNumber,
        'service_code': serviceCode,
      });
      
      // Validate inputs before starting session
      final validatedPhone = SecureUssdUtils.validatePhoneNumber(phoneNumber);
      final validatedCode = SecureUssdUtils.validateServiceCode(serviceCode);
      
      // Check if user is rate limited
      if (_securityMonitor.isUserRateLimited(validatedPhone)) {
        _securityMonitor.logSecurityEvent('session_start_rate_limited', {
          'phone_number': validatedPhone,
        });
        throw SecurityException('Rate limit exceeded. Please try again later.');
      }
      
      // Start session with validated data
      final session = await _sessionService.startSession(
        phoneNumber: validatedPhone,
        serviceCode: validatedCode,
        networkCode: networkCode,
      );
      
      _securityMonitor.logSecurityEvent('session_started', {
        'session_id': session.id,
        'phone_number': session.phoneNumber,
        'service_code': session.serviceCode,
      });
      
      return session;
      
    } catch (e) {
      _securityMonitor.logSecurityEvent('session_start_failed', {
        'phone_number': phoneNumber,
        'error': e.toString(),
      });
      rethrow;
    }
  }
  
  /// Send a secure USSD request
  Future<UssdResponse> sendSecureRequest(
    String userInput,
    EndpointConfig endpoint,
  ) async {
    final currentSession = _sessionService.currentSession;
    if (currentSession == null) {
      throw Exception('No active session');
    }
    
    try {
      // Validate and sanitize user input
      final sanitizedInput = userInput.isEmpty 
          ? userInput 
          : SecureUssdUtils.validateMenuSelection(userInput);
      
      // Update session path
      if (sanitizedInput.isNotEmpty) {
        await _sessionService.addUserInputToPath(sanitizedInput);
      }
      
      // Build text for API request
      final textInput = SecureUssdUtils.buildTextInput(currentSession.ussdPath);
      
      // Create secure request
      final request = UssdRequest(
        sessionId: currentSession.id,
        phoneNumber: currentSession.phoneNumber,
        text: textInput,
        serviceCode: currentSession.serviceCode,
      );
      
      // Security monitoring
      _securityMonitor.detectAnomalousActivity(request);
      
      // Add request to session
      await _sessionService.addRequest(request);
      
      // Send secure API request
      final response = await _apiService.sendUssdRequest(request, endpoint);
      
      // Add response to session
      await _sessionService.addResponse(response);
      
      _securityMonitor.logSecurityEvent('request_completed', {
        'session_id': currentSession.id,
        'phone_number': currentSession.phoneNumber,
        'response_type': response.continueSession ? 'CON' : 'END',
      });
      
      return response;
      
    } catch (e) {
      _securityMonitor.logSecurityEvent('request_failed', {
        'session_id': currentSession.id,
        'phone_number': currentSession.phoneNumber,
        'error': e.toString(),
      });
      rethrow;
    }
  }
  
  /// End current session securely
  Future<void> endSecureSession() async {
    final currentSession = _sessionService.currentSession;
    if (currentSession != null) {
      _securityMonitor.logSecurityEvent('session_ended', {
        'session_id': currentSession.id,
        'phone_number': currentSession.phoneNumber,
        'duration_minutes': DateTime.now().difference(currentSession.createdAt).inMinutes,
      });
      
      await _sessionService.endSession();
    }
  }
  
  /// Get current session
  UssdSession? get currentSession => _sessionService.currentSession;
  
  /// Get session history
  List<UssdSession> get sessionHistory => _sessionService.sessionHistory;
  
  /// Get security statistics
  Map<String, dynamic> getSecurityStats() => _securityMonitor.getSecurityStats();
  
  /// Check if user is rate limited
  bool isUserRateLimited(String phoneNumber) {
    try {
      final validatedPhone = SecureUssdUtils.validatePhoneNumber(phoneNumber);
      return _securityMonitor.isUserRateLimited(validatedPhone);
    } catch (e) {
      return true; // If validation fails, treat as rate limited for safety
    }
  }
  
  /// Get recent security events
  List<SecurityLog> getRecentSecurityEvents({
    int limit = 50,
    SecuritySeverity? minSeverity,
  }) {
    return _securityMonitor.getRecentEvents(
      limit: limit,
      minSeverity: minSeverity,
    );
  }
  
  /// Clear all security data (for testing or admin actions)
  Future<void> clearAllSecurityData() async {
    await _sessionService.clearSecureStorage();
    _securityMonitor.clearAll();
    SecureUssdUtils.clearRateLimitData();
    
    _securityMonitor.logSecurityEvent('security_data_cleared', {
      'timestamp': DateTime.now().toIso8601String(),
    });
  }
}

/// Example usage showing integration
class SecureUssdExample {
  static Future<void> demonstrateSecureUsage() async {
    final secureProvider = SecureUssdProvider();
    
    try {
      // Initialize security services
      await secureProvider.initialize();
      
      // Start secure session
      final session = await secureProvider.startSecureSession(
        phoneNumber: '+256700000000',
        serviceCode: '*123#',
      );
      
      print('Secure session started: ${session.id}');
      
      // Configure endpoint
      final endpoint = EndpointConfig(
        id: 'secure_test',
        name: 'Secure Test Endpoint',
        url: 'https://secure-api.example.com/ussd',
        headers: {'Authorization': 'Bearer secure-token'},
        isActive: true,
      );
      
      // Send secure requests
      var response = await secureProvider.sendSecureRequest('', endpoint);
      print('Initial response: ${response.message}');
      
      if (response.continueSession) {
        response = await secureProvider.sendSecureRequest('1', endpoint);
        print('Menu selection response: ${response.message}');
      }
      
      // End session
      await secureProvider.endSecureSession();
      
      // Check security stats
      final stats = secureProvider.getSecurityStats();
      print('Security statistics: $stats');
      
    } catch (e) {
      print('Secure USSD error: $e');
      
      // Get recent security events to analyze the issue
      final events = secureProvider.getRecentSecurityEvents(
        limit: 10,
        minSeverity: SecuritySeverity.medium,
      );
      
      for (final event in events) {
        print('Security event: ${event.event} - ${event.severity.name}');
      }
    }
  }
}