import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:brainbee/config/api_config.dart';
import 'package:http/http.dart' as http;

class AuthApiService {
  // 10.0.2.2
  static const String _baseUrl = BBApiConfig.baseUrl;
  static const Duration _timeoutDuration = Duration(seconds: 15);

  // Login API call
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
    required String role,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse("$_baseUrl/api/auth/login"),
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({
              "email": email,
              "password": password,
              "role": role,
            }),
          )
          .timeout(_timeoutDuration);

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': data,
          'statusCode': response.statusCode,
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? data['status'] ?? "Login failed",
          'statusCode': response.statusCode,
        };
      }
    } on SocketException {
      return {
        'success': false,
        'message':
            "❌ Server not reachable. Please check your internet connection.",
        'error': 'network_error',
      };
    } on TimeoutException {
      return {
        'success': false,
        'message': "⏰ Request timeout. Please try again.",
        'error': 'timeout_error',
      };
    } catch (e) {
      return {
        'success': false,
        'message': "Login failed: ${e.toString()}",
        'error': 'unknown_error',
      };
    }
  }

  // Signup API call
  Future<Map<String, dynamic>> signup({
    required String email,
    required String fullName,
    required String firstName,
    required String lastName,
    required String password,
    required String role,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse("$_baseUrl/api/auth/register"),
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({
              "email": email,
              "fullName": fullName,
              "firstName": firstName,
              "lastName": lastName,
              "password": password,
              "role": role,
            }),
          )
          .timeout(_timeoutDuration);

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        return {
          'success': true,
          'data': data,
          'statusCode': response.statusCode,
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? data['status'] ?? "Signup failed",
          'statusCode': response.statusCode,
        };
      }
    } on SocketException {
      return {
        'success': false,
        'message':
            "❌ Server not reachable. Please check your internet connection.",
        'error': 'network_error',
      };
    } on TimeoutException {
      return {
        'success': false,
        'message': "⏰ Request timeout. Please try again.",
        'error': 'timeout_error',
      };
    } catch (e) {
      return {
        'success': false,
        'message': "Signup failed: ${e.toString()}",
        'error': 'unknown_error',
      };
    }
  }

  // Verify token API call
  Future<Map<String, dynamic>> verifyToken(String token) async {
    try {
      final response = await http
          .get(
            Uri.parse(
              "https://fyp-backend-express.onrender.com/api/auth/protected",
            ),
            headers: {"Authorization": "Bearer $token"},
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': jsonDecode(response.body),
          'statusCode': response.statusCode,
        };
      } else {
        return {
          'success': false,
          'message': "Token verification failed",
          'statusCode': response.statusCode,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': "Token verification failed: ${e.toString()}",
        'error': 'verification_error',
      };
    }
  }

  // Google Login API call (placeholder)
  Future<Map<String, dynamic>> googleLogin({
    required String idToken,
    required String role,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse("$_baseUrl/google-login"),
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({"idToken": idToken, "role": role}),
          )
          .timeout(_timeoutDuration);

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': data,
          'statusCode': response.statusCode,
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? "Google login failed",
          'statusCode': response.statusCode,
        };
      }
    } on SocketException {
      return {
        'success': false,
        'message':
            "❌ Server not reachable. Please check your internet connection.",
        'error': 'network_error',
      };
    } on TimeoutException {
      return {
        'success': false,
        'message': "⏰ Request timeout. Please try again.",
        'error': 'timeout_error',
      };
    } catch (e) {
      return {
        'success': false,
        'message': "Google login failed: ${e.toString()}",
        'error': 'unknown_error',
      };
    }
  }

  // Forgot Password API call (placeholder)
  Future<Map<String, dynamic>> forgotPassword(String email) async {
    try {
      final response = await http
          .post(
            Uri.parse("$_baseUrl/forgot-password"),
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({"email": email}),
          )
          .timeout(_timeoutDuration);

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': data,
          'statusCode': response.statusCode,
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? "Password reset request failed",
          'statusCode': response.statusCode,
        };
      }
    } on SocketException {
      return {
        'success': false,
        'message':
            "❌ Server not reachable. Please check your internet connection.",
        'error': 'network_error',
      };
    } on TimeoutException {
      return {
        'success': false,
        'message': "⏰ Request timeout. Please try again.",
        'error': 'timeout_error',
      };
    } catch (e) {
      return {
        'success': false,
        'message': "Password reset request failed: ${e.toString()}",
        'error': 'unknown_error',
      };
    }
  }
}
