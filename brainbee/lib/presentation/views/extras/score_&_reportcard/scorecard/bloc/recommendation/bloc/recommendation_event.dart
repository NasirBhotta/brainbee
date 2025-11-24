part of 'recommendation_bloc.dart';

abstract class RecommendationEvent extends Equatable {
  const RecommendationEvent();

  @override
  List<Object?> get props => [];
}

class LoadRecommendations extends RecommendationEvent {
  final String studentId;

  const LoadRecommendations(this.studentId);

  @override
  List<Object?> get props => [studentId];
}

class RefreshRecommendations extends RecommendationEvent {
  final String studentId;

  const RefreshRecommendations(this.studentId);

  @override
  List<Object?> get props => [studentId];
}
