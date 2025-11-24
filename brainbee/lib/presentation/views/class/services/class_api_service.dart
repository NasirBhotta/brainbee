// lib/data/services/class_api_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:brainbee/config/api_config.dart';
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
  static const String _baseUrl = BBApiConfig.baseUrl;
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

      print("POST request to $endpoint with body: $body");

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

  Future<http.Response> uploadFile(
    String endpoint,
    String filePath, {
    Map<String, String>? fields,
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl$endpoint');
      final request = http.MultipartRequest('POST', uri);

      // Add headers
      request.headers.addAll(await _headers);

      // IMPORTANT: This field name MUST match what your backend expects.
      // We are changing it from 'file' to 'solution'.
      final file = await http.MultipartFile.fromPath('solution', filePath);
      request.files.add(file);

      // Add any additional fields if your backend needs them
      if (fields != null) {
        request.fields.addAll(fields);
      }

      final streamedResponse = await request.send().timeout(timeout);
      final response = await http.Response.fromStream(streamedResponse);

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
