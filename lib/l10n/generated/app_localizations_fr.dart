import 'app_localizations.dart';

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Émulateur USSD';

  @override
  String get initializing => 'Initialisation...';

  @override
  String get ussd => 'USSD';

  @override
  String get config => 'Config';

  @override
  String get history => 'Historique';

  @override
  String get ussdSession => 'Session USSD';

  @override
  String get configuration => 'Configuration';

  @override
  String get sessionHistory => 'Historique des Sessions';

  @override
  String get openAccessibilitySettings => 'Ouvrir les paramètres d\'accessibilité';

  @override
  String get configureAccessibilityOptions => 'Configurer les options d\'accessibilité';

  @override
  String get ussdSessionScreenTooltip => 'Écran de Session USSD';

  @override
  String get endpointConfigurationTooltip => 'Configuration du Point de Terminaison';

  @override
  String get sessionHistoryTooltip => 'Historique des Sessions';

  @override
  String navigatedToScreen(String screenName) {
    return 'Navigation vers l\'écran $screenName';
  }

  @override
  String get error => 'Erreur';

  @override
  String get dismissError => 'Ignorer l\'erreur';

  @override
  String get connected => 'Connecté';

  @override
  String get endSession => 'Terminer la Session';

  @override
  String get ussdSessionEnded => 'Session USSD terminée.';

  @override
  String get enterPhoneNumber => 'Entrez le numéro de téléphone';

  @override
  String get enterServiceCode => 'Entrez le code de service comme *123#';

  @override
  String get enterNetworkCode => 'Entrez le code réseau';

  @override
  String get startSession => 'Démarrer la Session';

  @override
  String get sessionStarted => 'Session démarrée';

  @override
  String get sessionEnded => 'Session terminée';

  @override
  String get networkError => 'Échec de la connexion réseau. Veuillez vérifier votre connexion internet.';

  @override
  String get invalidPhoneNumber => 'Format de numéro de téléphone invalide';

  @override
  String get sessionTimeout => 'Session expirée';

  @override
  String get phoneNumberHint => 'Entrez un numéro de téléphone comme +1234567890';

  @override
  String get serviceCodeHint => 'Entrez un code de service comme *123#';

  @override
  String get networkCodeHint => 'Entrez un code réseau comme MTN';

  @override
  String get sessionDetails => 'Détails de la Session';

  @override
  String get language => 'Langue';

  @override
  String get selectLanguage => 'Sélectionner la Langue';

  @override
  String languageChangedTo(String languageName) {
    return 'Langue changée en $languageName';
  }

  @override
  String get english => 'Anglais';

  @override
  String get swahili => 'Swahili';

  @override
  String get french => 'Français';

  @override
  String get amharic => 'Amharique';

  @override
  String get hausa => 'Haoussa';

  @override
  String get arabic => 'Arabe';

  @override
  String get noActiveSession => 'Aucune session active';

  @override
  String get startNewSessionPrompt => 'Démarrez une nouvelle session USSD pour voir la conversation';
}