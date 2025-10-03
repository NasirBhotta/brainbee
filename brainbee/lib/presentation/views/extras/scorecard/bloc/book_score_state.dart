part of 'book_score_bloc.dart';

sealed class BookScoreState extends Equatable {
  const BookScoreState();

  @override
  List<Object> get props => [];
}

final class BookScoreInitial extends BookScoreState {}

class OverallScoreLoading extends BookScoreState {}

class OverallScoreLoaded extends BookScoreState {
  final OverallScoreData data;

  const OverallScoreLoaded(this.data);
}

class OverallScoreEmpty extends BookScoreState {}

class OverallScoreError extends BookScoreState {
  final String message;

  const OverallScoreError(this.message);
}
