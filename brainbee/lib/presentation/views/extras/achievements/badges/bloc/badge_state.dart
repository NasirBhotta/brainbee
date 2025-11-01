// lib/presentation/views/extras/achievements/badges/bloc/badge_state.dart

import 'package:equatable/equatable.dart';
import 'package:brainbee/presentation/views/extras/achievements/badges/models/badge_model.dart';

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
  final int totalBadgesCount;
  final int earnedBadgesCount;
  final bool hasEarnedBadges;

  const BadgeLoaded({
    required this.badges,
    required this.categorizedBadges,
    required this.totalBadgesCount,
    required this.earnedBadgesCount,
    required this.hasEarnedBadges,
  });

  @override
  List<Object?> get props => [
    badges,
    categorizedBadges,
    totalBadgesCount,
    earnedBadgesCount,
    hasEarnedBadges,
  ];
}

class BadgeRefreshing extends BadgeState {
  final List<BbBadge> currentBadges;
  final Map<BbBadgeCategory, List<BbBadge>> categorizedBadges;
  final int totalBadgesCount;
  final int earnedBadgesCount;
  final bool hasEarnedBadges;

  const BadgeRefreshing({
    required this.currentBadges,
    required this.categorizedBadges,
    required this.totalBadgesCount,
    required this.earnedBadgesCount,
    required this.hasEarnedBadges,
  });

  @override
  List<Object?> get props => [
    currentBadges,
    categorizedBadges,
    totalBadgesCount,
    earnedBadgesCount,
    hasEarnedBadges,
  ];
}

class BadgeError extends BadgeState {
  final String message;
  final bool isNetworkError;

  const BadgeError({required this.message, this.isNetworkError = false});

  @override
  List<Object?> get props => [message, isNetworkError];
}
