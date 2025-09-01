import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/accessibility_settings.dart';
import '../services/accessibility_service.dart';

class AccessibilityProvider extends ChangeNotifier {
  static const String _settingsKey = 'accessibility_settings';

  AccessibilitySettings _settings = const AccessibilitySettings();
  AccessibilityService? _accessibilityService;
  bool _isInitialized = false;

  AccessibilitySettings get settings => _settings;
  bool get isInitialized => _isInitialized;
  AccessibilityService? get accessibilityService => _accessibilityService;

  /// Initialize the accessibility provider
  Future<void> init() async {
    if (_isInitialized) return;

    try {
      _accessibilityService = AccessibilityService();
      await _accessibilityService!.init();
      await _loadSettings();
      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to initialize accessibility provider: $e');
    }
  }

  /// Load accessibility settings from storage
  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final settingsJson = prefs.getString(_settingsKey);

      if (settingsJson != null) {
        final data = json.decode(settingsJson) as Map<String, dynamic>;
        // Convert duration from milliseconds back to Duration
        if (data['inputTimeout'] is int) {
          data['inputTimeout'] = data['inputTimeout'] as int;
        }
        _settings = AccessibilitySettings.fromJson(data);
      }
    } catch (e) {
      debugPrint('Failed to load accessibility settings: $e');
      _settings = const AccessibilitySettings();
    }
  }

  /// Save accessibility settings to storage
  Future<void> _saveSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = _settings.toJson();
      // Convert Duration to milliseconds for storage
      data['inputTimeout'] = _settings.inputTimeout.inMilliseconds;
      await prefs.setString(_settingsKey, json.encode(data));
    } catch (e) {
      debugPrint('Failed to save accessibility settings: $e');
    }
  }

  /// Update accessibility settings
  Future<void> updateSettings(AccessibilitySettings newSettings) async {
    _settings = newSettings;
    await _saveSettings();

    // Update accessibility service configuration
    if (_accessibilityService != null) {
      await _accessibilityService!.updateSettings(_settings);
    }

    notifyListeners();
  }

  /// Toggle high contrast theme
  Future<void> toggleHighContrast() async {
    await updateSettings(
      _settings.copyWith(useHighContrast: !_settings.useHighContrast),
    );
  }

  /// Toggle voice input
  Future<void> toggleVoiceInput() async {
    await updateSettings(
      _settings.copyWith(enableVoiceInput: !_settings.enableVoiceInput),
    );
  }

  /// Toggle text-to-speech
  Future<void> toggleTextToSpeech() async {
    await updateSettings(
      _settings.copyWith(enableTextToSpeech: !_settings.enableTextToSpeech),
    );
  }

  /// Set text scale factor
  Future<void> setTextScaleFactor(double factor) async {
    await updateSettings(
      _settings.copyWith(textScaleFactor: factor.clamp(0.8, 2.0)),
    );
  }

  /// Set input timeout
  Future<void> setInputTimeout(Duration timeout) async {
    await updateSettings(_settings.copyWith(inputTimeout: timeout));
  }

  /// Toggle haptic feedback
  Future<void> toggleHapticFeedback() async {
    await updateSettings(
      _settings.copyWith(enableHapticFeedback: !_settings.enableHapticFeedback),
    );
  }

  /// Provide haptic feedback if enabled
  void hapticFeedback([
    HapticFeedback feedback = HapticFeedback.selectionClick,
  ]) {
    if (_settings.enableHapticFeedback) {
      switch (feedback) {
        case HapticFeedback.lightImpact:
          HapticFeedback.lightImpact();
          break;
        case HapticFeedback.mediumImpact:
          HapticFeedback.mediumImpact();
          break;
        case HapticFeedback.heavyImpact:
          HapticFeedback.heavyImpact();
          break;
        case HapticFeedback.selectionClick:
        default:
          HapticFeedback.selectionClick();
          break;
      }
    }
  }

  /// Announce text for screen readers
  void announceForScreenReader(String text) {
    if (_accessibilityService != null) {
      _accessibilityService!.announce(text);
    }
  }

  /// Speak text using TTS if enabled
  Future<void> speak(String text) async {
    if (_settings.enableTextToSpeech && _accessibilityService != null) {
      await _accessibilityService!.speak(text);
    }
  }

  /// Start voice input if enabled
  Future<String?> startVoiceInput() async {
    if (_settings.enableVoiceInput && _accessibilityService != null) {
      return await _accessibilityService!.startListening();
    }
    return null;
  }

  /// Stop voice input
  Future<void> stopVoiceInput() async {
    if (_accessibilityService != null) {
      await _accessibilityService!.stopListening();
    }
  }

  @override
  void dispose() {
    _accessibilityService?.dispose();
    super.dispose();
  }
}

enum HapticFeedback { lightImpact, mediumImpact, heavyImpact, selectionClick }
