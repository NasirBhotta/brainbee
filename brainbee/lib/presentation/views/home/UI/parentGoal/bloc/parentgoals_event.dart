part of 'parentgoals_bloc.dart';

sealed class ParentGoalsEvent extends Equatable {
  const ParentGoalsEvent();

  @override
  List<Object> get props => [];
}

class FetchParentGoals extends ParentGoalsEvent {}

class MarkParentGoalComplete extends ParentGoalsEvent {
  final String goalId;

  const MarkParentGoalComplete(this.goalId);

  @override
  List<Object> get props => [goalId];
}
