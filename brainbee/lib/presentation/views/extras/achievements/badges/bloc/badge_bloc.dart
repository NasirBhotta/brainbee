// lib/blocs/badge/badge_bloc.dart
import 'dart:async';
import 'package:brainbee/presentation/views/extras/achievements/badges/models/badge_model.dart';
import 'package:brainbee/presentation/views/extras/achievements/badges/services/badge_api_services.dart';
import 'package:brainbee/repositories/badge_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'badge_event.dart';
import 'badge_state.dart';

class BadgeBloc extends Bloc<BadgeEvent, BadgeState> {
  final BadgeRepository _repository;

  BadgeBloc({required BadgeRepository repository})
    : _repository = repository,
      super(BadgeInitial()) {
    on<LoadBadges>(_onLoadBadges);
    on<RefreshBadges>(_onRefreshBadges);
    on<RetryLoadBadges>(_onRetryLoadBadges);
  }

  Future<void> _onLoadBadges(LoadBadges event, Emitter<BadgeState> emit) async {
    emit(BadgeLoading());
    await _loadBadges(event.studentId, emit);
  }

  Future<void> _onRefreshBadges(
    RefreshBadges event,
    Emitter<BadgeState> emit,
  ) async {
    final currentState = state;
    if (currentState is BadgeLoaded) {
      emit(
        BadgeRefreshing(
          currentBadges: currentState.badges,
          categorizedBadges: currentState.categorizedBadges,
          earnedBadgesCount: currentState.earnedBadgesCount,
          totalBadgesCount: currentState.totalBadgesCount,
          hasEarnedBadges: currentState.hasEarnedBadges,
        ),
      );
    }
    await _loadBadges(event.studentId, emit);
  }

  Future<void> _onRetryLoadBadges(
    RetryLoadBadges event,
    Emitter<BadgeState> emit,
  ) async {
    emit(BadgeLoading());
    await _loadBadges(event.studentId, emit);
  }

  Future<void> _loadBadges(String studentId, Emitter<BadgeState> emit) async {
    try {
      final response = await _repository.getBadges(studentId);

      if (response.success) {
        final categorizedBadges = _categorizeBadges(response.badges);
        final earnedBadges =
            response.badges.where((badge) => badge.isEarned).toList();

        emit(
          BadgeLoaded(
            badges: response.badges,
            categorizedBadges: categorizedBadges,
            earnedBadgesCount: earnedBadges.length,
            totalBadgesCount: response.badges.length,
            hasEarnedBadges: earnedBadges.isNotEmpty,
          ),
        );
      } else {
        emit(
          BadgeError(
            message: response.message ?? 'Failed to load badges',
            studentId: studentId,
          ),
        );
      }
    } on BadgeApiException catch (e) {
      emit(
        BadgeError(
          message: e.message,
          isNetworkError: _isNetworkError(e),
          studentId: studentId,
        ),
      );
    } catch (e) {
      emit(
        BadgeError(
          message: 'An unexpected error occurred. Please try again.',
          studentId: studentId,
        ),
      );
    }
  }

  Map<BbBadgeCategory, List<BbBadge>> _categorizeBadges(List<BbBadge> badges) {
    final Map<BbBadgeCategory, List<BbBadge>> categorized = {};

    for (final badge in badges) {
      categorized.putIfAbsent(badge.category, () => []).add(badge);
    }

    return categorized;
  }

  bool _isNetworkError(BadgeApiException exception) {
    return exception.statusCode == -1 ||
        exception.statusCode == 408 ||
        exception.message.toLowerCase().contains('internet') ||
        exception.message.toLowerCase().contains('connection') ||
        exception.message.toLowerCase().contains('network');
  }
}
