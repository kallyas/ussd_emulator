import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../models/accessibility_settings.dart';

class AccessibilityService {
  late SpeechToText _speechToText;
  late FlutterTts _flutterTts;
  bool _speechEnabled = false;
  bool _ttsEnabled = false;
  bool _isListening = false;
  String _lastWords = '';

  bool get speechEnabled => _speechEnabled;
  bool get ttsEnabled => _ttsEnabled;
  bool get isListening => _isListening;
  String get lastWords => _lastWords;

  /// Initialize the accessibility service
  Future<void> init() async {
    await _initSpeechToText();
    await _initTextToSpeech();
  }

  /// Initialize speech-to-text
  Future<void> _initSpeechToText() async {
    try {
      _speechToText = SpeechToText();
      _speechEnabled = await _speechToText.initialize(
        onError: (error) => debugPrint('Speech recognition error: $error'),
        onStatus: (status) => debugPrint('Speech recognition status: $status'),
      );
      debugPrint('Speech recognition available: $_speechEnabled');
    } catch (e) {
      debugPrint('Failed to initialize speech recognition: $e');
      _speechEnabled = false;
    }
  }

  /// Initialize text-to-speech
  Future<void> _initTextToSpeech() async {
    try {
      _flutterTts = FlutterTts();

      // Configure TTS settings
      await _flutterTts.setLanguage("en-US");
      await _flutterTts.setSpeechRate(0.5);
      await _flutterTts.setVolume(0.8);
      await _flutterTts.setPitch(1.0);

      // Set up completion handler
      _flutterTts.setCompletionHandler(() {
        debugPrint('TTS completed');
      });

      // Set up error handler
      _flutterTts.setErrorHandler((msg) {
        debugPrint('TTS error: $msg');
      });

      _ttsEnabled = true;
      debugPrint('Text-to-speech initialized successfully');
    } catch (e) {
      debugPrint('Failed to initialize text-to-speech: $e');
      _ttsEnabled = false;
    }
  }

  /// Update service configuration based on accessibility settings
  Future<void> updateSettings(AccessibilitySettings settings) async {
    if (_ttsEnabled) {
      // Adjust TTS settings based on user preferences
      await _flutterTts.setSpeechRate(settings.textScaleFactor * 0.5);
    }
  }

  /// Start listening for voice input
  Future<String?> startListening({Duration? timeout}) async {
    if (!_speechEnabled || _isListening) return null;

    try {
      _lastWords = '';
      _isListening = true;

      // Use a completer to wait for speech recognition result
      String? result;

      await _speechToText.listen(
        onResult: (result) {
          _lastWords = result.recognizedWords;
          debugPrint('Speech result: $_lastWords');
        },
        listenFor: timeout ?? const Duration(seconds: 10),
        pauseFor: const Duration(seconds: 3),
        partialResults: false,
        localeId: "en_US",
        cancelOnError: true,
        listenMode: ListenMode.confirmation,
      );

      // Wait for listening to complete
      while (_speechToText.isListening) {
        await Future.delayed(const Duration(milliseconds: 100));
      }

      _isListening = false;
      result = _lastWords;

      if (result.isNotEmpty) {
        // Provide haptic feedback for successful recognition
        HapticFeedback.lightImpact();
      }

      return result.isEmpty ? null : result;
    } catch (e) {
      debugPrint('Error during speech recognition: $e');
      _isListening = false;
      return null;
    }
  }

  /// Stop listening for voice input
  Future<void> stopListening() async {
    if (_speechEnabled && _isListening) {
      await _speechToText.stop();
      _isListening = false;
    }
  }

  /// Speak text using text-to-speech
  Future<void> speak(String text) async {
    if (!_ttsEnabled || text.trim().isEmpty) return;

    try {
      // Stop any ongoing speech
      await _flutterTts.stop();

      // Clean up text for better TTS pronunciation
      String cleanText = _cleanTextForTTS(text);

      // Speak the text
      await _flutterTts.speak(cleanText);
    } catch (e) {
      debugPrint('Error during text-to-speech: $e');
    }
  }

  /// Stop any ongoing text-to-speech
  Future<void> stopSpeaking() async {
    if (_ttsEnabled) {
      await _flutterTts.stop();
    }
  }

  /// Announce text for screen readers and accessibility services
  void announce(String text) {
    if (text.trim().isEmpty) return;

    // Use Flutter's accessibility framework to announce
    SystemSound.play(SystemSoundType.click);

    // Also speak if TTS is enabled
    speak(text);
  }

  /// Clean text for better TTS pronunciation
  String _cleanTextForTTS(String text) {
    String cleaned = text
        // Replace common abbreviations with full words
        .replaceAll(RegExp(r'\bCON\b'), 'Continue')
        .replaceAll(RegExp(r'\bEND\b'), 'End')
        .replaceAll(RegExp(r'\bUSSD\b'), 'U S S D')
        .replaceAll(RegExp(r'#'), ' hash ')
        .replaceAll(RegExp(r'\*'), ' star ')
        // Remove excessive whitespace
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();

    return cleaned;
  }

  /// Check if device supports speech recognition
  Future<bool> checkSpeechAvailability() async {
    if (!_speechEnabled) return false;
    return await _speechToText.hasPermission;
  }

  /// Request speech recognition permissions
  Future<bool> requestSpeechPermissions() async {
    try {
      return await _speechToText.initialize();
    } catch (e) {
      debugPrint('Failed to request speech permissions: $e');
      return false;
    }
  }

  /// Get available TTS languages
  Future<List<dynamic>> getAvailableLanguages() async {
    if (!_ttsEnabled) return [];
    return await _flutterTts.getLanguages;
  }

  /// Set TTS language
  Future<void> setLanguage(String language) async {
    if (_ttsEnabled) {
      await _flutterTts.setLanguage(language);
    }
  }

  /// Set TTS speech rate
  Future<void> setSpeechRate(double rate) async {
    if (_ttsEnabled) {
      await _flutterTts.setSpeechRate(rate.clamp(0.1, 2.0));
    }
  }

  /// Set TTS pitch
  Future<void> setPitch(double pitch) async {
    if (_ttsEnabled) {
      await _flutterTts.setPitch(pitch.clamp(0.1, 2.0));
    }
  }

  /// Dispose of resources
  void dispose() {
    stopListening();
    stopSpeaking();
    _speechToText.cancel();
  }
}
