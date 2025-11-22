import 'dart:convert';

import 'package:brainbee/presentation/views/class/services/class_api_service.dart';

class QuizService {
  final ClassApiService apiService;
  QuizService({required this.apiService});

  Future<List<Map<String, dynamic>>> getQuizzes(String classId) async {
    try {
      final response = await apiService.get('/api/classes/$classId/quizzes');
      final data = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(data['data']['quizzes'] ?? []);
    } catch (e) {
      throw Exception('Failed to load quizzes: $e');
    }
  }

  Future<Map<String, dynamic>> getQuizDetail(String quizId) async {
    try {
      final response = await apiService.get('/api/quizzes/$quizId');
      final data = jsonDecode(response.body);
      return data['data']['quiz'] as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Failed to load quiz: $e');
    }
  }

  Future<Map<String, dynamic>> submitQuiz(
    String quizId,
    Map<String, dynamic> answers,
  ) async {
    try {
      final response = await apiService.post(
        '/api/quizzes/$quizId/submit',
        data: {'answers': answers},
      );
      final data = jsonDecode(response.body);
      return data['data']['submission'] as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Failed to submit quiz: $e');
    }
  }
}
