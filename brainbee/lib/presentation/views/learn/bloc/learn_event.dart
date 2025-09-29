part of 'learn_bloc.dart';

sealed class BookContentEvent extends Equatable {
  const BookContentEvent();

  @override
  List<Object?> get props => [];
}

class LoadBookChapters extends BookContentEvent {
  final String subject;
  final int grade;

  const LoadBookChapters({required this.subject, required this.grade});

  @override
  List<Object?> get props => [subject, grade];
}

class LoadChapterDetails extends BookContentEvent {
  final String subject;
  final int grade;
  final int chapterNumber;

  const LoadChapterDetails({
    required this.subject,
    required this.grade,
    required this.chapterNumber,
  });

  @override
  List<Object?> get props => [subject, grade, chapterNumber];
}

class LoadChapterById extends BookContentEvent {
  final String chapterId;

  const LoadChapterById(this.chapterId);

  @override
  List<Object?> get props => [chapterId];
}

class ResetBookContent extends BookContentEvent {
  const ResetBookContent();
}
