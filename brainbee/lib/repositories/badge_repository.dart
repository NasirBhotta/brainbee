// lib/repositories/badge_repository.dart

import 'package:brainbee/presentation/views/extras/badges/models/badge_model.dart';
import 'package:brainbee/presentation/views/extras/badges/models/badge_response.dart';
import 'package:brainbee/presentation/views/extras/badges/services/badge_api_services.dart';

abstract class BadgeRepository {
  Future<BadgeResponse> getBadges(String studentId);
}

class BadgeRepositoryImpl implements BadgeRepository {
  final BadgeApiService _apiService;

  BadgeRepositoryImpl({required BadgeApiService apiService})
    : _apiService = apiService;

  @override
  Future<BadgeResponse> getBadges(String studentId) async {
    try {
      final response = await _apiService.getBadges(studentId);

      // Filter out expired badges as per business rules
      final filteredBadges =
          response.badges
              .where((badge) => badge.status != BbBadgeStatus.expired)
              .toList();

      // Sort badges: earned badges first within their categories
      final sortedBadges = _sortBadgesByStatusAndCategory(filteredBadges);

      return BadgeResponse(
        badges: sortedBadges,
        success: response.success,
        message: response.message,
      );
    } catch (e) {
      rethrow;
    }
  }

  List<BbBadge> _sortBadgesByStatusAndCategory(List<BbBadge> badges) {
    // Group badges by category
    final Map<BbBadgeCategory, List<BbBadge>> categorizedBadges = {};

    for (final badge in badges) {
      categorizedBadges.putIfAbsent(badge.category, () => []).add(badge);
    }

    // Sort within each category: earned badges first
    for (final category in categorizedBadges.keys) {
      categorizedBadges[category]!.sort((a, b) {
        // First, sort by earned status (earned first)
        if (a.isEarned && !b.isEarned) return -1;
        if (!a.isEarned && b.isEarned) return 1;

        // If both have same earned status, sort by earned date (most recent first)
        if (a.isEarned && b.isEarned) {
          if (a.earnedDate != null && b.earnedDate != null) {
            return b.earnedDate!.compareTo(a.earnedDate!);
          }
        }

        // Finally, sort by name alphabetically
        return a.name.compareTo(b.name);
      });
    }

    // Combine all categories back into a single list
    final List<BbBadge> sortedBadges = [];

    // Define category order
    final categoryOrder = [
      BbBadgeCategory.score,
      BbBadgeCategory.streak,
      BbBadgeCategory.achievement,
      BbBadgeCategory.milestone,
    ];

    for (final category in categoryOrder) {
      if (categorizedBadges.containsKey(category)) {
        sortedBadges.addAll(categorizedBadges[category]!);
      }
    }

    return sortedBadges;
  }
}
