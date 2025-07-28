import 'package:flutter/material.dart';
import 'package:brainbee/core/constants/bb_colors.dart';
import 'package:brainbee/core/models/reward_model.dart';

class RewardCard extends StatelessWidget {
  final RewardModel reward;
  final VoidCallback onTap;

  const RewardCard({
    super.key,
    required this.reward,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: BBColors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image and status badge
            Stack(
              children: [
                Container(
                  height: 120,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        BBColors.primaryColor.withOpacity(0.1),
                        BBColors.secondaryColor.withOpacity(0.1),
                      ],
                    ),
                  ),
                  child: Center(
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [BBColors.primaryColor, BBColors.secondaryColor],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        _getRewardIcon(),
                        color: BBColors.white,
                        size: 32,
                      ),
                    ),
                  ),
                ),
                // Status badge
                if (reward.status == RewardStatus.redeemed)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: BBColors.successGreen,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Redeemed',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: BBColors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                if (reward.status == RewardStatus.insufficientCoins)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: BBColors.alertRed,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Insufficient',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: BBColors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      reward.title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: BBColors.darkHeading,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    // Description
                    Text(
                      reward.description,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: BBColors.bodyText,
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    // Price and button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: BBColors.primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.monetization_on,
                                color: BBColors.primaryColor,
                                size: 14,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                '${reward.coinPrice}',
                                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: BBColors.primaryColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: _getButtonColor(),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            _getButtonIcon(),
                            color: BBColors.white,
                            size: 16,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getRewardIcon() {
    switch (reward.title.toLowerCase()) {
      case 'pubg mobile uc':
        return Icons.sports_esports;
      case 'amazon gift card':
        return Icons.card_giftcard;
      case 'spotify premium':
        return Icons.music_note;
      case 'netflix subscription':
        return Icons.movie;
      case 'gaming mouse':
        return Icons.mouse;
      case 'discord nitro':
        return Icons.chat;
      default:
        return Icons.redeem;
    }
  }

  Color _getButtonColor() {
    switch (reward.status) {
      case RewardStatus.available:
        return BBColors.primaryColor;
      case RewardStatus.redeemed:
        return BBColors.successGreen;
      case RewardStatus.insufficientCoins:
        return BBColors.disabledText;
    }
  }

  IconData _getButtonIcon() {
    switch (reward.status) {
      case RewardStatus.available:
        return Icons.arrow_forward;
      case RewardStatus.redeemed:
        return Icons.check;
      case RewardStatus.insufficientCoins:
        return Icons.lock;
    }
  }
}