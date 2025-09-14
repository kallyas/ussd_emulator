import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:ussd_emulator/providers/language_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('LanguageProvider', () {
    late LanguageProvider languageProvider;

    setUp(() {
      languageProvider = LanguageProvider();
      SharedPreferences.setMockInitialValues({});
    });

    test('should have default locale as English', () {
      expect(languageProvider.currentLocale, const Locale('en', 'US'));
    });

    test('should support 6 languages', () {
      expect(LanguageProvider.supportedLocales.length, 6);
      expect(LanguageProvider.supportedLocales, contains(const Locale('en', 'US')));
      expect(LanguageProvider.supportedLocales, contains(const Locale('sw', 'TZ')));
      expect(LanguageProvider.supportedLocales, contains(const Locale('fr', 'FR')));
      expect(LanguageProvider.supportedLocales, contains(const Locale('am', 'ET')));
      expect(LanguageProvider.supportedLocales, contains(const Locale('ha', 'NG')));
      expect(LanguageProvider.supportedLocales, contains(const Locale('ar', 'SA')));
    });

    test('should have language names for all supported languages', () {
      expect(LanguageProvider.languageNames['en'], 'English');
      expect(LanguageProvider.languageNames['sw'], 'Kiswahili');
      expect(LanguageProvider.languageNames['fr'], 'Français');
      expect(LanguageProvider.languageNames['am'], 'አማርኛ');
      expect(LanguageProvider.languageNames['ha'], 'Hausa');
      expect(LanguageProvider.languageNames['ar'], 'العربية');
    });

    test('should change locale and notify listeners', () async {
      bool notified = false;
      languageProvider.addListener(() {
        notified = true;
      });

      await languageProvider.setLocale(const Locale('sw', 'TZ'));

      expect(languageProvider.currentLocale, const Locale('sw', 'TZ'));
      expect(notified, true);
    });

    test('should not change to same locale', () async {
      languageProvider.addListener(() {
        fail('Should not notify when setting same locale');
      });

      await languageProvider.setLocale(const Locale('en', 'US'));
      
      expect(languageProvider.currentLocale, const Locale('en', 'US'));
    });

    test('should only accept supported locales', () async {
      const unsupportedLocale = Locale('de', 'DE'); // German - not supported
      
      await languageProvider.setLocale(unsupportedLocale);
      
      // Should remain at default locale
      expect(languageProvider.currentLocale, const Locale('en', 'US'));
    });

    test('should detect RTL correctly', () {
      languageProvider.setLocale(const Locale('ar', 'SA'));
      expect(languageProvider.isRTL, true);
      expect(languageProvider.textDirection, TextDirection.rtl);

      languageProvider.setLocale(const Locale('en', 'US'));
      expect(languageProvider.isRTL, false);
      expect(languageProvider.textDirection, TextDirection.ltr);
    });

    test('should get language names correctly', () {
      expect(languageProvider.getLanguageName('en'), 'English');
      expect(languageProvider.getLanguageName('sw'), 'Kiswahili');
      expect(languageProvider.getLanguageName('ar'), 'العربية');
      expect(languageProvider.getLanguageName('unknown'), 'unknown');
    });

    test('should get supported locales with names', () {
      final localesWithNames = languageProvider.getSupportedLocalesWithNames();
      
      expect(localesWithNames.length, 6);
      expect(localesWithNames[const Locale('en', 'US')], 'English');
      expect(localesWithNames[const Locale('sw', 'TZ')], 'Kiswahili');
      expect(localesWithNames[const Locale('ar', 'SA')], 'العربية');
    });

    test('should save and load locale from SharedPreferences', () async {
      SharedPreferences.setMockInitialValues({
        'language_code': 'sw',
        'country_code': 'TZ',
      });

      await languageProvider.init();
      
      expect(languageProvider.currentLocale, const Locale('sw', 'TZ'));
    });

    test('should handle missing SharedPreferences gracefully', () async {
      SharedPreferences.setMockInitialValues({});

      await languageProvider.init();
      
      // Should remain at default
      expect(languageProvider.currentLocale, const Locale('en', 'US'));
    });
  });
}