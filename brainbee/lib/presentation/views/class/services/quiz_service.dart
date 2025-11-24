import 'dart:convert';
import 'package:brainbee/presentation/views/class/services/class_api_service.dart';

class QuizService {
  final ClassApiService apiService;
  QuizService({required this.apiService});

  /// Get all quizzes for the current student
  Future<List<Map<String, dynamic>>> getQuizzes() async {
    try {
      final response = await apiService.get('/api/teacherQuizzes/student');
      final data = jsonDecode(response.body);

      if (data['status'] == 'success') {
        return List<Map<String, dynamic>>.from(data['data']['quizzes'] ?? []);
      } else {
        throw Exception('Failed to load quizzes');
      }
    } catch (e) {
      throw Exception('Failed to load quizzes: $e');
    }
  }

  /// Get detailed information about a specific quiz
  Future<Map<String, dynamic>> getQuizDetail(String quizId) async {
    try {
      final response = await apiService.get('/api/teacherQuizzes/$quizId');
      final data = jsonDecode(response.body);

      if (data['status'] == 'success') {
        return data['data']['quiz'] as Map<String, dynamic>;
      } else {
        throw Exception('Failed to load quiz details');
      }
    } catch (e) {
      throw Exception('Failed to load quiz: $e');
    }
  }

  /// Submit quiz answers
  /// answers should be a list of selected option indices [0, 2, 1]
  /// timeSpent is in seconds
  Future<Map<String, dynamic>> submitQuiz(
    String quizId,
    List<int> answers,
    int timeSpent,
  ) async {
    try {
      final response = await apiService.post(
        '/api/teacherQuizzes/$quizId/submit',
        data: {'answers': answers, 'timeSpent': timeSpent},
      );

      final data = jsonDecode(response.body);

      if (data['status'] == 'success') {
        return data['data']['quizAttempt'] as Map<String, dynamic>;
      } else {
        throw Exception(data['message'] ?? 'Failed to submit quiz');
      }
    } catch (e) {
      throw Exception('Failed to submit quiz: $e');
    }
  }

  /// Download quiz question sheet (for document-based quizzes)
  Future<String> downloadQuizSheet(String quizId) async {
    try {
      final response = await apiService.get(
        '/api/teacherQuizzes/$quizId/download',
      );

      final data = jsonDecode(response.body);

      if (data['status'] == 'success') {
        return data['data']['path'] as String;
      } else {
        throw Exception('Failed to download quiz sheet');
      }
    } catch (e) {
      throw Exception('Failed to download quiz sheet: $e');
    }
  }

  /// Upload completed quiz sheet (for document-based quizzes)
  Future<void> uploadQuizSheet(String quizId, String filePath) async {
    try {
      final response = await apiService.uploadFile(
        '/api/teacherQuizzes/$quizId/upload',
        filePath,
      );

      final data = jsonDecode(response.body);

      if (data['status'] != 'success') {
        throw Exception(data['message'] ?? 'Failed to upload quiz sheet');
      }
    } catch (e) {
      throw Exception('Failed to upload quiz sheet: $e');
    }
  }
}
