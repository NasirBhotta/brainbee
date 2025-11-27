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
  final String bookName;

  const GenerateNewQuiz({required this.topicKey, required this.bookName});

  @override
  List<Object> get props => [topicKey, bookName];
}

class RefreshQuizzes extends QuizEvent {
  final String subject;
  final int grade;

  const RefreshQuizzes({required this.subject, required this.grade});

  @override
  List<Object> get props => [subject, grade];
}

class LoadQuizById extends QuizEvent {
  final String quizId;

  const LoadQuizById({required this.quizId});

  @override
  List<Object> get props => [quizId];
}

class SubmitQuizPerformance extends QuizEvent {
  final int timeSpentSeconds;
  final String bookId;
  final String studentId;
  final String quizId;
  final List<Map<String, dynamic>> answers;

  const SubmitQuizPerformance({
    required this.bookId,
    required this.studentId,
    required this.quizId,
    required this.answers,
    required this.timeSpentSeconds,
  });

  @override
  List<Object> get props => [
    studentId,
    quizId,
    answers,
    timeSpentSeconds,
    bookId,
  ];
}
