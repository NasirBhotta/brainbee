part of 'recommendation_bloc.dart';

abstract class RecommendationState extends Equatable {
  const RecommendationState();

  @override
  List<Object?> get props => [];
}

class RecommendationInitial extends RecommendationState {}

class RecommendationLoading extends RecommendationState {}

class RecommendationLoaded extends RecommendationState {
  final RecommendationResponse data;

  const RecommendationLoaded(this.data);

  @override
  List<Object?> get props => [data];
}

class RecommendationEmpty extends RecommendationState {}

class RecommendationError extends RecommendationState {
  final String message;

  const RecommendationError(this.message);

  @override
  List<Object?> get props => [message];
}
