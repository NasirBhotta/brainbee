// lib/presentation/views/extras/achievements/badges/services/badge_api_service.dart

import 'dart:convert';
import 'dart:io';
import 'package:brainbee/config/api_config.dart';
import 'package:brainbee/core/utils/helper/bb_token.dart';
import 'package:http/http.dart' as http;

class BadgeApiException implements Exception {
  final String message;
  final int? statusCode;

  BadgeApiException({required this.message, this.statusCode});

  @override
  String toString() =>
      'BadgeApiException: $message${statusCode != null ? ' (Status: $statusCode)' : ''}';
}

class BadgeApiService {
  static const String _baseUrl = BBApiConfig.baseUrl;
  final http.Client _client;
  final Duration timeout;

  BadgeApiService({
    http.Client? client,
    this.timeout = const Duration(seconds: 30),
  }) : _client = client ?? http.Client();

  Future<Map<String, String>> get _headers async {
    final tokenData = await getTokenAndUser();
    final token = tokenData.token ?? '';
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  /// Fetch all badges for a specific student
  Future<http.Response> getAllBadgesForStudent(String studentId) async {
    try {
      final uri = Uri.parse('$_baseUrl/api/student/badges/$studentId');

      final response = await _client
          .get(uri, headers: await _headers)
          .timeout(timeout);

      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Refresh badge data for a student
  Future<http.Response> refreshBadges(String studentId) async {
    try {
      final uri = Uri.parse('$_baseUrl/api/badges/student/$studentId');

      final headers = await _headers;
      headers['Cache-Control'] = 'no-cache';

      final response = await _client
          .get(uri, headers: headers)
          .timeout(timeout);

      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  http.Response _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return response;
    } else {
      String errorMessage = 'Request failed';
      try {
        final errorData = jsonDecode(response.body);
        errorMessage =
            errorData['message'] ?? errorData['error'] ?? errorMessage;
      } catch (e) {
        errorMessage = response.reasonPhrase ?? errorMessage;
      }
      throw BadgeApiException(
        message: errorMessage,
        statusCode: response.statusCode,
      );
    }
  }

  Exception _handleError(dynamic error) {
    if (error is BadgeApiException) {
      return error;
    } else if (error is SocketException) {
      return BadgeApiException(message: 'No internet connection');
    } else if (error is HttpException) {
      return BadgeApiException(message: 'HTTP error: ${error.message}');
    } else if (error is FormatException) {
      return BadgeApiException(message: 'Invalid response format');
    } else {
      return BadgeApiException(message: 'Unexpected error: $error');
    }
  }

  void dispose() {
    _client.close();
  }
}
