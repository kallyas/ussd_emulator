import 'app_localizations.dart';

/// The translations for Hausa (`ha`).
class AppLocalizationsHa extends AppLocalizations {
  AppLocalizationsHa([String locale = 'ha']) : super(locale);

  @override
  String get appTitle => 'Mai kwaikwayi USSD';

  @override
  String get initializing => 'Ana farawa...';

  @override
  String get ussd => 'USSD';

  @override
  String get config => 'Saiti';

  @override
  String get history => 'Tarihi';

  @override
  String get ussdSession => 'Zama USSD';

  @override
  String get configuration => 'Tsarawa';

  @override
  String get sessionHistory => 'Tarihin Zama';

  @override
  String get openAccessibilitySettings => 'Buɗe saitunan samun dama';

  @override
  String get configureAccessibilityOptions => 'Saita zaɓuɓɓukan samun dama';

  @override
  String get ussdSessionScreenTooltip => 'Fuskar Zama USSD';

  @override
  String get endpointConfigurationTooltip => 'Tsarin Ƙarshen Batu';

  @override
  String get sessionHistoryTooltip => 'Tarihin Zama';

  @override
  String navigatedToScreen(String screenName) {
    return 'An kai zuwa fuskar $screenName';
  }

  @override
  String get error => 'Kuskure';

  @override
  String get dismissError => 'Kau da kuskure';

  @override
  String get connected => 'An haɗa';

  @override
  String get endSession => 'Kammala Zama';

  @override
  String get ussdSessionEnded => 'Zama USSD ya ƙare.';

  @override
  String get enterPhoneNumber => 'Shigar da lambar waya';

  @override
  String get enterServiceCode => 'Shigar da lambar sabis kamar *123#';

  @override
  String get enterNetworkCode => 'Shigar da lambar cibiyar sadarwa';

  @override
  String get startSession => 'Fara Zama';

  @override
  String get sessionStarted => 'Zama ya fara';

  @override
  String get sessionEnded => 'Zama ya ƙare';

  @override
  String get networkError => 'Haɗin cibiyar sadarwa ya kasa. Da fatan za a duba haɗin intanet ɗinku.';

  @override
  String get invalidPhoneNumber => 'Tsarin lambar waya mara inganci';

  @override
  String get sessionTimeout => 'Lokacin zama ya ƙare';

  @override
  String get phoneNumberHint => 'Shigar da lambar waya kamar +1234567890';

  @override
  String get serviceCodeHint => 'Shigar da lambar sabis kamar *123#';

  @override
  String get networkCodeHint => 'Shigar da lambar cibiyar sadarwa kamar MTN';

  @override
  String get sessionDetails => 'Cikakken Bayani na Zama';

  @override
  String get language => 'Harshe';

  @override
  String get selectLanguage => 'Zaɓi Harshe';

  @override
  String languageChangedTo(String languageName) {
    return 'Harshe ya canza zuwa $languageName';
  }

  @override
  String get english => 'Turanci';

  @override
  String get swahili => 'Harshen Swahili';

  @override
  String get french => 'Faransanci';

  @override
  String get amharic => 'Harshen Amharic';

  @override
  String get hausa => 'Hausa';

  @override
  String get arabic => 'Larabci';
}