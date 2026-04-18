import 'package:flutter/foundation.dart';
import '../models/ussd_session.dart';
import '../models/ussd_request.dart';
import '../models/ussd_response.dart';
import '../models/endpoint_config.dart';
import '../services/ussd_session_service.dart';
import '../services/ussd_api_service.dart';
import '../services/endpoint_config_service.dart';
import '../services/connectivity_service.dart';
import '../services/ussd_cache_service.dart';
import '../services/offline_queue_service.dart';
import '../utils/ussd_utils.dart';

class UssdProvider with ChangeNotifier {
  final UssdSessionService _sessionService = UssdSessionService();
  final UssdApiService _apiService = UssdApiService();
  final EndpointConfigService _configService = EndpointConfigService();

  final ConnectivityService _connectivityService;
  final UssdCacheService _cacheService;
  final OfflineQueueService _queueService;

  UssdProvider({
    ConnectivityService? connectivityService,
    UssdCacheService? cacheService,
    OfflineQueueService? queueService,
  })  : _connectivityService = connectivityService ?? ConnectivityService(),
        _cacheService = cacheService ?? UssdCacheService(),
        _queueService = queueService ?? OfflineQueueService() {
    _connectivityService.addListener(_onConnectivityChanged);
  }

  bool _isInitialized = false;
  bool _isLoading = false;
  String? _error;
  bool _lastResponseFromCache = false;

  bool get isInitialized => _isInitialized;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isOffline => _connectivityService.isOffline;
  bool get lastResponseFromCache => _lastResponseFromCache;
  int get queuedRequestCount => _queueService.length;

  UssdSession? get currentSession => _sessionService.currentSession;
  List<UssdSession> get sessionHistory => _sessionService.sessionHistory;
  List<EndpointConfig> get endpointConfigs => _configService.configs;
  EndpointConfig? get activeEndpointConfig => _configService.activeConfig;

  UssdCacheService get cacheService => _cacheService;
  OfflineQueueService get queueService => _queueService;

  Future<void> init() async {
    if (_isInitialized) return;

    _setLoading(true);
    try {
      await Future.wait([
        _sessionService.init(),
        _configService.init(),
        _connectivityService.init(),
        _cacheService.init(),
        _queueService.init(),
      ]);
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
    _lastResponseFromCache = false;

    try {
      final isInitialRequest = currentSession!.requests.isEmpty;

      if (!isInitialRequest) {
        await _sessionService.addUserInputToPath(cleanInput);
        notifyListeners();
      }

      final textForRequest = isInitialRequest
          ? ''
          : UssdUtils.buildTextInput(currentSession!.ussdPath);

      final request = UssdRequest(
        sessionId: currentSession!.id,
        phoneNumber: currentSession!.phoneNumber,
        text: textForRequest,
        serviceCode: currentSession!.serviceCode,
      );

      await _sessionService.addRequest(request);
      notifyListeners();

      final response = await _sendWithOfflineFallback(request);

      await _sessionService.addResponse(response);
      notifyListeners();
    } catch (e) {
      _setError('Failed to send USSD input: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  /// Attempts a live request; falls back to cache or queues for later.
  Future<UssdResponse> _sendWithOfflineFallback(UssdRequest request) async {
    final config = activeEndpointConfig!;

    if (_connectivityService.isOffline) {
      final cached = await _cacheService.getCachedResponse(request);
      if (cached != null) {
        _lastResponseFromCache = true;
        return cached;
      }
      await _queueService.enqueue(request, config);
      return const UssdResponse(
        text: 'You are offline. This request has been queued and will be '
            'sent automatically when connectivity is restored.',
        continueSession: false,
      );
    }

    try {
      final response = await _apiService.sendUssdRequest(request, config);
      await _cacheService.cacheResponse(request, response);
      return response;
    } catch (e) {
      final cached = await _cacheService.getCachedResponse(request);
      if (cached != null) {
        _lastResponseFromCache = true;
        return cached;
      }
      await _queueService.enqueue(request, config);
      rethrow;
    }
  }

  void _onConnectivityChanged() {
    if (_connectivityService.isOnline && !_queueService.isEmpty) {
      _processQueue();
    }
    notifyListeners();
  }

  Future<void> _processQueue() async {
    await _queueService.processQueue((queued) async {
      final response = await _apiService.sendUssdRequest(
        queued.request,
        queued.config,
      );
      await _cacheService.cacheResponse(queued.request, response);
    });
    notifyListeners();
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
      rethrow;
    }
  }

  Future<void> updateEndpointConfig(int index, EndpointConfig config) async {
    try {
      await _configService.updateConfig(index, config);
      notifyListeners();
    } catch (e) {
      _setError('Failed to update endpoint config: ${e.toString()}');
      rethrow;
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
      return await _apiService.testEndpoint(config);
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

  void clearError() => _clearError();

  @override
  void dispose() {
    _connectivityService.removeListener(_onConnectivityChanged);
    super.dispose();
  }
}
