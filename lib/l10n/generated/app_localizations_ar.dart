import 'app_localizations.dart';

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
  String get networkError => 'فشل الاتصال بالشبكة. يرجى التحقق من اتصال الإنترنت.';

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
}