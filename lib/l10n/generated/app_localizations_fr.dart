// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

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
  String get openAccessibilitySettings =>
      'Ouvrir les paramètres d\'accessibilité';

  @override
  String get configureAccessibilityOptions =>
      'Configurer les options d\'accessibilité';

  @override
  String get accessibilitySettings => 'Paramètres d\'accessibilité';

  @override
  String get ussdSessionScreenTooltip => 'Écran de Session USSD';

  @override
  String get endpointConfigurationTooltip =>
      'Configuration du Point de Terminaison';

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
  String get networkError =>
      'Échec de la connexion réseau. Veuillez vérifier votre connexion internet.';

  @override
  String get invalidPhoneNumber => 'Format de numéro de téléphone invalide';

  @override
  String get sessionTimeout => 'Session expirée';

  @override
  String get phoneNumberHint =>
      'Entrez un numéro de téléphone comme +1234567890';

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
  String get startNewSessionPrompt =>
      'Démarrez une nouvelle session USSD pour voir la conversation';

  @override
  String get templates => 'Templates';

  @override
  String get templateLibrary => 'Template Library';

  @override
  String get templateLibraryTooltip => 'Manage USSD templates';

  @override
  String get manageUssdTemplates => 'Manage and execute USSD templates';

  @override
  String get createTemplate => 'Create Template';

  @override
  String get createNewTemplate => 'Create a new USSD template';

  @override
  String get totalTemplates => 'Total Templates';

  @override
  String get categories => 'Categories';

  @override
  String get searchTemplates => 'Search templates...';

  @override
  String get allCategories => 'All Categories';

  @override
  String get noTemplatesFound => 'No templates found';

  @override
  String get noTemplatesYet => 'No templates yet';

  @override
  String get tryDifferentSearch => 'Try a different search or filter';

  @override
  String get createFirstTemplate => 'Create your first template to get started';

  @override
  String stepCount(int count) {
    return '$count steps';
  }

  @override
  String get executeTemplate => 'Execute Template';

  @override
  String get moreActions => 'More actions';

  @override
  String get editTemplate => 'Edit Template';

  @override
  String get duplicateTemplate => 'Duplicate Template';

  @override
  String get exportTemplate => 'Export Template';

  @override
  String get deleteTemplate => 'Delete Template';

  @override
  String confirmDeleteTemplate(String name) {
    return 'Are you sure you want to delete \'$name\'?';
  }

  @override
  String get templateDetails => 'Template Details';

  @override
  String get templateName => 'Template Name';

  @override
  String get enterTemplateName => 'Enter template name';

  @override
  String get templateNameRequired => 'Template name is required';

  @override
  String get enterTemplateDescription => 'Enter template description';

  @override
  String get descriptionRequired => 'Description is required';

  @override
  String get serviceCode => 'Service Code';

  @override
  String get serviceCodeRequired => 'Service code is required';

  @override
  String get category => 'Category';

  @override
  String get enterCategory => 'Enter category (optional)';

  @override
  String get templateSteps => 'Template Steps';

  @override
  String get addStep => 'Add Step';

  @override
  String get templateBuilderComingSoon => 'Template Builder Coming Soon';

  @override
  String get templateBuilderDescription =>
      'The full template builder with step editor, variables, and validation will be available in the next update.';

  @override
  String get templateExecutionComingSoon => 'Template Execution Coming Soon';

  @override
  String get templateExecutionDescription =>
      'Real-time template execution with step-by-step feedback and automation will be available in the next update.';

  @override
  String get featureComingSoon => 'This feature is coming soon!';
}
