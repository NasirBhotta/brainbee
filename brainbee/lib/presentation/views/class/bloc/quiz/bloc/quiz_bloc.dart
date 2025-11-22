import 'package:bloc/bloc.dart';
import 'package:brainbee/presentation/views/class/repo/class_quiz_repo.dart';
import 'package:equatable/equatable.dart';
import 'package:brainbee/presentation/views/class/models/quiz_model.dart';

part 'quiz_event.dart';
part 'quiz_state.dart';

class QuizBloc extends Bloc<QuizEvent, QuizState> {
  final ClassQuizRepository repository;
  String? _currentClassId;

  QuizBloc({required this.repository}) : super(QuizInitial()) {
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
    Emitter<QuizState> emit,
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
    Emitter<QuizState> emit,
  ) async {
    final currentState = state;
    try {
      final quizzes = await repository.getQuizzes(event.classId);
      emit(quizzes.isEmpty ? QuizEmpty() : QuizListLoaded(quizzes: quizzes));
    } catch (e) {
      if (currentState is QuizListLoaded) emit(currentState);
    }
  }

  Future<void> _onStartQuiz(
    StartQuizEvent event,
    Emitter<QuizState> emit,
  ) async {
    final now = DateTime.now();
    final remaining = event.quiz.effectiveDueTime.difference(now);
    emit(
      QuizInProgress(quiz: event.quiz, answers: {}, remainingTime: remaining),
    );
  }

  Future<void> _onUpdateAnswer(
    UpdateAnswerEvent event,
    Emitter<QuizState> emit,
  ) async {
    final currentState = state;
    if (currentState is! QuizInProgress) return;
    final newAnswers = Map<String, dynamic>.from(currentState.answers);
    newAnswers[event.questionId] = event.answer;
    emit(currentState.copyWith(answers: newAnswers));
  }

  Future<void> _onSubmitQuiz(
    SubmitQuizEvent event,
    Emitter<QuizState> emit,
  ) async {
    final currentState = state;
    if (currentState is QuizInProgress) {
      emit(currentState.copyWith(isSubmitting: true));
    }

    try {
      await repository.submitQuiz(event.quizId, event.answers);
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
      if (currentState is QuizInProgress) {
        emit(currentState.copyWith(isSubmitting: false));
      }
    }
  }

  Future<void> _onDownloadSheet(
    DownloadQuizSheetEvent event,
    Emitter<QuizState> emit,
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
    Emitter<QuizState> emit,
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
    if (str.contains('no internet') || str.contains('network'))
      return 'No internet connection';
    if (str.contains('expired') || str.contains('deadline'))
      return 'Quiz time has expired';
    return 'An error occurred. Please try again.';
  }

  bool _isNetworkError(dynamic e) {
    final str = e.toString().toLowerCase();
    return str.contains('no internet') || str.contains('network');
  }
}
