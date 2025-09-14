import 'app_localizations.dart';

/// The translations for Swahili (`sw`).
class AppLocalizationsSw extends AppLocalizations {
  AppLocalizationsSw([String locale = 'sw']) : super(locale);

  @override
  String get appTitle => 'Kijazo cha USSD';

  @override
  String get initializing => 'Kuanzisha...';

  @override
  String get ussd => 'USSD';

  @override
  String get config => 'Mipangilio';

  @override
  String get history => 'Historia';

  @override
  String get ussdSession => 'Kipindi cha USSD';

  @override
  String get configuration => 'Mipangilio';

  @override
  String get sessionHistory => 'Historia ya Vipindi';

  @override
  String get openAccessibilitySettings => 'Fungua mipangilio ya ufikishaji';

  @override
  String get configureAccessibilityOptions => 'Sanidi chaguo za ufikishaji';

  @override
  String get ussdSessionScreenTooltip => 'Skrini ya Kipindi cha USSD';

  @override
  String get endpointConfigurationTooltip => 'Usanidi wa Mwisho';

  @override
  String get sessionHistoryTooltip => 'Historia ya Vipindi';

  @override
  String navigatedToScreen(String screenName) {
    return 'Imeelekea kwenye skrini ya $screenName';
  }

  @override
  String get error => 'Hitilafu';

  @override
  String get dismissError => 'Ondoa hitilafu';

  @override
  String get connected => 'Imeunganishwa';

  @override
  String get endSession => 'Maliza Kipindi';

  @override
  String get ussdSessionEnded => 'Kipindi cha USSD kimemalizika.';

  @override
  String get enterPhoneNumber => 'Ingiza nambari ya simu';

  @override
  String get enterServiceCode => 'Ingiza msimbo wa huduma kama *123#';

  @override
  String get enterNetworkCode => 'Ingiza msimbo wa mtandao';

  @override
  String get startSession => 'Anza Kipindi';

  @override
  String get sessionStarted => 'Kipindi kimeanza';

  @override
  String get sessionEnded => 'Kipindi kimemalizika';

  @override
  String get networkError => 'Muunganisho wa mtandao umeshindwa. Tafadhali kagua muunganisho wako wa intaneti.';

  @override
  String get invalidPhoneNumber => 'Muundo mbaya wa nambari ya simu';

  @override
  String get sessionTimeout => 'Kipindi kimepita';

  @override
  String get phoneNumberHint => 'Ingiza nambari ya simu kama +1234567890';

  @override
  String get serviceCodeHint => 'Ingiza msimbo wa huduma kama *123#';

  @override
  String get networkCodeHint => 'Ingiza msimbo wa mtandao kama MTN';

  @override
  String get sessionDetails => 'Maelezo ya Kipindi';

  @override
  String get language => 'Lugha';

  @override
  String get selectLanguage => 'Chagua Lugha';

  @override
  String languageChangedTo(String languageName) {
    return 'Lugha imebadilishwa kuwa $languageName';
  }

  @override
  String get english => 'Kiingereza';

  @override
  String get swahili => 'Kiswahili';

  @override
  String get french => 'Kifaransa';

  @override
  String get amharic => 'Kiamhara';

  @override
  String get hausa => 'Kihausa';

  @override
  String get arabic => 'Kiarabu';
}