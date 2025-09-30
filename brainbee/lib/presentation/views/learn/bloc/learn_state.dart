part of 'learn_bloc.dart';

abstract class BookContentState extends Equatable {
  const BookContentState();

  @override
  List<Object?> get props => [];
}

class BookContentInitial extends BookContentState {
  const BookContentInitial();
}

class BookContentLoading extends BookContentState {
  const BookContentLoading();
}

class BookChaptersLoaded extends BookContentState {
  final BookContentData bookData;
  final String subject;
  final int grade;

  const BookChaptersLoaded({
    required this.bookData,
    required this.subject,
    required this.grade,
  });

  @override
  List<Object?> get props => [bookData, subject, grade];
}

class ChapterDetailsLoaded extends BookContentState {
  final BookChapter chapter;

  const ChapterDetailsLoaded(this.chapter);

  @override
  List<Object?> get props => [chapter];
}

class BookContentError extends BookContentState {
  final String message;

  const BookContentError(this.message);

  @override
  List<Object?> get props => [message];
}

class FlashcardInitial extends BookContentState {}

class FlashcardLoading extends BookContentState {}

class FlashcardsLoaded extends BookContentState {
  final List<Flashcard> flashcards;

  const FlashcardsLoaded({required this.flashcards});

  @override
  List<Object> get props => [flashcards];
}

class FlashcardGenerating extends BookContentState {}

class FlashcardGenerated extends BookContentState {
  final String message;
  const FlashcardGenerated({required this.message});

  @override
  List<Object> get props => [message];
}

class FlashcardError extends BookContentState {
  final String message;

  const FlashcardError({required this.message});

  @override
  List<Object> get props => [message];
}
