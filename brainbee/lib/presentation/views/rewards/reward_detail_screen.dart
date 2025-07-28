import 'package:flutter/material.dart';
import 'package:brainbee/core/constants/bb_colors.dart';
import 'package:brainbee/core/models/reward_model.dart';
import 'package:brainbee/presentation/views/rewards/widgets/redemption_bottom_sheet.dart';

class RewardDetailScreen extends StatefulWidget {
  final RewardModel reward;
  final int currentCoins;
  final Function(RewardModel redeemedReward, int coinsDeducted) onRedemptionSuccess;

  const RewardDetailScreen({
    super.key,
    required this.reward,
    required this.currentCoins,
    required this.onRedemptionSuccess,
  });

  @override
  State<RewardDetailScreen> createState() => _RewardDetailScreenState();
}

class _RewardDetailScreenState extends State<RewardDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final canAfford = widget.currentCoins >= widget.reward.coinPrice;
    final isRedeemed = widget.reward.status == RewardStatus.redeemed;
    final isAvailable = widget.reward.status == RewardStatus.available;

    return Scaffold(
      backgroundColor: BBColors.lightGrayBG,
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            backgroundColor: BBColors.secondaryColor,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [BBColors.primaryColor, BBColors.secondaryColor],
                  ),
                ),
                child: Center(
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: BBColors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Icon(
                      _getRewardIcon(),
                      color: BBColors.secondaryColor,
                      size: 64,
                    ),
                  ),
                ),
              ),
            ),
            actions: [
              Container(
                margin: const EdgeInsets.only(right: 16, top: 8),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: BBColors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.monetization_on,
                      color: BBColors.secondaryColor,
                      size: 18,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${widget.currentCoins}',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: BBColors.secondaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and Price
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.reward.title,
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: BBColors.darkHeading,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [BBColors.primaryColor, BBColors.secondaryColor],
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.monetization_on,
                                    color: BBColors.white,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    '${widget.reward.coinPrice} Coins',
                                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                      color: BBColors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isRedeemed)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: BBColors.successGreen,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.check_circle,
                                color: BBColors.white,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Redeemed',
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
                  const SizedBox(height: 24),
                  // Description
                  _buildSection(
                    'Description',
                    widget.reward.description,
                  ),
                  const SizedBox(height: 20),
                  // Redemption Instructions
                  _buildSection(
                    'How to Redeem',
                    widget.reward.redemptionInstructions,
                  ),
                  const SizedBox(height: 20),
                  // Terms & Conditions
                  _buildSection(
                    'Terms & Conditions',
                    widget.reward.termsAndConditions,
                  ),
                  const SizedBox(height: 20),
                  // Redeemed Info (if applicable)
                  if (isRedeemed && widget.reward.redeemedAt != null) ...[
                    _buildSection(
                      'Redemption Details',
                      'Redeemed on ${_formatDate(widget.reward.redeemedAt!)}' +
                          (widget.reward.submittedInfo != null 
                            ? '\nSubmitted: ${widget.reward.submittedInfo}'
                            : ''),
                    ),
                    const SizedBox(height: 20),
                  ],
                  // Insufficient Coins Warning
                  if (!canAfford && isAvailable)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: BBColors.alertRed.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: BBColors.alertRed.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.warning_amber_rounded,
                            color: BBColors.alertRed,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Insufficient Coins',
                                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                    color: BBColors.alertRed,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'You need ${widget.reward.coinPrice - widget.currentCoins} more coins to redeem this reward.',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: BBColors.alertRed,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 100), // Space for bottom button
                ],
              ),
            ),
          ),
        ],
      ),
      // Floating Action Button / Redeem Button
      floatingActionButton: _buildRedeemButton(context, canAfford, isRedeemed, isAvailable),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildSection(String title, String content) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: BBColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: BBColors.darkHeading,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: BBColors.bodyText,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRedeemButton(BuildContext context, bool canAfford, bool isRedeemed, bool isAvailable) {
    Color buttonColor;
    String buttonText;
    IconData buttonIcon;
    bool isEnabled;

    if (isRedeemed) {
      buttonColor = BBColors.successGreen;
      buttonText = 'Already Redeemed';
      buttonIcon = Icons.check_circle;
      isEnabled = false;
    } else if (!canAfford) {
      buttonColor = BBColors.disabledText;
      buttonText = 'Insufficient Coins';
      buttonIcon = Icons.lock;
      isEnabled = false;
    } else {
      buttonColor = BBColors.primaryColor;
      buttonText = 'Redeem Now';
      buttonIcon = Icons.redeem;
      isEnabled = true;
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: ElevatedButton(
        onPressed: isEnabled ? () => _showRedemptionBottomSheet(context) : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonColor,
          foregroundColor: BBColors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: isEnabled ? 8 : 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(buttonIcon, size: 24),
            const SizedBox(width: 8),
            Text(
              buttonText,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: BBColors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showRedemptionBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => RedemptionBottomSheet(
        reward: widget.reward,
        currentCoins: widget.currentCoins,
        onRedemptionSuccess: widget.onRedemptionSuccess,
      ),
    );
  }

  IconData _getRewardIcon() {
    switch (widget.reward.title.toLowerCase()) {
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}