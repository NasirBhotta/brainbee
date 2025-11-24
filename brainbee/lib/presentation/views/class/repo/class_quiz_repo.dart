import 'package:brainbee/presentation/views/class/models/quiz_model.dart';

abstract class ClassQuizRepository {
  Future<List<ClassQuiz>> getQuizzes(String classId);
  Future<ClassQuiz> getQuizDetail(String quizId);
  Future<void> submitQuiz(String quizId, List<int> answers, int timeSpent);
  Future<String> downloadQuizSheet(String quizId);
  Future<void> uploadQuizSheet(String quizId, String filePath);
}
