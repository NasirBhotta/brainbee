part of 'quiz_bloc.dart';

abstract class QuizState extends Equatable {
  const QuizState();

  @override
  List<Object?> get props => [];
}

class QuizInitial extends QuizState {}

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

class QuizStarted extends QuizState {
  final QuizData quiz;

  const QuizStarted({required this.quiz});

  @override
  List<Object> get props => [quiz];
}

class QuizGenerating extends QuizState {
  final String message;

  const QuizGenerating({required this.message});

  @override
  List<Object> get props => [message];
}

class QuizGenerated extends QuizState {
  final String message;

  const QuizGenerated(this.message);

  @override
  List<Object> get props => [message];
}

class QuizError extends QuizState {
  final String message;

  const QuizError({required this.message});

  @override
  List<Object> get props => [message];
}

class QuizLoading extends QuizState {}

class QuizzesLoaded extends QuizState {
  final QuizData quizData;

  const QuizzesLoaded({required this.quizData});

  @override
  List<Object> get props => [quizData];
}

class QuizSubmitting extends QuizState {
  const QuizSubmitting();
}

class QuizSubmitted extends QuizState {
  final Map<String, dynamic> result;

  const QuizSubmitted({required this.result});

  @override
  List<Object> get props => [result];
}

class QuizSubmissionError extends QuizState {
  final String message;

  const QuizSubmissionError({required this.message});

  @override
  List<Object> get props => [message];
}

class TopicsWithStatusLoading extends QuizState {}

class TopicsWithStatusLoaded extends QuizState {
  final List<Topic> topics;
  final int chapterNumber;
  final Map<String, List<Topic>>
  allTopicsByChapter; // ✅ Store all chapters' topics

  const TopicsWithStatusLoaded({
    required this.topics,
    required this.chapterNumber,
    required this.allTopicsByChapter,
  });

  @override
  List<Object> get props => [topics, chapterNumber, allTopicsByChapter];
}

class TopicsWithStatusError extends QuizState {
  final String message;

  const TopicsWithStatusError(this.message);

  @override
  List<Object> get props => [message];
}

// ✅ NEW: State for loading all topics at once
class AllTopicsStatusLoading extends QuizState {}

class AllTopicsStatusLoaded extends QuizState {
  final Map<String, List<Topic>> allTopicsByChapter;

  const AllTopicsStatusLoaded({required this.allTopicsByChapter});

  @override
  List<Object> get props => [allTopicsByChapter];
}
