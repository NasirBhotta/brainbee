import 'package:flutter/material.dart';
import 'package:brainbee/core/constants/bb_colors.dart';
import 'package:brainbee/core/models/reward_model.dart';
import 'package:brainbee/presentation/views/rewards/widgets/reward_card.dart';
import 'package:brainbee/presentation/views/rewards/reward_detail_screen.dart';

class RewardCatalogScreen extends StatefulWidget {
  const RewardCatalogScreen({super.key});

  @override
  State<RewardCatalogScreen> createState() => _RewardCatalogScreenState();
}

class _RewardCatalogScreenState extends State<RewardCatalogScreen> {
  // Mock data - will be replaced with actual data source
  final List<RewardModel> rewards = [
    RewardModel(
      id: '1',
      title: 'PUBG Mobile UC',
      description: 'Get 300 UC for PUBG Mobile to unlock premium items and battle passes.',
      imageUrl: 'https://via.placeholder.com/150x150/87DB8B/FFFFFF?text=PUBG',
      coinPrice: 500,
      status: RewardStatus.available,
      redemptionInstructions: 'Enter your PUBG Mobile ID and we will send UC directly to your account within 24 hours.',
      termsAndConditions: 'Valid for PUBG Mobile accounts only. UC will be delivered within 24 hours. This is a one-time reward per student.',
      requiresUserInput: true,
      inputLabel: 'PUBG Mobile ID',
      inputPlaceholder: 'Enter your PUBG Mobile ID',
    ),
    RewardModel(
      id: '2',
      title: 'Amazon Gift Card',
      description: 'Get a \$10 Amazon gift card to shop for anything you want.',
      imageUrl: 'https://via.placeholder.com/150x150/4BB69A/FFFFFF?text=Amazon',
      coinPrice: 800,
      status: RewardStatus.available,
      redemptionInstructions: 'Enter your email address and we will send the Amazon gift card code within 48 hours.',
      termsAndConditions: 'Gift card valid for Amazon purchases only. Code will be sent via email within 48 hours. This is a one-time reward per student.',
      requiresUserInput: true,
      inputLabel: 'Email Address',
      inputPlaceholder: 'Enter your email address',
    ),
    RewardModel(
      id: '3',
      title: 'Spotify Premium',
      description: 'Get 1 month of Spotify Premium subscription for unlimited music.',
      imageUrl: 'https://via.placeholder.com/150x150/87DB8B/FFFFFF?text=Spotify',
      coinPrice: 300,
      status: RewardStatus.redeemed,
      redemptionInstructions: 'Enter your Spotify email and we will upgrade your account to Premium.',
      termsAndConditions: 'Valid for existing Spotify accounts only. Premium access will be activated within 12 hours.',
      requiresUserInput: true,
      inputLabel: 'Spotify Email',
      inputPlaceholder: 'Enter your Spotify email',
      redeemedAt: DateTime.now().subtract(const Duration(days: 2)),
      submittedInfo: 'user@example.com',
    ),
    RewardModel(
      id: '4',
      title: 'Netflix Subscription',
      description: 'Get 1 month of Netflix Basic subscription to watch unlimited movies and shows.',
      imageUrl: 'https://via.placeholder.com/150x150/4BB69A/FFFFFF?text=Netflix',
      coinPrice: 1200,
      status: RewardStatus.available,
      redemptionInstructions: 'Enter your email address and we will send you Netflix subscription details.',
      termsAndConditions: 'Netflix subscription valid for 1 month from activation date. Account details will be sent via email.',
      requiresUserInput: true,
      inputLabel: 'Email Address',
      inputPlaceholder: 'Enter your email address',
    ),
    RewardModel(
      id: '5',
      title: 'Gaming Mouse',
      description: 'High-performance gaming mouse with RGB lighting and customizable buttons.',
      imageUrl: 'https://via.placeholder.com/150x150/87DB8B/FFFFFF?text=Mouse',
      coinPrice: 2000,
      status: RewardStatus.insufficientCoins,
      redemptionInstructions: 'Enter your shipping address and we will deliver the gaming mouse within 7-10 business days.',
      termsAndConditions: 'Free shipping within the country. Delivery takes 7-10 business days. This is a one-time reward per student.',
      requiresUserInput: true,
      inputLabel: 'Shipping Address',
      inputPlaceholder: 'Enter your complete shipping address',
    ),
    RewardModel(
      id: '6',
      title: 'Discord Nitro',
      description: 'Get 1 month of Discord Nitro for enhanced chat features and custom emojis.',
      imageUrl: 'https://via.placeholder.com/150x150/4BB69A/FFFFFF?text=Discord',
      coinPrice: 250,
      status: RewardStatus.available,
      redemptionInstructions: 'Enter your Discord username and we will send you a Nitro gift link.',
      termsAndConditions: 'Valid for existing Discord accounts only. Nitro will be activated within 24 hours.',
      requiresUserInput: true,
      inputLabel: 'Discord Username',
      inputPlaceholder: 'Enter your Discord username',
    ),
  ];

  int currentCoins = 750; // Mock user coin balance

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BBColors.lightGrayBG,
      appBar: AppBar(
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
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
                  '$currentCoins',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: BBColors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Header gradient
          Container(
            height: 80,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [BBColors.secondaryColor, BBColors.lightGrayBG],
              ),
            ),
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
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.75,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: rewards.length,
                itemBuilder: (context, index) {
                  final reward = rewards[index];
                  final canAfford = currentCoins >= reward.coinPrice;
                  final updatedReward = reward.status == RewardStatus.available && !canAfford
                      ? reward.copyWith(status: RewardStatus.insufficientCoins)
                      : reward;
                  
                  return RewardCard(
                    reward: updatedReward,
                    onTap: () => _navigateToRewardDetail(updatedReward),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToRewardDetail(RewardModel reward) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RewardDetailScreen(
          reward: reward,
          currentCoins: currentCoins,
          onRedemptionSuccess: (redeemedReward, coinsDeducted) {
            setState(() {
              currentCoins -= coinsDeducted;
              // Update the reward status in the list
              final index = rewards.indexWhere((r) => r.id == redeemedReward.id);
              if (index != -1) {
                rewards[index] = redeemedReward;
              }
            });
          },
        ),
      ),
    );
  }
}