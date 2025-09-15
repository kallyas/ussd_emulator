// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'محاكي USSD';

  @override
  String get initializing => 'جاري التهيئة...';

  @override
  String get ussd => 'USSD';

  @override
  String get config => 'الإعدادات';

  @override
  String get history => 'التاريخ';

  @override
  String get ussdSession => 'جلسة USSD';

  @override
  String get configuration => 'التكوين';

  @override
  String get sessionHistory => 'تاريخ الجلسات';

  @override
  String get openAccessibilitySettings => 'فتح إعدادات إمكانية الوصول';

  @override
  String get configureAccessibilityOptions => 'تكوين خيارات إمكانية الوصول';

  @override
  String get accessibilitySettings => 'إعدادات إمكانية الوصول';

  @override
  String get ussdSessionScreenTooltip => 'شاشة جلسة USSD';

  @override
  String get endpointConfigurationTooltip => 'تكوين نقطة النهاية';

  @override
  String get sessionHistoryTooltip => 'تاريخ الجلسات';

  @override
  String navigatedToScreen(String screenName) {
    return 'تم الانتقال إلى شاشة $screenName';
  }

  @override
  String get error => 'خطأ';

  @override
  String get dismissError => 'إغلاق الخطأ';

  @override
  String get connected => 'متصل';

  @override
  String get endSession => 'إنهاء الجلسة';

  @override
  String get ussdSessionEnded => 'انتهت جلسة USSD.';

  @override
  String get enterPhoneNumber => 'أدخل رقم الهاتف';

  @override
  String get enterServiceCode => 'أدخل رمز الخدمة مثل *123#';

  @override
  String get enterNetworkCode => 'أدخل رمز الشبكة';

  @override
  String get startSession => 'بدء الجلسة';

  @override
  String get sessionStarted => 'بدأت الجلسة';

  @override
  String get sessionEnded => 'انتهت الجلسة';

  @override
  String get networkError =>
      'فشل الاتصال بالشبكة. يرجى التحقق من اتصال الإنترنت.';

  @override
  String get invalidPhoneNumber => 'تنسيق رقم الهاتف غير صالح';

  @override
  String get sessionTimeout => 'انتهت مهلة الجلسة';

  @override
  String get phoneNumberHint => 'أدخل رقم الهاتف مثل +1234567890';

  @override
  String get serviceCodeHint => 'أدخل رمز الخدمة مثل *123#';

  @override
  String get networkCodeHint => 'أدخل رمز الشبكة مثل MTN';

  @override
  String get sessionDetails => 'تفاصيل الجلسة';

  @override
  String get language => 'اللغة';

  @override
  String get selectLanguage => 'اختر اللغة';

  @override
  String languageChangedTo(String languageName) {
    return 'تم تغيير اللغة إلى $languageName';
  }

  @override
  String get english => 'الإنجليزية';

  @override
  String get swahili => 'السواحيلية';

  @override
  String get french => 'الفرنسية';

  @override
  String get amharic => 'الأمهرية';

  @override
  String get hausa => 'الهوسا';

  @override
  String get arabic => 'العربية';

  @override
  String get noActiveSession => 'لا توجد جلسة نشطة';

  @override
  String get startNewSessionPrompt => 'ابدأ جلسة USSD جديدة لرؤية المحادثة';

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
