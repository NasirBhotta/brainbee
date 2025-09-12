part of 'quiz_bloc.dart';

// quiz_state.dart
abstract class QuizState extends Equatable {
  const QuizState();

  @override
  List<Object> get props => [];
}

class QuizInitial extends QuizState {}

class QuizLoading extends QuizState {}

class QuizzesLoaded extends QuizState {
  final List<ParsedChapter> chapters;
  final String subject;
  final int totalQuizzes;

  const QuizzesLoaded({
    required this.chapters,
    required this.subject,
    required this.totalQuizzes,
  });

  @override
  List<Object> get props => [chapters, subject, totalQuizzes];
}

class QuizStarted extends QuizState {
  final QuizData quiz;

  const QuizStarted({required this.quiz});

  @override
  List<Object> get props => [quiz];
}

class QuizGenerating extends QuizState {
  final String message;

  const QuizGenerating({this.message = 'Generating quiz...'});

  @override
  List<Object> get props => [message];
}

class QuizError extends QuizState {
  final String message;

  const QuizError({required this.message});

  @override
  List<Object> get props => [message];
}
