import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'providers/ussd_provider.dart';
import 'providers/accessibility_provider.dart';
import 'providers/language_provider.dart';
import 'screens/home_screen.dart';
import 'utils/accessibility_themes.dart';
import 'utils/design_system.dart';
import 'l10n/generated/app_localizations.dart';

void main() {
  runApp(const UssdEmulatorApp());
}

class UssdEmulatorApp extends StatelessWidget {
  const UssdEmulatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => UssdProvider()),
        ChangeNotifierProvider(create: (context) => AccessibilityProvider()),
        ChangeNotifierProvider(create: (context) => LanguageProvider()),
      ],
      child: Consumer2<AccessibilityProvider, LanguageProvider>(
        builder: (context, accessibilityProvider, languageProvider, child) {
          final settings = accessibilityProvider.settings;

          return MaterialApp(
            title: 'USSD Emulator',
            debugShowCheckedModeBanner: false,

            // Localization support
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: languageProvider.currentLocale,
            localeResolutionCallback: (locale, supportedLocales) {
              // Check if the current device locale is supported
              if (locale != null) {
                for (var supportedLocale in supportedLocales) {
                  if (supportedLocale.languageCode == locale.languageCode) {
                    return supportedLocale;
                  }
                }
              }
              // If not supported, return English as default
              return const Locale('en', 'US');
            },

            // Dynamic theme based on accessibility settings

      theme: (!settings.accessibilityEnabled)
        ? UssdDesignSystem.getLightTheme()
        : settings.useHighContrast
          ? AccessibilityThemes.getHighContrastLightTheme()
          : UssdDesignSystem.getLightTheme(),

      darkTheme: (!settings.accessibilityEnabled)
        ? UssdDesignSystem.getDarkTheme()
        : settings.useHighContrast
          ? AccessibilityThemes.getHighContrastDarkTheme()
          : UssdDesignSystem.getDarkTheme(),

            themeMode: ThemeMode.system,

            // Apply text scale factor for accessibility
            builder: (context, child) {
              return Directionality(
                textDirection: languageProvider.textDirection,
                child: MediaQuery(
                  data: MediaQuery.of(
                    context,
                  ).copyWith(textScaleFactor: settings.textScaleFactor),
                  child: child!,
                ),
              );
            },

            home: const HomeScreen(),

            // Accessibility shortcuts
            shortcuts: const {
              // Tab navigation
              SingleActivator(LogicalKeyboardKey.tab): NextFocusIntent(),
              SingleActivator(LogicalKeyboardKey.tab, shift: true):
                  PreviousFocusIntent(),

              // Enter to activate
              SingleActivator(LogicalKeyboardKey.enter): ActivateIntent(),
              SingleActivator(LogicalKeyboardKey.space): ActivateIntent(),
            },
          );
        },
      ),
    );
  }
}
