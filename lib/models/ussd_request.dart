import 'package:json_annotation/json_annotation.dart';

part 'ussd_request.g.dart';

@JsonSerializable()
class UssdRequest {
  final String sessionId;
  final String phoneNumber;
  final String text;
  final String serviceCode;

  const UssdRequest({
    required this.sessionId,
    required this.phoneNumber,
    required this.text,
    required this.serviceCode,
  });

  factory UssdRequest.fromJson(Map<String, dynamic> json) =>
      _$UssdRequestFromJson(json);

  Map<String, dynamic> toJson() => _$UssdRequestToJson(this);
}