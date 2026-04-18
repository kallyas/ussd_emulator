import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/ussd_request.dart';
import '../models/endpoint_config.dart';

/// A request that was made while offline and is waiting to be replayed.
class QueuedRequest {
  final String id;
  final UssdRequest request;
  final EndpointConfig config;
  final DateTime timestamp;
  int retryCount;
  String? failureReason;

  QueuedRequest({
    required this.id,
    required this.request,
    required this.config,
    required this.timestamp,
    this.retryCount = 0,
    this.failureReason,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'request': request.toJson(),
    'config': config.toJson(),
    'timestamp': timestamp.toIso8601String(),
    'retryCount': retryCount,
    'failureReason': failureReason,
  };

  factory QueuedRequest.fromJson(Map<String, dynamic> json) => QueuedRequest(
    id: json['id'] as String,
    request: UssdRequest.fromJson(json['request'] as Map<String, dynamic>),
    config: EndpointConfig.fromJson(json['config'] as Map<String, dynamic>),
    timestamp: DateTime.parse(json['timestamp'] as String),
    retryCount: (json['retryCount'] as int?) ?? 0,
    failureReason: json['failureReason'] as String?,
  );
}

/// Persists offline requests across app restarts and replays them when
/// connectivity is restored.
class OfflineQueueService extends ChangeNotifier {
  static const String _prefsKey = 'ussd_offline_queue';
  static const int _maxRetries = 3;

  SharedPreferences? _prefs;
  final List<QueuedRequest> _queue = [];

  int get length => _queue.length;
  bool get isEmpty => _queue.isEmpty;
  List<QueuedRequest> get items => List.unmodifiable(_queue);

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _loadFromPrefs();
  }

  void _loadFromPrefs() {
    final raw = _prefs?.getString(_prefsKey);
    if (raw == null) return;

    try {
      final List<dynamic> decoded = jsonDecode(raw);
      _queue.clear();
      for (final item in decoded) {
        try {
          _queue.add(QueuedRequest.fromJson(item as Map<String, dynamic>));
        } catch (_) {
          // Skip malformed entries
        }
      }
    } catch (e) {
      debugPrint('OfflineQueueService: failed to load queue: $e');
    }
  }

  Future<void> _saveToPrefs() async {
    try {
      final encoded = jsonEncode(_queue.map((r) => r.toJson()).toList());
      await _prefs?.setString(_prefsKey, encoded);
    } catch (e) {
      debugPrint('OfflineQueueService: failed to save queue: $e');
    }
  }

  /// Add a request to the queue.
  Future<void> enqueue(UssdRequest request, EndpointConfig config) async {
    final queued = QueuedRequest(
      id: '${DateTime.now().millisecondsSinceEpoch}_${request.sessionId}',
      request: request,
      config: config,
      timestamp: DateTime.now(),
    );
    _queue.add(queued);
    await _saveToPrefs();
    notifyListeners();
  }

  /// Process the queue by calling [executor] for each item.
  /// Items that succeed are removed; items that fail are retried up to
  /// [_maxRetries] times before being marked as failed and dropped.
  Future<void> processQueue(
    Future<void> Function(QueuedRequest) executor,
  ) async {
    if (_queue.isEmpty) return;

    final toProcess = List<QueuedRequest>.from(_queue);
    for (final item in toProcess) {
      try {
        await executor(item);
        _queue.remove(item);
      } catch (e) {
        item.retryCount++;
        item.failureReason = e.toString();
        if (item.retryCount >= _maxRetries) {
          debugPrint(
            'OfflineQueueService: dropping request ${item.id} after '
            '$_maxRetries retries: $e',
          );
          _queue.remove(item);
        }
      }
    }

    await _saveToPrefs();
    notifyListeners();
  }

  /// Remove a specific item from the queue.
  Future<void> remove(String id) async {
    _queue.removeWhere((r) => r.id == id);
    await _saveToPrefs();
    notifyListeners();
  }

  /// Clear the entire queue.
  Future<void> clearAll() async {
    _queue.clear();
    await _prefs?.remove(_prefsKey);
    notifyListeners();
  }
}
