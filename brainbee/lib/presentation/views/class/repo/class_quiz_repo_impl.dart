import 'dart:convert';
import 'package:brainbee/presentation/views/class/models/quiz_model.dart';
import 'package:brainbee/presentation/views/class/repo/class_quiz_repo.dart';
import 'package:brainbee/presentation/views/class/services/class_api_service.dart';

class ClassQuizRepositoryImpl implements ClassQuizRepository {
  final ClassApiService apiService;
  ClassQuizRepositoryImpl({required this.apiService});

  @override
  Future<List<ClassQuiz>> getQuizzes(String classId) async {
    try {
      final response = await apiService.get('/api/classes/$classId/quizzes');
      final data = jsonDecode(response.body);
      final list = data['data']['quizzes'] as List? ?? [];
      return list.map((q) => ClassQuiz.fromJson(q)).toList();
    } catch (e) {
      throw Exception('Failed to load quizzes: $e');
    }
  }

  @override
  Future<ClassQuiz> getQuizDetail(String quizId) async {
    try {
      final response = await apiService.get('/api/quizzes/$quizId');
      final data = jsonDecode(response.body);
      return ClassQuiz.fromJson(data['data']['quiz']);
    } catch (e) {
      throw Exception('Failed to load quiz: $e');
    }
  }

  @override
  Future<void> submitQuiz(String quizId, Map<String, dynamic> answers) async {
    try {
      await apiService.post(
        '/api/quizzes/$quizId/submit',
        data: {'answers': answers},
      );
    } catch (e) {
      throw Exception('Failed to submit quiz: $e');
    }
  }

  @override
  Future<String> downloadQuizSheet(String quizId) async {
    try {
      await Future.delayed(const Duration(seconds: 2));
      return '/downloads/quiz_$quizId.pdf';
    } catch (e) {
      throw Exception('Failed to download: $e');
    }
  }

  @override
  Future<void> uploadQuizSheet(String quizId, String filePath) async {
    try {
      await Future.delayed(const Duration(seconds: 2));
      // In real impl, upload file to server
    } catch (e) {
      throw Exception('Failed to upload: $e');
    }
  }
}
