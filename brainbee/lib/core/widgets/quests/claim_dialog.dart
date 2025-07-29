import 'package:brainbee/presentation/views/extras/coinquests/models/quest.dart';
import 'package:brainbee/core/constants/bb_colors.dart';
import 'package:flutter/material.dart';

class ClaimDialog extends StatelessWidget {
  final Quest quest;
  final VoidCallback onConfirm;

  const ClaimDialog({super.key, required this.quest, required this.onConfirm});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: BBColors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      contentPadding: EdgeInsets.zero,
      titlePadding: EdgeInsets.zero,
      title: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [BBColors.primaryColor, BBColors.secondaryColor],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: BBColors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: BBColors.white.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Text(
                quest.iconUrl ?? '🎯',
                style: const TextStyle(fontSize: 18),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Claim Reward',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: BBColors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
      content: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Confirm claiming ${quest.coinReward} coins for completing "${quest.title}"?',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: BBColors.bodyText,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    BBColors.yellowAccent.withOpacity(0.1),
                    BBColors.yellowAccent.withOpacity(0.15),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: BBColors.yellowAccent.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.monetization_on,
                    color: BBColors.yellowAccent,
                    size: 24,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '+${quest.coinReward} Coins',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: BBColors.darkHeading,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Will be added to your wallet',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: BBColors.bodyText,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      actions: [
        Row(
          children: [
            Expanded(
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                style: TextButton.styleFrom(
                  foregroundColor: BBColors.bodyText,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: BorderSide(color: BBColors.borderGray, width: 1),
                  ),
                ),
                child: Text(
                  'Cancel',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: BBColors.bodyText,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton(
                onPressed: onConfirm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: BBColors.primaryColor,
                  foregroundColor: BBColors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 2,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.redeem, size: 16, color: BBColors.white),
                    const SizedBox(width: 6),
                    Text(
                      'Claim Now',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: BBColors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
