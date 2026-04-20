import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/ussd_request.dart';
import '../models/ussd_response.dart';

/// A single cached response entry with TTL metadata.
class CacheEntry {
  final UssdResponse response;
  final DateTime timestamp;
  final Duration ttl;
  int hitCount;

  CacheEntry({
    required this.response,
    required this.timestamp,
    required this.ttl,
    this.hitCount = 0,
  });

  bool get isExpired => DateTime.now().difference(timestamp) > ttl;

  Map<String, dynamic> toJson() => {
    'response': response.toJson(),
    'timestamp': timestamp.toIso8601String(),
    'ttlMs': ttl.inMilliseconds,
    'hitCount': hitCount,
  };

  factory CacheEntry.fromJson(Map<String, dynamic> json) => CacheEntry(
    response: UssdResponse.fromJson(json['response'] as Map<String, dynamic>),
    timestamp: DateTime.parse(json['timestamp'] as String),
    ttl: Duration(milliseconds: json['ttlMs'] as int),
    hitCount: (json['hitCount'] as int?) ?? 0,
  );
}

/// Persists USSD responses keyed by (serviceCode, text, phoneNumber).
/// Uses shared_preferences — no additional dependencies required.
class UssdCacheService extends ChangeNotifier {
  static const String _prefsKey = 'ussd_response_cache';
  static const Duration defaultTtl = Duration(hours: 24);

  SharedPreferences? _prefs;
  final Map<String, CacheEntry> _cache = {};

  int _totalRequests = 0;
  int _cacheHits = 0;

  int get entryCount => _cache.length;
  int get totalRequests => _totalRequests;
  int get cacheHits => _cacheHits;
  double get hitRate =>
      _totalRequests == 0 ? 0.0 : (_cacheHits / _totalRequests) * 100;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _loadFromPrefs();
  }

  void _loadFromPrefs() {
    final raw = _prefs?.getString(_prefsKey);
    if (raw == null) return;

    try {
      final Map<String, dynamic> decoded = jsonDecode(raw);
      _cache.clear();
      for (final entry in decoded.entries) {
        try {
          final cacheEntry = CacheEntry.fromJson(
            entry.value as Map<String, dynamic>,
          );
          if (!cacheEntry.isExpired) {
            _cache[entry.key] = cacheEntry;
          }
        } catch (_) {
          // Skip malformed entries
        }
      }
    } catch (e) {
      debugPrint('UssdCacheService: failed to load cache: $e');
    }
  }

  Future<void> _saveToPrefs() async {
    try {
      final encoded = jsonEncode(_cache.map((k, v) => MapEntry(k, v.toJson())));
      await _prefs?.setString(_prefsKey, encoded);
    } catch (e) {
      debugPrint('UssdCacheService: failed to save cache: $e');
    }
  }

  String _cacheKey(UssdRequest request) =>
      '${request.serviceCode}:${request.text}:${request.phoneNumber}';

  /// Store a response in the cache.
  Future<void> cacheResponse(
    UssdRequest request,
    UssdResponse response, {
    Duration? ttl,
  }) async {
    final key = _cacheKey(request);
    _cache[key] = CacheEntry(
      response: response,
      timestamp: DateTime.now(),
      ttl: ttl ?? defaultTtl,
    );
    await _saveToPrefs();
    notifyListeners();
  }

  /// Return a cached response if one exists and has not expired.
  /// Returns null on a miss.
  Future<UssdResponse?> getCachedResponse(UssdRequest request) async {
    _totalRequests++;
    final key = _cacheKey(request);
    final entry = _cache[key];

    if (entry == null) return null;

    if (entry.isExpired) {
      _cache.remove(key);
      await _saveToPrefs();
      notifyListeners();
      return null;
    }

    entry.hitCount++;
    _cacheHits++;
    notifyListeners();
    return entry.response;
  }

  /// Remove all expired entries and persist.
  Future<void> evictExpired() async {
    final expired = _cache.entries
        .where((e) => e.value.isExpired)
        .map((e) => e.key)
        .toList();
    for (final key in expired) {
      _cache.remove(key);
    }
    if (expired.isNotEmpty) {
      await _saveToPrefs();
      notifyListeners();
    }
  }

  /// Clear the entire cache.
  Future<void> clearAll() async {
    _cache.clear();
    _totalRequests = 0;
    _cacheHits = 0;
    await _prefs?.remove(_prefsKey);
    notifyListeners();
  }

  /// Snapshot of all current (non-expired) entries for display.
  List<MapEntry<String, CacheEntry>> get entries =>
      _cache.entries.where((e) => !e.value.isExpired).toList();
}
