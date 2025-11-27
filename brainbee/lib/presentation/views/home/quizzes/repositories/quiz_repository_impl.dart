import 'dart:convert';

import 'package:brainbee/presentation/views/home/quizzes/models/book_model.dart';
import 'package:brainbee/presentation/views/home/quizzes/models/quiz_data_model.dart';
import 'package:brainbee/presentation/views/home/quizzes/repositories/quiz_repository.dart';
import 'package:brainbee/presentation/views/home/quizzes/services/quiz_api_service.dart';

class QuizRepositoryImpl implements QuizRepository {
  final QuizApiService apiService;

  QuizRepositoryImpl({required this.apiService});

  @override
  Future<BookData> getQuizzesBySubject({
    required String subject,
    required int grade,
  }) async {
    try {
      final response = await apiService.get(
        '/api/student/fetch-quizzes/$subject/$grade',
      );

      var data = jsonDecode(response.body);

      return BookData.fromJson(data['data']);
    } catch (e) {
      throw Exception('Failed to load quizzes: $e');
    }
  }

  @override
  Future<QuizData> generateQuiz({
    required String topicKey,
    required String bookName,
  }) async {
    try {
      final response = await apiService.post(
        '/api/openai/quiz/generate',
        data: {
          'topic_query': topicKey,
          'subject': bookName,
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
      final response = await apiService.get(
        '/api/student/fetch-quizzes/$quizId/questions',
      );
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
    required int grade,
    String? subject,
  }) async {
    try {
      final queryParams = <String, String>{'grade': grade.toString()};
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

  @override
  Future<Map<String, dynamic>> submitQuizPerformance({
    required String bookId,
    required String studentId,
    required String quizId,
    required List<Map<String, dynamic>> answers,
    required int timeSpentSeconds,
  }) async {
    try {
      final response = await apiService.post(
        '/api/student/quiz/submit-quiz',
        data: {
          'bookId': bookId,
          'quiz_id': quizId,
          'answers': answers,
          'timeSpentSeconds': timeSpentSeconds,
        },
      );

      final Map<String, dynamic> data = jsonDecode(response.body);
      return data;
    } catch (e) {
      throw Exception('Failed to submit quiz performance: $e');
    }
  }
}
