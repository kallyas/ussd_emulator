import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/ussd_provider.dart';
import '../providers/accessibility_provider.dart';
import '../utils/design_system.dart';
import '../utils/page_transitions.dart';
import 'ussd_session_screen.dart';
import 'endpoint_config_screen.dart';
import 'session_history_screen.dart';
import 'accessibility_settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  int _selectedIndex = 0;
  late AnimationController _navigationController;
  late AnimationController _fabController;
  late Animation<double> _navigationAnimation;
  late Animation<double> _fabAnimation;

  @override
  void initState() {
    super.initState();
    
    // Initialize animation controllers
    _navigationController = AnimationController(
      duration: UssdDesignSystem.animationMedium,
      vsync: this,
    );
    _fabController = AnimationController(
      duration: UssdDesignSystem.animationMedium,
      vsync: this,
    );
    
    _navigationAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _navigationController,
        curve: UssdDesignSystem.curveDefault,
      ),
    );
    
    _fabAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fabController,
        curve: Curves.elasticOut,
      ),
    );
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UssdProvider>().init();
      context.read<AccessibilityProvider>().init();
      _navigationController.forward();
      Future.delayed(UssdDesignSystem.animationMedium, () {
        _fabController.forward();
      });
    });
  }

  @override
  void dispose() {
    _navigationController.dispose();
    _fabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<UssdProvider>();

    if (!provider.isInitialized) {
      return Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).colorScheme.primaryContainer,
                Theme.of(context).colorScheme.surface,
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(UssdDesignSystem.spacingL),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    shape: BoxShape.circle,
                    boxShadow: UssdDesignSystem.getShadow(
                      UssdDesignSystem.elevationLevel3,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  child: Icon(
                    Icons.phone_in_talk_rounded,
                    size: 48,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                )
                .animate(onPlay: (controller) => controller.repeat())
                .scale(
                  begin: const Offset(1.0, 1.0),
                  end: const Offset(1.1, 1.1),
                  duration: const Duration(milliseconds: 1000),
                  curve: Curves.easeInOut,
                )
                .then()
                .scale(
                  begin: const Offset(1.1, 1.1),
                  end: const Offset(1.0, 1.0),
                  duration: const Duration(milliseconds: 1000),
                  curve: Curves.easeInOut,
                ),
                const SizedBox(height: UssdDesignSystem.spacingL),
                Text(
                  'USSD Emulator',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                )
                .animate()
                .fadeIn(delay: const Duration(milliseconds: 300))
                .slideY(begin: 0.3, end: 0.0),
                const SizedBox(height: UssdDesignSystem.spacingM),
                Text(
                  'Initializing...',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                )
                .animate()
                .fadeIn(delay: const Duration(milliseconds: 500))
                .slideY(begin: 0.3, end: 0.0),
                const SizedBox(height: UssdDesignSystem.spacingXL),
                SizedBox(
                  width: 200,
                  child: LinearProgressIndicator(
                    backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).colorScheme.primary,
                    ),
                  ),
                )
                .animate()
                .fadeIn(delay: const Duration(milliseconds: 700))
                .slideY(begin: 0.3, end: 0.0),
              ],
            ),
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
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: UssdDesignSystem.borderRadiusSmall,
                ),
                child: Icon(
                  Icons.phone_in_talk_rounded,
                  size: 20,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
              const SizedBox(width: UssdDesignSystem.spacingS),
              const Text('USSD Emulator'),
            ],
          ),
        )
        .animate()
        .fadeIn(delay: const Duration(milliseconds: 200))
        .slideX(begin: -0.3, end: 0.0),
        actions: [
          Semantics(
            label: 'Open accessibility settings',
            hint: 'Configure accessibility options',
            child: ScaleTransition(
              scale: _fabAnimation,
              child: Container(
                margin: const EdgeInsets.only(right: UssdDesignSystem.spacingS),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondaryContainer,
                  borderRadius: UssdDesignSystem.borderRadiusSmall,
                  boxShadow: UssdDesignSystem.getShadow(UssdDesignSystem.elevationLevel1),
                ),
                child: IconButton(
                  icon: const Icon(Icons.accessibility_rounded),
                  onPressed: () {
                    final accessibilityProvider = context.read<AccessibilityProvider>();
                    accessibilityProvider.hapticFeedback();
                    Navigator.push(
                      context,
                      PageTransitions.slideFromRight(const AccessibilitySettingsScreen()),
                    );
                  },
                  tooltip: 'Accessibility Settings',
                  color: Theme.of(context).colorScheme.onSecondaryContainer,
                ),
              ),
            ),
          ),
        ],
      ),
      body: AnimatedSwitcher(
        duration: UssdDesignSystem.animationMedium,
        transitionBuilder: (Widget child, Animation<double> animation) {
          return SlideTransition(
            position: animation.drive(
              Tween(
                begin: const Offset(0.3, 0.0),
                end: Offset.zero,
              ).chain(CurveTween(curve: UssdDesignSystem.curveDefault)),
            ),
            child: FadeTransition(
              opacity: animation,
              child: child,
            ),
          );
        },
        child: screens[_selectedIndex],
      ),
      bottomNavigationBar: SlideTransition(
        position: _navigationAnimation.drive(
          Tween(
            begin: const Offset(0.0, 1.0),
            end: Offset.zero,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            boxShadow: UssdDesignSystem.getShadow(UssdDesignSystem.elevationLevel3),
          ),
          child: Semantics(
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
                String screenName = [
                  'USSD Session',
                  'Configuration',
                  'Session History',
                ][index];
                accessibilityProvider.announceForScreenReader(
                  'Navigated to $screenName screen',
                );
              },
              type: BottomNavigationBarType.fixed,
              backgroundColor: Theme.of(context).colorScheme.surface,
              selectedItemColor: Theme.of(context).colorScheme.primary,
              unselectedItemColor: Theme.of(context).colorScheme.onSurfaceVariant,
              elevation: 0, // Using custom shadow instead
              items: [
                BottomNavigationBarItem(
                  icon: _buildNavIcon(Icons.phone_rounded, 0),
                  label: 'USSD',
                  tooltip: 'USSD Session Screen',
                ),
                BottomNavigationBarItem(
                  icon: _buildNavIcon(Icons.settings_rounded, 1),
                  label: 'Config',
                  tooltip: 'Endpoint Configuration',
                ),
                BottomNavigationBarItem(
                  icon: _buildNavIcon(Icons.history_rounded, 2),
                  label: 'History',
                  tooltip: 'Session History',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavIcon(IconData icon, int index) {
    final isSelected = _selectedIndex == index;
    
    return AnimatedContainer(
      duration: UssdDesignSystem.animationFast,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isSelected 
            ? Theme.of(context).colorScheme.primaryContainer
            : Colors.transparent,
        borderRadius: UssdDesignSystem.borderRadiusSmall,
      ),
      child: Icon(
        icon,
        color: isSelected 
            ? Theme.of(context).colorScheme.onPrimaryContainer
            : Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }
}
