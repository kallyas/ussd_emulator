import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:ussd_emulator/l10n/generated/app_localizations.dart';
import 'package:ussd_emulator/l10n/generated/app_localizations_en.dart';
import 'package:ussd_emulator/l10n/generated/app_localizations_sw.dart';
import 'package:ussd_emulator/l10n/generated/app_localizations_ar.dart';
import 'package:ussd_emulator/l10n/generated/app_localizations_fr.dart';
import 'package:ussd_emulator/l10n/generated/app_localizations_am.dart';
import 'package:ussd_emulator/l10n/generated/app_localizations_ha.dart';

void main() {
  group('AppLocalizations', () {
    test('English localization should have all strings', () {
      final l10n = AppLocalizationsEn();

      expect(l10n.appTitle, 'USSD Emulator');
      expect(l10n.startSession, 'Start Session');
      expect(l10n.endSession, 'End Session');
      expect(l10n.enterPhoneNumber, 'Enter phone number');
      expect(l10n.enterServiceCode, 'Enter service code like *123#');
      expect(l10n.language, 'Language');
      expect(l10n.selectLanguage, 'Select Language');
      expect(l10n.english, 'English');
      expect(l10n.swahili, 'Swahili');
      expect(l10n.arabic, 'Arabic');
      expect(l10n.noActiveSession, 'No active session');
    });

    test('Swahili localization should have translated strings', () {
      final l10n = AppLocalizationsSw();

      expect(l10n.appTitle, 'Kijazo cha USSD');
      expect(l10n.startSession, 'Anza Kipindi');
      expect(l10n.endSession, 'Maliza Kipindi');
      expect(l10n.enterPhoneNumber, 'Ingiza nambari ya simu');
      expect(l10n.language, 'Lugha');
      expect(l10n.selectLanguage, 'Chagua Lugha');
      expect(l10n.english, 'Kiingereza');
      expect(l10n.swahili, 'Kiswahili');
      expect(l10n.noActiveSession, 'Hakuna kipindi kilichoanza');
    });

    test('Arabic localization should have translated strings', () {
      final l10n = AppLocalizationsAr();

      expect(l10n.appTitle, 'محاكي USSD');
      expect(l10n.startSession, 'بدء الجلسة');
      expect(l10n.endSession, 'إنهاء الجلسة');
      expect(l10n.enterPhoneNumber, 'أدخل رقم الهاتف');
      expect(l10n.language, 'اللغة');
      expect(l10n.selectLanguage, 'اختر اللغة');
      expect(l10n.english, 'الإنجليزية');
      expect(l10n.arabic, 'العربية');
      expect(l10n.noActiveSession, 'لا توجد جلسة نشطة');
    });

    test('French localization should have translated strings', () {
      final l10n = AppLocalizationsFr();

      expect(l10n.appTitle, 'Émulateur USSD');
      expect(l10n.startSession, 'Démarrer la Session');
      expect(l10n.endSession, 'Terminer la Session');
      expect(l10n.enterPhoneNumber, 'Entrez le numéro de téléphone');
      expect(l10n.language, 'Langue');
      expect(l10n.selectLanguage, 'Sélectionner la Langue');
      expect(l10n.english, 'Anglais');
      expect(l10n.french, 'Français');
      expect(l10n.noActiveSession, 'Aucune session active');
    });

    test('Amharic localization should have translated strings', () {
      final l10n = AppLocalizationsAm();

      expect(l10n.appTitle, 'የUSSD አስመሳይ');
      expect(l10n.startSession, 'ክፍለ ጊዜ ጀምር');
      expect(l10n.endSession, 'ክፍለ ጊዜን አቁም');
      expect(l10n.enterPhoneNumber, 'የስልክ ቁጥር አስገባ');
      expect(l10n.language, 'ቋንቋ');
      expect(l10n.selectLanguage, 'ቋንቋ ምረጥ');
      expect(l10n.english, 'እንግሊዝኛ');
      expect(l10n.amharic, 'አማርኛ');
      expect(l10n.noActiveSession, 'ንቁ ክፍለ ጊዜ የለም');
    });

    test('Hausa localization should have translated strings', () {
      final l10n = AppLocalizationsHa();

      expect(l10n.appTitle, 'Mai kwaikwayi USSD');
      expect(l10n.startSession, 'Fara Zama');
      expect(l10n.endSession, 'Kammala Zama');
      expect(l10n.enterPhoneNumber, 'Shigar da lambar waya');
      expect(l10n.language, 'Harshe');
      expect(l10n.selectLanguage, 'Zaɓi Harshe');
      expect(l10n.english, 'Turanci');
      expect(l10n.hausa, 'Hausa');
      expect(l10n.noActiveSession, 'Babu zama mai aiki');
    });

    test('lookupAppLocalizations should return correct localizations', () {
      expect(
        lookupAppLocalizations(const Locale('en')),
        isA<AppLocalizationsEn>(),
      );
      expect(
        lookupAppLocalizations(const Locale('sw')),
        isA<AppLocalizationsSw>(),
      );
      expect(
        lookupAppLocalizations(const Locale('ar')),
        isA<AppLocalizationsAr>(),
      );
      expect(
        lookupAppLocalizations(const Locale('fr')),
        isA<AppLocalizationsFr>(),
      );
      expect(
        lookupAppLocalizations(const Locale('am')),
        isA<AppLocalizationsAm>(),
      );
      expect(
        lookupAppLocalizations(const Locale('ha')),
        isA<AppLocalizationsHa>(),
      );
    });

    test('Parameterized messages should work correctly', () {
      final l10n = AppLocalizationsEn();

      expect(
        l10n.navigatedToScreen('Test Screen'),
        'Navigated to Test Screen screen',
      );
      expect(l10n.languageChangedTo('English'), 'Language changed to English');
    });

    test('All supported locales should be defined', () {
      expect(AppLocalizations.supportedLocales.length, 6);
      expect(AppLocalizations.supportedLocales, contains(const Locale('en')));
      expect(AppLocalizations.supportedLocales, contains(const Locale('sw')));
      expect(AppLocalizations.supportedLocales, contains(const Locale('ar')));
      expect(AppLocalizations.supportedLocales, contains(const Locale('fr')));
      expect(AppLocalizations.supportedLocales, contains(const Locale('am')));
      expect(AppLocalizations.supportedLocales, contains(const Locale('ha')));
    });
  });
}
