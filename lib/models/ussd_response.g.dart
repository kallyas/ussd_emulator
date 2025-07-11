// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ussd_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UssdResponse _$UssdResponseFromJson(Map<String, dynamic> json) => UssdResponse(
  text: json['text'] as String,
  continueSession: json['continueSession'] as bool,
  sessionId: json['sessionId'] as String?,
);

Map<String, dynamic> _$UssdResponseToJson(UssdResponse instance) =>
    <String, dynamic>{
      'text': instance.text,
      'continueSession': instance.continueSession,
      'sessionId': instance.sessionId,
    };
