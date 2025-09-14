import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider extends ChangeNotifier {
  static const String _languageCodeKey = 'language_code';
  static const String _countryCodeKey = 'country_code';

  Locale _currentLocale = const Locale('en', 'US');

  Locale get currentLocale => _currentLocale;

  static const List<Locale> supportedLocales = [
    Locale('en', 'US'), // English
    Locale('sw', 'TZ'), // Swahili
    Locale('fr', 'FR'), // French
    Locale('am', 'ET'), // Amharic
    Locale('ha', 'NG'), // Hausa
    Locale('ar', 'SA'), // Arabic
  ];

  static const Map<String, String> languageNames = {
    'en': 'English',
    'sw': 'Kiswahili',
    'fr': 'Français',
    'am': 'አማርኛ',
    'ha': 'Hausa',
    'ar': 'العربية',
  };

  /// Initialize the language provider
  Future<void> init() async {
    await _loadSavedLocale();
  }

  /// Load saved locale from shared preferences
  Future<void> _loadSavedLocale() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final languageCode = prefs.getString(_languageCodeKey);
      final countryCode = prefs.getString(_countryCodeKey);

      if (languageCode != null) {
        final locale = Locale(languageCode, countryCode);
        if (_isLocaleSupported(locale)) {
          _currentLocale = locale;
          notifyListeners();
        }
      }
    } catch (e) {
      // If there's an error loading preferences, use default locale
      debugPrint('Error loading saved locale: $e');
    }
  }

  /// Set the current locale
  Future<void> setLocale(Locale locale) async {
    if (_currentLocale == locale) return;

    if (_isLocaleSupported(locale)) {
      _currentLocale = locale;
      await _saveLocale(locale);
      notifyListeners();
    }
  }

  /// Save locale to shared preferences
  Future<void> _saveLocale(Locale locale) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_languageCodeKey, locale.languageCode);
      if (locale.countryCode != null) {
        await prefs.setString(_countryCodeKey, locale.countryCode!);
      } else {
        await prefs.remove(_countryCodeKey);
      }
    } catch (e) {
      debugPrint('Error saving locale: $e');
    }
  }

  /// Check if a locale is supported
  bool _isLocaleSupported(Locale locale) {
    return supportedLocales.any(
      (supportedLocale) => supportedLocale.languageCode == locale.languageCode,
    );
  }

  /// Get the display name for a language code
  String getLanguageName(String languageCode) {
    return languageNames[languageCode] ?? languageCode;
  }

  /// Get all supported locales with their display names
  Map<Locale, String> getSupportedLocalesWithNames() {
    final Map<Locale, String> localeNames = {};
    for (final locale in supportedLocales) {
      localeNames[locale] = getLanguageName(locale.languageCode);
    }
    return localeNames;
  }

  /// Check if current locale is RTL
  bool get isRTL => _currentLocale.languageCode == 'ar';

  /// Get text direction based on current locale
  TextDirection get textDirection =>
      isRTL ? TextDirection.rtl : TextDirection.ltr;
}
