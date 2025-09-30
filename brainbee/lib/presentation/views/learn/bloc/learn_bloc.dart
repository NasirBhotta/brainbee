import 'package:bloc/bloc.dart';
import 'package:brainbee/presentation/views/learn/model/flashcard_models/content.model.dart';
import 'package:brainbee/presentation/views/learn/model/flashcard_models/flashcard_model.dart';
import 'package:brainbee/presentation/views/learn/repository/flashcard_repo.dart';
import 'package:equatable/equatable.dart';

part 'learn_event.dart';
part 'learn_state.dart';

class BookContentBloc extends Bloc<BookContentEvent, BookContentState> {
  final FlashCardContentRepository repository;

  BookContentBloc({required this.repository})
    : super(const BookContentInitial()) {
    on<LoadBookChapters>(_onLoadBookChapters);
    on<LoadChapterDetails>(_onLoadChapterDetails);
    on<LoadChapterById>(_onLoadChapterById);
    on<ResetBookContent>(_onResetBookContent);
    on<LoadFlashcards>(_onLoadFlashcards);
    on<GenerateFlashcards>(_onGenerateFlashcards);
  }

  Future<void> _onLoadBookChapters(
    LoadBookChapters event,
    Emitter<BookContentState> emit,
  ) async {
    emit(const BookContentLoading());
    try {
      final bookData = await repository.getBookChapters(
        subject: event.subject,
        grade: event.grade,
      );
      emit(
        BookChaptersLoaded(
          bookData: bookData,
          subject: event.subject,
          grade: event.grade,
        ),
      );
    } catch (e) {
      emit(BookContentError(e.toString()));
    }
  }

  Future<void> _onLoadChapterDetails(
    LoadChapterDetails event,
    Emitter<BookContentState> emit,
  ) async {
    emit(const BookContentLoading());
    try {
      final chapter = await repository.getChapterDetails(
        subject: event.subject,
        grade: event.grade,
        chapterNumber: event.chapterNumber,
      );
      emit(ChapterDetailsLoaded(chapter));
    } catch (e) {
      emit(BookContentError(e.toString()));
    }
  }

  Future<void> _onLoadChapterById(
    LoadChapterById event,
    Emitter<BookContentState> emit,
  ) async {
    emit(const BookContentLoading());
    try {
      final chapter = await repository.getChapterById(event.chapterId);
      emit(ChapterDetailsLoaded(chapter));
    } catch (e) {
      emit(BookContentError(e.toString()));
    }
  }

  void _onResetBookContent(
    ResetBookContent event,
    Emitter<BookContentState> emit,
  ) {
    emit(const BookContentInitial());
  }

  Future<void> _onLoadFlashcards(
    LoadFlashcards event,
    Emitter<BookContentState> emit,
  ) async {
    emit(FlashcardLoading());
    try {
      final flashcards = await repository.getFlashcardsForBook(
        studentId: event.studentId,
        bookName: event.bookName,
      );
      emit(FlashcardsLoaded(flashcards: flashcards));
    } catch (e) {
      emit(
        FlashcardError(message: 'Failed to load flashcards: ${e.toString()}'),
      );
    }
  }

  Future<void> _onGenerateFlashcards(
    GenerateFlashcards event,
    Emitter<BookContentState> emit,
  ) async {
    emit(FlashcardGenerating());
    try {
      final message = await repository.generateFlashcards(
        studentId: event.studentId,
        subject: event.subject,
        topicQuery: event.topicQuery,
      );
      emit(FlashcardGenerated(message: message));
    } catch (e) {
      emit(
        FlashcardError(
          message: 'Failed to generate flashcards: ${e.toString()}',
        ),
      );
    }
  }
}
