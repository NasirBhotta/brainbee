import 'package:brainbee/presentation/views/extras/coinquests/UI/quest_detail_screen.dart';
import 'package:brainbee/presentation/views/extras/coinquests/models/quest.dart';
import 'package:brainbee/core/constants/bb_colors.dart';
import 'package:flutter/material.dart';

class QuestCard extends StatelessWidget {
  final Quest quest;
  final VoidCallback onClaim;
  final bool isLoading;

  const QuestCard({
    super.key,
    required this.quest,
    required this.onClaim,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 1,
      color: BBColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: BBColors.borderGray.withOpacity(0.3), width: 1),
      ),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder:
                  (context) => QuestDetailScreen(
                    quest: quest,
                    onClaim: onClaim,
                    isLoading: isLoading,
                  ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              // Quest Icon
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: _getStatusColor().withOpacity(0.1),
                  borderRadius: BorderRadius.circular(21),
                  border: Border.all(
                    color: _getStatusColor().withOpacity(0.3),
                    width: 1.5,
                  ),
                ),
                child: Center(
                  child: Text(
                    quest.iconUrl ?? '🎯',
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
              ),
              const SizedBox(width: 14),

              // Quest Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      quest.title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: BBColors.darkHeading,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      quest.description,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: BBColors.bodyText),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          Icons.monetization_on,
                          size: 14,
                          color: BBColors.primaryColor,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          '${quest.coinReward} coins',
                          style: Theme.of(
                            context,
                          ).textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w500,
                            color: BBColors.darkHeading,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Action Button
              _buildActionButton(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(BuildContext context) {
    if (quest.isIncomplete) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: BBColors.borderGray.withOpacity(0.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.hourglass_empty, size: 12, color: BBColors.disabledText),
            const SizedBox(width: 4),
            Text(
              'In Progress',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: BBColors.disabledText,
                fontWeight: FontWeight.w500,
                fontSize: 11,
              ),
            ),
          ],
        ),
      );
    } else if (quest.isClaimed) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: BBColors.successGreen.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: BBColors.successGreen.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle, size: 12, color: BBColors.successGreen),
            const SizedBox(width: 4),
            Text(
              'Claimed',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: BBColors.successGreen,
                fontWeight: FontWeight.w500,
                fontSize: 11,
              ),
            ),
          ],
        ),
      );
    } else if (quest.canClaim) {
      return ElevatedButton(
        onPressed: isLoading ? null : onClaim,
        style: ElevatedButton.styleFrom(
          backgroundColor: BBColors.primaryColor,
          foregroundColor: BBColors.white,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 1,
          minimumSize: Size.zero,
        ),
        child:
            isLoading
                ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(
                      width: 12,
                      height: 12,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          BBColors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Claiming...',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: BBColors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                      ),
                    ),
                  ],
                )
                : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.redeem, size: 12, color: BBColors.white),
                    const SizedBox(width: 4),
                    Text(
                      'Claim Now',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: BBColors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
      );
    }

    return const SizedBox.shrink();
  }

  Color _getStatusColor() {
    switch (quest.status) {
      case QuestStatus.incomplete:
        return BBColors.disabledText;
      case QuestStatus.complete:
        return BBColors.primaryColor;
      case QuestStatus.claimed:
        return BBColors.successGreen;
    }
  }

  // String _getStatusText() {
  //   switch (quest.status) {
  //     case QuestStatus.incomplete:
  //       return 'Incomplete';
  //     case QuestStatus.complete:
  //       return 'Ready';
  //     case QuestStatus.claimed:
  //       return quest.type == QuestType.oneTime ? 'Done' : 'Claimed';
  //   }
  // }
}
