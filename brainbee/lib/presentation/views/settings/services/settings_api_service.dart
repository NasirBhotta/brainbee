// services/settings_api_service.dart
import 'dart:convert';
import 'package:brainbee/config/api_config.dart';
import 'package:http/http.dart' as http;

class SettingsApiService {
  static const String baseUrl = BBApiConfig.baseUrl;
  static const Duration timeoutDuration = Duration(seconds: 15);

  Future<http.Response> getProfile(String token) async {
    return await http
        .get(
          Uri.parse("$baseUrl/api/auth/get-profile"),
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $token",
          },
        )
        .timeout(timeoutDuration);
  }

  /// Get available books for a specific grade (no authentication needed)
  Future<http.Response> getAvailableBooksForGrade(int grade) async {
    return await http
        .get(
          Uri.parse("$baseUrl/api/student/subjects/grades/$grade/books"),
          headers: {"Content-Type": "application/json"},
        )
        .timeout(timeoutDuration);
  }

  /// NEW PREFERRED METHOD - Update grade and selected books using book IDs
  Future<http.Response> updateGradeAndBooks({
    required int grade,
    required List<String> bookIds,
    required String token,
  }) async {
    return await http
        .patch(
          Uri.parse("$baseUrl/api/student/subjects/update/grade-books"),
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $token",
          },
          body: jsonEncode({"grade": grade, "bookIds": bookIds}),
        )
        .timeout(timeoutDuration);
  }

  /// LEGACY METHOD - Update grade and subjects using subject names
  /// This is kept for backward compatibility
  Future<http.Response> updateGradeAndSubjects({
    required int grade,
    required List<String> subjects,
    required String token,
  }) async {
    return await http
        .patch(
          Uri.parse("$baseUrl/api/students/me/grade-subjects"),
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $token",
          },
          body: jsonEncode({"grade": grade, "subjects": subjects}),
        )
        .timeout(timeoutDuration);
  }

  /// Get student's selected books
  Future<http.Response> getStudentBooks(String token) async {
    return await http
        .get(
          Uri.parse("$baseUrl/api/students/me/books"),
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $token",
          },
        )
        .timeout(timeoutDuration);
  }

  Future<http.Response> updatePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
    required String token,
  }) async {
    return await http
        .post(
          Uri.parse("$baseUrl/api/auth/change-password"),
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $token",
          },
          body: jsonEncode({
            "currentPassword": currentPassword,
            "newPassword": newPassword,
            "confirmPassword": confirmPassword,
          }),
        )
        .timeout(timeoutDuration);
  }
}
