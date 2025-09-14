import 'app_localizations.dart';

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'USSD Emulator';

  @override
  String get initializing => 'Initializing...';

  @override
  String get ussd => 'USSD';

  @override
  String get config => 'Config';

  @override
  String get history => 'History';

  @override
  String get ussdSession => 'USSD Session';

  @override
  String get configuration => 'Configuration';

  @override
  String get sessionHistory => 'Session History';

  @override
  String get openAccessibilitySettings => 'Open accessibility settings';

  @override
  String get configureAccessibilityOptions => 'Configure accessibility options';

  @override
  String get ussdSessionScreenTooltip => 'USSD Session Screen';

  @override
  String get endpointConfigurationTooltip => 'Endpoint Configuration';

  @override
  String get sessionHistoryTooltip => 'Session History';

  @override
  String navigatedToScreen(String screenName) {
    return 'Navigated to $screenName screen';
  }

  @override
  String get error => 'Error';

  @override
  String get dismissError => 'Dismiss error';

  @override
  String get connected => 'Connected';

  @override
  String get endSession => 'End Session';

  @override
  String get ussdSessionEnded => 'USSD session ended.';

  @override
  String get enterPhoneNumber => 'Enter phone number';

  @override
  String get enterServiceCode => 'Enter service code like *123#';

  @override
  String get enterNetworkCode => 'Enter network code';

  @override
  String get startSession => 'Start Session';

  @override
  String get sessionStarted => 'Session started';

  @override
  String get sessionEnded => 'Session ended';

  @override
  String get networkError => 'Network connection failed. Please check your internet connection.';

  @override
  String get invalidPhoneNumber => 'Invalid phone number format';

  @override
  String get sessionTimeout => 'Session timed out';

  @override
  String get phoneNumberHint => 'Enter phone number like +1234567890';

  @override
  String get serviceCodeHint => 'Enter service code like *123#';

  @override
  String get networkCodeHint => 'Enter network code like MTN';

  @override
  String get sessionDetails => 'Session Details';

  @override
  String get language => 'Language';

  @override
  String get selectLanguage => 'Select Language';

  @override
  String languageChangedTo(String languageName) {
    return 'Language changed to $languageName';
  }

  @override
  String get english => 'English';

  @override
  String get swahili => 'Swahili';

  @override
  String get french => 'French';

  @override
  String get amharic => 'Amharic';

  @override
  String get hausa => 'Hausa';

  @override
  String get arabic => 'Arabic';
}