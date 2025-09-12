part of 'quiz_bloc.dart';

sealed class QuizEvent extends Equatable {
  const QuizEvent();

  @override
  List<Object> get props => [];
}

class LoadSubjectQuizzes extends QuizEvent {
  final String subject;
  final String studentId;

  const LoadSubjectQuizzes({required this.subject, required this.studentId});

  @override
  List<Object> get props => [subject, studentId];
}

class StartExistingQuiz extends QuizEvent {
  final QuizData quizData;

  const StartExistingQuiz({required this.quizData});

  @override
  List<Object> get props => [quizData];
}

class GenerateNewQuiz extends QuizEvent {
  final String topicKey;
  final String studentId;

  const GenerateNewQuiz({required this.topicKey, required this.studentId});

  @override
  List<Object> get props => [topicKey, studentId];
}

class RefreshQuizzes extends QuizEvent {
  final String subject;
  final String studentId;

  const RefreshQuizzes({required this.subject, required this.studentId});

  @override
  List<Object> get props => [subject, studentId];
}
