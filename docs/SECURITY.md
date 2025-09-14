# Security Enhancement Documentation

This document describes the security enhancements implemented in the USSD Emulator application.

## Overview

The security enhancement adds comprehensive protection against common vulnerabilities including:
- Input validation and sanitization
- Secure data storage with encryption
- Network security with request signing
- Security monitoring and anomaly detection
- Rate limiting and abuse prevention

## New Security Components

### 1. Secure Input Validation (`SecureUssdUtils`)

Enhanced validation utilities that extend the existing `UssdUtils` class:

```dart
import 'package:ussd_emulator/utils/secure_ussd_utils.dart';

// Validate and sanitize USSD input
final sanitizedInput = SecureUssdUtils.sanitizeUssdInput('*123#');

// Validate phone numbers with international format support
final validPhone = SecureUssdUtils.validatePhoneNumber('+256700000000');

// Check for suspicious patterns
final isSuspicious = SecureUssdUtils.containsSuspiciousPatterns('<script>alert("xss")</script>');

// Rate limiting
final isRateLimited = SecureUssdUtils.checkRateLimit(phoneNumber);
```

**Features:**
- Maximum input length enforcement (160 chars for USSD, 15 for phone)
- Dangerous character removal (`<>`, `"`, `&`, control characters)
- Phone number format validation with international support
- USSD code format validation
- Session ID format validation
- Menu selection validation
- Suspicious pattern detection (XSS, SQL injection, script injection)
- In-memory rate limiting (10 requests/minute, 100 requests/hour)

### 2. Secure Storage (`SecureUssdSessionService`)

Encrypted session storage that extends `UssdSessionService`:

```dart
import 'package:ussd_emulator/services/secure_ussd_session_service.dart';

final secureService = SecureUssdSessionService();
await secureService.init();

// All session data is automatically encrypted
final session = await secureService.startSession(
  phoneNumber: '+256700000000',
  serviceCode: '*123#',
);
```

**Features:**
- AES-256 encryption for all session data
- Secure key management with FlutterSecureStorage
- Data integrity verification with HMAC
- Automatic migration from insecure storage
- Secure deletion and cleanup
- Android: Encrypted SharedPreferences with hardware-backed keystore
- iOS: Keychain with biometric protection

### 3. Secure API Service (`SecureUssdApiService`)

Enhanced API service with security features:

```dart
import 'package:ussd_emulator/services/secure_ussd_api_service.dart';

final secureApi = SecureUssdApiService();

// All requests are automatically signed and validated
final response = await secureApi.sendUssdRequest(request, endpoint);
```

**Features:**
- Request signing with HMAC-SHA256
- Security headers (X-Content-Type-Options, X-Frame-Options, etc.)
- Request/response sanitization and validation
- Secure logging with sensitive data filtering
- Rate limiting enforcement
- Timeout and retry handling
- Certificate pinning ready (structure in place)

### 4. Security Monitoring (`SecurityMonitor`)

Comprehensive security event logging and anomaly detection:

```dart
import 'package:ussd_emulator/services/security_monitor.dart';

final monitor = SecurityMonitor();

// Log security events
monitor.logSecurityEvent('user_login', {
  'user_id': 'user123',
  'ip_address': '192.168.1.1',
});

// Detect anomalous activity
monitor.detectAnomalousActivity(ussdRequest);

// Get security statistics
final stats = monitor.getSecurityStats();
```

**Features:**
- Security event logging with severity classification
- Anomaly detection for suspicious patterns
- Rate limiting enforcement
- User activity tracking
- Security statistics and reporting
- Automatic alerts for critical events
- Sensitive data masking in logs

## Integration Example

Use the `SecureUssdProvider` for complete integration:

```dart
import 'package:ussd_emulator/providers/secure_ussd_provider.dart';

final provider = SecureUssdProvider();
await provider.initialize();

// Start secure session
final session = await provider.startSecureSession(
  phoneNumber: '+256700000000',
  serviceCode: '*123#',
);

// Send secure request
final response = await provider.sendSecureRequest('1', endpoint);

// End session
await provider.endSecureSession();

// Monitor security
final stats = provider.getSecurityStats();
final events = provider.getRecentSecurityEvents(minSeverity: SecuritySeverity.medium);
```

## Security Configuration

### Rate Limits
```dart
// Default limits (configurable)
const MAX_REQUESTS_PER_MINUTE = 10;
const MAX_REQUESTS_PER_HOUR = 100;
const SUSPICIOUS_ACTIVITY_THRESHOLD = 5;
```

### Input Limits
```dart
const MAX_INPUT_LENGTH = 160;      // USSD input
const MAX_PHONE_LENGTH = 15;       // Phone numbers
const MAX_USSD_CODE_LENGTH = 20;   // Service codes
const MAX_SESSION_ID_LENGTH = 100; // Session IDs
```

### Storage Configuration
```dart
// Android secure storage options
AndroidOptions(
  encryptedSharedPreferences: true,
  keyCipherAlgorithm: KeyCipherAlgorithm.RSA_ECB_PKCS1Padding,
  storageCipherAlgorithm: StorageCipherAlgorithm.AES_GCM_NoPadding,
)

// iOS secure storage options
IOSOptions(
  accessibility: IOSAccessibility.first_unlock_this_device,
  synchronizable: false,
)
```

## Security Best Practices

### 1. Input Validation
- Always validate and sanitize user input
- Use the secure validation methods for all inputs
- Check for suspicious patterns before processing
- Enforce length limits consistently

### 2. Data Protection
- Use secure storage for all sensitive data
- Never store credentials in plain text
- Implement proper key management
- Enable data integrity verification

### 3. Network Security
- Sign all API requests
- Validate all responses
- Use secure headers
- Filter sensitive data from logs
- Implement certificate pinning in production

### 4. Monitoring
- Log all security events
- Monitor for anomalous activity
- Implement rate limiting
- Review security statistics regularly
- Respond to critical alerts promptly

## Migration Guide

### From Existing UssdUtils
```dart
// Before
final isValid = UssdUtils.isValidPhoneNumber(phone);

// After (enhanced security)
try {
  final validPhone = SecureUssdUtils.validatePhoneNumber(phone);
  // Use validPhone
} catch (ValidationException e) {
  // Handle validation error
  print('Validation failed: ${e.message}');
}
```

### From Existing UssdSessionService
```dart
// Before
final sessionService = UssdSessionService();

// After (encrypted storage)
final secureSessionService = SecureUssdSessionService();
await secureSessionService.init();
// All existing methods work the same but with encryption
```

### From Existing UssdApiService
```dart
// Before
final apiService = UssdApiService();

// After (signed requests)
final secureApiService = SecureUssdApiService();
// All existing methods work the same but with security features
```

## Testing

Security features include comprehensive tests:

```bash
# Run security tests
flutter test test/secure_ussd_utils_test.dart
flutter test test/secure_ussd_api_service_test.dart
flutter test test/security_monitor_test.dart

# Run all tests
flutter test
```

## Dependencies

The security enhancement adds these dependencies:

```yaml
dependencies:
  flutter_secure_storage: ^9.0.0  # Secure encrypted storage
  encrypt: ^5.0.1                 # AES encryption
  crypto: ^3.0.3                  # Cryptographic functions
  dio_certificate_pinning: ^4.1.1 # Certificate pinning
  dio_smart_retry: ^6.0.0         # Smart retry logic
```

## Security Compliance

This implementation addresses:
- OWASP Mobile Top 10 security risks
- Input validation vulnerabilities
- Data storage security
- Network communication security
- Security monitoring and incident response

## Troubleshooting

### Common Issues

**ValidationException: Input too long**
- Check input length limits
- Ensure inputs are within defined bounds

**SecurityException: Rate limit exceeded**
- Implement proper rate limiting handling
- Consider user experience for legitimate users

**Encryption/Decryption errors**
- Ensure secure storage is properly initialized
- Check device compatibility with encryption features

**Network security errors**
- Verify endpoint configuration
- Check certificate pinning settings
- Review security headers compatibility

### Debug Mode

Enable debug logging for security events:

```dart
// Security events are automatically logged to console
// In production, integrate with proper logging service
```

## Production Considerations

1. **Key Management**: Implement proper key rotation and backup
2. **Certificate Pinning**: Configure for production endpoints
3. **Logging**: Integrate with centralized logging system
4. **Monitoring**: Set up alerts for critical security events
5. **Performance**: Monitor encryption/decryption performance
6. **Compliance**: Ensure regulatory compliance for your region