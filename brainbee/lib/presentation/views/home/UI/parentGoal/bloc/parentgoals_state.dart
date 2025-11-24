part of 'parentgoals_bloc.dart';

sealed class ParentGoalsState extends Equatable {
  const ParentGoalsState();

  @override
  List<Object> get props => [];
}

final class ParentGoalsInitial extends ParentGoalsState {}

final class ParentGoalsLoading extends ParentGoalsState {}

final class ParentGoalsLoaded extends ParentGoalsState {
  final List<ParentGoal> goals;

  const ParentGoalsLoaded(this.goals);

  @override
  List<Object> get props => [goals];
}

final class ParentGoalsError extends ParentGoalsState {
  final String message;

  const ParentGoalsError(this.message);

  @override
  List<Object> get props => [message];
}

final class ParentGoalMarkingComplete extends ParentGoalsState {}

final class ParentGoalMarkedComplete extends ParentGoalsState {
  final String message;

  const ParentGoalMarkedComplete(this.message);

  @override
  List<Object> get props => [message];
}

final class ParentGoalMarkCompleteError extends ParentGoalsState {
  final String message;

  const ParentGoalMarkCompleteError(this.message);

  @override
  List<Object> get props => [message];
}
