import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'providers/ussd_provider.dart';
import 'providers/accessibility_provider.dart';
import 'screens/home_screen.dart';
import 'utils/accessibility_themes.dart';
import 'utils/design_system.dart';

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
      ],
      child: Consumer<AccessibilityProvider>(
        builder: (context, accessibilityProvider, child) {
          final settings = accessibilityProvider.settings;

          return MaterialApp(
            title: 'USSD Emulator',
            debugShowCheckedModeBanner: false,

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
              return MediaQuery(
                data: MediaQuery.of(
                  context,
                ).copyWith(textScaleFactor: settings.textScaleFactor),
                child: child!,
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
