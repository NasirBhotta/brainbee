import 'dart:convert';
import 'dart:io';
import 'package:brainbee/core/utils/helper/bb_token.dart';
import 'package:http/http.dart' as http;

class FlashCardContentApiException implements Exception {
  final String message;
  final int? statusCode;

  FlashCardContentApiException({required this.message, this.statusCode});

  @override
  String toString() =>
      'FlashCardContentApiException: $message${statusCode != null ? ' (Status: $statusCode)' : ''}';
}

class FlashCardContentApiService {
  static const String _baseUrl = 'http://10.0.2.2:5000';
  final http.Client _client;
  final Duration timeout;

  FlashCardContentApiService({
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

  Future<http.Response> getBookChapters({
    required String subject,
    required int grade,
  }) async {
    try {
      final uri = Uri.parse(
        '$_baseUrl/api/student/books/$subject/$grade/chapters',
      );

      final response = await _client
          .get(uri, headers: await _headers)
          .timeout(timeout);

      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // GET request for specific chapter details
  Future<http.Response> getChapterDetails({
    required String subject,
    required int grade,
    required int chapterNumber,
  }) async {
    try {
      final uri = Uri.parse(
        '$_baseUrl/api/student/FlashCards/$subject/$grade/chapters/$chapterNumber',
      );

      final response = await _client
          .get(uri, headers: await _headers)
          .timeout(timeout);

      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // GET request for chapter by ID
  Future<http.Response> getChapterById(String chapterId) async {
    try {
      final uri = Uri.parse('$_baseUrl/api/student/chapters/$chapterId');

      final response = await _client
          .get(uri, headers: await _headers)
          .timeout(timeout);

      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Handle response and check for errors
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
      throw FlashCardContentApiException(
        message: errorMessage,
        statusCode: response.statusCode,
      );
    }
  }

  // Handle various types of errors
  Exception _handleError(dynamic error) {
    if (error is FlashCardContentApiException) {
      return error;
    } else if (error is SocketException) {
      return FlashCardContentApiException(message: 'No internet connection');
    } else if (error is HttpException) {
      return FlashCardContentApiException(
        message: 'HTTP error: ${error.message}',
      );
    } else if (error is FormatException) {
      return FlashCardContentApiException(message: 'Invalid response format');
    } else {
      return FlashCardContentApiException(message: 'Unexpected error: $error');
    }
  }

  // Dispose the HTTP client
  void dispose() {
    _client.close();
  }
}
