// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Amharic (`am`).
class AppLocalizationsAm extends AppLocalizations {
  AppLocalizationsAm([String locale = 'am']) : super(locale);

  @override
  String get appTitle => 'የUSSD አስመሳይ';

  @override
  String get initializing => 'በመጀመር ላይ...';

  @override
  String get ussd => 'USSD';

  @override
  String get config => 'ማቀናበሪያ';

  @override
  String get history => 'ታሪክ';

  @override
  String get ussdSession => 'የUSSD ክፍለ ጊዜ';

  @override
  String get configuration => 'ማቀናበሪያ';

  @override
  String get sessionHistory => 'የክፍለ ጊዜ ታሪክ';

  @override
  String get openAccessibilitySettings => 'የተደራሽነት ቅንብሮችን ክፈት';

  @override
  String get configureAccessibilityOptions => 'የተደራሽነት አማራጮችን አስተካክል';

  @override
  String get accessibilitySettings => 'የተደራሽነት ቅንጅቶች';

  @override
  String get ussdSessionScreenTooltip => 'የUSSD ክፍለ ጊዜ ማያ ገጽ';

  @override
  String get endpointConfigurationTooltip => 'የመጨረሻ ነጥብ ማቀናበሪያ';

  @override
  String get sessionHistoryTooltip => 'የክፍለ ጊዜ ታሪክ';

  @override
  String navigatedToScreen(String screenName) {
    return 'ወደ $screenName ማያ ገጽ ተንቀሳቅሷል';
  }

  @override
  String get error => 'ስህተት';

  @override
  String get dismissError => 'ስህተቱን አስወግድ';

  @override
  String get connected => 'ተገናኝቷል';

  @override
  String get endSession => 'ክፍለ ጊዜን አቁም';

  @override
  String get ussdSessionEnded => 'የUSSD ክፍለ ጊዜ ተጠናቋል።';

  @override
  String get enterPhoneNumber => 'የስልክ ቁጥር አስገባ';

  @override
  String get enterServiceCode => 'እንደ *123# ያለ የአገልግሎት ኮድ አስገባ';

  @override
  String get enterNetworkCode => 'የአውታረ መረብ ኮድ አስገባ';

  @override
  String get startSession => 'ክፍለ ጊዜ ጀምር';

  @override
  String get sessionStarted => 'ክፍለ ጊዜ ተጀምሯል';

  @override
  String get sessionEnded => 'ክፍለ ጊዜ ተጠናቋል';

  @override
  String get networkError =>
      'የአውታረ መረብ ግንኙነት ተሳክቶ አልተሳካም። እባክዎ የኢንተርኔት ግንኙነትዎን ይፈትሹ።';

  @override
  String get invalidPhoneNumber => 'ልክ ያልሆነ የስልክ ቁጥር አቀራረብ';

  @override
  String get sessionTimeout => 'ክፍለ ጊዜ ጊዜው አልፏል';

  @override
  String get phoneNumberHint => 'እንደ +1234567890 ያለ የስልክ ቁጥር አስገባ';

  @override
  String get serviceCodeHint => 'እንደ *123# ያለ የአገልግሎት ኮድ አስገባ';

  @override
  String get networkCodeHint => 'እንደ MTN ያለ የአውታረ መረብ ኮድ አስገባ';

  @override
  String get sessionDetails => 'የክፍለ ጊዜ ዝርዝሮች';

  @override
  String get language => 'ቋንቋ';

  @override
  String get selectLanguage => 'ቋንቋ ምረጥ';

  @override
  String languageChangedTo(String languageName) {
    return 'ቋንቋ ወደ $languageName ተቀይሯል';
  }

  @override
  String get english => 'እንግሊዝኛ';

  @override
  String get swahili => 'ስዋሂሊ';

  @override
  String get french => 'ፈረንሳይኛ';

  @override
  String get amharic => 'አማርኛ';

  @override
  String get hausa => 'ሃውሳ';

  @override
  String get arabic => 'ዓረብኛ';

  @override
  String get noActiveSession => 'ንቁ ክፍለ ጊዜ የለም';

  @override
  String get startNewSessionPrompt => 'ውይይቱን ለማየት አዲስ የUSSD ክፍለ ጊዜ ጀምር';

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
