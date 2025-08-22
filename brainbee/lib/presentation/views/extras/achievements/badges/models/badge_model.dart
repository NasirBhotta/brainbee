// lib/models/Bbbadge_model.dart
import 'package:equatable/equatable.dart';

enum BbBadgeCategory { score, streak, achievement, milestone, participation }

enum BbBadgeStatus { earned, unearned, expired }

class BbBadge extends Equatable {
  final String id;
  final String name;
  final String description;
  final String iconUrl;
  final BbBadgeCategory category;
  final BbBadgeStatus status;
  final DateTime? earnedDate;
  final String earningCriteria;
  final int? requiredValue;
  final String? iconAsset; // For local assets

  const BbBadge({
    required this.id,
    required this.name,
    required this.description,
    required this.iconUrl,
    required this.category,
    required this.status,
    this.earnedDate,
    required this.earningCriteria,
    this.requiredValue,
    this.iconAsset,
  });

  factory BbBadge.fromJson(Map<String, dynamic> json) {
    return BbBadge(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      iconUrl: json['iconUrl'] as String,
      category: BbBadgeCategory.values.firstWhere(
        (e) => e.name == json['category'],
        orElse: () => BbBadgeCategory.achievement,
      ),
      status: BbBadgeStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => BbBadgeStatus.unearned,
      ),
      earnedDate:
          json['earnedDate'] != null
              ? DateTime.parse(json['earnedDate'] as String)
              : null,
      earningCriteria: json['earningCriteria'] as String,
      requiredValue: json['requiredValue'] as int?,
      iconAsset: json['iconAsset'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'iconUrl': iconUrl,
      'category': category.name,
      'status': status.name,
      'earnedDate': earnedDate?.toIso8601String(),
      'earningCriteria': earningCriteria,
      'requiredValue': requiredValue,
      'iconAsset': iconAsset,
    };
  }

  BbBadge copyWith({
    String? id,
    String? name,
    String? description,
    String? iconUrl,
    BbBadgeCategory? category,
    BbBadgeStatus? status,
    DateTime? earnedDate,
    String? earningCriteria,
    int? requiredValue,
    String? iconAsset,
  }) {
    return BbBadge(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      iconUrl: iconUrl ?? this.iconUrl,
      category: category ?? this.category,
      status: status ?? this.status,
      earnedDate: earnedDate ?? this.earnedDate,
      earningCriteria: earningCriteria ?? this.earningCriteria,
      requiredValue: requiredValue ?? this.requiredValue,
      iconAsset: iconAsset ?? this.iconAsset,
    );
  }

  bool get isEarned => status == BbBadgeStatus.earned;
  bool get isUnearned => status == BbBadgeStatus.unearned;
  bool get isExpired => status == BbBadgeStatus.expired;

  String get categoryDisplayName {
    switch (category) {
      case BbBadgeCategory.score:
        return 'Score';
      case BbBadgeCategory.streak:
        return 'Streak';
      case BbBadgeCategory.achievement:
        return 'Achievement';
      case BbBadgeCategory.milestone:
        return 'Milestone';
      case BbBadgeCategory.participation:
        return 'Participation';
    }
  }

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    iconUrl,
    category,
    status,
    earnedDate,
    earningCriteria,
    requiredValue,
    iconAsset,
  ];
}
