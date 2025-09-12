import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/ussd_provider.dart';
import '../utils/design_system.dart';
import '../widgets/modern_input_field.dart';

class UssdSessionForm extends StatefulWidget {
  const UssdSessionForm({super.key});

  @override
  State<UssdSessionForm> createState() => _UssdSessionFormState();
}

class _UssdSessionFormState extends State<UssdSessionForm> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController(text: '+1234567890');
  final _serviceCodeController = TextEditingController(text: '*123#');
  final _networkCodeController = TextEditingController(text: 'MTN');

  @override
  void dispose() {
    _phoneController.dispose();
    _serviceCodeController.dispose();
    _networkCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<UssdProvider>();
    final colorScheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(UssdDesignSystem.spacingM),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header with icon and title
            Container(
              padding: const EdgeInsets.all(UssdDesignSystem.spacingXL),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    colorScheme.primaryContainer,
                    colorScheme.primaryContainer.withOpacity(0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: UssdDesignSystem.borderRadiusLarge,
                boxShadow: UssdDesignSystem.getShadow(UssdDesignSystem.elevationLevel2),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(UssdDesignSystem.spacingM),
                    decoration: BoxDecoration(
                      color: colorScheme.primary,
                      shape: BoxShape.circle,
                      boxShadow: UssdDesignSystem.getShadow(
                        UssdDesignSystem.elevationLevel3,
                        color: colorScheme.primary,
                      ),
                    ),
                    child: Icon(
                      Icons.phone_in_talk_rounded,
                      size: 48,
                      color: colorScheme.onPrimary,
                    ),
                  )
                  .animate()
                  .scale(
                    begin: const Offset(0.0, 0.0),
                    end: const Offset(1.0, 1.0),
                    duration: UssdDesignSystem.animationMedium,
                    curve: Curves.elasticOut,
                  ),
                  const SizedBox(height: UssdDesignSystem.spacingM),
                  Text(
                    'Start New USSD Session',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                  .animate(delay: const Duration(milliseconds: 200))
                  .fadeIn(duration: UssdDesignSystem.animationMedium)
                  .slideY(begin: 0.3, end: 0.0),
                  const SizedBox(height: UssdDesignSystem.spacingS),
                  Text(
                    'Enter your details to connect to USSD service',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onPrimaryContainer.withOpacity(0.8),
                    ),
                    textAlign: TextAlign.center,
                  )
                  .animate(delay: const Duration(milliseconds: 300))
                  .fadeIn(duration: UssdDesignSystem.animationMedium)
                  .slideY(begin: 0.3, end: 0.0),
                ],
              ),
            )
            .animate()
            .slideY(
              begin: -0.5,
              end: 0.0,
              duration: UssdDesignSystem.animationMedium,
              curve: UssdDesignSystem.curveDefault,
            ),
            
            const SizedBox(height: UssdDesignSystem.spacingXL),
            
            // Form fields
            Container(
              padding: const EdgeInsets.all(UssdDesignSystem.spacingL),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: UssdDesignSystem.borderRadiusLarge,
                boxShadow: UssdDesignSystem.getShadow(UssdDesignSystem.elevationLevel1),
              ),
              child: Column(
                children: [
                  ModernTextField(
                    controller: _phoneController,
                    label: 'Phone Number',
                    hint: '+1234567890',
                    keyboardType: TextInputType.phone,
                    suffixIcon: Icon(
                      Icons.phone_rounded,
                      color: colorScheme.primary,
                    ),
                  )
                  .animate(delay: const Duration(milliseconds: 400))
                  .slideX(begin: -1.0, end: 0.0)
                  .fadeIn(),
                  
                  const SizedBox(height: UssdDesignSystem.spacingL),
                  
                  ModernTextField(
                    controller: _serviceCodeController,
                    label: 'Service Code',
                    hint: '*123#',
                    suffixIcon: Icon(
                      Icons.dialpad_rounded,
                      color: colorScheme.primary,
                    ),
                  )
                  .animate(delay: const Duration(milliseconds: 500))
                  .slideX(begin: -1.0, end: 0.0)
                  .fadeIn(),
                  
                  const SizedBox(height: UssdDesignSystem.spacingL),
                  
                  ModernTextField(
                    controller: _networkCodeController,
                    label: 'Network Code (Optional)',
                    hint: 'MTN, GLO, etc.',
                    suffixIcon: Icon(
                      Icons.cell_tower_rounded,
                      color: colorScheme.primary,
                    ),
                  )
                  .animate(delay: const Duration(milliseconds: 600))
                  .slideX(begin: -1.0, end: 0.0)
                  .fadeIn(),
                ],
              ),
            ),
            
            const SizedBox(height: UssdDesignSystem.spacingXL),
            
            // Start session button
            PulseButton(
              onPressed: provider.isLoading ? null : _startSession,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: UssdDesignSystem.spacingM,
                ),
                decoration: BoxDecoration(
                  gradient: provider.isLoading 
                      ? null 
                      : UssdDesignSystem.getPrimaryGradient(colorScheme),
                  color: provider.isLoading 
                      ? colorScheme.onSurface.withOpacity(0.12) 
                      : null,
                  borderRadius: UssdDesignSystem.borderRadiusMedium,
                  boxShadow: provider.isLoading 
                      ? null 
                      : UssdDesignSystem.getShadow(
                          UssdDesignSystem.elevationLevel3,
                          color: colorScheme.primary,
                        ),
                ),
                child: provider.isLoading
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                colorScheme.primary,
                              ),
                            ),
                          ),
                          const SizedBox(width: UssdDesignSystem.spacingS),
                          Text(
                            'Starting Session...',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: colorScheme.onSurface.withOpacity(0.6),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.rocket_launch_rounded,
                            color: colorScheme.onPrimary,
                          ),
                          const SizedBox(width: UssdDesignSystem.spacingS),
                          Text(
                            'Start USSD Session',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: colorScheme.onPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
              ),
            )
            .animate(delay: const Duration(milliseconds: 700))
            .slideY(begin: 1.0, end: 0.0)
            .fadeIn(),
            
            const SizedBox(height: UssdDesignSystem.spacingXL),
            
            // Quick actions
            Container(
              padding: const EdgeInsets.all(UssdDesignSystem.spacingL),
              decoration: BoxDecoration(
                color: colorScheme.surfaceVariant,
                borderRadius: UssdDesignSystem.borderRadiusLarge,
                border: Border.all(
                  color: colorScheme.outline.withOpacity(0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.flash_on_rounded,
                        color: colorScheme.primary,
                        size: 20,
                      ),
                      const SizedBox(width: UssdDesignSystem.spacingS),
                      Text(
                        'Quick Actions',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: UssdDesignSystem.spacingM),
                  Wrap(
                    spacing: UssdDesignSystem.spacingS,
                    runSpacing: UssdDesignSystem.spacingS,
                    children: [
                      _buildQuickActionChip('*123#', colorScheme),
                      _buildQuickActionChip('*555#', colorScheme),
                      _buildQuickActionChip('*777#', colorScheme),
                      _buildQuickActionChip('*999#', colorScheme),
                    ],
                  ),
                ],
              ),
            )
            .animate(delay: const Duration(milliseconds: 800))
            .slideY(begin: 1.0, end: 0.0)
            .fadeIn(),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionChip(String code, ColorScheme colorScheme) {
    return PulseButton(
      onPressed: () {
        _serviceCodeController.text = code;
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: UssdDesignSystem.spacingM,
          vertical: UssdDesignSystem.spacingS,
        ),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: UssdDesignSystem.borderRadiusSmall,
          border: Border.all(
            color: colorScheme.outline.withOpacity(0.3),
          ),
          boxShadow: UssdDesignSystem.getShadow(UssdDesignSystem.elevationLevel1),
        ),
        child: Text(
          code,
          style: TextStyle(
            color: colorScheme.primary,
            fontWeight: FontWeight.w600,
            fontFamily: 'monospace',
          ),
        ),
      ),
    );
  }

  void _startSession() {
    // Basic validation
    if (_phoneController.text.isEmpty || _serviceCodeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please fill in all required fields'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    final provider = context.read<UssdProvider>();
    provider.startSession(
      phoneNumber: _phoneController.text,
      serviceCode: _serviceCodeController.text,
      networkCode: _networkCodeController.text.isNotEmpty
          ? _networkCodeController.text
          : null,
    );
  }
}
