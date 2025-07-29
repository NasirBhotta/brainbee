// screens/quest_detail_screen.dart
import 'package:brainbee/core/utils/quest_extensions.dart';
import 'package:brainbee/core/widgets/quests/claim_dialog.dart';
import 'package:brainbee/core/constants/bb_colors.dart';
import 'package:flutter/material.dart';
import '../models/quest.dart';

class QuestDetailScreen extends StatelessWidget {
  final Quest quest;
  final VoidCallback onClaim;
  final bool isLoading;

  const QuestDetailScreen({
    super.key,
    required this.quest,
    required this.onClaim,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BBColors.lightGrayBG,
      appBar: AppBar(
        title: Text(
          'Quest Details',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: BBColors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: BBColors.secondaryColor,
        iconTheme: const IconThemeData(color: BBColors.white),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeaderSection(context),
            const SizedBox(height: 16),
            _buildDetailsSection(context),
            const SizedBox(height: 16),
            _buildProgressSection(context),
            const SizedBox(height: 16),
            _buildRewardSection(context),
            const SizedBox(height: 24),
            _buildActionButton(context),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderSection(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [BBColors.primaryColor, BBColors.secondaryColor],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: BBColors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(32),
                border: Border.all(
                  color: BBColors.white.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: Center(
                child: Text(
                  quest.iconUrl ?? '🎯',
                  style: const TextStyle(fontSize: 28),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              quest.title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: BBColors.white,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: BBColors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: BBColors.white.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Text(
                quest.type.displayName,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: BBColors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsSection(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: BBColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: BBColors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.description, color: BBColors.primaryColor, size: 18),
              const SizedBox(width: 6),
              Text(
                'Description',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: BBColors.darkHeading,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            quest.description,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: BBColors.bodyText,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          _buildDetailRow(
            context,
            'Quest Type',
            quest.type.displayName,
            Icons.category,
          ),
          const SizedBox(height: 10),
          _buildDetailRow(
            context,
            'Status',
            _getStatusText(),
            _getStatusIcon(),
          ),
          if (quest.completedAt != null) ...[
            const SizedBox(height: 10),
            _buildDetailRow(
              context,
              'Completed At',
              _formatDateTime(quest.completedAt!),
              Icons.check_circle,
            ),
          ],
          if (quest.claimedAt != null) ...[
            const SizedBox(height: 10),
            _buildDetailRow(
              context,
              'Claimed At',
              _formatDateTime(quest.claimedAt!),
              Icons.redeem,
            ),
          ],
          if (quest.resetTime != null && quest.type != QuestType.oneTime) ...[
            const SizedBox(height: 10),
            _buildDetailRow(
              context,
              'Resets At',
              _formatDateTime(quest.resetTime!),
              Icons.refresh,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Row(
      children: [
        Icon(icon, size: 14, color: BBColors.bodyText),
        const SizedBox(width: 6),
        Text(
          '$label: ',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w500,
            color: BBColors.bodyText,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: BBColors.darkHeading),
          ),
        ),
      ],
    );
  }

  Widget _buildProgressSection(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: BBColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: BBColors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.track_changes, color: BBColors.primaryColor, size: 18),
              const SizedBox(width: 6),
              Text(
                'Progress',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: BBColors.darkHeading,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 6,
                  decoration: BoxDecoration(
                    color: BBColors.borderGray,
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: _getProgressValue(),
                    child: Container(
                      decoration: BoxDecoration(
                        color: _getProgressColor(),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                '${(_getProgressValue() * 100).toInt()}%',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: _getProgressColor(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            _getProgressDescription(),
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: BBColors.bodyText),
          ),
        ],
      ),
    );
  }

  Widget _buildRewardSection(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            BBColors.primaryColor.withOpacity(0.08),
            BBColors.secondaryColor.withOpacity(0.08),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: BBColors.primaryColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.card_giftcard, color: BBColors.primaryColor, size: 20),
              const SizedBox(width: 6),
              Text(
                'Reward',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: BBColors.darkHeading,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: BBColors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: BBColors.primaryColor.withOpacity(0.1),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.monetization_on,
                  color: BBColors.primaryColor,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  '${quest.coinReward} Coins',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: BBColors.darkHeading,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          if (quest.isClaimed) ...[
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.check_circle,
                  color: BBColors.successGreen,
                  size: 14,
                ),
                const SizedBox(width: 4),
                Text(
                  'Already claimed',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: BBColors.successGreen,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionButton(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14),
      width: double.infinity,
      child: _buildDetailClaimButton(context),
    );
  }

  Widget _buildDetailClaimButton(BuildContext context) {
    if (quest.isIncomplete) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: BBColors.borderGray.withOpacity(0.5),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.hourglass_empty, color: BBColors.disabledText, size: 18),
            const SizedBox(width: 6),
            Text(
              'Quest In Progress',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: BBColors.disabledText,
              ),
            ),
          ],
        ),
      );
    } else if (quest.isClaimed) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: BBColors.successGreen.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: BBColors.successGreen.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, color: BBColors.successGreen, size: 20),
            const SizedBox(width: 6),
            Text(
              quest.type == QuestType.oneTime
                  ? 'Quest Completed'
                  : 'Reward Claimed',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: BBColors.successGreen,
              ),
            ),
          ],
        ),
      );
    } else if (quest.canClaim) {
      return ElevatedButton(
        onPressed: isLoading ? null : () => _showClaimDialog(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: BBColors.primaryColor,
          foregroundColor: BBColors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 2,
        ),
        child:
            isLoading
                ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          BBColors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Claiming...',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: BBColors.white,
                      ),
                    ),
                  ],
                )
                : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.redeem, size: 20, color: BBColors.white),
                    const SizedBox(width: 6),
                    Text(
                      'Claim ${quest.coinReward} Coins',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: BBColors.white,
                      ),
                    ),
                  ],
                ),
      );
    }

    return const SizedBox.shrink();
  }

  void _showClaimDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => ClaimDialog(
            quest: quest,
            onConfirm: () {
              Navigator.of(context).pop();
              onClaim();
            },
          ),
    );
  }

  double _getProgressValue() {
    switch (quest.status) {
      case QuestStatus.incomplete:
        return 0.0;
      case QuestStatus.complete:
        return 1.0;
      case QuestStatus.claimed:
        return 1.0;
    }
  }

  Color _getProgressColor() {
    switch (quest.status) {
      case QuestStatus.incomplete:
        return BBColors.disabledText;
      case QuestStatus.complete:
        return BBColors.primaryColor;
      case QuestStatus.claimed:
        return BBColors.successGreen;
    }
  }

  String _getProgressDescription() {
    switch (quest.status) {
      case QuestStatus.incomplete:
        return 'Keep working to complete this quest!';
      case QuestStatus.complete:
        return 'Quest completed! Ready to claim your reward.';
      case QuestStatus.claimed:
        return quest.type == QuestType.oneTime
            ? 'Quest permanently completed.'
            : 'Reward claimed! Quest will reset according to schedule.';
    }
  }

  String _getStatusText() {
    switch (quest.status) {
      case QuestStatus.incomplete:
        return 'In Progress';
      case QuestStatus.complete:
        return 'Ready to Claim';
      case QuestStatus.claimed:
        return quest.type == QuestType.oneTime ? 'Completed' : 'Claimed';
    }
  }

  IconData _getStatusIcon() {
    switch (quest.status) {
      case QuestStatus.incomplete:
        return Icons.hourglass_empty;
      case QuestStatus.complete:
        return Icons.check_circle_outline;
      case QuestStatus.claimed:
        return Icons.check_circle;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else {
      return 'Just now';
    }
  }
}
