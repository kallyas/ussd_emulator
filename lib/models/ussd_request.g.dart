// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ussd_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UssdRequest _$UssdRequestFromJson(Map<String, dynamic> json) => UssdRequest(
  sessionId: json['sessionId'] as String,
  phoneNumber: json['phoneNumber'] as String,
  text: json['text'] as String,
  serviceCode: json['serviceCode'] as String,
);

Map<String, dynamic> _$UssdRequestToJson(UssdRequest instance) =>
    <String, dynamic>{
      'sessionId': instance.sessionId,
      'phoneNumber': instance.phoneNumber,
      'text': instance.text,
      'serviceCode': instance.serviceCode,
    };
