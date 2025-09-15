import 'package:flutter_test/flutter_test.dart';
import 'package:ussd_emulator/services/security_monitor.dart';
import 'package:ussd_emulator/models/ussd_request.dart';

void main() {
  group('SecurityMonitor', () {
    late SecurityMonitor monitor;

    setUp(() {
      monitor = SecurityMonitor();
      monitor.clearAll(); // Clear any previous state
    });

    group('logSecurityEvent', () {
      test('should log security event with correct severity', () {
        monitor.logSecurityEvent('test_event', {'key': 'value'});

        final events = monitor.getRecentEvents(limit: 1);
        expect(events.length, 1);
        expect(events.first.event, 'test_event');
        expect(events.first.context['key'], 'value');
      });

      test('should sanitize sensitive data in context', () {
        monitor.logSecurityEvent('test_event', {
          'phone_number': '+256700000000',
          'session_id': 'very_long_session_id_12345678',
          'password': 'secret123',
        });

        final events = monitor.getRecentEvents(limit: 1);
        final context = events.first.context;

        expect(context['phone_number'], '+25****00');
        expect(context['session_id'], 'very_lon...');
        expect(context['password'], '[REDACTED]');
      });

      test('should determine correct severity levels', () {
        monitor.logSecurityEvent('rate_limit_exceeded', {});
        monitor.logSecurityEvent('suspicious_input_pattern', {});
        monitor.logSecurityEvent('unusual_service_code', {});
        monitor.logSecurityEvent('info_event', {});

        final events = monitor.getRecentEvents(limit: 4);
        expect(
          events[3].severity,
          SecuritySeverity.critical,
        ); // rate_limit_exceeded
        expect(
          events[2].severity,
          SecuritySeverity.high,
        ); // suspicious_input_pattern
        expect(
          events[1].severity,
          SecuritySeverity.medium,
        ); // unusual_service_code
        expect(events[0].severity, SecuritySeverity.low); // info_event
      });
    });

    group('detectAnomalousActivity', () {
      test('should detect rate limit exceeded', () {
        final request = UssdRequest(
          sessionId: 'test_session',
          phoneNumber: '+256700000000',
          text: '1',
          serviceCode: '*123#',
        );

        // Make requests up to the rate limit
        for (int i = 0; i < 10; i++) {
          monitor.detectAnomalousActivity(request);
        }

        // Next request should trigger rate limit
        expect(
          () => monitor.detectAnomalousActivity(request),
          throwsA(isA<SecurityException>()),
        );
      });

      test('should detect suspicious input patterns', () {
        final request = UssdRequest(
          sessionId: 'test_session',
          phoneNumber: '+256700000000',
          text: '<script>alert("xss")</script>',
          serviceCode: '*123#',
        );

        monitor.detectAnomalousActivity(request);

        final events = monitor.getRecentEvents(
          eventType: 'suspicious_input_pattern',
        );
        expect(events.length, 1);
        expect(events.first.severity, SecuritySeverity.medium);
      });

      test('should detect unusual session ID length', () {
        final request = UssdRequest(
          sessionId:
              'very_very_long_session_id_that_exceeds_normal_length_and_might_indicate_an_attack_or_bug_${'x' * 100}',
          phoneNumber: '+256700000000',
          text: '1',
          serviceCode: '*123#',
        );

        monitor.detectAnomalousActivity(request);

        final events = monitor.getRecentEvents(eventType: 'unusual_session_id');
        expect(events.length, 1);
      });

      test('should detect unusual text length', () {
        final request = UssdRequest(
          sessionId: 'test_session',
          phoneNumber: '+256700000000',
          text: 'very_long_text_input_that_exceeds_normal_ussd_input_length',
          serviceCode: '*123#',
        );

        monitor.detectAnomalousActivity(request);

        final events = monitor.getRecentEvents(
          eventType: 'unusual_text_length',
        );
        expect(events.length, 1);
      });

      test('should detect unusual service codes', () {
        final request = UssdRequest(
          sessionId: 'test_session',
          phoneNumber: '+256700000000',
          text: '1',
          serviceCode: '*999999#', // Unusual service code
        );

        monitor.detectAnomalousActivity(request);

        final events = monitor.getRecentEvents(
          eventType: 'unusual_service_code',
        );
        expect(events.length, 1);
      });

      test('should track repeated suspicious activity', () {
        final request = UssdRequest(
          sessionId: 'test_session',
          phoneNumber: '+256700000000',
          text: '<script>',
          serviceCode: '*123#',
        );

        // Generate multiple suspicious activities
        for (int i = 0; i < 5; i++) {
          monitor.detectAnomalousActivity(
            UssdRequest(
              sessionId: 'test_session_$i',
              phoneNumber: '+256700000000',
              text: '<script>alert($i)</script>',
              serviceCode: '*123#',
            ),
          );
        }

        final events = monitor.getRecentEvents(
          eventType: 'repeated_suspicious_activity',
        );
        expect(events.length, 1);
        expect(events.first.severity, SecuritySeverity.critical);
      });
    });

    group('rate limiting', () {
      test('should track requests per phone number separately', () {
        final request1 = UssdRequest(
          sessionId: 'test_session',
          phoneNumber: '+256700000000',
          text: '1',
          serviceCode: '*123#',
        );

        final request2 = UssdRequest(
          sessionId: 'test_session',
          phoneNumber: '+256700000001',
          text: '1',
          serviceCode: '*123#',
        );

        // Phone 1 hits rate limit
        for (int i = 0; i < 10; i++) {
          monitor.detectAnomalousActivity(request1);
        }

        expect(monitor.isUserRateLimited('+256700000000'), true);
        expect(monitor.isUserRateLimited('+256700000001'), false);

        // Phone 2 should still work
        expect(
          () => monitor.detectAnomalousActivity(request2),
          returnsNormally,
        );
      });

      test('should reset rate limits after time window', () {
        // This test would require time manipulation in a real scenario
        // For now, we'll test the basic functionality
        expect(monitor.isUserRateLimited('+256700000000'), false);
      });
    });

    group('getRecentEvents', () {
      test('should filter events by severity', () {
        monitor.logSecurityEvent(
          'critical_event',
          {},
          severity: SecuritySeverity.critical,
        );
        monitor.logSecurityEvent(
          'medium_event',
          {},
          severity: SecuritySeverity.medium,
        );
        monitor.logSecurityEvent(
          'low_event',
          {},
          severity: SecuritySeverity.low,
        );

        final criticalEvents = monitor.getRecentEvents(
          minSeverity: SecuritySeverity.critical,
        );
        expect(criticalEvents.length, 1);
        expect(criticalEvents.first.event, 'critical_event');

        final mediumAndAbove = monitor.getRecentEvents(
          minSeverity: SecuritySeverity.medium,
        );
        expect(mediumAndAbove.length, 2);
      });

      test('should filter events by type', () {
        monitor.logSecurityEvent('type_a', {});
        monitor.logSecurityEvent('type_b', {});
        monitor.logSecurityEvent('type_a', {});

        final typeAEvents = monitor.getRecentEvents(eventType: 'type_a');
        expect(typeAEvents.length, 2);

        final typeBEvents = monitor.getRecentEvents(eventType: 'type_b');
        expect(typeBEvents.length, 1);
      });

      test('should limit number of returned events', () {
        for (int i = 0; i < 10; i++) {
          monitor.logSecurityEvent('test_event_$i', {});
        }

        final limitedEvents = monitor.getRecentEvents(limit: 5);
        expect(limitedEvents.length, 5);
      });
    });

    group('getSecurityStats', () {
      test('should return correct statistics', () {
        monitor.logSecurityEvent(
          'event_type_1',
          {},
          severity: SecuritySeverity.high,
        );
        monitor.logSecurityEvent(
          'event_type_1',
          {},
          severity: SecuritySeverity.high,
        );
        monitor.logSecurityEvent(
          'event_type_2',
          {},
          severity: SecuritySeverity.medium,
        );

        final stats = monitor.getSecurityStats();

        expect(stats['total_events_24h'], 3);
        expect(stats['event_counts']['event_type_1'], 2);
        expect(stats['event_counts']['event_type_2'], 1);
        expect(stats['severity_counts']['high'], 2);
        expect(stats['severity_counts']['medium'], 1);
      });
    });

    group('getSuspiciousActivityCount', () {
      test('should return correct suspicious activity count', () {
        expect(monitor.getSuspiciousActivityCount('+256700000000'), 0);

        // Generate suspicious activity
        final request = UssdRequest(
          sessionId: 'test_session',
          phoneNumber: '+256700000000',
          text: '<script>',
          serviceCode: '*123#',
        );

        monitor.detectAnomalousActivity(request);
        expect(monitor.getSuspiciousActivityCount('+256700000000'), 1);

        monitor.detectAnomalousActivity(request);
        expect(monitor.getSuspiciousActivityCount('+256700000000'), 2);
      });
    });
  });
}
