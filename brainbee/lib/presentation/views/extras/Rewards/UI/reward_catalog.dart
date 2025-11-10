import 'package:brainbee/presentation/views/extras/Rewards/UI/reward_detail.dart';
import 'package:brainbee/presentation/views/extras/Rewards/models/reward.dart';
import 'package:brainbee/presentation/views/extras/Rewards/bloc/reward_bloc.dart';
import 'package:brainbee/core/widgets/reward/reward_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:brainbee/core/constants/bb_colors.dart';

class RewardCatalogScreen extends StatefulWidget {
  const RewardCatalogScreen({super.key});

  @override
  State<RewardCatalogScreen> createState() => _RewardCatalogScreenState();
}

class _RewardCatalogScreenState extends State<RewardCatalogScreen> {
  @override
  void initState() {
    super.initState();
    // Load rewards when screen opens
    context.read<RewardBloc>().add(LoadRewardsEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BBColors.lightGrayBG,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: BBColors.white),
          onPressed: () => Navigator.of(context).pop(true),
        ),
        title: Text(
          'Reward Store',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: BBColors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: BBColors.secondaryColor,
        elevation: 0,
        centerTitle: true,
        actions: [
          BlocBuilder<RewardBloc, RewardState>(
            builder: (context, state) {
              int coins = 0;
              if (state is RewardsLoaded) {
                coins = state.userCoins;
              } else if (state is RewardRedeeming) {
                coins = state.userCoins;
              }

              return Container(
                margin: const EdgeInsets.only(right: 16),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: BBColors.primaryColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.monetization_on,
                      color: BBColors.white,
                      size: 18,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$coins',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: BBColors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: BlocConsumer<RewardBloc, RewardState>(
        listener: (context, state) {
          if (state is RewardRedemptionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: BBColors.successGreen,
                duration: const Duration(seconds: 3),
              ),
            );
          } else if (state is RewardError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: BBColors.alertRed,
                duration: const Duration(seconds: 3),
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is RewardLoading || state is RewardInitial) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  BBColors.primaryColor,
                ),
              ),
            );
          }

          if (state is RewardError && state is! RewardsLoaded) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: BBColors.alertRed),
                  const SizedBox(height: 16),
                  Text(
                    'Failed to load rewards',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.message,
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      context.read<RewardBloc>().add(LoadRewardsEvent());
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: BBColors.primaryColor,
                    ),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          List<RewardModel> rewards = [];
          int currentCoins = 0;

          if (state is RewardsLoaded) {
            rewards = state.rewards;
            currentCoins = state.userCoins;
          } else if (state is RewardRedeeming) {
            rewards = state.rewards;
            currentCoins = state.userCoins;
          } else if (state is RewardRedemptionSuccess) {
            rewards = state.rewards;
            currentCoins = state.userCoins;
          }

          if (rewards.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.redeem, size: 64, color: BBColors.disabledText),
                  const SizedBox(height: 16),
                  Text(
                    'No rewards available',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Header
              SizedBox(
                height: 80,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      'Redeem your coins for amazing rewards!',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: BBColors.darkHeading,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
              // Rewards grid
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    context.read<RewardBloc>().add(LoadRewardsEvent());
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.75,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                          ),
                      itemCount: rewards.length,
                      itemBuilder: (context, index) {
                        final reward = rewards[index];
                        final canAfford = currentCoins >= reward.coinPrice;
                        final updatedReward =
                            reward.status == RewardStatus.available &&
                                    !canAfford
                                ? reward.copyWith(
                                  status: RewardStatus.insufficientCoins,
                                )
                                : reward;

                        return RewardCard(
                          reward: updatedReward,
                          onTap:
                              () => _navigateToRewardDetail(
                                context,
                                updatedReward,
                                currentCoins,
                              ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _navigateToRewardDetail(
    BuildContext context,
    RewardModel reward,
    int currentCoins,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) =>
                RewardDetailScreen(reward: reward, currentCoins: currentCoins),
      ),
    );
  }
}
