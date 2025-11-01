// lib/presentation/views/extras/achievements/badges/bloc/badge_bloc.dart

import 'package:brainbee/repositories/badge_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:brainbee/presentation/views/extras/achievements/badges/bloc/badge_event.dart';
import 'package:brainbee/presentation/views/extras/achievements/badges/bloc/badge_state.dart';
import 'package:brainbee/core/utils/badge_utills/badge_utills.dart';

class BadgeBloc extends Bloc<BadgeEvent, BadgeState> {
  final BadgeRepository repository;

  BadgeBloc({required this.repository}) : super(BadgeInitial()) {
    on<LoadBadges>(_onLoadBadges);
    on<RefreshBadges>(_onRefreshBadges);
    on<RetryLoadBadges>(_onRetryLoadBadges);
  }

  Future<void> _onLoadBadges(LoadBadges event, Emitter<BadgeState> emit) async {
    emit(BadgeLoading());

    try {
      final badges = await repository.getAllBadgesForStudent(event.studentId);
      final categorized = BadgeUtils.groupBadgesByCategory(badges);
      final earnedCount = BadgeUtils.filterEarnedBadges(badges).length;

      emit(
        BadgeLoaded(
          badges: badges,
          categorizedBadges: categorized,
          totalBadgesCount: badges.length,
          earnedBadgesCount: earnedCount,
          hasEarnedBadges: earnedCount > 0,
        ),
      );
    } catch (e) {
      emit(
        BadgeError(
          message: e.toString(),
          isNetworkError:
              e.toString().contains('internet') ||
              e.toString().contains('connection'),
        ),
      );
    }
  }

  Future<void> _onRefreshBadges(
    RefreshBadges event,
    Emitter<BadgeState> emit,
  ) async {
    if (state is BadgeLoaded) {
      final currentState = state as BadgeLoaded;

      emit(
        BadgeRefreshing(
          currentBadges: currentState.badges,
          categorizedBadges: currentState.categorizedBadges,
          totalBadgesCount: currentState.totalBadgesCount,
          earnedBadgesCount: currentState.earnedBadgesCount,
          hasEarnedBadges: currentState.hasEarnedBadges,
        ),
      );
    }

    try {
      final badges = await repository.refreshBadges(event.studentId);
      final categorized = BadgeUtils.groupBadgesByCategory(badges);
      final earnedCount = BadgeUtils.filterEarnedBadges(badges).length;

      emit(
        BadgeLoaded(
          badges: badges,
          categorizedBadges: categorized,
          totalBadgesCount: badges.length,
          earnedBadgesCount: earnedCount,
          hasEarnedBadges: earnedCount > 0,
        ),
      );
    } catch (e) {
      if (state is BadgeRefreshing) {
        final refreshingState = state as BadgeRefreshing;
        emit(
          BadgeLoaded(
            badges: refreshingState.currentBadges,
            categorizedBadges: refreshingState.categorizedBadges,
            totalBadgesCount: refreshingState.totalBadgesCount,
            earnedBadgesCount: refreshingState.earnedBadgesCount,
            hasEarnedBadges: refreshingState.hasEarnedBadges,
          ),
        );
      }
    }
  }

  Future<void> _onRetryLoadBadges(
    RetryLoadBadges event,
    Emitter<BadgeState> emit,
  ) async {
    add(LoadBadges(studentId: event.studentId));
  }
}
