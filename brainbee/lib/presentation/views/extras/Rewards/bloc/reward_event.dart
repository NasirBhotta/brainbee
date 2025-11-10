part of 'reward_bloc.dart';

abstract class RewardEvent extends Equatable {
  const RewardEvent();

  @override
  List<Object?> get props => [];
}

class LoadRewardsEvent extends RewardEvent {}

class RedeemRewardEvent extends RewardEvent {
  final String rewardId;
  final String? userInput;

  const RedeemRewardEvent({required this.rewardId, this.userInput});

  @override
  List<Object?> get props => [rewardId, userInput];
}

class RefreshUserCoinsEvent extends RewardEvent {}
