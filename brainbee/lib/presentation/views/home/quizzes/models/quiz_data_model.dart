import 'package:brainbee/presentation/views/home/quizzes/models/quiz_question_model.dart';

class QuizData {
  final String quizId;
  final String topicKey;
  final List<QuizQuestion> questions;

  QuizData({
    required this.quizId,
    required this.topicKey,
    required this.questions,
  });

  factory QuizData.fromJson(Map<String, dynamic> json) {
    var questionsJson = json['data']['questions'] as List;
    List<QuizQuestion> questionsList =
        questionsJson
            .map((questionJson) => QuizQuestion.fromJson(questionJson))
            .toList();

    return QuizData(
      quizId: json['data']['quiz_id'] ?? '',
      topicKey: json['data']['topic_key'] ?? '',
      questions: questionsList,
    );
  }
}
