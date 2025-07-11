import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/endpoint_config.dart';

class EndpointConfigService {
  static const String _configsKey = 'endpoint_configs';
  static const String _activeConfigKey = 'active_endpoint_config';
  
  List<EndpointConfig> _configs = [];
  EndpointConfig? _activeConfig;

  List<EndpointConfig> get configs => _configs;
  EndpointConfig? get activeConfig => _activeConfig;

  Future<void> init() async {
    await _loadConfigs();
    await _loadActiveConfig();
    
    if (_configs.isEmpty) {
      await _createDefaultConfigs();
    }
  }

  Future<void> _createDefaultConfigs() async {
    final defaultConfigs = [
      EndpointConfig(
        name: 'Local Development',
        url: 'http://localhost:8080/ussd',
        headers: {'Content-Type': 'application/json'},
        isActive: true,
      ),
      EndpointConfig(
        name: 'Staging',
        url: 'https://staging.example.com/ussd',
        headers: {'Content-Type': 'application/json'},
        isActive: false,
      ),
    ];

    _configs = defaultConfigs;
    _activeConfig = defaultConfigs.first;
    
    await _saveConfigs();
    await _saveActiveConfig();
  }

  Future<void> addConfig(EndpointConfig config) async {
    _validateConfig(config);
    _configs.add(config);
    await _saveConfigs();
  }

  Future<void> updateConfig(int index, EndpointConfig config) async {
    _validateConfig(config, excludeIndex: index);
    if (index >= 0 && index < _configs.length) {
      _configs[index] = config;
      
      if (_activeConfig?.name == _configs[index].name) {
        _activeConfig = config;
        await _saveActiveConfig();
      }
      
      await _saveConfigs();
    }
  }

  Future<void> deleteConfig(int index) async {
    if (index >= 0 && index < _configs.length) {
      final deletedConfig = _configs.removeAt(index);
      
      if (_activeConfig?.name == deletedConfig.name) {
        _activeConfig = _configs.isNotEmpty ? _configs.first : null;
        await _saveActiveConfig();
      }
      
      await _saveConfigs();
    }
  }

  Future<void> setActiveConfig(EndpointConfig config) async {
    _activeConfig = config;
    await _saveActiveConfig();
  }

  Future<void> _saveConfigs() async {
    final prefs = await SharedPreferences.getInstance();
    final configsJson = jsonEncode(_configs.map((c) => c.toJson()).toList());
    await prefs.setString(_configsKey, configsJson);
  }

  Future<void> _loadConfigs() async {
    final prefs = await SharedPreferences.getInstance();
    final configsJson = prefs.getString(_configsKey);
    
    if (configsJson != null) {
      try {
        final List<dynamic> configsData = jsonDecode(configsJson);
        _configs = configsData.map((data) => EndpointConfig.fromJson(data)).toList();
      } catch (e) {
        _configs = [];
      }
    }
  }

  Future<void> _saveActiveConfig() async {
    if (_activeConfig == null) return;
    
    final prefs = await SharedPreferences.getInstance();
    final configJson = jsonEncode(_activeConfig!.toJson());
    await prefs.setString(_activeConfigKey, configJson);
  }

  Future<void> _loadActiveConfig() async {
    final prefs = await SharedPreferences.getInstance();
    final configJson = prefs.getString(_activeConfigKey);
    
    if (configJson != null) {
      try {
        final configData = jsonDecode(configJson);
        _activeConfig = EndpointConfig.fromJson(configData);
      } catch (e) {
        _activeConfig = null;
      }
    }
  }

  void _validateConfig(EndpointConfig config, {int? excludeIndex}) {
    if (config.name.trim().isEmpty) {
      throw ArgumentError('Configuration name cannot be empty');
    }
    
    if (config.url.trim().isEmpty) {
      throw ArgumentError('Configuration URL cannot be empty');
    }
    
    // Basic URL format validation
    if (!config.url.startsWith('http://') && !config.url.startsWith('https://')) {
      throw ArgumentError('URL must start with http:// or https://');
    }
    
    // Check for duplicate names (excluding the config being updated)
    for (int i = 0; i < _configs.length; i++) {
      if (excludeIndex != null && i == excludeIndex) continue;
      if (_configs[i].name.toLowerCase() == config.name.toLowerCase()) {
        throw ArgumentError('A configuration with this name already exists');
      }
    }
  }
}