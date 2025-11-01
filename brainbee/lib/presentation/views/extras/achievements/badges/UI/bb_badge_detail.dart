// ==========================================
// COMPLETE FILE: lib/presentation/views/extras/achievements/badges/screens/badge_detail_screen.dart
// ==========================================
import 'package:brainbee/core/constants/bb_colors.dart';
import 'package:brainbee/core/utils/bb_date_formatter.dart';
import 'package:brainbee/core/utils/badge_utills/badge_utills.dart';
import 'package:brainbee/core/widgets/badges/badge_icon_widget.dart';
import 'package:brainbee/presentation/views/extras/achievements/badges/models/badge_model.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BadgeDetailScreen extends StatelessWidget {
  final BbBadge badge;

  const BadgeDetailScreen({super.key, required this.badge});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BBColors.lightGrayBG,
      appBar: AppBar(
        title: Text(
          badge.name,
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 18),
        ),
        backgroundColor: BBColors.white,
        foregroundColor: BBColors.darkHeading,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: BBColors.borderGray),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Badge hero section
            Container(
              width: double.infinity,
              color: BBColors.white,
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  // Badge icon with glow effect for earned badges
                  Container(
                    decoration:
                        badge.isEarned
                            ? BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: BBColors.primaryColor.withOpacity(0.3),
                                  blurRadius: 20,
                                  spreadRadius: 5,
                                ),
                              ],
                            )
                            : null,
                    child: BadgeIconWidget(
                      badge: badge,
                      size: 120,
                      showEarnedIndicator: false,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Badge name
                  Text(
                    badge.name,
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: BBColors.darkHeading,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),

                  // Badge status
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color:
                          badge.isEarned
                              ? BBColors.successGreen.withOpacity(0.1)
                              : BBColors.disabledText.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color:
                            badge.isEarned
                                ? BBColors.successGreen
                                : BBColors.disabledText,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          badge.isEarned
                              ? Icons.check_circle
                              : Icons.lock_outline,
                          size: 16,
                          color:
                              badge.isEarned
                                  ? BBColors.successGreen
                                  : BBColors.disabledText,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          badge.isEarned ? 'Earned' : 'Not Earned',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color:
                                badge.isEarned
                                    ? BBColors.successGreen
                                    : BBColors.disabledText,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Earned date
                  if (badge.isEarned && badge.earnedDate != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      'Earned on ${DateFormatter.formatBadgeDate(badge.earnedDate!)}',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: BBColors.bodyText,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Badge details
            _DetailCard(
              title: 'Description',
              content: badge.description,
              icon: Icons.info_outline,
            ),

            const SizedBox(height: 12),

            _DetailCard(
              title: 'How to Earn',
              content: badge.earningCriteria,
              icon: Icons.assignment_outlined,
            ),

            const SizedBox(height: 12),

            _DetailCard(
              title: 'Category',
              content: _getCategoryDisplayName(badge.category),
              icon: BadgeUtils.getCategoryIcon(badge.category),
            ),

            // Progress section for unearned badges
            if (!badge.isEarned && badge.currentProgress > 0) ...[
              const SizedBox(height: 12),
              _ProgressCard(badge: badge),
            ],

            // Motivational section for unearned badges with no progress
            if (!badge.isEarned && badge.currentProgress == 0) ...[
              const SizedBox(height: 12),
              _MotivationalCard(),
            ],

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  String _getCategoryDisplayName(BbBadgeCategory category) {
    switch (category) {
      case BbBadgeCategory.score:
        return 'Score Achievement';
      case BbBadgeCategory.streak:
        return 'Streak Achievement';
      case BbBadgeCategory.achievement:
        return 'General Achievement';
      case BbBadgeCategory.participation:
        return 'Participation';
      case BbBadgeCategory.milestone:
        return 'Milestone';
    }
  }
}

class _DetailCard extends StatelessWidget {
  final String title;
  final String content;
  final IconData icon;

  const _DetailCard({
    required this.title,
    required this.content,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: BBColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: BBColors.primaryColor),
              const SizedBox(width: 8),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: BBColors.darkHeading,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: BBColors.bodyText,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressCard extends StatelessWidget {
  final BbBadge badge;

  const _ProgressCard({required this.badge});

  @override
  Widget build(BuildContext context) {
    final progressPercentage = badge.progressPercentage;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: BBColors.primaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: BBColors.primaryColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.trending_up, size: 20, color: BBColors.primaryColor),
              const SizedBox(width: 8),
              Text(
                'Your Progress',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: BBColors.primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Progress',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: BBColors.bodyText,
                ),
              ),
              Text(
                '${badge.currentProgress}/${badge.targetValue}',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: BBColors.primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progressPercentage,
              backgroundColor: BBColors.borderGray,
              valueColor: AlwaysStoppedAnimation<Color>(BBColors.primaryColor),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 6),

          Text(
            '${(progressPercentage * 100).toInt()}% complete',
            style: GoogleFonts.poppins(fontSize: 12, color: BBColors.bodyText),
          ),
          const SizedBox(height: 12),

          Text(
            'Keep going! You\'re making great progress towards earning this badge.',
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: BBColors.bodyText,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _MotivationalCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            BBColors.primaryColor.withOpacity(0.1),
            BBColors.secondaryColor.withOpacity(0.1),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.rocket_launch, size: 20, color: BBColors.primaryColor),
              const SizedBox(width: 8),
              Text(
                'Ready to Start?',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: BBColors.primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Complete the required activities to unlock this badge and add it to your collection. Every step brings you closer to your goal!',
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: BBColors.bodyText,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: BBColors.primaryColor,
                foregroundColor: BBColors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Start Learning',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
