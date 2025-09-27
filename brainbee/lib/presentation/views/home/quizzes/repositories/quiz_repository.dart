// quiz_repository.dart
import 'package:brainbee/presentation/views/home/quizzes/models/book_model.dart';
import 'package:brainbee/presentation/views/home/quizzes/models/quiz_data_model.dart';

abstract class QuizRepository {
  Future<BookData> getQuizzesBySubject({
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
