// lib/presentation/views/extras/leaderboard/services/leaderboard_api_service.dart

import 'dart:convert';
import 'dart:io';
import 'package:brainbee/core/utils/helper/bb_token.dart';
import 'package:http/http.dart' as http;

class LeaderboardApiException implements Exception {
  final String message;
  final int? statusCode;

  LeaderboardApiException({required this.message, this.statusCode});

  @override
  String toString() =>
      'LeaderboardApiException: $message${statusCode != null ? ' (Status: $statusCode)' : ''}';
}

class LeaderboardApiService {
  static const String _baseUrl = 'http://10.0.2.2:5000';
  final http.Client _client;
  final Duration timeout;

  LeaderboardApiService({
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

  /// Fetch leaderboard data by type (weekly, monthly, or overall)
  Future<http.Response> getLeaderboard(String type) async {
    try {
      final uri = Uri.parse('$_baseUrl/api/student/leaderboard?type=$type');

      final response = await _client
          .get(uri, headers: await _headers)
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
      throw LeaderboardApiException(
        message: errorMessage,
        statusCode: response.statusCode,
      );
    }
  }

  Exception _handleError(dynamic error) {
    if (error is LeaderboardApiException) {
      return error;
    } else if (error is SocketException) {
      return LeaderboardApiException(message: 'No internet connection');
    } else if (error is HttpException) {
      return LeaderboardApiException(message: 'HTTP error: ${error.message}');
    } else if (error is FormatException) {
      return LeaderboardApiException(message: 'Invalid response format');
    } else {
      return LeaderboardApiException(message: 'Unexpected error: $error');
    }
  }

  void dispose() {
    _client.close();
  }
}
