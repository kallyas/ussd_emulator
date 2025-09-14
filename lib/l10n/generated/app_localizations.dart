import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_am.dart';
import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_ha.dart';
import 'app_localizations_sw.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('am'),
    Locale('ar'),
    Locale('en'),
    Locale('fr'),
    Locale('ha'),
    Locale('sw'),
  ];

  /// The title of the application
  ///
  /// In en, this message translates to:
  /// **'USSD Emulator'**
  String get appTitle;

  /// Loading message shown during app initialization
  ///
  /// In en, this message translates to:
  /// **'Initializing...'**
  String get initializing;

  /// USSD navigation label
  ///
  /// In en, this message translates to:
  /// **'USSD'**
  String get ussd;

  /// Configuration navigation label
  ///
  /// In en, this message translates to:
  /// **'Config'**
  String get config;

  /// History navigation label
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get history;

  /// USSD Session screen name
  ///
  /// In en, this message translates to:
  /// **'USSD Session'**
  String get ussdSession;

  /// Configuration screen name
  ///
  /// In en, this message translates to:
  /// **'Configuration'**
  String get configuration;

  /// Session History screen name
  ///
  /// In en, this message translates to:
  /// **'Session History'**
  String get sessionHistory;

  /// Accessibility button label
  ///
  /// In en, this message translates to:
  /// **'Open accessibility settings'**
  String get openAccessibilitySettings;

  /// Accessibility button hint
  ///
  /// In en, this message translates to:
  /// **'Configure accessibility options'**
  String get configureAccessibilityOptions;

  /// Accessibility settings screen title
  ///
  /// In en, this message translates to:
  /// **'Accessibility Settings'**
  String get accessibilitySettings;

  /// Tooltip for USSD session navigation
  ///
  /// In en, this message translates to:
  /// **'USSD Session Screen'**
  String get ussdSessionScreenTooltip;

  /// Tooltip for configuration navigation
  ///
  /// In en, this message translates to:
  /// **'Endpoint Configuration'**
  String get endpointConfigurationTooltip;

  /// Tooltip for history navigation
  ///
  /// In en, this message translates to:
  /// **'Session History'**
  String get sessionHistoryTooltip;

  /// Accessibility announcement for screen navigation
  ///
  /// In en, this message translates to:
  /// **'Navigated to {screenName} screen'**
  String navigatedToScreen(String screenName);

  /// Error label
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// Button to dismiss error message
  ///
  /// In en, this message translates to:
  /// **'Dismiss error'**
  String get dismissError;

  /// Connection status label
  ///
  /// In en, this message translates to:
  /// **'Connected'**
  String get connected;

  /// Button to end USSD session
  ///
  /// In en, this message translates to:
  /// **'End Session'**
  String get endSession;

  /// Message shown when USSD session ends
  ///
  /// In en, this message translates to:
  /// **'USSD session ended.'**
  String get ussdSessionEnded;

  /// Phone number input label
  ///
  /// In en, this message translates to:
  /// **'Enter phone number'**
  String get enterPhoneNumber;

  /// Service code input label with example
  ///
  /// In en, this message translates to:
  /// **'Enter service code like *123#'**
  String get enterServiceCode;

  /// Network code input label
  ///
  /// In en, this message translates to:
  /// **'Enter network code'**
  String get enterNetworkCode;

  /// Button to start USSD session
  ///
  /// In en, this message translates to:
  /// **'Start Session'**
  String get startSession;

  /// Message when session starts
  ///
  /// In en, this message translates to:
  /// **'Session started'**
  String get sessionStarted;

  /// Message when session ends
  ///
  /// In en, this message translates to:
  /// **'Session ended'**
  String get sessionEnded;

  /// Network error message
  ///
  /// In en, this message translates to:
  /// **'Network connection failed. Please check your internet connection.'**
  String get networkError;

  /// Phone number validation error
  ///
  /// In en, this message translates to:
  /// **'Invalid phone number format'**
  String get invalidPhoneNumber;

  /// Session timeout error message
  ///
  /// In en, this message translates to:
  /// **'Session timed out'**
  String get sessionTimeout;

  /// Phone number input hint
  ///
  /// In en, this message translates to:
  /// **'Enter phone number like +1234567890'**
  String get phoneNumberHint;

  /// Service code input hint
  ///
  /// In en, this message translates to:
  /// **'Enter service code like *123#'**
  String get serviceCodeHint;

  /// Network code input hint
  ///
  /// In en, this message translates to:
  /// **'Enter network code like MTN'**
  String get networkCodeHint;

  /// Session details section title
  ///
  /// In en, this message translates to:
  /// **'Session Details'**
  String get sessionDetails;

  /// Language settings label
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// Language selection dialog title
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// Message shown when language is changed
  ///
  /// In en, this message translates to:
  /// **'Language changed to {languageName}'**
  String languageChangedTo(String languageName);

  /// English language name
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// Swahili language name
  ///
  /// In en, this message translates to:
  /// **'Swahili'**
  String get swahili;

  /// French language name
  ///
  /// In en, this message translates to:
  /// **'French'**
  String get french;

  /// Amharic language name
  ///
  /// In en, this message translates to:
  /// **'Amharic'**
  String get amharic;

  /// Hausa language name
  ///
  /// In en, this message translates to:
  /// **'Hausa'**
  String get hausa;

  /// Arabic language name
  ///
  /// In en, this message translates to:
  /// **'Arabic'**
  String get arabic;

  /// Message when no USSD session is active
  ///
  /// In en, this message translates to:
  /// **'No active session'**
  String get noActiveSession;

  /// Prompt to start a new session
  ///
  /// In en, this message translates to:
  /// **'Start a new USSD session to see conversation'**
  String get startNewSessionPrompt;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'am',
    'ar',
    'en',
    'fr',
    'ha',
    'sw',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'am':
      return AppLocalizationsAm();
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
    case 'ha':
      return AppLocalizationsHa();
    case 'sw':
      return AppLocalizationsSw();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
