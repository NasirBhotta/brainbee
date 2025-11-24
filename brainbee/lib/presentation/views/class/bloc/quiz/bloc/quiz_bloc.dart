import 'package:bloc/bloc.dart';
import 'package:brainbee/presentation/views/class/repo/class_quiz_repo.dart';
import 'package:equatable/equatable.dart';
import 'package:brainbee/presentation/views/class/models/quiz_model.dart';

part 'quiz_event.dart';
part 'quiz_state.dart';

class ClassQuizBloc extends Bloc<ClassQuizEvent, ClassQuizState> {
  final ClassQuizRepository repository;
  String? _currentClassId;
  DateTime? _quizStartTime;

  ClassQuizBloc({required this.repository}) : super(QuizInitial()) {
    on<FetchQuizzesEvent>(_onFetchQuizzes);
    on<RefreshQuizzesEvent>(_onRefreshQuizzes);
    on<StartQuizEvent>(_onStartQuiz);
    on<UpdateAnswerEvent>(_onUpdateAnswer);
    on<SubmitQuizEvent>(_onSubmitQuiz);
    on<DownloadQuizSheetEvent>(_onDownloadSheet);
    on<UploadQuizSheetEvent>(_onUploadSheet);
  }

  Future<void> _onFetchQuizzes(
    FetchQuizzesEvent event,
    Emitter<ClassQuizState> emit,
  ) async {
    emit(QuizLoading());
    _currentClassId = event.classId;
    try {
      final quizzes = await repository.getQuizzes(event.classId);
      if (quizzes.isEmpty) {
        emit(QuizEmpty());
      } else {
        emit(QuizListLoaded(quizzes: quizzes));
      }
    } catch (e) {
      emit(
        QuizError(
          message: _getErrorMessage(e),
          isNetworkError: _isNetworkError(e),
        ),
      );
    }
  }

  Future<void> _onRefreshQuizzes(
    RefreshQuizzesEvent event,
    Emitter<ClassQuizState> emit,
  ) async {
    final currentState = state;
    try {
      final quizzes = await repository.getQuizzes(event.classId);
      emit(quizzes.isEmpty ? QuizEmpty() : QuizListLoaded(quizzes: quizzes));
    } catch (e) {
      // On error, restore previous state if it was loaded
      if (currentState is QuizListLoaded) {
        emit(currentState);
      }
    }
  }

  Future<void> _onStartQuiz(
    StartQuizEvent event,
    Emitter<ClassQuizState> emit,
  ) async {
    final now = DateTime.now();
    _quizStartTime = now;
    final remaining = event.quiz.effectiveDueTime.difference(now);

    emit(
      QuizInProgress(
        quiz: event.quiz,
        answers: {},
        remainingTime: remaining,
        startTime: now,
      ),
    );
  }

  Future<void> _onUpdateAnswer(
    UpdateAnswerEvent event,
    Emitter<ClassQuizState> emit,
  ) async {
    final currentState = state;
    if (currentState is! QuizInProgress) return;

    final newAnswers = Map<String, dynamic>.from(currentState.answers);
    newAnswers[event.questionId] = event.answer;

    emit(currentState.copyWith(answers: newAnswers));
  }

  Future<void> _onSubmitQuiz(
    SubmitQuizEvent event,
    Emitter<ClassQuizState> emit,
  ) async {
    final currentState = state;
    if (currentState is QuizInProgress) {
      emit(currentState.copyWith(isSubmitting: true));
    }

    try {
      // Convert answers to the format expected by API
      // The API expects answers as a list of indices corresponding to question order
      final quiz = (currentState is QuizInProgress) ? currentState.quiz : null;

      if (quiz == null) {
        throw Exception('Quiz not found in current state');
      }

      // Create ordered list of answers matching question order
      final orderedAnswers = <int>[];
      for (var question in quiz.questions) {
        final answer = event.answers[question.id];

        if (answer == null) {
          // If no answer provided, default to -1 or 0
          orderedAnswers.add(-1);
        } else if (answer is int) {
          orderedAnswers.add(answer);
        } else if (answer is String) {
          // If answer is option text, find its index
          final index = question.options.indexOf(answer);
          orderedAnswers.add(index >= 0 ? index : -1);
        } else if (answer is List && answer.isNotEmpty) {
          // For multi-select, take first answer
          orderedAnswers.add(answer[0] as int);
        } else {
          orderedAnswers.add(-1);
        }
      }

      // Calculate time spent in seconds
      final timeSpent =
          _quizStartTime != null
              ? DateTime.now().difference(_quizStartTime!).inSeconds
              : 0;

      print(
        "the payload of the quiz submitted is $orderedAnswers and $timeSpent",
      );

      await repository.submitQuiz(event.quizId, orderedAnswers, timeSpent);

      emit(
        QuizSubmitSuccess(
          quizId: event.quizId,
          submittedAt: DateTime.now(),
          isAutoSubmit: event.isAutoSubmit,
          answers: event.answers,
        ),
      );
    } catch (e) {
      emit(QuizSubmitError(quizId: event.quizId, message: _getErrorMessage(e)));

      // Restore previous state
      if (currentState is QuizInProgress) {
        emit(currentState.copyWith(isSubmitting: false));
      }
    }
  }

  Future<void> _onDownloadSheet(
    DownloadQuizSheetEvent event,
    Emitter<ClassQuizState> emit,
  ) async {
    emit(QuizSheetDownloading());
    try {
      final path = await repository.downloadQuizSheet(event.quiz.id);
      emit(QuizSheetDownloadSuccess(path: path));
    } catch (e) {
      emit(QuizSheetDownloadError(message: _getErrorMessage(e)));
    }
  }

  Future<void> _onUploadSheet(
    UploadQuizSheetEvent event,
    Emitter<ClassQuizState> emit,
  ) async {
    emit(QuizSheetUploading());
    try {
      await repository.uploadQuizSheet(event.quizId, event.filePath);
      emit(
        QuizSheetUploadSuccess(
          quizId: event.quizId,
          uploadedAt: DateTime.now(),
        ),
      );
    } catch (e) {
      emit(QuizSheetUploadError(message: _getErrorMessage(e)));
    }
  }

  String _getErrorMessage(dynamic e) {
    final str = e.toString().toLowerCase();

    if (str.contains('no internet') ||
        str.contains('network') ||
        str.contains('socketexception')) {
      return 'No internet connection';
    }

    if (str.contains('expired') || str.contains('deadline')) {
      return 'Quiz time has expired';
    }

    if (str.contains('unauthorized') || str.contains('401')) {
      return 'Session expired. Please login again.';
    }

    if (str.contains('forbidden') || str.contains('403')) {
      return 'You do not have permission to access this quiz';
    }

    if (str.contains('not found') || str.contains('404')) {
      return 'Quiz not found';
    }

    // Extract message from exception if available
    if (str.contains('exception:')) {
      final parts = str.split('exception:');
      if (parts.length > 1) {
        return parts[1].trim();
      }
    }

    return 'An error occurred. Please try again.';
  }

  bool _isNetworkError(dynamic e) {
    final str = e.toString().toLowerCase();
    return str.contains('no internet') ||
        str.contains('network') ||
        str.contains('socketexception') ||
        str.contains('connection');
  }
}
