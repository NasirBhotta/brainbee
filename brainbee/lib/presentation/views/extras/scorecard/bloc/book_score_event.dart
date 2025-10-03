part of 'book_score_bloc.dart';

sealed class BookScoreEvent extends Equatable {
  const BookScoreEvent();

  @override
  List<Object> get props => [];
}

class LoadOverallScore extends BookScoreEvent {}

class RefreshOverallScore extends BookScoreEvent {}

class LoadBookScore extends BookScoreEvent {
  final String bookId;

  const LoadBookScore(this.bookId);
}

class RefreshBookScore extends BookScoreEvent {
  final String bookId;

  const RefreshBookScore(this.bookId);
}
