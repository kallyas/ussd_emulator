import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/analytics_models.dart';

/// Records session events and response metrics locally.
/// All data is stored in shared_preferences — no PII is collected.
/// Phone numbers and session IDs are the only identifiers; they are
/// stored only on-device and never transmitted.
class AnalyticsService extends ChangeNotifier {
  static const String _eventsKey = 'analytics_events';
  static const String _metricsKey = 'analytics_metrics';
  static const int _maxEvents = 500;
  static const int _maxMetrics = 500;

  static const _uuid = Uuid();

  SharedPreferences? _prefs;
  final List<SessionEvent> _events = [];
  final List<ResponseMetric> _metrics = [];

  // In-flight timers: requestId → start time
  final Map<String, DateTime> _timers = {};

  bool _enabled = true;
  bool get enabled => _enabled;

  List<SessionEvent> get events => List.unmodifiable(_events);
  List<ResponseMetric> get metrics => List.unmodifiable(_metrics);

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _loadEvents();
    _loadMetrics();
  }

  // ── Persistence ──────────────────────────────────────────────────────────

  void _loadEvents() {
    final raw = _prefs?.getString(_eventsKey);
    if (raw == null) return;
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      _events.clear();
      for (final item in list) {
        try {
          _events.add(SessionEvent.fromJson(item as Map<String, dynamic>));
        } catch (_) {}
      }
    } catch (e) {
      debugPrint('AnalyticsService: failed to load events: $e');
    }
  }

  void _loadMetrics() {
    final raw = _prefs?.getString(_metricsKey);
    if (raw == null) return;
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      _metrics.clear();
      for (final item in list) {
        try {
          _metrics.add(ResponseMetric.fromJson(item as Map<String, dynamic>));
        } catch (_) {}
      }
    } catch (e) {
      debugPrint('AnalyticsService: failed to load metrics: $e');
    }
  }

  Future<void> _saveEvents() async {
    try {
      await _prefs?.setString(
        _eventsKey,
        jsonEncode(_events.map((e) => e.toJson()).toList()),
      );
    } catch (e) {
      debugPrint('AnalyticsService: failed to save events: $e');
    }
  }

  Future<void> _saveMetrics() async {
    try {
      await _prefs?.setString(
        _metricsKey,
        jsonEncode(_metrics.map((m) => m.toJson()).toList()),
      );
    } catch (e) {
      debugPrint('AnalyticsService: failed to save metrics: $e');
    }
  }

  // ── Event tracking ────────────────────────────────────────────────────────

  Future<void> trackSessionStart({
    required String sessionId,
    required String serviceCode,
    required String endpointName,
  }) async {
    if (!_enabled) return;
    await _addEvent(
      SessionEvent(
        id: _uuid.v4(),
        type: SessionEventType.sessionStart,
        timestamp: DateTime.now(),
        sessionId: sessionId,
        serviceCode: serviceCode,
        endpointName: endpointName,
      ),
    );
  }

  Future<void> trackSessionEnd({
    required String sessionId,
    required String serviceCode,
    required String endpointName,
    required int messageCount,
  }) async {
    if (!_enabled) return;
    await _addEvent(
      SessionEvent(
        id: _uuid.v4(),
        type: SessionEventType.sessionEnd,
        timestamp: DateTime.now(),
        sessionId: sessionId,
        serviceCode: serviceCode,
        endpointName: endpointName,
        metadata: {'messageCount': messageCount},
      ),
    );
  }

  Future<void> trackError({
    required String sessionId,
    required String serviceCode,
    required String endpointName,
    required String error,
  }) async {
    if (!_enabled) return;
    await _addEvent(
      SessionEvent(
        id: _uuid.v4(),
        type: SessionEventType.error,
        timestamp: DateTime.now(),
        sessionId: sessionId,
        serviceCode: serviceCode,
        endpointName: endpointName,
        metadata: {'error': error},
      ),
    );
  }

  Future<void> _addEvent(SessionEvent event) async {
    _events.add(event);
    if (_events.length > _maxEvents) {
      _events.removeRange(0, _events.length - _maxEvents);
    }
    await _saveEvents();
    notifyListeners();
  }

  // ── Response time tracking ────────────────────────────────────────────────

  /// Call before sending a request; returns a timer ID to pass to [endTimer].
  String startTimer() {
    final id = _uuid.v4();
    _timers[id] = DateTime.now();
    return id;
  }

  /// Call after receiving a response. Records the metric and returns elapsed ms.
  Future<int> endTimer({
    required String timerId,
    required String sessionId,
    required String endpointName,
    required String serviceCode,
    required bool success,
    String? errorMessage,
  }) async {
    final start = _timers.remove(timerId);
    final elapsed = start != null
        ? DateTime.now().difference(start).inMilliseconds
        : 0;

    if (!_enabled) return elapsed;

    final metric = ResponseMetric(
      id: _uuid.v4(),
      sessionId: sessionId,
      endpointName: endpointName,
      serviceCode: serviceCode,
      responseTimeMs: elapsed,
      success: success,
      errorMessage: errorMessage,
      timestamp: DateTime.now(),
    );

    _metrics.add(metric);
    if (_metrics.length > _maxMetrics) {
      _metrics.removeRange(0, _metrics.length - _maxMetrics);
    }
    await _saveMetrics();
    notifyListeners();
    return elapsed;
  }

  // ── Summary computation ───────────────────────────────────────────────────

  AnalyticsSummary computeSummary() {
    if (_events.isEmpty && _metrics.isEmpty) return AnalyticsSummary.empty();

    final starts = _events
        .where((e) => e.type == SessionEventType.sessionStart)
        .toList();
    final ends = _events
        .where((e) => e.type == SessionEventType.sessionEnd)
        .toList();
    final errors = _events
        .where((e) => e.type == SessionEventType.error)
        .toList();

    // Sessions by service code
    final byCode = <String, int>{};
    for (final e in starts) {
      byCode[e.serviceCode] = (byCode[e.serviceCode] ?? 0) + 1;
    }

    // Avg response time by endpoint
    final timesByEndpoint = <String, List<int>>{};
    for (final m in _metrics) {
      timesByEndpoint
          .putIfAbsent(m.endpointName, () => [])
          .add(m.responseTimeMs);
    }
    final avgByEndpoint = timesByEndpoint.map(
      (k, v) => MapEntry(k, v.reduce((a, b) => a + b) / v.length),
    );

    // Errors by endpoint
    final errorsByEndpoint = <String, int>{};
    for (final e in errors) {
      errorsByEndpoint[e.endpointName] =
          (errorsByEndpoint[e.endpointName] ?? 0) + 1;
    }

    // Overall avg response time
    final allTimes = _metrics.map((m) => m.responseTimeMs).toList();
    final avgMs = allTimes.isEmpty
        ? 0.0
        : allTimes.reduce((a, b) => a + b) / allTimes.length;

    // Total session duration (sum of start→end pairs per sessionId)
    var totalDuration = Duration.zero;
    for (final start in starts) {
      final end = ends.where((e) => e.sessionId == start.sessionId).toList();
      if (end.isNotEmpty) {
        totalDuration += end.first.timestamp.difference(start.timestamp).abs();
      }
    }

    final totalRequests = _metrics.length;
    final totalErrors = errors.length;

    return AnalyticsSummary(
      totalSessions: starts.length,
      totalRequests: totalRequests,
      totalErrors: totalErrors,
      avgResponseTimeMs: avgMs,
      errorRate: totalRequests == 0
          ? 0
          : (_metrics.where((m) => !m.success).length / totalRequests) * 100,
      sessionsByServiceCode: byCode,
      avgResponseTimeByEndpoint: avgByEndpoint,
      errorsByEndpoint: errorsByEndpoint,
      totalSessionDuration: totalDuration,
    );
  }

  // ── Settings & data management ────────────────────────────────────────────

  void setEnabled(bool value) {
    _enabled = value;
    notifyListeners();
  }

  Future<void> clearAll() async {
    _events.clear();
    _metrics.clear();
    _timers.clear();
    await _prefs?.remove(_eventsKey);
    await _prefs?.remove(_metricsKey);
    notifyListeners();
  }

  /// Export all data as a JSON string.
  String exportJson() {
    return jsonEncode({
      'exportedAt': DateTime.now().toIso8601String(),
      'events': _events.map((e) => e.toJson()).toList(),
      'metrics': _metrics.map((m) => m.toJson()).toList(),
    });
  }

  /// Export metrics as CSV rows (header + data).
  String exportCsv() {
    final buf = StringBuffer();
    buf.writeln(
      'timestamp,sessionId,endpointName,serviceCode,responseTimeMs,success,errorMessage',
    );
    for (final m in _metrics) {
      buf.writeln(
        '${m.timestamp.toIso8601String()},'
        '${m.sessionId},'
        '${m.endpointName},'
        '${m.serviceCode},'
        '${m.responseTimeMs},'
        '${m.success},'
        '${m.errorMessage ?? ''}',
      );
    }
    return buf.toString();
  }
}
