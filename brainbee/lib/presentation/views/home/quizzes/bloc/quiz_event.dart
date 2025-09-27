part of 'quiz_bloc.dart';

sealed class QuizEvent extends Equatable {
  const QuizEvent();

  @override
  List<Object> get props => [];
}

class LoadSubjectQuizzes extends QuizEvent {
  final String subject;
  final int grade;

  const LoadSubjectQuizzes({required this.subject, required this.grade});

  @override
  List<Object> get props => [subject, grade];
}

class StartExistingQuiz extends QuizEvent {
  final QuizData quizData;

  const StartExistingQuiz({required this.quizData});

  @override
  List<Object> get props => [quizData];
}

class GenerateNewQuiz extends QuizEvent {
  final String topicKey;
  final int grade;

  const GenerateNewQuiz({required this.topicKey, required this.grade});

  @override
  List<Object> get props => [topicKey, grade];
}

class RefreshQuizzes extends QuizEvent {
  final String subject;
  final int grade;

  const RefreshQuizzes({required this.subject, required this.grade});

  @override
  List<Object> get props => [subject, grade];
}
