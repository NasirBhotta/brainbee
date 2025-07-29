import 'package:brainbee/core/constants/bb_colors.dart';
import 'package:brainbee/presentation/views/extras/badges/models/badge_model.dart';
import 'package:flutter/material.dart';

class BadgeUtils {
  static Color getCategoryColor(BbBadgeCategory category) {
    switch (category) {
      case BbBadgeCategory.score:
        return BBColors.primaryColor; // Green
      case BbBadgeCategory.streak:
        return BBColors.secondaryColor; // Teal
      case BbBadgeCategory.achievement:
        return BBColors
            .successGreen; // Slightly different green, necessary for distinction
      case BbBadgeCategory.milestone:
        return BBColors.orangeAccent;
      case BbBadgeCategory.participation:
        return Colors.purple; // Used here for visual separation, if necessary
    }
  }

  static IconData getCategoryIcon(BbBadgeCategory category) {
    switch (category) {
      case BbBadgeCategory.score:
        return Icons.star;
      case BbBadgeCategory.streak:
        return Icons.local_fire_department;
      case BbBadgeCategory.achievement:
        return Icons.emoji_events;
      case BbBadgeCategory.milestone:
        return Icons.flag;
      case BbBadgeCategory.participation:
        return Icons.group;
    }
  }

  static String getCategoryDisplayName(BbBadgeCategory category) {
    switch (category) {
      case BbBadgeCategory.score:
        return 'Score Badges';
      case BbBadgeCategory.streak:
        return 'Streak Badges';
      case BbBadgeCategory.achievement:
        return 'Achievement Badges';
      case BbBadgeCategory.milestone:
        return 'Milestone Badges';
      case BbBadgeCategory.participation:
        return 'Participation Badges';
    }
  }

  static String getProgressText(List<BbBadge> badges) {
    final earnedCount = badges.where((badge) => badge.isEarned).length;
    final totalCount = badges.length;
    return '$earnedCount/$totalCount';
  }

  static double getProgressPercentage(List<BbBadge> badges) {
    if (badges.isEmpty) return 0.0;
    final earnedCount = badges.where((badge) => badge.isEarned).length;
    return earnedCount / badges.length;
  }

  static List<BbBadge> filterEarnedBadges(List<BbBadge> badges) {
    return badges.where((badge) => badge.isEarned).toList();
  }

  static List<BbBadge> filterUnearnedBadges(List<BbBadge> badges) {
    return badges.where((badge) => badge.isUnearned).toList();
  }

  static Map<BbBadgeCategory, List<BbBadge>> groupBadgesByCategory(
    List<BbBadge> badges,
  ) {
    final Map<BbBadgeCategory, List<BbBadge>> grouped = {};

    for (final badge in badges) {
      grouped.putIfAbsent(badge.category, () => []).add(badge);
    }

    return grouped;
  }

  static List<BbBadge> sortBadgesWithinCategory(List<BbBadge> badges) {
    badges.sort((a, b) {
      // Earned badges first
      if (a.isEarned && !b.isEarned) return -1;
      if (!a.isEarned && b.isEarned) return 1;

      // If both earned, sort by earned date (most recent first)
      if (a.isEarned && b.isEarned) {
        if (a.earnedDate != null && b.earnedDate != null) {
          return b.earnedDate!.compareTo(a.earnedDate!);
        }
      }

      // Sort by name alphabetically
      return a.name.compareTo(b.name);
    });

    return badges;
  }
}
