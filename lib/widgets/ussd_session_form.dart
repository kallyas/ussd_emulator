import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/ussd_provider.dart';

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

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Start New USSD Session',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _phoneController,
                      decoration: const InputDecoration(
                        labelText: 'Phone Number',
                        prefixIcon: Icon(Icons.phone),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a phone number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _serviceCodeController,
                      decoration: const InputDecoration(
                        labelText: 'Service Code',
                        prefixIcon: Icon(Icons.dialpad),
                        border: OutlineInputBorder(),
                        hintText: '*123#',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a service code';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _networkCodeController,
                      decoration: const InputDecoration(
                        labelText: 'Network Code (Optional)',
                        prefixIcon: Icon(Icons.cell_tower),
                        border: OutlineInputBorder(),
                        hintText: 'MTN, GLO, etc.',
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: provider.isLoading ? null : _startSession,
                        child: provider.isLoading
                            ? const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Text('Starting Session...'),
                                ],
                              )
                            : const Text('Start USSD Session'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Quick Actions',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            _serviceCodeController.text = '*123#';
                          },
                          child: const Text('*123#'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            _serviceCodeController.text = '*555#';
                          },
                          child: const Text('*555#'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            _serviceCodeController.text = '*777#';
                          },
                          child: const Text('*777#'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _startSession() {
    if (_formKey.currentState!.validate()) {
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
}
