// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

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
  String get accessibilitySettings => 'Mipangilio ya Ufikishaji';

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
  String get networkError =>
      'Muunganisho wa mtandao umeshindwa. Tafadhali kagua muunganisho wako wa intaneti.';

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

  @override
  String get noActiveSession => 'Hakuna kipindi kilichoanza';

  @override
  String get startNewSessionPrompt =>
      'Anza kipindi kipya cha USSD kuona mazungumzo';

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
