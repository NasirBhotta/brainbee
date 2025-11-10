// lib/data/services/class_api_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:brainbee/core/utils/helper/bb_token.dart';
import 'package:http/http.dart' as http;

class ClassApiException implements Exception {
  final String message;
  final int? statusCode;

  ClassApiException({required this.message, this.statusCode});

  @override
  String toString() =>
      'ClassApiException: $message${statusCode != null ? ' (Status: $statusCode)' : ''}';
}

class ClassApiService {
  static const String _baseUrl = 'http://10.0.2.2:5000';
  final http.Client _client;
  final Duration timeout;

  ClassApiService({
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

  // GET request
  Future<http.Response> get(
    String endpoint, {
    Map<String, String>? queryParams,
  }) async {
    try {
      Uri uri = Uri.parse('$_baseUrl$endpoint');
      if (queryParams != null) {
        uri = uri.replace(queryParameters: queryParams);
      }

      final response = await _client
          .get(uri, headers: await _headers)
          .timeout(timeout);
      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // POST request
  Future<http.Response> post(
    String endpoint, {
    Map<String, dynamic>? data,
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl$endpoint');
      final body = data != null ? jsonEncode(data) : null;

      final response = await _client
          .post(uri, headers: await _headers, body: body)
          .timeout(timeout);
      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // PUT request
  Future<http.Response> put(
    String endpoint, {
    Map<String, dynamic>? data,
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl$endpoint');
      final body = data != null ? jsonEncode(data) : null;

      final response = await _client
          .put(uri, headers: await _headers, body: body)
          .timeout(timeout);
      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // DELETE request
  Future<http.Response> delete(String endpoint) async {
    try {
      final uri = Uri.parse('$_baseUrl$endpoint');
      final response = await _client
          .delete(uri, headers: await _headers)
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
      throw ClassApiException(
        message: errorMessage,
        statusCode: response.statusCode,
      );
    }
  }

  // Handle various types of errors
  Exception _handleError(dynamic error) {
    if (error is ClassApiException) {
      return error;
    } else if (error is SocketException) {
      return ClassApiException(message: 'No internet connection');
    } else if (error is HttpException) {
      return ClassApiException(message: 'HTTP error: ${error.message}');
    } else if (error is FormatException) {
      return ClassApiException(message: 'Invalid response format');
    } else {
      return ClassApiException(message: 'Unexpected error: $error');
    }
  }

  // Dispose the HTTP client
  void dispose() {
    _client.close();
  }
}
