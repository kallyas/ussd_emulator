// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ussd_session.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UssdSession _$UssdSessionFromJson(Map<String, dynamic> json) => UssdSession(
  id: json['id'] as String,
  phoneNumber: json['phoneNumber'] as String,
  serviceCode: json['serviceCode'] as String,
  networkCode: json['networkCode'] as String?,
  requests: (json['requests'] as List<dynamic>)
      .map((e) => UssdRequest.fromJson(e as Map<String, dynamic>))
      .toList(),
  responses: (json['responses'] as List<dynamic>)
      .map((e) => UssdResponse.fromJson(e as Map<String, dynamic>))
      .toList(),
  ussdPath: (json['ussdPath'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  createdAt: DateTime.parse(json['createdAt'] as String),
  endedAt: json['endedAt'] == null
      ? null
      : DateTime.parse(json['endedAt'] as String),
  isActive: json['isActive'] as bool,
);

Map<String, dynamic> _$UssdSessionToJson(UssdSession instance) =>
    <String, dynamic>{
      'id': instance.id,
      'phoneNumber': instance.phoneNumber,
      'serviceCode': instance.serviceCode,
      'networkCode': instance.networkCode,
      'requests': instance.requests,
      'responses': instance.responses,
      'ussdPath': instance.ussdPath,
      'createdAt': instance.createdAt.toIso8601String(),
      'endedAt': instance.endedAt?.toIso8601String(),
      'isActive': instance.isActive,
    };
