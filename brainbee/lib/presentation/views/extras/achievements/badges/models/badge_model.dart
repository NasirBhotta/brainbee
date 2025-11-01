// lib/presentation/views/extras/achievements/badges/models/badge_model.dart

class BbBadge {
  final String badgeId;
  final String name;
  final String description;
  final String earningCriteria;
  final BbBadgeCategory category;
  final String iconUrl;
  final String? iconAsset; // Local asset path (optional)
  final bool isEarned;
  final DateTime? earnedDate;
  final int currentProgress;
  final int targetValue;
  final bool isExpired; // For time-limited badges

  BbBadge({
    required this.badgeId,
    required this.name,
    required this.description,
    required this.earningCriteria,
    required this.category,
    required this.iconUrl,
    this.iconAsset,
    required this.isEarned,
    this.earnedDate,
    required this.currentProgress,
    required this.targetValue,
    this.isExpired = false,
  });

  factory BbBadge.fromJson(Map<String, dynamic> json) {
    return BbBadge(
      badgeId: json['badgeId'] ?? '',
      name: json['badgeName'] ?? '',
      description: json['badgeDescription'] ?? '',
      earningCriteria: json['badgeEarningCriteria'] ?? '',
      category: _parseBadgeCategory(json['badgeCategory']),
      iconUrl: json['badgeIconUrl'] ?? '',
      iconAsset: json['badgeIconAsset'], // Optional local asset
      isEarned: json['isEarned'] ?? false,
      earnedDate:
          json['earnedDate'] != null
              ? DateTime.tryParse(json['earnedDate'])
              : null,
      currentProgress: json['currentProgress'] ?? 0,
      targetValue: json['targetValue'] ?? 0,
      isExpired: json['isExpired'] ?? false,
    );
  }

  static BbBadgeCategory _parseBadgeCategory(String? category) {
    switch (category?.toLowerCase()) {
      case 'score':
        return BbBadgeCategory.score;
      case 'streak':
        return BbBadgeCategory.streak;
      case 'achievement':
        return BbBadgeCategory.achievement;
      case 'participation':
        return BbBadgeCategory.participation;
      case 'milestone':
        return BbBadgeCategory.milestone;
      default:
        return BbBadgeCategory.achievement;
    }
  }

  double get progressPercentage {
    if (targetValue == 0) return 0.0;
    return (currentProgress / targetValue).clamp(0.0, 1.0);
  }

  String get categoryDisplayName {
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

  Map<String, dynamic> toJson() {
    return {
      'badgeId': badgeId,
      'badgeName': name,
      'badgeDescription': description,
      'badgeEarningCriteria': earningCriteria,
      'badgeCategory': category.name,
      'badgeIconUrl': iconUrl,
      'badgeIconAsset': iconAsset,
      'isEarned': isEarned,
      'earnedDate': earnedDate?.toIso8601String(),
      'currentProgress': currentProgress,
      'targetValue': targetValue,
      'isExpired': isExpired,
    };
  }

  BbBadge copyWith({
    String? badgeId,
    String? name,
    String? description,
    String? earningCriteria,
    BbBadgeCategory? category,
    String? iconUrl,
    String? iconAsset,
    bool? isEarned,
    DateTime? earnedDate,
    int? currentProgress,
    int? targetValue,
    bool? isExpired,
  }) {
    return BbBadge(
      badgeId: badgeId ?? this.badgeId,
      name: name ?? this.name,
      description: description ?? this.description,
      earningCriteria: earningCriteria ?? this.earningCriteria,
      category: category ?? this.category,
      iconUrl: iconUrl ?? this.iconUrl,
      iconAsset: iconAsset ?? this.iconAsset,
      isEarned: isEarned ?? this.isEarned,
      earnedDate: earnedDate ?? this.earnedDate,
      currentProgress: currentProgress ?? this.currentProgress,
      targetValue: targetValue ?? this.targetValue,
      isExpired: isExpired ?? this.isExpired,
    );
  }
}

enum BbBadgeCategory { score, streak, achievement, participation, milestone }
