import 'package:bloc/bloc.dart';
import 'package:brainbee/presentation/views/extras/Rewards/models/reward.dart';
import 'package:brainbee/presentation/views/extras/Rewards/repo/reward_repo.dart';
import 'package:equatable/equatable.dart';

part 'reward_event.dart';
part 'reward_state.dart';

class RewardBloc extends Bloc<RewardEvent, RewardState> {
  final RewardRepository _repository;

  RewardBloc({RewardRepository? repository})
    : _repository = repository ?? RewardRepository(),
      super(RewardInitial()) {
    on<LoadRewardsEvent>(_onLoadRewards);
    on<RedeemRewardEvent>(_onRedeemReward);
    on<RefreshUserCoinsEvent>(_onRefreshUserCoins);
  }

  Future<void> _onLoadRewards(
    LoadRewardsEvent event,
    Emitter<RewardState> emit,
  ) async {
    emit(RewardLoading());
    try {
      final rewards = await _repository.fetchRewards();
      final userCoins = await _repository.getUserCoins();

      emit(RewardsLoaded(rewards: rewards, userCoins: userCoins));
    } catch (e) {
      emit(RewardError(message: e.toString()));
    }
  }

  Future<void> _onRedeemReward(
    RedeemRewardEvent event,
    Emitter<RewardState> emit,
  ) async {
    if (state is! RewardsLoaded) return;

    final currentState = state as RewardsLoaded;
    emit(
      RewardRedeeming(
        rewards: currentState.rewards,
        userCoins: currentState.userCoins,
      ),
    );

    try {
      final result = await _repository.redeemReward(
        rewardId: event.rewardId,
        userInput: event.userInput,
      );

      // Update the reward list with the redeemed reward
      final updatedRewards =
          currentState.rewards.map((r) {
            if (r.id == event.rewardId) {
              return r.copyWith(
                status: RewardStatus.redeemed,
                redeemedAt: DateTime.now(),
                submittedInfo: event.userInput,
              );
            }
            return r;
          }).toList();

      emit(
        RewardRedemptionSuccess(
          message: result['message'] ?? 'Reward redeemed successfully!',
          redeemedReward: updatedRewards.firstWhere(
            (r) => r.id == event.rewardId,
          ),
          rewards: updatedRewards,
          userCoins: result['remainingCoins'] ?? currentState.userCoins,
        ),
      );

      // Transition back to loaded state after showing success
      await Future.delayed(const Duration(milliseconds: 500));
      emit(
        RewardsLoaded(
          rewards: updatedRewards,
          userCoins: result['remainingCoins'] ?? currentState.userCoins,
        ),
      );
    } catch (e) {
      emit(RewardError(message: e.toString()));

      // Revert to previous loaded state
      await Future.delayed(const Duration(milliseconds: 500));
      emit(
        RewardsLoaded(
          rewards: currentState.rewards,
          userCoins: currentState.userCoins,
        ),
      );
    }
  }

  Future<void> _onRefreshUserCoins(
    RefreshUserCoinsEvent event,
    Emitter<RewardState> emit,
  ) async {
    if (state is RewardsLoaded) {
      final currentState = state as RewardsLoaded;
      try {
        final userCoins = await _repository.getUserCoins();
        emit(
          RewardsLoaded(rewards: currentState.rewards, userCoins: userCoins),
        );
      } catch (e) {
        // Silently fail, keep current state
        print('Error refreshing coins: $e');
      }
    }
  }
}
