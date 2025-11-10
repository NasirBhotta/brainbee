part of 'reward_bloc.dart';

abstract class RewardState extends Equatable {
  const RewardState();

  @override
  List<Object?> get props => [];
}

class RewardInitial extends RewardState {}

class RewardLoading extends RewardState {}

class RewardsLoaded extends RewardState {
  final List<RewardModel> rewards;
  final int userCoins;

  const RewardsLoaded({required this.rewards, required this.userCoins});

  @override
  List<Object?> get props => [rewards, userCoins];
}

class RewardRedeeming extends RewardState {
  final List<RewardModel> rewards;
  final int userCoins;

  const RewardRedeeming({required this.rewards, required this.userCoins});

  @override
  List<Object?> get props => [rewards, userCoins];
}

class RewardRedemptionSuccess extends RewardState {
  final String message;
  final RewardModel redeemedReward;
  final List<RewardModel> rewards;
  final int userCoins;

  const RewardRedemptionSuccess({
    required this.message,
    required this.redeemedReward,
    required this.rewards,
    required this.userCoins,
  });

  @override
  List<Object?> get props => [message, redeemedReward, rewards, userCoins];
}

class RewardError extends RewardState {
  final String message;

  const RewardError({required this.message});

  @override
  List<Object?> get props => [message];
}
