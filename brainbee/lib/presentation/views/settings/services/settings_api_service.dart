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

  Future<http.Response> updateGradeAndSubjects({
    required int grade,
    required List<String> subjects,
    required String token,
  }) async {
    return await http
        .patch(
          Uri.parse("$baseUrl/api/student/update-grade-subjects"),
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $token",
          },
          body: jsonEncode({"grade": grade, "subjects": subjects}),
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
        .patch(
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
