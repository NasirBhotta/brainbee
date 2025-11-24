import 'package:brainbee/config/api_config.dart';
import 'package:http/http.dart' as http;

class ParentGoalsApiService {
  static const String baseUrl = BBApiConfig.baseUrl;
  static const Duration timeoutDuration = Duration(seconds: 30);

  /// Fetch all parent-assigned goals for the current student
  Future<http.Response> getStudentGoals(String token) async {
    return await http
        .get(
          Uri.parse("$baseUrl/api/parentGoals/student/"),
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $token",
          },
        )
        .timeout(timeoutDuration);
  }

  /// Mark a parent goal as complete
  Future<http.Response> markGoalComplete(String goalId, String token) async {
    return await http
        .patch(
          Uri.parse("$baseUrl/api/parentGoals/$goalId/complete"),
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $token",
          },
        )
        .timeout(timeoutDuration);
  }
}
