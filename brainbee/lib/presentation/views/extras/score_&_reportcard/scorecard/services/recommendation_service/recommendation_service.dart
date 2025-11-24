import 'dart:convert';
import 'package:brainbee/config/api_config.dart';
import 'package:brainbee/core/utils/helper/bb_token.dart';
import 'package:brainbee/presentation/views/extras/score_&_reportcard/scorecard/model/recommendation_model/recommendation_model.dart';
import 'package:http/http.dart' as http;

class RecommendationService {
  static const String _baseUrl = BBApiConfig.baseUrl;
  final http.Client _client;
  final Duration timeout;

  RecommendationService({
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

  Future<RecommendationResponse> getRecommendations(String studentId) async {
    try {
      final uri = Uri.parse('$_baseUrl/api/student/recommendations');

      final response = await _client
          .post(
            uri,
            headers: await _headers,
            body: jsonEncode({'student_id': studentId}),
          )
          .timeout(timeout);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final jsonData = jsonDecode(response.body);
        return RecommendationResponse.fromJson(jsonData);
      } else {
        throw Exception(
          'Failed to load recommendations: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Failed to load recommendations: $e');
    }
  }

  void dispose() {
    _client.close();
  }
}
