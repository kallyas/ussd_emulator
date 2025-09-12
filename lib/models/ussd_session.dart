import 'package:json_annotation/json_annotation.dart';
import 'ussd_request.dart';
import 'ussd_response.dart';

part 'ussd_session.g.dart';

@JsonSerializable()
class UssdSession {
  final String id;
  final String phoneNumber;
  final String serviceCode;
  final String? networkCode;
  final List<UssdRequest> requests;
  final List<UssdResponse> responses;
  final List<String> ussdPath;
  final DateTime createdAt;
  final DateTime? endedAt;
  final bool isActive;

  const UssdSession({
    required this.id,
    required this.phoneNumber,
    required this.serviceCode,
    this.networkCode,
    required this.requests,
    required this.responses,
    required this.ussdPath,
    required this.createdAt,
    this.endedAt,
    required this.isActive,
  });

  factory UssdSession.fromJson(Map<String, dynamic> json) =>
      _$UssdSessionFromJson(json);

  Map<String, dynamic> toJson() => _$UssdSessionToJson(this);

  UssdSession copyWith({
    String? id,
    String? phoneNumber,
    String? serviceCode,
    String? networkCode,
    List<UssdRequest>? requests,
    List<UssdResponse>? responses,
    List<String>? ussdPath,
    DateTime? createdAt,
    Object? endedAt = const Object(),
    bool? isActive,
  }) {
    return UssdSession(
      id: id ?? this.id,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      serviceCode: serviceCode ?? this.serviceCode,
      networkCode: networkCode ?? this.networkCode,
      requests: requests ?? this.requests,
      responses: responses ?? this.responses,
      ussdPath: ussdPath ?? this.ussdPath,
      createdAt: createdAt ?? this.createdAt,
      endedAt: endedAt == const Object() ? this.endedAt : endedAt as DateTime?,
      isActive: isActive ?? this.isActive,
    );
  }

  /// Get the current USSD path as a concatenated string (e.g., "1*2*1")
  String get pathAsText => ussdPath.join('*');

  /// Check if this is the initial USSD request (empty path)
  bool get isInitialRequest => ussdPath.isEmpty;
}
