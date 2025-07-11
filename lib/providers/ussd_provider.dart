import 'package:flutter/foundation.dart';
import '../models/ussd_session.dart';
import '../models/ussd_request.dart';
import '../models/endpoint_config.dart';
import '../services/ussd_session_service.dart';
import '../services/ussd_api_service.dart';
import '../services/endpoint_config_service.dart';
import '../utils/ussd_utils.dart';

class UssdProvider with ChangeNotifier {
  final UssdSessionService _sessionService = UssdSessionService();
  final UssdApiService _apiService = UssdApiService();
  final EndpointConfigService _configService = EndpointConfigService();

  bool _isInitialized = false;
  bool _isLoading = false;
  String? _error;

  bool get isInitialized => _isInitialized;
  bool get isLoading => _isLoading;
  String? get error => _error;

  UssdSession? get currentSession => _sessionService.currentSession;
  List<UssdSession> get sessionHistory => _sessionService.sessionHistory;
  List<EndpointConfig> get endpointConfigs => _configService.configs;
  EndpointConfig? get activeEndpointConfig => _configService.activeConfig;

  Future<void> init() async {
    if (_isInitialized) return;
    
    _setLoading(true);
    try {
      await _sessionService.init();
      await _configService.init();
      _isInitialized = true;
      _clearError();
    } catch (e) {
      _setError('Failed to initialize: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> startSession({
    required String phoneNumber,
    required String serviceCode,
    String? networkCode,
  }) async {
    _setLoading(true);
    _clearError();
    
    try {
      await _sessionService.startSession(
        phoneNumber: phoneNumber,
        serviceCode: serviceCode,
        networkCode: networkCode,
      );
      notifyListeners();
    } catch (e) {
      _setError('Failed to start session: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> sendUssdInput(String input) async {
    if (currentSession == null) {
      _setError('No active session');
      return;
    }

    if (activeEndpointConfig == null) {
      _setError('No active endpoint configuration');
      return;
    }

    final cleanInput = UssdUtils.cleanUserInput(input);
    if (cleanInput.isEmpty) {
      _setError('Please enter a valid input');
      return;
    }

    _setLoading(true);
    _clearError();

    try {
      // Check if this is the very first request (no previous requests)
      final isInitialRequest = currentSession!.requests.isEmpty;
      
      // Add user input to path (except for initial request)
      if (!isInitialRequest) {
        await _sessionService.addUserInputToPath(cleanInput);
        notifyListeners();
      }

      // Build the text field using the updated path
      final textForRequest = isInitialRequest 
          ? '' // Empty text for initial USSD request
          : UssdUtils.buildTextInput(currentSession!.ussdPath);

      final request = UssdRequest(
        sessionId: currentSession!.id,
        phoneNumber: currentSession!.phoneNumber,
        text: textForRequest,
        serviceCode: currentSession!.serviceCode,
      );

      await _sessionService.addRequest(request);
      notifyListeners();

      final response = await _apiService.sendUssdRequest(request, activeEndpointConfig!);
      
      await _sessionService.addResponse(response);
      notifyListeners();
    } catch (e) {
      _setError('Failed to send USSD input: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> endSession() async {
    _setLoading(true);
    _clearError();
    
    try {
      await _sessionService.endSession();
      notifyListeners();
    } catch (e) {
      _setError('Failed to end session: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> clearSessionHistory() async {
    _setLoading(true);
    _clearError();
    
    try {
      await _sessionService.clearHistory();
      notifyListeners();
    } catch (e) {
      _setError('Failed to clear session history: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> addEndpointConfig(EndpointConfig config) async {
    try {
      await _configService.addConfig(config);
      notifyListeners();
    } catch (e) {
      _setError('Failed to add endpoint config: ${e.toString()}');
    }
  }

  Future<void> updateEndpointConfig(int index, EndpointConfig config) async {
    try {
      await _configService.updateConfig(index, config);
      notifyListeners();
    } catch (e) {
      _setError('Failed to update endpoint config: ${e.toString()}');
    }
  }

  Future<void> deleteEndpointConfig(int index) async {
    try {
      await _configService.deleteConfig(index);
      notifyListeners();
    } catch (e) {
      _setError('Failed to delete endpoint config: ${e.toString()}');
    }
  }

  Future<void> setActiveEndpointConfig(EndpointConfig config) async {
    try {
      await _configService.setActiveConfig(config);
      notifyListeners();
    } catch (e) {
      _setError('Failed to set active endpoint config: ${e.toString()}');
    }
  }

  Future<bool> testEndpointConfig(EndpointConfig config) async {
    _setLoading(true);
    _clearError();
    
    try {
      final result = await _apiService.testEndpoint(config);
      return result;
    } catch (e) {
      _setError('Failed to test endpoint: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }

  void clearError() {
    _clearError();
  }
}