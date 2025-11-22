part of 'quiz_bloc.dart';

abstract class QuizState extends Equatable {
  const QuizState();
  @override
  List<Object?> get props => [];
}

class QuizInitial extends QuizState {}

class QuizLoading extends QuizState {}

class QuizListLoaded extends QuizState {
  final List<ClassQuiz> quizzes;
  const QuizListLoaded({required this.quizzes});
  @override
  List<Object?> get props => [quizzes];
}

class QuizEmpty extends QuizState {}

class QuizError extends QuizState {
  final String message;
  final bool isNetworkError;
  const QuizError({required this.message, this.isNetworkError = false});
  @override
  List<Object?> get props => [message, isNetworkError];
}

class QuizInProgress extends QuizState {
  final ClassQuiz quiz;
  final Map<String, dynamic> answers;
  final Duration remainingTime;
  final bool isSubmitting;

  const QuizInProgress({
    required this.quiz,
    required this.answers,
    required this.remainingTime,
    this.isSubmitting = false,
  });

  @override
  List<Object?> get props => [quiz, answers, remainingTime, isSubmitting];

  QuizInProgress copyWith({
    ClassQuiz? quiz,
    Map<String, dynamic>? answers,
    Duration? remainingTime,
    bool? isSubmitting,
  }) {
    return QuizInProgress(
      quiz: quiz ?? this.quiz,
      answers: answers ?? this.answers,
      remainingTime: remainingTime ?? this.remainingTime,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }
}

class QuizSubmitSuccess extends QuizState {
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

class QuizSubmitError extends QuizState {
  final String quizId;
  final String message;
  const QuizSubmitError({required this.quizId, required this.message});
  @override
  List<Object?> get props => [quizId, message];
}

class QuizSheetDownloading extends QuizState {}

class QuizSheetDownloadSuccess extends QuizState {
  final String path;
  const QuizSheetDownloadSuccess({required this.path});
  @override
  List<Object?> get props => [path];
}

class QuizSheetDownloadError extends QuizState {
  final String message;
  const QuizSheetDownloadError({required this.message});
  @override
  List<Object?> get props => [message];
}

class QuizSheetUploading extends QuizState {}

class QuizSheetUploadSuccess extends QuizState {
  final String quizId;
  final DateTime uploadedAt;
  const QuizSheetUploadSuccess({
    required this.quizId,
    required this.uploadedAt,
  });
  @override
  List<Object?> get props => [quizId, uploadedAt];
}

class QuizSheetUploadError extends QuizState {
  final String message;
  const QuizSheetUploadError({required this.message});
  @override
  List<Object?> get props => [message];
}
