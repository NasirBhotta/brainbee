import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:brainbee/presentation/views/home/quizzes/models/book_model.dart';
import 'package:brainbee/presentation/views/home/quizzes/models/quiz_data_model.dart';
import 'package:brainbee/presentation/views/home/quizzes/repositories/quiz_repository.dart';
import 'package:equatable/equatable.dart';

part 'quiz_event.dart';
part 'quiz_state.dart';

class QuizBloc extends Bloc<QuizEvent, QuizState> {
  final QuizRepository quizRepository;

  // Store topics by chapter for efficient updates
  final Map<String, List<Topic>> _topicsByChapter = {};

  QuizBloc({required this.quizRepository}) : super(QuizInitial()) {
    on<LoadSubjectQuizzes>(_onLoadSubjectQuizzes);
    on<StartExistingQuiz>(_onStartExistingQuiz);
    on<GenerateNewQuiz>(_onGenerateNewQuiz);
    on<RefreshQuizzes>(_onRefreshQuizzes);
    on<LoadQuizById>(_onLoadQuizById);
    on<SubmitQuizPerformance>(_onSubmitQuizPerformance);
    on<LoadTopicsWithStatus>(_onLoadTopicsWithStatus);
    on<RefreshTopicStatus>(_onRefreshTopicStatus);
    on<LoadAllTopicsStatus>(_onLoadAllTopicsStatus);
  }

  Future<void> _onLoadSubjectQuizzes(
    LoadSubjectQuizzes event,
    Emitter<QuizState> emit,
  ) async {
    try {
      emit(BookDataLoading());

      final bookData = await quizRepository.getQuizzesBySubject(
        subject: event.subject,
        grade: event.grade,
      );

      // ✅ DON'T clear topics here - let them persist until new ones load
      // This prevents the UI from showing empty data between loads

      emit(BookDataLoaded(bookData: bookData));
    } catch (e) {
      emit(BookDataError(message: 'Failed to load quizzes: ${e.toString()}'));
    }
  }

  Future<void> _onStartExistingQuiz(
    StartExistingQuiz event,
    Emitter<QuizState> emit,
  ) async {
    try {
      emit(QuizStarted(quiz: event.quizData));
    } catch (e) {
      emit(QuizError(message: 'Failed to start quiz: ${e.toString()}'));
    }
  }

  Future<void> _onGenerateNewQuiz(
    GenerateNewQuiz event,
    Emitter<QuizState> emit,
  ) async {
    try {
      emit(QuizGenerating(message: 'Generating new quiz for topic...'));

      await quizRepository.generateQuiz(
        topicKey: event.topicKey,
        bookName: event.bookName,
      );

      emit(QuizGenerated("Quiz generated successfully, go back to take quiz"));
    } catch (e) {
      emit(QuizError(message: 'Failed to generate quiz: ${e.toString()}'));
    }
  }

  Future<void> _onSubmitQuizPerformance(
    SubmitQuizPerformance event,
    Emitter<QuizState> emit,
  ) async {
    try {
      emit(const QuizSubmitting());

      final result = await quizRepository.submitQuizPerformance(
        bookId: event.bookId,
        studentId: event.studentId,
        quizId: event.quizId,
        answers: event.answers,
        timeSpentSeconds: event.timeSpentSeconds,
      );

      emit(QuizSubmitted(result: result));

      // ✅ Trigger topic status refresh after quiz submission
      // This will update unlock status for all chapters
      if (state is BookDataLoaded) {
        final bookState = state as BookDataLoaded;
        add(
          LoadAllTopicsStatus(
            bookTitle: event.bookTitle ?? '',
            chapters: bookState.bookData.chapters,
            bookId: event.bookId,
          ),
        );
      }
    } catch (e) {
      emit(
        QuizSubmissionError(message: 'Failed to submit quiz: ${e.toString()}'),
      );
    }
  }

  Future<void> _onRefreshQuizzes(
    RefreshQuizzes event,
    Emitter<QuizState> emit,
  ) async {
    add(LoadSubjectQuizzes(subject: event.subject, grade: event.grade));
  }

  Future<void> _onLoadTopicsWithStatus(
    LoadTopicsWithStatus event,
    Emitter<QuizState> emit,
  ) async {
    try {
      final topics = await quizRepository.getTopicsWithStatus(
        bookTitle: event.bookTitle,
        chapterNumber: event.chapterNumber,
        bookId: event.bookId,
      );

      // Store topics for this chapter
      final chapterKey = '${event.bookTitle}_${event.chapterNumber}';
      _topicsByChapter[chapterKey] = topics;

      // ✅ Emit updated state with all accumulated topics
      emit(
        TopicsWithStatusLoaded(
          topics: topics,
          chapterNumber: event.chapterNumber,
          allTopicsByChapter: Map.from(_topicsByChapter),
        ),
      );
    } catch (e) {
      emit(TopicsWithStatusError(e.toString()));
    }
  }

  Future<void> _onRefreshTopicStatus(
    RefreshTopicStatus event,
    Emitter<QuizState> emit,
  ) async {
    await _onLoadTopicsWithStatus(
      LoadTopicsWithStatus(
        bookTitle: event.bookTitle,
        chapterNumber: event.chapterNumber,
        bookId: event.bookId,
      ),
      emit,
    );
  }

  /// ✅ Load all topics for all chapters at once
  /// Clear cache only when explicitly starting a fresh load
  Future<void> _onLoadAllTopicsStatus(
    LoadAllTopicsStatus event,
    Emitter<QuizState> emit,
  ) async {
    try {
      print("=== BLOC: Starting LoadAllTopicsStatus ===");
      print("Book title received: ${event.bookTitle}");
      print("Number of chapters: ${event.chapters.length}");

      emit(AllTopicsStatusLoading());

      // ✅ Clear only when explicitly loading all topics
      // This ensures old data doesn't persist when we want fresh data
      _topicsByChapter.clear();

      // Load topics for all chapters in parallel for better performance
      final futures = event.chapters.map((chapter) async {
        print("BLOC: Loading topics for chapter ${chapter.chapter}");

        final topics = await quizRepository.getTopicsWithStatus(
          bookTitle: event.bookTitle,
          chapterNumber: chapter.chapter,
          bookId: event.bookId,
        );

        final chapterKey = '${event.bookTitle}_${chapter.chapter}';
        print("BLOC: Loaded ${topics.length} topics for key: $chapterKey");

        return MapEntry(chapterKey, topics);
      });

      final results = await Future.wait(futures);

      // Update cache with fresh data
      for (final entry in results) {
        _topicsByChapter[entry.key] = entry.value;
        print(
          "BLOC: Cached ${entry.value.length} topics for key: ${entry.key}",
        );
      }

      print("=== BLOC: All topics cached ===");
      print("Total cache keys: ${_topicsByChapter.keys.toList()}");

      emit(
        AllTopicsStatusLoaded(allTopicsByChapter: Map.from(_topicsByChapter)),
      );
    } catch (e) {
      print("=== BLOC ERROR: $e ===");
      emit(TopicsWithStatusError('Failed to load all topics: ${e.toString()}'));
    }
  }

  FutureOr<void> _onLoadQuizById(
    LoadQuizById event,
    Emitter<QuizState> emit,
  ) async {
    emit(QuizLoading());

    try {
      final quizData = await quizRepository.getQuizById(event.quizId);
      emit(QuizzesLoaded(quizData: quizData));
    } catch (e) {
      emit(QuizError(message: 'Failed to load quiz: ${e.toString()}'));
    }
  }
}
