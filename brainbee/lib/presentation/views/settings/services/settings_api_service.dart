import 'dart:convert';

import 'package:http/http.dart' as http;

class SettingsApiService {
  static const String baseUrl = "http://10.0.2.2:5000";
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
}
