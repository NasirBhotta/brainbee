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

  QuizBloc({required this.quizRepository}) : super(QuizInitial()) {
    on<LoadSubjectQuizzes>(_onLoadSubjectQuizzes);
    on<StartExistingQuiz>(_onStartExistingQuiz);
    on<GenerateNewQuiz>(_onGenerateNewQuiz);
    on<RefreshQuizzes>(_onRefreshQuizzes);
    on<LoadQuizById>(_onLoadQuizById);
  }

  Future<void> _onLoadSubjectQuizzes(
    LoadSubjectQuizzes event,
    Emitter<QuizState> emit,
  ) async {
    try {
      emit(BookDataLoading());

      // print("Subject: ${event.subject}, Grade: ${event.grade}");

      final bookData = await quizRepository.getQuizzesBySubject(
        subject: event.subject,
        grade: event.grade,
      );

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
      // You might want to refresh quiz data or validate it here
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

  Future<void> _onRefreshQuizzes(
    RefreshQuizzes event,
    Emitter<QuizState> emit,
  ) async {
    // Same as load but doesn't show loading state
    add(LoadSubjectQuizzes(subject: event.subject, grade: event.grade));
  }

  // List<ParsedChapter> _parseQuizzesIntoChapters(
  //   List<QuizData> quizzes,
  //   String subject,
  // ) {
  //   final Map<String, List<QuizData>> chapterGroups = {};

  //   // Group quizzes by chapter using topic_key pattern
  //   for (final quiz in quizzes) {
  //     final chapterKey = _extractChapterKey(quiz.topicKey);
  //     chapterGroups[chapterKey] ??= [];
  //     chapterGroups[chapterKey]!.add(quiz);
  //   }

  //   // Convert to ParsedChapter objects
  //   final chapters = <ParsedChapter>[];
  //   int colorIndex = 0;

  //   for (final entry in chapterGroups.entries) {
  //     final chapterInfo = _parseChapterInfo(entry.key);
  //     final topics = _createTopicsFromQuizzes(entry.value);

  //     chapters.add(
  //       ParsedChapter(
  //         bookName: chapterInfo['bookName']!,
  //         chapterNumber: int.parse(chapterInfo['chapterNumber']!),
  //         chapterTitle: chapterInfo['chapterTitle']!,
  //         topics: topics,
  //         color: _getChapterColor(colorIndex),
  //         icon: _getChapterIcon(subject, colorIndex),
  //       ),
  //     );

  //     colorIndex++;
  //   }

  //   // Sort chapters by chapter number
  //   chapters.sort((a, b) => a.chapterNumber.compareTo(b.chapterNumber));

  //   return chapters;
  // }

  // String _extractChapterKey(String topicKey) {
  //   // Extract chapter part from topic_key like "Biology 9th Chapter 3 Morphology"
  //   // Returns "Biology 9th Chapter 3"
  //   final parts = topicKey.split(' ');
  //   final chapterIndex = parts.indexOf('Chapter');
  //   if (chapterIndex != -1 && chapterIndex + 1 < parts.length) {
  //     return parts.sublist(0, chapterIndex + 2).join(' ');
  //   }
  //   return topicKey; // fallback
  // }

  // Map<String, String> _parseChapterInfo(String chapterKey) {
  //   // Parse "Biology 9th Chapter 3" into components
  //   final parts = chapterKey.split(' ');
  //   final chapterIndex = parts.indexOf('Chapter');

  //   return {
  //     'bookName': parts.sublist(0, chapterIndex).join(' '),
  //     'chapterNumber': parts[chapterIndex + 1],
  //     'chapterTitle':
  //         'Chapter ${parts[chapterIndex + 1]}', // You might want to get actual titles
  //   };
  // }

  // List<ParsedTopic> _createTopicsFromQuizzes(List<QuizData> quizzes) {
  //   return quizzes.map((quiz) {
  //     final topicTitle = _extractTopicTitle(quiz.topicKey);
  //     return ParsedTopic(
  //       topicKey: quiz.topicKey,
  //       topicTitle: topicTitle,
  //       hasQuiz: true,
  //       quizData: quiz,
  //     );
  //   }).toList();
  // }

  //   String _extractTopicTitle(String topicKey) {
  //     // Extract topic title from "Biology 9th Chapter 3 Morphology"
  //     // Returns "Morphology"
  //     final parts = topicKey.split(' ');
  //     final chapterIndex = parts.indexOf('Chapter');
  //     if (chapterIndex != -1 && chapterIndex + 2 < parts.length) {
  //       return parts.sublist(chapterIndex + 2).join(' ');
  //     }
  //     return topicKey; // fallback
  //   }

  //   Color _getChapterColor(int index) {
  //     const colors = [
  //       BBColors.progressColor1,
  //       BBColors.progressColor2,
  //       BBColors.progressColor3,
  //       BBColors.progressColor4,
  //     ];
  //     return colors[index % colors.length];
  //   }

  //   IconData _getChapterIcon(String subject, int index) {
  //     switch (subject.toLowerCase()) {
  //       case 'mathematics':
  //         return Icons.calculate;
  //       case 'physics':
  //         return Icons.science;
  //       case 'biology':
  //         return Icons.biotech;
  //       case 'chemistry':
  //         return Icons.add_reaction;
  //       default:
  //         return Icons.book;
  //     }
  //   }

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
