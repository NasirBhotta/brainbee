import 'package:brainbee/presentation/views/extras/Rewards/models/reward.dart';
import 'package:flutter/material.dart';
import 'package:brainbee/core/constants/bb_colors.dart';
import 'package:brainbee/core/utils/bb_text.dart';

class RewardCard extends StatelessWidget {
  final RewardModel reward;
  final VoidCallback onTap;

  const RewardCard({super.key, required this.reward, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isRedeemed = reward.status == RewardStatus.redeemed;
    final isInsufficient = reward.status == RewardStatus.insufficientCoins;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: BBColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color:
                isRedeemed
                    ? BBColors.successGreen
                    : isInsufficient
                    ? BBColors.alertRed.withOpacity(0.3)
                    : BBColors.borderGray,
            width: isRedeemed ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image placeholder
                Container(
                  height: 120,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        BBColors.primaryColor.withOpacity(0.3),
                        BBColors.secondaryColor.withOpacity(0.3),
                      ],
                    ),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      _getRewardIcon(),
                      size: 48,
                      color: BBColors.primaryColor,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        reward.title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: BBColors.darkHeading,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(
                            Icons.monetization_on,
                            size: 16,
                            color: BBColors.primaryColor,
                          ),
                          const SizedBox(width: 4),
                          BBText(
                            data: '${reward.coinPrice}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: BBColors.primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            // Status badge
            if (isRedeemed || isInsufficient)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color:
                        isRedeemed ? BBColors.successGreen : BBColors.alertRed,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isRedeemed ? Icons.check : Icons.lock,
                        size: 12,
                        color: BBColors.white,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        isRedeemed ? 'Redeemed' : 'Locked',
                        style: const TextStyle(
                          color: BBColors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
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
}
