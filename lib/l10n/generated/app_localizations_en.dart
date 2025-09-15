// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

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
  String get accessibilitySettings => 'Accessibility Settings';

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
  String get networkError =>
      'Network connection failed. Please check your internet connection.';

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

  @override
  String get noActiveSession => 'No active session';

  @override
  String get startNewSessionPrompt =>
      'Start a new USSD session to see conversation';

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
