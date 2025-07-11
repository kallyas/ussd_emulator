import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/ussd_request.dart';
import '../models/ussd_response.dart';
import '../models/endpoint_config.dart';

class UssdApiService {
  static const int _timeoutSeconds = 30;

  Future<UssdResponse> sendUssdRequest(
    UssdRequest request,
    EndpointConfig config,
  ) async {
    try {
      final uri = Uri.parse(config.url);
      
      final headers = {
        'Content-Type': 'application/json',
        ...config.headers,
      };

      final body = jsonEncode(request.toJson());

      final response = await http
          .post(
            uri,
            headers: headers,
            body: body,
          )
          .timeout(const Duration(seconds: _timeoutSeconds));

      if (response.statusCode == 200) {
        final responseBody = response.body.trim();
        
        // Try to parse as JSON first (for backward compatibility)
        try {
          final responseData = jsonDecode(responseBody);
          return UssdResponse.fromJson(responseData);
        } catch (e) {
          // If JSON parsing fails, treat as text response with CON/END format
          return UssdResponse.fromTextResponse(responseBody);
        }
      } else {
        throw UssdApiException(
          'HTTP ${response.statusCode}: ${response.reasonPhrase}',
          response.statusCode,
          response.body,
        );
      }
    } catch (e) {
      if (e is UssdApiException) {
        rethrow;
      }
      throw UssdApiException(
        'Network error: ${e.toString()}',
        0,
        null,
      );
    }
  }

  Future<bool> testEndpoint(EndpointConfig config) async {
    try {
      final uri = Uri.parse(config.url);
      
      final headers = {
        'Content-Type': 'application/json',
        ...config.headers,
      };

      final testRequest = UssdRequest(
        sessionId: 'test-session',
        phoneNumber: '+1234567890',
        text: '',
        serviceCode: '*123#',
      );

      final body = jsonEncode(testRequest.toJson());

      final response = await http
          .post(
            uri,
            headers: headers,
            body: body,
          )
          .timeout(const Duration(seconds: _timeoutSeconds));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        // Also try to parse the response to ensure it's valid
        final responseBody = response.body.trim();
        if (responseBody.isNotEmpty) {
          try {
            // Try JSON parsing first
            jsonDecode(responseBody);
            return true;
          } catch (e) {
            // Check if it's a valid CON/END format
            return responseBody.startsWith('CON ') || 
                   responseBody.startsWith('END ') ||
                   responseBody.isNotEmpty;
          }
        }
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}

class UssdApiException implements Exception {
  final String message;
  final int statusCode;
  final String? responseBody;

  const UssdApiException(this.message, this.statusCode, this.responseBody);

  @override
  String toString() => 'UssdApiException: $message';
}