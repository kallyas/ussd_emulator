import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/ussd_provider.dart';
import '../providers/accessibility_provider.dart';
import 'ussd_session_screen.dart';
import 'endpoint_config_screen.dart';
import 'session_history_screen.dart';
import 'accessibility_settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UssdProvider>().init();
      context.read<AccessibilityProvider>().init();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<UssdProvider>();

    if (!provider.isInitialized) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(
                'Initializing USSD Emulator...',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
        ),
      );
    }

    final screens = [
      const UssdSessionScreen(),
      const EndpointConfigScreen(),
      const SessionHistoryScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Semantics(
          label: 'USSD Emulator main screen',
          child: const Text('USSD Emulator'),
        ),
        actions: [
          Semantics(
            label: 'Open accessibility settings',
            hint: 'Configure accessibility options',
            child: IconButton(
              icon: const Icon(Icons.accessibility),
              onPressed: () {
                final accessibilityProvider = context.read<AccessibilityProvider>();
                accessibilityProvider.hapticFeedback();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AccessibilitySettingsScreen(),
                  ),
                );
              },
              tooltip: 'Accessibility Settings',
            ),
          ),
        ],
      ),
      body: screens[_selectedIndex],
      bottomNavigationBar: Semantics(
        label: 'Main navigation with ${screens.length} tabs',
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) {
            final accessibilityProvider = context.read<AccessibilityProvider>();
            accessibilityProvider.hapticFeedback();
            
            setState(() {
              _selectedIndex = index;
            });
            
            // Announce navigation change for screen readers
            String screenName = ['USSD Session', 'Configuration', 'Session History'][index];
            accessibilityProvider.announceForScreenReader('Navigated to $screenName screen');
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.phone),
              label: 'USSD',
              tooltip: 'USSD Session Screen',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: 'Config',
              tooltip: 'Endpoint Configuration',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history),
              label: 'History',
              tooltip: 'Session History',
            ),
          ],
        ),
      ),
    );
  }
}
