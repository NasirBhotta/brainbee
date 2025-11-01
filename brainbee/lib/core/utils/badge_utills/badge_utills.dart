// lib/core/utils/badge_utills/badge_utills.dart
import 'package:brainbee/core/constants/bb_colors.dart';
import 'package:brainbee/presentation/views/extras/achievements/badges/models/badge_model.dart';
import 'package:flutter/material.dart';

class BadgeUtils {
  /// Returns the color associated with a badge category
  static Color getCategoryColor(BbBadgeCategory category) {
    switch (category) {
      case BbBadgeCategory.score:
        return Colors.amber;
      case BbBadgeCategory.streak:
        return Colors.orange;
      case BbBadgeCategory.achievement:
        return Colors.amber;
      case BbBadgeCategory.milestone:
        return BBColors.primaryColor;
      case BbBadgeCategory.participation:
        return BBColors.successGreen;
    }
  }

  /// Returns the icon associated with a badge category
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

  /// Returns the display name for a badge category (plural form)
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

  /// Returns progress text in format "earned/total"
  static String getProgressText(List<BbBadge> badges) {
    final earnedCount = filterEarnedBadges(badges).length;
    final totalCount = badges.where((badge) => !badge.isExpired).length;
    return '$earnedCount/$totalCount';
  }

  /// Returns progress percentage (0.0 to 1.0)
  static double getProgressPercentage(List<BbBadge> badges) {
    final nonExpiredBadges = badges.where((badge) => !badge.isExpired).toList();
    if (nonExpiredBadges.isEmpty) return 0.0;

    final earnedCount =
        nonExpiredBadges.where((badge) => badge.isEarned).length;
    return earnedCount / nonExpiredBadges.length;
  }

  /// Filters and returns only earned, non-expired badges
  static List<BbBadge> filterEarnedBadges(List<BbBadge> badges) {
    return badges.where((badge) => badge.isEarned && !badge.isExpired).toList();
  }

  /// Filters and returns only unearned badges
  static List<BbBadge> filterUnearnedBadges(List<BbBadge> badges) {
    return badges
        .where((badge) => !badge.isEarned && !badge.isExpired)
        .toList();
  }

  /// Filters and returns only expired badges
  static List<BbBadge> filterExpiredBadges(List<BbBadge> badges) {
    return badges.where((badge) => badge.isExpired).toList();
  }

  /// Groups badges by their category
  static Map<BbBadgeCategory, List<BbBadge>> groupBadgesByCategory(
    List<BbBadge> badges,
  ) {
    final Map<BbBadgeCategory, List<BbBadge>> grouped = {};

    // Filter out expired badges by default
    final nonExpiredBadges = badges.where((badge) => !badge.isExpired).toList();

    for (final badge in nonExpiredBadges) {
      grouped.putIfAbsent(badge.category, () => []).add(badge);
    }

    return grouped;
  }

  /// Sorts badges within a category:
  /// 1. Earned badges first (sorted by earned date, most recent first)
  /// 2. Unearned badges with progress (sorted by progress percentage)
  /// 3. Unearned badges without progress (sorted alphabetically)
  static List<BbBadge> sortBadgesWithinCategory(List<BbBadge> badges) {
    badges.sort((a, b) {
      // Filter out expired badges should be first (if any remain)
      if (a.isExpired && !b.isExpired) return 1;
      if (!a.isExpired && b.isExpired) return -1;

      // Earned badges come before unearned
      if (a.isEarned && !b.isEarned) return -1;
      if (!a.isEarned && b.isEarned) return 1;

      // Both earned: sort by earned date (most recent first)
      if (a.isEarned && b.isEarned) {
        if (a.earnedDate != null && b.earnedDate != null) {
          return b.earnedDate!.compareTo(a.earnedDate!);
        }
        // If one has no earned date, prioritize the one with a date
        if (a.earnedDate != null) return -1;
        if (b.earnedDate != null) return 1;
      }

      // Both unearned: prioritize badges with progress
      final aHasProgress = a.currentProgress > 0;
      final bHasProgress = b.currentProgress > 0;

      if (aHasProgress && !bHasProgress) return -1;
      if (!aHasProgress && bHasProgress) return 1;

      // Both have progress: sort by progress percentage (highest first)
      if (aHasProgress && bHasProgress) {
        final progressComparison = b.progressPercentage.compareTo(
          a.progressPercentage,
        );
        if (progressComparison != 0) return progressComparison;
      }

      // Finally, sort alphabetically by name
      return a.name.compareTo(b.name);
    });

    return badges;
  }

  /// Returns count of earned badges (excluding expired)
  static int getEarnedBadgeCount(List<BbBadge> badges) {
    return filterEarnedBadges(badges).length;
  }

  /// Returns count of total badges (excluding expired)
  static int getTotalBadgeCount(List<BbBadge> badges) {
    return badges.where((badge) => !badge.isExpired).length;
  }

  /// Returns true if user has earned any badges
  static bool hasEarnedBadges(List<BbBadge> badges) {
    return badges.any((badge) => badge.isEarned && !badge.isExpired);
  }

  /// Returns the most recently earned badge, or null if none earned
  static BbBadge? getMostRecentlyEarnedBadge(List<BbBadge> badges) {
    final earnedBadges = filterEarnedBadges(badges);
    if (earnedBadges.isEmpty) return null;

    earnedBadges.sort((a, b) {
      if (a.earnedDate == null && b.earnedDate == null) return 0;
      if (a.earnedDate == null) return 1;
      if (b.earnedDate == null) return -1;
      return b.earnedDate!.compareTo(a.earnedDate!);
    });

    return earnedBadges.first;
  }

  /// Returns badges that are close to being earned (>= 50% progress)
  static List<BbBadge> getBadgesNearCompletion(List<BbBadge> badges) {
    return badges
        .where(
          (badge) =>
              !badge.isEarned &&
              !badge.isExpired &&
              badge.progressPercentage >= 0.5,
        )
        .toList();
  }
}
