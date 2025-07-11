import 'package:json_annotation/json_annotation.dart';

part 'ussd_response.g.dart';

@JsonSerializable()
class UssdResponse {
  final String text;
  final bool continueSession;
  final String? sessionId;

  const UssdResponse({
    required this.text,
    required this.continueSession,
    this.sessionId,
  });

  factory UssdResponse.fromJson(Map<String, dynamic> json) =>
      _$UssdResponseFromJson(json);

  /// Create UssdResponse from plain text response (CON/END format)
  factory UssdResponse.fromTextResponse(String textResponse) {
    if (textResponse.startsWith('CON ')) {
      return UssdResponse(
        text: textResponse.substring(4), // Remove "CON " prefix
        continueSession: true,
      );
    } else if (textResponse.startsWith('END ')) {
      return UssdResponse(
        text: textResponse.substring(4), // Remove "END " prefix
        continueSession: false,
      );
    } else {
      // Fallback: treat as continuation if no explicit prefix
      return UssdResponse(
        text: textResponse,
        continueSession: true,
      );
    }
  }

  Map<String, dynamic> toJson() => _$UssdResponseToJson(this);
}