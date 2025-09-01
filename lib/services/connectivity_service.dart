import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ConnectivityService extends ChangeNotifier {
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> _subscription;
  
  List<ConnectivityResult> _connectionStatus = [ConnectivityResult.none];
  bool _isOnline = false;
  DateTime? _lastConnectionTime;
  Duration _connectionUptime = Duration.zero;
  Timer? _uptimeTimer;

  List<ConnectivityResult> get connectionStatus => _connectionStatus;
  bool get isOnline => _isOnline;
  bool get isOffline => !_isOnline;
  DateTime? get lastConnectionTime => _lastConnectionTime;
  Duration get connectionUptime => _connectionUptime;

  String get connectionTypeString {
    if (_connectionStatus.contains(ConnectivityResult.wifi)) {
      return 'WiFi';
    } else if (_connectionStatus.contains(ConnectivityResult.mobile)) {
      return 'Mobile';
    } else if (_connectionStatus.contains(ConnectivityResult.ethernet)) {
      return 'Ethernet';
    } else {
      return 'None';
    }
  }

  bool get hasStableConnection {
    return _isOnline && 
           _lastConnectionTime != null && 
           DateTime.now().difference(_lastConnectionTime!).inSeconds > 5;
  }

  Future<void> init() async {
    try {
      _connectionStatus = await _connectivity.checkConnectivity();
      _updateOnlineStatus();
      
      _subscription = _connectivity.onConnectivityChanged.listen(
        _updateConnectivity,
        onError: (error) {
          debugPrint('Connectivity subscription error: $error');
        },
      );
    } catch (e) {
      debugPrint('Failed to initialize connectivity service: $e');
      _connectionStatus = [ConnectivityResult.none];
      _updateOnlineStatus();
    }
  }

  void _updateConnectivity(List<ConnectivityResult> result) {
    final wasOnline = _isOnline;
    _connectionStatus = result;
    _updateOnlineStatus();
    
    if (!wasOnline && _isOnline) {
      _onConnectionRestored();
    } else if (wasOnline && !_isOnline) {
      _onConnectionLost();
    }
    
    notifyListeners();
  }

  void _updateOnlineStatus() {
    _isOnline = _connectionStatus.any((result) => 
        result != ConnectivityResult.none);
  }

  void _onConnectionRestored() {
    _lastConnectionTime = DateTime.now();
    _startUptimeTimer();
    debugPrint('Connection restored: ${connectionTypeString}');
  }

  void _onConnectionLost() {
    _stopUptimeTimer();
    debugPrint('Connection lost');
  }

  void _startUptimeTimer() {
    _stopUptimeTimer();
    final startTime = DateTime.now();
    
    _uptimeTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_isOnline) {
        _connectionUptime = DateTime.now().difference(startTime);
        notifyListeners();
      } else {
        timer.cancel();
      }
    });
  }

  void _stopUptimeTimer() {
    _uptimeTimer?.cancel();
    _uptimeTimer = null;
    _connectionUptime = Duration.zero;
  }

  /// Test actual internet connectivity by attempting to reach a reliable endpoint
  Future<bool> testInternetConnectivity() async {
    if (!_isOnline) return false;
    
    try {
      // Simple HTTP request to test actual internet connectivity
      // Using a lightweight, reliable service
      final client = HttpClient();
      final request = await client.getUrl(Uri.parse('https://www.google.com'));
      request.headers.add('User-Agent', 'USSD-Emulator-Connectivity-Test');
      
      final response = await request.close().timeout(Duration(seconds: 10));
      client.close();
      
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// Get connection quality based on type and stability
  ConnectionQuality get connectionQuality {
    if (!_isOnline) return ConnectionQuality.none;
    
    if (_connectionStatus.contains(ConnectivityResult.ethernet)) {
      return ConnectionQuality.excellent;
    } else if (_connectionStatus.contains(ConnectivityResult.wifi)) {
      return hasStableConnection 
          ? ConnectionQuality.good 
          : ConnectionQuality.fair;
    } else if (_connectionStatus.contains(ConnectivityResult.mobile)) {
      return hasStableConnection 
          ? ConnectionQuality.fair 
          : ConnectionQuality.poor;
    } else {
      return ConnectionQuality.poor;
    }
  }

  @override
  void dispose() {
    _subscription.cancel();
    _stopUptimeTimer();
    super.dispose();
  }
}

enum ConnectionQuality {
  none,
  poor,
  fair,
  good,
  excellent,
}

extension ConnectionQualityExtension on ConnectionQuality {
  String get displayName {
    switch (this) {
      case ConnectionQuality.none:
        return 'No Connection';
      case ConnectionQuality.poor:
        return 'Poor';
      case ConnectionQuality.fair:
        return 'Fair';
      case ConnectionQuality.good:
        return 'Good';
      case ConnectionQuality.excellent:
        return 'Excellent';
    }
  }

  Color get color {
    switch (this) {
      case ConnectionQuality.none:
        return Colors.grey;
      case ConnectionQuality.poor:
        return Colors.red;
      case ConnectionQuality.fair:
        return Colors.orange;
      case ConnectionQuality.good:
        return Colors.yellow;
      case ConnectionQuality.excellent:
        return Colors.green;
    }
  }
}