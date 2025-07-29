// lib/blocs/badge/badge_state.dart
import 'package:brainbee/presentation/views/extras/badges/models/badge_model.dart';
import 'package:equatable/equatable.dart';

abstract class BadgeState extends Equatable {
  const BadgeState();

  @override
  List<Object?> get props => [];
}

class BadgeInitial extends BadgeState {}

class BadgeLoading extends BadgeState {}

class BadgeLoaded extends BadgeState {
  final List<BbBadge> badges;
  final Map<BbBadgeCategory, List<BbBadge>> categorizedBadges;
  final int earnedBadgesCount;
  final int totalBadgesCount;
  final bool hasEarnedBadges;

  const BadgeLoaded({
    required this.badges,
    required this.categorizedBadges,
    required this.earnedBadgesCount,
    required this.totalBadgesCount,
    required this.hasEarnedBadges,
  });

  @override
  List<Object?> get props => [
    badges,
    categorizedBadges,
    earnedBadgesCount,
    totalBadgesCount,
    hasEarnedBadges,
  ];
}

class BadgeError extends BadgeState {
  final String message;
  final bool isNetworkError;
  final String? studentId;

  const BadgeError({
    required this.message,
    this.isNetworkError = false,
    this.studentId,
  });

  @override
  List<Object?> get props => [message, isNetworkError, studentId];
}

class BadgeRefreshing extends BadgeState {
  final List<BbBadge> currentBadges;
  final Map<BbBadgeCategory, List<BbBadge>> categorizedBadges;
  final int earnedBadgesCount;
  final int totalBadgesCount;
  final bool hasEarnedBadges;

  const BadgeRefreshing({
    required this.currentBadges,
    required this.categorizedBadges,
    required this.earnedBadgesCount,
    required this.totalBadgesCount,
    required this.hasEarnedBadges,
  });

  @override
  List<Object?> get props => [
    currentBadges,
    categorizedBadges,
    earnedBadgesCount,
    totalBadgesCount,
    hasEarnedBadges,
  ];
}
