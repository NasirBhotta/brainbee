part of 'quiz_bloc.dart';

abstract class ClassQuizEvent extends Equatable {
  const ClassQuizEvent();
  @override
  List<Object?> get props => [];
}

class FetchQuizzesEvent extends ClassQuizEvent {
  final String classId;
  const FetchQuizzesEvent({required this.classId});
  @override
  List<Object?> get props => [classId];
}

class RefreshQuizzesEvent extends ClassQuizEvent {
  final String classId;
  const RefreshQuizzesEvent({required this.classId});
  @override
  List<Object?> get props => [classId];
}

class StartQuizEvent extends ClassQuizEvent {
  final ClassQuiz quiz;
  const StartQuizEvent({required this.quiz});
  @override
  List<Object?> get props => [quiz];
}

class SubmitQuizEvent extends ClassQuizEvent {
  final String quizId;
  final Map<String, dynamic> answers;
  final bool isAutoSubmit;
  const SubmitQuizEvent({
    required this.quizId,
    required this.answers,
    this.isAutoSubmit = false,
  });
  @override
  List<Object?> get props => [quizId, answers, isAutoSubmit];
}

class UpdateAnswerEvent extends ClassQuizEvent {
  final String questionId;
  final dynamic answer;
  const UpdateAnswerEvent({required this.questionId, required this.answer});
  @override
  List<Object?> get props => [questionId, answer];
}

class DownloadQuizSheetEvent extends ClassQuizEvent {
  final ClassQuiz quiz;
  const DownloadQuizSheetEvent({required this.quiz});
  @override
  List<Object?> get props => [quiz];
}

class UploadQuizSheetEvent extends ClassQuizEvent {
  final String quizId;
  final String filePath;
  const UploadQuizSheetEvent({required this.quizId, required this.filePath});
  @override
  List<Object?> get props => [quizId, filePath];
}
