import 'dart:convert';

import 'package:brainbee/presentation/views/home/quizzes/models/quiz_model.dart';
import 'package:brainbee/presentation/views/home/quizzes/repositories/quiz_repository.dart';
import 'package:brainbee/presentation/views/home/quizzes/services/quiz_api_service.dart';

class QuizRepositoryImpl implements QuizRepository {
  final QuizApiService apiService;

  QuizRepositoryImpl({required this.apiService});

  @override
  Future<List<QuizData>> getQuizzesBySubject({
    required String subject,
    required String studentId,
  }) async {
    try {
      final response = await apiService.get(
        '/api/quizzes',
        queryParams: {'subject': subject, 'student_id': studentId},
      );

      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => QuizData.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load quizzes: $e');
    }
  }

  @override
  Future<QuizData> generateQuiz({
    required String topicKey,
    required String studentId,
  }) async {
    try {
      final response = await apiService.post(
        '/api/quizzes/generate',
        data: {
          'topic_key': topicKey,
          'student_id': studentId,
          'num_questions': 5,
          'difficulty_target': 'medium',
        },
      );

      final Map<String, dynamic> data = jsonDecode(response.body);
      return QuizData.fromJson(data);
    } catch (e) {
      throw Exception('Failed to generate quiz: $e');
    }
  }

  @override
  Future<QuizData> getQuizById(String quizId) async {
    try {
      final response = await apiService.get('/api/quizzes/$quizId');
      final Map<String, dynamic> data = jsonDecode(response.body);
      return QuizData.fromJson(data);
    } catch (e) {
      throw Exception('Failed to load quiz: $e');
    }
  }

  @override
  Future<List<String>> getAvailableSubjects() async {
    try {
      final response = await apiService.get('/api/subjects');
      final Map<String, dynamic> data = jsonDecode(response.body);
      return List<String>.from(data['subjects'] ?? []);
    } catch (e) {
      return [];
    }
  }

  @override
  Future<Map<String, dynamic>> getQuizStatistics({
    required String studentId,
    String? subject,
  }) async {
    try {
      final queryParams = <String, String>{'student_id': studentId};
      if (subject != null) {
        queryParams['subject'] = subject;
      }

      final response = await apiService.get(
        '/api/quizzes/statistics',
        queryParams: queryParams,
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {};
    }
  }
}
