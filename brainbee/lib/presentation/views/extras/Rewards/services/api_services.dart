// ============================================
// FILE 1: bb_api_service.dart
// ============================================
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class RewardApiService {
  // Base URL - Change this to your backend URL
  static const String _baseUrl = 'http://10.0.2.2:5000/api/student';

  // For local testing:
  // static const String _baseUrl = 'http://localhost:3000/api/v1';
  // For Android emulator:
  // static const String _baseUrl = 'http://10.0.2.2:3000/api/v1';

  // Timeout duration
  static const Duration _timeout = Duration(seconds: 30);

  /// Get auth token from SharedPreferences
  Future<String?> _getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('auth_token');
    } catch (e) {
      print('Error getting token: $e');
      return null;
    }
  }

  /// Get request
  Future<Map<String, dynamic>> getRequest({
    required String endpoint,
    Map<String, String>? queryParameters,
  }) async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('Authentication token not found. Please login again.');
      }

      final uri = Uri.parse(
        '$_baseUrl$endpoint',
      ).replace(queryParameters: queryParameters);

      print('GET Request: $uri');

      final response = await http
          .get(
            uri,
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(_timeout);

      return _handleResponse(response);
    } on SocketException {
      throw Exception('No internet connection. Please check your network.');
    } on http.ClientException {
      throw Exception('Failed to connect to server. Please try again.');
    } on TimeoutException {
      throw Exception('Request timeout. Please try again.');
    } catch (e) {
      throw Exception('Failed to fetch data: $e');
    }
  }

  /// Post request
  Future<Map<String, dynamic>> postRequest({
    required String endpoint,
    Map<String, dynamic>? body,
  }) async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('Authentication token not found. Please login again.');
      }

      final uri = Uri.parse('$_baseUrl$endpoint');

      print('POST Request: $uri');
      print('Body: ${jsonEncode(body)}');

      final response = await http
          .post(
            uri,
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(_timeout);

      return _handleResponse(response);
    } on SocketException {
      throw Exception('No internet connection. Please check your network.');
    } on http.ClientException {
      throw Exception('Failed to connect to server. Please try again.');
    } on TimeoutException {
      throw Exception('Request timeout. Please try again.');
    } catch (e) {
      throw Exception('Failed to submit data: $e');
    }
  }

  /// Put request
  Future<Map<String, dynamic>> putRequest({
    required String endpoint,
    Map<String, dynamic>? body,
  }) async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('Authentication token not found. Please login again.');
      }

      final uri = Uri.parse('$_baseUrl$endpoint');

      print('PUT Request: $uri');
      print('Body: ${jsonEncode(body)}');

      final response = await http
          .put(
            uri,
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(_timeout);

      return _handleResponse(response);
    } on SocketException {
      throw Exception('No internet connection. Please check your network.');
    } on http.ClientException {
      throw Exception('Failed to connect to server. Please try again.');
    } on TimeoutException {
      throw Exception('Request timeout. Please try again.');
    } catch (e) {
      throw Exception('Failed to update data: $e');
    }
  }

  /// Delete request
  Future<Map<String, dynamic>> deleteRequest({required String endpoint}) async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('Authentication token not found. Please login again.');
      }

      final uri = Uri.parse('$_baseUrl$endpoint');

      print('DELETE Request: $uri');

      final response = await http
          .delete(
            uri,
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(_timeout);

      return _handleResponse(response);
    } on SocketException {
      throw Exception('No internet connection. Please check your network.');
    } on http.ClientException {
      throw Exception('Failed to connect to server. Please try again.');
    } on TimeoutException {
      throw Exception('Request timeout. Please try again.');
    } catch (e) {
      throw Exception('Failed to delete data: $e');
    }
  }

  /// Handle HTTP response
  Map<String, dynamic> _handleResponse(http.Response response) {
    print('Response Status: ${response.statusCode}');
    print('Response Body: ${response.body}');

    if (response.statusCode >= 200 && response.statusCode < 300) {
      try {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } catch (e) {
        throw Exception('Failed to parse response: $e');
      }
    } else if (response.statusCode == 401) {
      throw Exception('Session expired. Please login again.');
    } else if (response.statusCode == 403) {
      throw Exception('Access denied. You do not have permission.');
    } else if (response.statusCode == 404) {
      throw Exception('Resource not found.');
    } else if (response.statusCode == 500) {
      throw Exception('Server error. Please try again later.');
    } else {
      try {
        final errorBody = jsonDecode(response.body) as Map<String, dynamic>;
        final errorMessage = errorBody['message'] ?? 'Request failed';
        throw Exception(errorMessage);
      } catch (e) {
        throw Exception('Request failed with status: ${response.statusCode}');
      }
    }
  }

  /// Upload file (for future use - profile pictures, etc.)
  Future<Map<String, dynamic>> uploadFile({
    required String endpoint,
    required File file,
    required String fieldName,
    Map<String, String>? additionalFields,
  }) async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('Authentication token not found. Please login again.');
      }

      final uri = Uri.parse('$_baseUrl$endpoint');
      final request = http.MultipartRequest('POST', uri);

      request.headers.addAll({'Authorization': 'Bearer $token'});

      // Add file
      request.files.add(
        await http.MultipartFile.fromPath(fieldName, file.path),
      );

      // Add additional fields
      if (additionalFields != null) {
        request.fields.addAll(additionalFields);
      }

      print('Upload Request: $uri');

      final streamedResponse = await request.send().timeout(_timeout);
      final response = await http.Response.fromStream(streamedResponse);

      return _handleResponse(response);
    } on SocketException {
      throw Exception('No internet connection. Please check your network.');
    } on http.ClientException {
      throw Exception('Failed to connect to server. Please try again.');
    } on TimeoutException {
      throw Exception('Upload timeout. Please try again.');
    } catch (e) {
      throw Exception('Failed to upload file: $e');
    }
  }
}

// class ApiConfig {
//   // Development
//   static const String devBaseUrl = 'http://localhost:3000/api/v1';

//   // Staging
//   static const String stagingBaseUrl =
//       'https://staging-api.brainbee.com/api/v1';

//   // Production
//   static const String prodBaseUrl = 'https://api.brainbee.com/api/v1';

//   // Current environment
//   static const String baseUrl = devBaseUrl; // Change based on environment

//   // API endpoints
//   static const String rewards = '/rewards';
//   static const String rewardsCoins = '/rewards/coins';
//   static const String rewardsRedeem = '/rewards/redeem';
//   static const String rewardsHistory = '/rewards/history';
//   static const String studentCoins = '/student/coins';
// }
