part of 'quiz_bloc.dart';

abstract class ClassQuizState extends Equatable {
  const ClassQuizState();
  @override
  List<Object?> get props => [];
}

class QuizInitial extends ClassQuizState {}

class QuizLoading extends ClassQuizState {}

class QuizListLoaded extends ClassQuizState {
  final List<ClassQuiz> quizzes;
  const QuizListLoaded({required this.quizzes});
  @override
  List<Object?> get props => [quizzes];
}

class QuizEmpty extends ClassQuizState {}

class QuizError extends ClassQuizState {
  final String message;
  final bool isNetworkError;
  const QuizError({required this.message, this.isNetworkError = false});
  @override
  List<Object?> get props => [message, isNetworkError];
}

class QuizInProgress extends ClassQuizState {
  final ClassQuiz quiz;
  final Map<String, dynamic> answers;
  final Duration remainingTime;
  final bool isSubmitting;
  final DateTime startTime;

  const QuizInProgress({
    required this.quiz,
    required this.answers,
    required this.remainingTime,
    this.isSubmitting = false,
    required this.startTime,
  });

  @override
  List<Object?> get props => [
    quiz,
    answers,
    remainingTime,
    isSubmitting,
    startTime,
  ];

  QuizInProgress copyWith({
    ClassQuiz? quiz,
    Map<String, dynamic>? answers,
    Duration? remainingTime,
    bool? isSubmitting,
    DateTime? startTime,
  }) {
    return QuizInProgress(
      quiz: quiz ?? this.quiz,
      answers: answers ?? this.answers,
      remainingTime: remainingTime ?? this.remainingTime,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      startTime: startTime ?? this.startTime,
    );
  }
}

class QuizSubmitSuccess extends ClassQuizState {
  final String quizId;
  final DateTime submittedAt;
  final bool isAutoSubmit;
  final Map<String, dynamic> answers;
  const QuizSubmitSuccess({
    required this.quizId,
    required this.submittedAt,
    this.isAutoSubmit = false,
    required this.answers,
  });
  @override
  List<Object?> get props => [quizId, submittedAt, isAutoSubmit, answers];
}

class QuizSubmitError extends ClassQuizState {
  final String quizId;
  final String message;
  const QuizSubmitError({required this.quizId, required this.message});
  @override
  List<Object?> get props => [quizId, message];
}

class QuizSheetDownloading extends ClassQuizState {}

class QuizSheetDownloadSuccess extends ClassQuizState {
  final String path;
  const QuizSheetDownloadSuccess({required this.path});
  @override
  List<Object?> get props => [path];
}

class QuizSheetDownloadError extends ClassQuizState {
  final String message;
  const QuizSheetDownloadError({required this.message});
  @override
  List<Object?> get props => [message];
}

class QuizSheetUploading extends ClassQuizState {}

class QuizSheetUploadSuccess extends ClassQuizState {
  final String quizId;
  final DateTime uploadedAt;
  const QuizSheetUploadSuccess({
    required this.quizId,
    required this.uploadedAt,
  });
  @override
  List<Object?> get props => [quizId, uploadedAt];
}

class QuizSheetUploadError extends ClassQuizState {
  final String message;
  const QuizSheetUploadError({required this.message});
  @override
  List<Object?> get props => [message];
}
