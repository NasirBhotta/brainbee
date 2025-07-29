part of 'reward_bloc.dart';

sealed class RewardState extends Equatable {
  const RewardState();
  
  @override
  List<Object> get props => [];
}

final class RewardInitial extends RewardState {}
