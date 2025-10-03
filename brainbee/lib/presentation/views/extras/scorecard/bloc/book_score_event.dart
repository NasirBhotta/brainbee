part of 'book_score_bloc.dart';

sealed class BookScoreEvent extends Equatable {
  const BookScoreEvent();

  @override
  List<Object> get props => [];
}

class LoadOverallScore extends BookScoreEvent {}

class RefreshOverallScore extends BookScoreEvent {}
