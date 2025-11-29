part of 'quiz_bloc.dart';

abstract class QuizEvent extends Equatable {
  const QuizEvent();

  @override
  List<Object?> get props => [];
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
  final String bookId;
  final String studentId;
  final String quizId;
  final List<Map<String, dynamic>> answers;
  final int timeSpentSeconds;
  final String? bookTitle; // ✅ Added to refresh topics after submission

  const SubmitQuizPerformance({
    required this.bookId,
    required this.studentId,
    required this.quizId,
    required this.answers,
    required this.timeSpentSeconds,
    this.bookTitle,
  });

  @override
  List<Object?> get props => [
    bookId,
    studentId,
    quizId,
    answers,
    timeSpentSeconds,
    bookTitle,
  ];
}

class LoadTopicsWithStatus extends QuizEvent {
  final String bookTitle;
  final int chapterNumber;
  final String bookId;

  const LoadTopicsWithStatus({
    required this.bookTitle,
    required this.chapterNumber,
    required this.bookId,
  });

  @override
  List<Object> get props => [bookTitle, chapterNumber, bookId];
}

class RefreshTopicStatus extends QuizEvent {
  final String bookTitle;
  final int chapterNumber;
  final String bookId;

  const RefreshTopicStatus({
    required this.bookTitle,
    required this.chapterNumber,
    required this.bookId,
  });

  @override
  List<Object> get props => [bookTitle, chapterNumber];
}

// ✅ NEW: Event to load all topics for all chapters at once
class LoadAllTopicsStatus extends QuizEvent {
  final String bookTitle;
  final List<Chapter> chapters;
  final String bookId;

  const LoadAllTopicsStatus({
    required this.bookTitle,
    required this.chapters,
    required this.bookId,
  });

  @override
  List<Object> get props => [bookTitle, chapters, bookId];
}
