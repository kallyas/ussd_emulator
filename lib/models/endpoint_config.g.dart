// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'endpoint_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EndpointConfig _$EndpointConfigFromJson(Map<String, dynamic> json) =>
    EndpointConfig(
      name: json['name'] as String,
      url: json['url'] as String,
      headers: Map<String, String>.from(json['headers'] as Map),
      isActive: json['isActive'] as bool,
    );

Map<String, dynamic> _$EndpointConfigToJson(EndpointConfig instance) =>
    <String, dynamic>{
      'name': instance.name,
      'url': instance.url,
      'headers': instance.headers,
      'isActive': instance.isActive,
    };
