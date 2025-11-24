import 'package:brainbee/presentation/views/class/models/quiz_model.dart';
import 'package:brainbee/presentation/views/class/repo/class_quiz_repo.dart';
import 'package:brainbee/presentation/views/class/services/quiz_service.dart';

class ClassQuizRepositoryRepoImpl implements ClassQuizRepository {
  final QuizService quizService;

  ClassQuizRepositoryRepoImpl({required this.quizService});

  /// Get all quizzes for the current student
  @override
  Future<List<ClassQuiz>> getQuizzes(String classId) async {
    try {
      final quizzesJson = await quizService.getQuizzes();

      // Filter by classId if needed (API might return all student's quizzes)
      final filteredQuizzes =
          quizzesJson.where((quiz) {
            final quizClassId = quiz['classId']?['_id'] ?? '';
            return classId.isEmpty || quizClassId == classId;
          }).toList();

      return filteredQuizzes.map((json) => ClassQuiz.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch quizzes: $e');
    }
  }

  /// Get detailed quiz information
  @override
  Future<ClassQuiz> getQuizDetail(String quizId) async {
    try {
      final quizJson = await quizService.getQuizDetail(quizId);
      return ClassQuiz.fromJson(quizJson);
    } catch (e) {
      throw Exception('Failed to fetch quiz detail: $e');
    }
  }

  /// Submit quiz answers
  /// The answers map should have questionId as key and selected option index as value
  /// For example: {"question1_id": 0, "question2_id": 2}
  @override
  Future<Map<String, dynamic>> submitQuiz(
    String quizId,
    Map<String, dynamic> answers,
  ) async {
    try {
      // Convert answers map to list of indices in order
      // Assuming questions are in order and answers contains indices
      final answersList =
          answers.values.map((value) {
            if (value is List) {
              // For multi-select, take first option for now
              return value.isNotEmpty ? value[0] as int : 0;
            }
            return value as int;
          }).toList();

      // Calculate time spent (you might want to track this properly)
      final timeSpent = 0; // This should be calculated based on actual time

      final result = await quizService.submitQuiz(
        quizId,
        answersList,
        timeSpent,
      );

      return result;
    } catch (e) {
      throw Exception('Failed to submit quiz: $e');
    }
  }

  /// Download quiz sheet for document-based quizzes
  @override
  Future<String> downloadQuizSheet(String quizId) async {
    try {
      return await quizService.downloadQuizSheet(quizId);
    } catch (e) {
      throw Exception('Failed to download quiz sheet: $e');
    }
  }

  /// Upload completed quiz sheet
  @override
  Future<void> uploadQuizSheet(String quizId, String filePath) async {
    try {
      await quizService.uploadQuizSheet(quizId, filePath);
    } catch (e) {
      throw Exception('Failed to upload quiz sheet: $e');
    }
  }
}
