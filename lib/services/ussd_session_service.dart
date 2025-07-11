import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/ussd_session.dart';
import '../models/ussd_request.dart';
import '../models/ussd_response.dart';
import '../utils/ussd_utils.dart';

class UssdSessionService {
  static const String _sessionKey = 'ussd_session';
  static const String _sessionsHistoryKey = 'ussd_sessions_history';
  
  UssdSession? _currentSession;
  List<UssdSession> _sessionHistory = [];

  UssdSession? get currentSession => _currentSession;
  List<UssdSession> get sessionHistory => _sessionHistory;

  Future<void> init() async {
    await _loadCurrentSession();
    await _loadSessionHistory();
  }

  Future<UssdSession> startSession({
    required String phoneNumber,
    required String serviceCode,
    String? networkCode,
  }) async {
    final session = UssdSession(
      id: UssdUtils.generateSessionId(),
      phoneNumber: phoneNumber,
      serviceCode: serviceCode,
      networkCode: networkCode,
      requests: [],
      responses: [],
      ussdPath: [], // Initialize empty path
      createdAt: DateTime.now(),
      isActive: true,
    );

    _currentSession = session;
    await _saveCurrentSession();
    return session;
  }

  Future<UssdSession> addRequest(UssdRequest request) async {
    if (_currentSession == null) {
      throw Exception('No active session');
    }

    final updatedSession = _currentSession!.copyWith(
      requests: [..._currentSession!.requests, request],
    );

    _currentSession = updatedSession;
    await _saveCurrentSession();
    return updatedSession;
  }

  Future<UssdSession> addResponse(UssdResponse response) async {
    if (_currentSession == null) {
      throw Exception('No active session');
    }

    final updatedSession = _currentSession!.copyWith(
      responses: [..._currentSession!.responses, response],
      isActive: response.continueSession,
      endedAt: response.continueSession ? null : DateTime.now(),
    );

    _currentSession = updatedSession;
    await _saveCurrentSession();

    if (!response.continueSession) {
      await _endSession();
    }

    return updatedSession;
  }

  Future<UssdSession> addUserInputToPath(String userInput) async {
    if (_currentSession == null) {
      throw Exception('No active session');
    }

    final cleanInput = UssdUtils.cleanUserInput(userInput);
    final updatedPath = UssdUtils.addToPath(_currentSession!.ussdPath, cleanInput);
    
    final updatedSession = _currentSession!.copyWith(
      ussdPath: updatedPath,
    );

    _currentSession = updatedSession;
    await _saveCurrentSession();
    return updatedSession;
  }

  Future<void> endSession() async {
    if (_currentSession == null) return;

    final endedSession = _currentSession!.copyWith(
      isActive: false,
      endedAt: DateTime.now(),
    );

    _currentSession = endedSession;
    await _endSession();
  }

  Future<void> _endSession() async {
    if (_currentSession == null) return;

    _sessionHistory.insert(0, _currentSession!);
    if (_sessionHistory.length > 50) {
      _sessionHistory = _sessionHistory.take(50).toList();
    }

    await _saveSessionHistory();
    _currentSession = null;
    await _clearCurrentSession();
  }

  Future<void> _saveCurrentSession() async {
    if (_currentSession == null) return;
    
    final prefs = await SharedPreferences.getInstance();
    final sessionJson = jsonEncode(_currentSession!.toJson());
    await prefs.setString(_sessionKey, sessionJson);
  }

  Future<void> _loadCurrentSession() async {
    final prefs = await SharedPreferences.getInstance();
    final sessionJson = prefs.getString(_sessionKey);
    
    if (sessionJson != null) {
      try {
        final sessionData = jsonDecode(sessionJson);
        _currentSession = UssdSession.fromJson(sessionData);
      } catch (e) {
        await _clearCurrentSession();
      }
    }
  }

  Future<void> _clearCurrentSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionKey);
  }

  Future<void> _saveSessionHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = jsonEncode(_sessionHistory.map((s) => s.toJson()).toList());
    await prefs.setString(_sessionsHistoryKey, historyJson);
  }

  Future<void> _loadSessionHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = prefs.getString(_sessionsHistoryKey);
    
    if (historyJson != null) {
      try {
        final List<dynamic> historyData = jsonDecode(historyJson);
        _sessionHistory = historyData.map((data) => UssdSession.fromJson(data)).toList();
      } catch (e) {
        _sessionHistory = [];
      }
    }
  }

  Future<void> clearHistory() async {
    _sessionHistory.clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionsHistoryKey);
  }
}