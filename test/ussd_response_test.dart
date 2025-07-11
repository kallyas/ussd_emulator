import 'package:flutter_test/flutter_test.dart';
import 'package:ussd_emulator/models/ussd_response.dart';

void main() {
  group('UssdResponse', () {
    test('should parse CON response correctly', () {
      const textResponse =
          'CON Welcome to our service\n1. Check Balance\n2. Buy Airtime';

      final response = UssdResponse.fromTextResponse(textResponse);

      expect(
        response.text,
        'Welcome to our service\n1. Check Balance\n2. Buy Airtime',
      );
      expect(response.continueSession, true);
      expect(response.sessionId, null);
    });

    test('should parse END response correctly', () {
      const textResponse =
          'END Thank you for using our service!\nYour balance is \$10.50';

      final response = UssdResponse.fromTextResponse(textResponse);

      expect(
        response.text,
        'Thank you for using our service!\nYour balance is \$10.50',
      );
      expect(response.continueSession, false);
      expect(response.sessionId, null);
    });

    test('should handle response without prefix as continuation', () {
      const textResponse = 'Welcome to our service';

      final response = UssdResponse.fromTextResponse(textResponse);

      expect(response.text, 'Welcome to our service');
      expect(response.continueSession, true);
      expect(response.sessionId, null);
    });

    test('should handle empty CON response', () {
      const textResponse = 'CON ';

      final response = UssdResponse.fromTextResponse(textResponse);

      expect(response.text, '');
      expect(response.continueSession, true);
      expect(response.sessionId, null);
    });

    test('should handle empty END response', () {
      const textResponse = 'END ';

      final response = UssdResponse.fromTextResponse(textResponse);

      expect(response.text, '');
      expect(response.continueSession, false);
      expect(response.sessionId, null);
    });
  });
}
