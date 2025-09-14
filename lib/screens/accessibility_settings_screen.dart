import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/accessibility_provider.dart';
import '../providers/language_provider.dart';
import '../l10n/generated/app_localizations.dart';

class AccessibilitySettingsScreen extends StatefulWidget {
  const AccessibilitySettingsScreen({super.key});

  @override
  State<AccessibilitySettingsScreen> createState() =>
      _AccessibilitySettingsScreenState();
}

class _AccessibilitySettingsScreenState
    extends State<AccessibilitySettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.accessibilitySettings),
        backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
        elevation: 0,
      ),
      body: Consumer2<AccessibilityProvider, LanguageProvider>(
        builder: (context, accessibilityProvider, languageProvider, child) {
          if (!accessibilityProvider.isInitialized) {
            return const Center(child: CircularProgressIndicator());
          }
          final settings = accessibilityProvider.settings;
          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            children: [
              _buildSectionHeader('General'),
              _buildAccessibleCard([
                _buildSwitchTile(
                  title: 'Enable Accessibility',
                  subtitle: 'Master switch for all accessibility features',
                  icon: Icons.accessibility_new,
                  value: settings.accessibilityEnabled,
                  onChanged: (value) =>
                      accessibilityProvider.toggleAccessibilityEnabled(),
                ),
              ]),
              const SizedBox(height: 28),
              _buildSectionHeader(l10n.language),
              _buildAccessibleCard([
                _buildLanguageSelector(context, languageProvider, l10n),
              ]),
              const SizedBox(height: 28),
              _buildSectionHeader('Visual'),
              _buildAccessibleCard([
                _buildSwitchTile(
                  title: 'High Contrast',
                  subtitle: 'Increase color contrast for better visibility',
                  icon: Icons.contrast,
                  value: settings.useHighContrast,
                  onChanged: (value) =>
                      accessibilityProvider.toggleHighContrast(),
                ),
                const Divider(height: 1),
                _buildSliderTile(
                  title: 'Text Size',
                  subtitle: 'Adjust app-wide text size',
                  icon: Icons.text_fields,
                  value: settings.textScaleFactor,
                  min: 0.8,
                  max: 2.0,
                  divisions: 12,
                  onChanged: (value) =>
                      accessibilityProvider.setTextScaleFactor(value),
                  valueLabel: '${(settings.textScaleFactor * 100).round()}%',
                ),
              ]),
              const SizedBox(height: 28),
              _buildSectionHeader('Audio'),
              _buildAccessibleCard([
                _buildSwitchTile(
                  title: 'Text-to-Speech',
                  subtitle: 'Read USSD responses aloud',
                  icon: Icons.record_voice_over,
                  value: settings.enableTextToSpeech,
                  onChanged: (value) =>
                      accessibilityProvider.toggleTextToSpeech(),
                ),
                const Divider(height: 1),
                _buildSwitchTile(
                  title: 'Voice Input',
                  subtitle: 'Use your voice to enter USSD commands',
                  icon: Icons.mic,
                  value: settings.enableVoiceInput,
                  onChanged: (value) =>
                      accessibilityProvider.toggleVoiceInput(),
                ),
              ]),
              const SizedBox(height: 28),
              _buildSectionHeader('Motor'),
              _buildAccessibleCard([
                _buildSwitchTile(
                  title: 'Haptic Feedback',
                  subtitle: 'Vibration feedback for actions',
                  icon: Icons.vibration,
                  value: settings.enableHapticFeedback,
                  onChanged: (value) =>
                      accessibilityProvider.toggleHapticFeedback(),
                ),
                const Divider(height: 1),
                _buildSliderTile(
                  title: 'Input Timeout',
                  subtitle: 'How long before input times out',
                  icon: Icons.timer,
                  value: settings.inputTimeout.inSeconds.toDouble(),
                  min: 10,
                  max: 120,
                  divisions: 11,
                  onChanged: (value) => accessibilityProvider.setInputTimeout(
                    Duration(seconds: value.round()),
                  ),
                  valueLabel: '${settings.inputTimeout.inSeconds}s',
                ),
              ]),
              const SizedBox(height: 28),
              _buildSectionHeader('Navigation & Screen Reader'),
              _buildAccessibleCard([
                ListTile(
                  leading: const Icon(Icons.keyboard),
                  title: const Text('Keyboard Navigation'),
                  subtitle: const Text('Tab, Enter, and arrow keys supported'),
                  trailing: Icon(
                    Icons.check_circle,
                    color: settings.enableKeyboardNavigation
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.outline,
                  ),
                  minVerticalPadding: 18,
                  visualDensity: VisualDensity.compact,
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.accessibility),
                  title: const Text('Screen Reader'),
                  subtitle: const Text('Enhanced screen reader support'),
                  trailing: Icon(
                    Icons.check_circle,
                    color: settings.enableLiveRegions
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.outline,
                  ),
                  minVerticalPadding: 18,
                  visualDensity: VisualDensity.compact,
                ),
              ]),
              const SizedBox(height: 28),
              _buildSectionHeader('Test Accessibility'),
              _buildAccessibleCard([
                ListTile(
                  leading: const Icon(Icons.hearing),
                  title: const Text('Test Text-to-Speech'),
                  subtitle: const Text('Hear how responses will sound'),
                  onTap: () => _testTextToSpeech(accessibilityProvider),
                  minVerticalPadding: 18,
                  visualDensity: VisualDensity.compact,
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.mic_none),
                  title: const Text('Test Voice Input'),
                  subtitle: const Text('Try voice recognition'),
                  onTap: () => _testVoiceInput(accessibilityProvider),
                  minVerticalPadding: 18,
                  visualDensity: VisualDensity.compact,
                ),
              ]),
              const SizedBox(height: 36),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.primaryContainer.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Accessibility Information',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'This app supports WCAG 2.1 AA accessibility guidelines. All interactive elements have minimum 44pt touch targets and proper semantic labels.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildAccessibleCard(List<Widget> children) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(children: children),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Semantics(
      label: '$title. $subtitle. ${value ? 'Enabled' : 'Disabled'}',
      hint: 'Double tap to ${value ? 'disable' : 'enable'}',
      child: SwitchListTile(
        secondary: Icon(icon),
        title: Text(title),
        subtitle: Text(subtitle),
        value: value,
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildSliderTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required ValueChanged<double> onChanged,
    required String valueLabel,
  }) {
    return Semantics(
      label: '$title. $subtitle. Current value: $valueLabel',
      hint: 'Use slider to adjust value',
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(subtitle),
            const SizedBox(height: 8),
            Slider(
              value: value,
              min: min,
              max: max,
              divisions: divisions,
              label: valueLabel,
              onChanged: onChanged,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _testTextToSpeech(AccessibilityProvider provider) async {
    const testText =
        "This is a test of the text-to-speech feature. "
        "USSD responses will be read aloud like this.";

    provider.hapticFeedback();
    await provider.speak(testText);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Playing text-to-speech test'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _testVoiceInput(AccessibilityProvider provider) async {
    if (!provider.settings.enableVoiceInput) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enable voice input first'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    provider.hapticFeedback();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Listening... Say something to test voice input'),
        duration: Duration(seconds: 5),
      ),
    );

    final result = await provider.startVoiceInput();

    if (mounted) {
      if (result != null && result.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('You said: "$result"'),
            duration: const Duration(seconds: 3),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No speech detected. Please try again.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Widget _buildLanguageSelector(
    BuildContext context,
    LanguageProvider languageProvider,
    AppLocalizations l10n,
  ) {
    return ListTile(
      leading: Icon(Icons.language),
      title: Text(l10n.language),
      subtitle: Text(
        languageProvider.getLanguageName(
          languageProvider.currentLocale.languageCode,
        ),
      ),
      trailing: Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () => _showLanguageDialog(context, languageProvider, l10n),
      minVerticalPadding: 18,
      visualDensity: VisualDensity.compact,
    );
  }

  Future<void> _showLanguageDialog(
    BuildContext context,
    LanguageProvider languageProvider,
    AppLocalizations l10n,
  ) async {
    final localesWithNames = languageProvider.getSupportedLocalesWithNames();

    await showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(l10n.selectLanguage),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: localesWithNames.entries.map((entry) {
              final locale = entry.key;
              final name = entry.value;

              return ListTile(
                title: Text(name),
                leading: Radio<String>(
                  value: locale.languageCode,
                  groupValue: languageProvider.currentLocale.languageCode,
                  onChanged: (String? value) async {
                    if (value != null) {
                      await languageProvider.setLocale(locale);
                      if (context.mounted) {
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(l10n.languageChangedTo(name))),
                        );
                      }
                    }
                  },
                ),
                onTap: () async {
                  await languageProvider.setLocale(locale);
                  if (context.mounted) {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.languageChangedTo(name))),
                    );
                  }
                },
              );
            }).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }
}
