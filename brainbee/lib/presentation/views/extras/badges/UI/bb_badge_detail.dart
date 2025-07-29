// lib/screens/badge_detail_screen.dart
import 'package:brainbee/core/utils/bb_date_formatter.dart';
import 'package:brainbee/core/widgets/badges/badge_icon_widget.dart';
import 'package:flutter/material.dart';
import '../models/badge_model.dart';

class BadgeDetailScreen extends StatelessWidget {
  final BbBadge badge;

  const BadgeDetailScreen({super.key, required this.badge});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          badge.name,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: Colors.grey[200]),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Badge hero section
            Container(
              width: double.infinity,
              color: Colors.white,
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
                                  color: Colors.blue.withOpacity(0.3),
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
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
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
                              ? Colors.green.withOpacity(0.1)
                              : Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: badge.isEarned ? Colors.green : Colors.grey,
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
                              badge.isEarned ? Colors.green : Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          badge.isEarned ? 'Earned' : 'Not Earned',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color:
                                badge.isEarned
                                    ? Colors.green
                                    : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Earned date
                  if (badge.isEarned && badge.earnedDate != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      'Earned on ${DateFormatter.formatBadgeDate((badge.earnedDate!))}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
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
              content: badge.category.name,
              icon: _getCategoryIcon(badge.category),
            ),

            // Progress section for unearned badges
            if (!badge.isEarned) ...[
              const SizedBox(height: 12),
              _ProgressCard(badge: badge),
            ],

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  IconData _getCategoryIcon(BbBadgeCategory category) {
    switch (category) {
      case BbBadgeCategory.score:
        return Icons.star_outline;
      case BbBadgeCategory.streak:
        return Icons.local_fire_department_outlined;
      case BbBadgeCategory.achievement:
        return Icons.emoji_events_outlined;
      case BbBadgeCategory.participation:
        return Icons.people_outline;
      case BbBadgeCategory.milestone:
        return Icons.flag_outlined;
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
        color: Colors.white,
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
              Icon(icon, size: 20, color: Colors.blue),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
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
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.withOpacity(0.2), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.trending_up, size: 20, color: Colors.blue),
              const SizedBox(width: 8),
              const Text(
                'Keep Going!',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Complete the required actions to unlock this badge and add it to your collection.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.blue[700],
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),

          // Motivational CTA
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'Start Learning',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
