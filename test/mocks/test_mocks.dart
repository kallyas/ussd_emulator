import 'package:mockito/annotations.dart';
import 'package:ussd_emulator/providers/ussd_provider.dart';
import 'package:ussd_emulator/providers/accessibility_provider.dart';
import 'package:ussd_emulator/providers/language_provider.dart';
import 'package:ussd_emulator/providers/template_provider.dart';
import 'package:ussd_emulator/services/ussd_api_service.dart';
import 'package:ussd_emulator/services/ussd_session_service.dart';
import 'package:ussd_emulator/services/endpoint_config_service.dart';
import 'package:ussd_emulator/services/session_export_service.dart';
import 'package:ussd_emulator/services/template_service.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Generate comprehensive mocks for all services and providers
@GenerateMocks([
  // Providers
  UssdProvider,
  AccessibilityProvider,
  LanguageProvider,
  TemplateProvider,

  // Services
  UssdApiService,
  UssdSessionService,
  EndpointConfigService,
  SessionExportService,
  TemplateService,

  // External dependencies
  Dio,
  SharedPreferences,
])
void main() {
  // This file is used to generate mocks
  // Run: dart run build_runner build
}
