import 'package:json_annotation/json_annotation.dart';

part 'endpoint_config.g.dart';

@JsonSerializable()
class EndpointConfig {
  final String name;
  final String url;
  final Map<String, String> headers;
  final bool isActive;

  const EndpointConfig({
    required this.name,
    required this.url,
    required this.headers,
    required this.isActive,
  });

  factory EndpointConfig.fromJson(Map<String, dynamic> json) =>
      _$EndpointConfigFromJson(json);

  Map<String, dynamic> toJson() => _$EndpointConfigToJson(this);

  EndpointConfig copyWith({
    String? name,
    String? url,
    Map<String, String>? headers,
    bool? isActive,
  }) {
    return EndpointConfig(
      name: name ?? this.name,
      url: url ?? this.url,
      headers: headers ?? this.headers,
      isActive: isActive ?? this.isActive,
    );
  }
}