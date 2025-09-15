// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

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
  String get accessibilitySettings => 'Saitunan Samun Dama';

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
  String get networkError =>
      'Haɗin cibiyar sadarwa ya kasa. Da fatan za a duba haɗin intanet ɗinku.';

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

  @override
  String get noActiveSession => 'Babu zama mai aiki';

  @override
  String get startNewSessionPrompt =>
      'Fara sabon zama USSD don ganin tattaunawa';

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
