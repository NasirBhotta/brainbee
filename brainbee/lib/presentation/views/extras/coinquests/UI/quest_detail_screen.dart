// screens/quest_detail_screen.dart
import 'package:brainbee/core/utils/quest_extensions.dart';
import 'package:brainbee/core/widgets/quests/claim_dialog.dart';
import 'package:brainbee/core/constants/bb_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/quest.dart';
import '../bloc/quest_bloc.dart';
import '../bloc/quest_event.dart';
import '../bloc/quest_state.dart';

class QuestDetailScreen extends StatelessWidget {
  final Quest quest;
  final String userId;

  const QuestDetailScreen({
    super.key,
    required this.quest,
    required this.userId,
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
      body: BlocConsumer<QuestBloc, QuestState>(
        listener: (context, state) {
          if (state is QuestClaimed) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  '+${state.coinsAdded} Coins added to your Wallet!',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: BBColors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                backgroundColor: BBColors.successGreen,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            );
            // Navigate back after successful claim
            Navigator.of(context).pop();
          } else if (state is QuestError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  state.message,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: BBColors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                backgroundColor: BBColors.alertRed,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            );
          }
        },
        builder: (context, state) {
          // Get the current quest from state if available
          Quest currentQuest = quest;
          bool isLoading = false;

          if (state is QuestLoaded ||
              state is QuestClaiming ||
              state is QuestClaimed) {
            final quests =
                state is QuestLoaded
                    ? state.quests
                    : state is QuestClaiming
                    ? state.quests
                    : (state as QuestClaimed).quests;

            // Find the updated quest in the current state
            final updatedQuest = quests.firstWhere(
              (q) => q.id == quest.id,
              orElse: () => quest,
            );
            currentQuest = updatedQuest;

            // Check if this specific quest is being claimed
            isLoading =
                state is QuestClaiming && (state).claimingQuestId == quest.id;
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                _buildHeaderSection(context, currentQuest),
                const SizedBox(height: 16),
                _buildDetailsSection(context, currentQuest),
                const SizedBox(height: 16),
                _buildProgressSection(context, currentQuest),
                const SizedBox(height: 16),
                _buildRewardSection(context, currentQuest),
                const SizedBox(height: 24),
                _buildActionButton(context, currentQuest, isLoading),
                const SizedBox(height: 16),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeaderSection(BuildContext context, Quest currentQuest) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Simple icon container
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: BBColors.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(
                currentQuest.iconUrl ?? '🎯',
                style: const TextStyle(fontSize: 32),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Title
          Text(
            currentQuest.title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 12),

          // Simple type indicator
          Text(
            currentQuest.type.displayName,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: BBColors.primaryColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsSection(BuildContext context, Quest currentQuest) {
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
            currentQuest.description,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: BBColors.bodyText,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          _buildDetailRow(
            context,
            'Quest Type',
            currentQuest.type.displayName,
            Icons.category,
          ),
          const SizedBox(height: 10),
          _buildDetailRow(
            context,
            'Status',
            _getStatusText(currentQuest),
            _getStatusIcon(currentQuest),
          ),
          if (currentQuest.completedAt != null) ...[
            const SizedBox(height: 10),
            _buildDetailRow(
              context,
              'Completed At',
              _formatDateTime(currentQuest.completedAt!),
              Icons.check_circle,
            ),
          ],
          if (currentQuest.claimedAt != null) ...[
            const SizedBox(height: 10),
            _buildDetailRow(
              context,
              'Claimed At',
              _formatDateTime(currentQuest.claimedAt!),
              Icons.redeem,
            ),
          ],
          if (currentQuest.resetTime != null &&
              currentQuest.type != QuestType.oneTime) ...[
            const SizedBox(height: 10),
            _buildDetailRow(
              context,
              'Resets At',
              _formatDateTime(currentQuest.resetTime!),
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

  Widget _buildProgressSection(BuildContext context, Quest currentQuest) {
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
                    widthFactor: _getProgressValue(currentQuest),
                    child: Container(
                      decoration: BoxDecoration(
                        color: _getProgressColor(currentQuest),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                '${(_getProgressValue(currentQuest) * 100).toInt()}%',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: _getProgressColor(currentQuest),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            _getProgressDescription(currentQuest),
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: BBColors.bodyText),
          ),
        ],
      ),
    );
  }

  Widget _buildRewardSection(BuildContext context, Quest currentQuest) {
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
                  '${currentQuest.coinReward} Coins',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: BBColors.darkHeading,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          if (currentQuest.isClaimed) ...[
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

  Widget _buildActionButton(
    BuildContext context,
    Quest currentQuest,
    bool isLoading,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14),
      width: double.infinity,
      child: _buildDetailClaimButton(context, currentQuest, isLoading),
    );
  }

  Widget _buildDetailClaimButton(
    BuildContext context,
    Quest currentQuest,
    bool isLoading,
  ) {
    if (currentQuest.isIncomplete) {
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
    } else if (currentQuest.isClaimed) {
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
              currentQuest.type == QuestType.oneTime
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
    } else if (currentQuest.canClaim) {
      return ElevatedButton(
        onPressed:
            isLoading ? null : () => _showClaimDialog(context, currentQuest),
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
                      'Claim ${currentQuest.coinReward} Coins',
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

  void _showClaimDialog(BuildContext context, Quest currentQuest) {
    showDialog(
      context: context,
      builder:
          (context) => ClaimDialog(
            quest: currentQuest,
            onConfirm: () {
              Navigator.of(context).pop();
              context.read<QuestBloc>().add(ClaimQuest(userId, currentQuest));
            },
          ),
    );
  }

  double _getProgressValue(Quest currentQuest) {
    switch (currentQuest.status) {
      case QuestStatus.incomplete:
        return 0.0;
      case QuestStatus.complete:
        return 1.0;
      case QuestStatus.claimed:
        return 1.0;
    }
  }

  Color _getProgressColor(Quest currentQuest) {
    switch (currentQuest.status) {
      case QuestStatus.incomplete:
        return BBColors.disabledText;
      case QuestStatus.complete:
        return BBColors.primaryColor;
      case QuestStatus.claimed:
        return BBColors.successGreen;
    }
  }

  String _getProgressDescription(Quest currentQuest) {
    switch (currentQuest.status) {
      case QuestStatus.incomplete:
        return 'Keep working to complete this quest!';
      case QuestStatus.complete:
        return 'Quest completed! Ready to claim your reward.';
      case QuestStatus.claimed:
        return currentQuest.type == QuestType.oneTime
            ? 'Quest permanently completed.'
            : 'Reward claimed! Quest will reset according to schedule.';
    }
  }

  String _getStatusText(Quest currentQuest) {
    switch (currentQuest.status) {
      case QuestStatus.incomplete:
        return 'In Progress';
      case QuestStatus.complete:
        return 'Ready to Claim';
      case QuestStatus.claimed:
        return currentQuest.type == QuestType.oneTime ? 'Completed' : 'Claimed';
    }
  }

  IconData _getStatusIcon(Quest currentQuest) {
    switch (currentQuest.status) {
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
