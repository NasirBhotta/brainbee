// quiz_repository.dart
import 'package:brainbee/presentation/views/home/quizzes/models/quiz_model.dart';

abstract class QuizRepository {
  Future<List<QuizData>> getQuizzesBySubject({
    required String subject,
    required int grade,
  });

  Future<QuizData> generateQuiz({required String topicKey, required int grade});

  Future<QuizData> getQuizById(String quizId);

  Future<List<String>> getAvailableSubjects();

  Future<Map<String, dynamic>> getQuizStatistics({
    required int grade,
    String? subject,
  });
}
