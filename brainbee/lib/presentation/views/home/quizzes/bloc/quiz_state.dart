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
  final QuizData quizData;

  const QuizzesLoaded({required this.quizData});

  @override
  List<Object> get props => [quizData];
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

class BookDataLoading extends QuizState {}

class BookDataLoaded extends QuizState {
  final BookData bookData;

  const BookDataLoaded({required this.bookData});

  @override
  List<Object> get props => [bookData];
}

class BookDataError extends QuizState {
  final String message;

  const BookDataError({required this.message});

  @override
  List<Object> get props => [message];
}
