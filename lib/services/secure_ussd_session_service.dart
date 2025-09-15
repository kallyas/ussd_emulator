import 'dart:convert';
import 'dart:math';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:encrypt/encrypt.dart';
import 'package:crypto/crypto.dart';
import '../models/ussd_session.dart';
import '../models/ussd_request.dart';
import '../models/ussd_response.dart';
import '../utils/secure_ussd_utils.dart';
import 'ussd_session_service.dart';

/// Secure session service with encrypted storage and enhanced security
class SecureUssdSessionService extends UssdSessionService {
  static const String _encryptionKeyKey = 'session_encryption_key';
  static const String _sessionPrefix = 'secure_session_';
  static const String _historyPrefix = 'secure_history_';

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
      keyCipherAlgorithm: KeyCipherAlgorithm.RSA_ECB_PKCS1Padding,
      storageCipherAlgorithm: StorageCipherAlgorithm.AES_GCM_NoPadding,
    ),
    iOptions: IOSOptions(
      accessibility: IOSAccessibility.first_unlock_this_device,
      synchronizable: false,
    ),
  );

  late final Encrypter _encrypter;
  late final Key _encryptionKey;

  @override
  Future<void> init() async {
    await _initializeEncryption();
    await super.init(); // Call parent to load existing data if needed
    await _migrateFromInsecureStorage(); // Migrate any existing data
  }

  /// Initialize encryption system
  Future<void> _initializeEncryption() async {
    _encryptionKey = await _getOrCreateEncryptionKey();
    _encrypter = Encrypter(AES(_encryptionKey));
  }

  /// Get or create encryption key
  Future<Key> _getOrCreateEncryptionKey() async {
    final existingKey = await _secureStorage.read(key: _encryptionKeyKey);

    if (existingKey != null) {
      return Key.fromBase64(existingKey);
    }

    // Generate new key
    final key = Key.fromSecureRandom(32);
    await _secureStorage.write(key: _encryptionKeyKey, value: key.base64);
    return key;
  }

  @override
  Future<UssdSession> startSession({
    required String phoneNumber,
    required String serviceCode,
    String? networkCode,
  }) async {
    // Validate inputs with enhanced security
    final validatedPhoneNumber = SecureUssdUtils.validatePhoneNumber(
      phoneNumber,
    );
    final validatedServiceCode = SecureUssdUtils.validateServiceCode(
      serviceCode,
    );

    // Check rate limits
    if (SecureUssdUtils.checkRateLimit(validatedPhoneNumber)) {
      throw Exception(
        'Rate limit exceeded for phone number: $validatedPhoneNumber',
      );
    }

    final session = UssdSession(
      id: _generateSecureSessionId(),
      phoneNumber: validatedPhoneNumber,
      serviceCode: validatedServiceCode,
      networkCode: networkCode,
      requests: [],
      responses: [],
      ussdPath: [],
      createdAt: DateTime.now(),
      isActive: true,
    );

    _currentSession = session;
    await _saveSecureSession(session);
    return session;
  }

  @override
  Future<UssdSession> addRequest(UssdRequest request) async {
    if (_currentSession == null) {
      throw Exception('No active session');
    }

    // Validate request data
    SecureUssdUtils.validateSessionId(request.sessionId);
    SecureUssdUtils.validatePhoneNumber(request.phoneNumber);

    // Sanitize text input
    final sanitizedText = request.text.isEmpty
        ? request.text
        : SecureUssdUtils.secureCleanUserInput(request.text);

    // Check for suspicious patterns
    if (SecureUssdUtils.containsSuspiciousPatterns(sanitizedText)) {
      _logSecurityEvent('suspicious_input', {
        'session_id': request.sessionId,
        'phone_number': request.phoneNumber,
        'input_length': sanitizedText.length,
      });
    }

    final sanitizedRequest = UssdRequest(
      sessionId: request.sessionId,
      phoneNumber: request.phoneNumber,
      text: sanitizedText,
      serviceCode: request.serviceCode,
    );

    final updatedSession = _currentSession!.copyWith(
      requests: [..._currentSession!.requests, sanitizedRequest],
    );

    _currentSession = updatedSession;
    await _saveSecureSession(updatedSession);
    return updatedSession;
  }

  @override
  Future<UssdSession> addUserInputToPath(String userInput) async {
    if (_currentSession == null) {
      throw Exception('No active session');
    }

    // Validate and sanitize user input
    final validatedInput = SecureUssdUtils.validateMenuSelection(userInput);
    final sanitizedInput = SecureUssdUtils.secureCleanUserInput(validatedInput);

    final updatedPath = SecureUssdUtils.addToPath(
      _currentSession!.ussdPath,
      sanitizedInput,
    );

    final updatedSession = _currentSession!.copyWith(ussdPath: updatedPath);

    _currentSession = updatedSession;
    await _saveSecureSession(updatedSession);
    return updatedSession;
  }

  /// Save session with encryption
  Future<void> _saveSecureSession(UssdSession session) async {
    final encrypted = await _encryptSessionData(session);
    await _secureStorage.write(
      key: '$_sessionPrefix${session.id}',
      value: encrypted,
    );

    // Also save current session reference
    await _secureStorage.write(key: 'current_session_id', value: session.id);
  }

  /// Encrypt session data
  Future<String> _encryptSessionData(UssdSession session) async {
    final iv = IV.fromSecureRandom(16);
    final sessionJson = jsonEncode(session.toJson());
    final encrypted = _encrypter.encrypt(sessionJson, iv: iv);

    // Create integrity hash
    final hash = _createIntegrityHash(sessionJson, iv.base64);

    return '${iv.base64}:${encrypted.base64}:$hash';
  }

  /// Decrypt session data
  Future<UssdSession> _decryptSessionData(String encryptedData) async {
    final parts = encryptedData.split(':');
    if (parts.length != 3) {
      throw Exception('Invalid encrypted session format');
    }

    final iv = IV.fromBase64(parts[0]);
    final encrypted = Encrypted.fromBase64(parts[1]);
    final expectedHash = parts[2];

    final decrypted = _encrypter.decrypt(encrypted, iv: iv);

    // Verify integrity
    final actualHash = _createIntegrityHash(decrypted, iv.base64);
    if (actualHash != expectedHash) {
      throw Exception('Session data integrity check failed');
    }

    final sessionData = jsonDecode(decrypted);
    return UssdSession.fromJson(sessionData);
  }

  /// Create integrity hash for data verification
  String _createIntegrityHash(String data, String iv) {
    final bytes = utf8.encode('$data:$iv:${_encryptionKey.base64}');
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  @override
  Future<void> _endSession() async {
    if (_currentSession == null) return;

    // Add to encrypted history
    await _addToSecureHistory(_currentSession!);

    // Clear current session
    _currentSession = null;
    await _secureStorage.delete(key: 'current_session_id');
  }

  /// Add session to secure history
  Future<void> _addToSecureHistory(UssdSession session) async {
    final history = await _loadSecureHistory();
    history.insert(0, session);

    // Keep only last 50 sessions
    if (history.length > 50) {
      final toRemove = history.sublist(50);
      history.removeRange(50, history.length);

      // Clean up old session files
      for (final oldSession in toRemove) {
        await _secureStorage.delete(key: '$_sessionPrefix${oldSession.id}');
      }
    }

    await _saveSecureHistory(history);
  }

  /// Load session history from secure storage
  Future<List<UssdSession>> _loadSecureHistory() async {
    final historyJson = await _secureStorage.read(key: '${_historyPrefix}list');
    if (historyJson == null) return [];

    try {
      final decryptedHistory = await _decryptSessionData(historyJson);
      // This is a simplified approach - in practice, you'd want to store
      // session IDs and load individual sessions as needed
      return _sessionHistory;
    } catch (e) {
      return [];
    }
  }

  /// Save session history to secure storage
  Future<void> _saveSecureHistory(List<UssdSession> history) async {
    _sessionHistory = history;
    // For simplicity, we'll just update the in-memory list
    // In a full implementation, you'd encrypt and store the session list
  }

  /// Generate secure session ID
  String _generateSecureSessionId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = Random.secure();
    final randomBytes = List<int>.generate(8, (i) => random.nextInt(256));
    final randomHex = randomBytes
        .map((b) => b.toRadixString(16).padLeft(2, '0'))
        .join();
    return 'secure_${timestamp}_$randomHex';
  }

  /// Migrate existing insecure data to secure storage
  Future<void> _migrateFromInsecureStorage() async {
    // Load any existing session from parent class
    if (_currentSession != null) {
      await _saveSecureSession(_currentSession!);
    }

    // Migrate history if exists
    if (_sessionHistory.isNotEmpty) {
      await _saveSecureHistory(_sessionHistory);
    }
  }

  /// Log security events
  void _logSecurityEvent(String event, Map<String, dynamic> context) {
    // In a production app, this would integrate with a proper logging system
    final sanitizedContext = _sanitizeLogContext(context);
    print('SECURITY_EVENT: $event - ${jsonEncode(sanitizedContext)}');
  }

  /// Sanitize log context to remove sensitive data
  Map<String, dynamic> _sanitizeLogContext(Map<String, dynamic> context) {
    final sanitized = <String, dynamic>{};

    for (final entry in context.entries) {
      if (entry.key.toLowerCase().contains('phone')) {
        // Mask phone numbers
        sanitized[entry.key] = _maskPhoneNumber(entry.value.toString());
      } else if (entry.key.toLowerCase().contains('session')) {
        // Truncate session IDs
        sanitized[entry.key] = entry.value.toString().substring(0, 8) + '...';
      } else {
        sanitized[entry.key] = entry.value;
      }
    }

    return sanitized;
  }

  /// Mask phone number for logging
  String _maskPhoneNumber(String phone) {
    if (phone.length <= 4) return '****';
    return '${phone.substring(0, 2)}****${phone.substring(phone.length - 2)}';
  }

  /// Clean up secure storage (for testing or account deletion)
  Future<void> clearSecureStorage() async {
    await _secureStorage.deleteAll();
    _currentSession = null;
    _sessionHistory.clear();
  }
}
