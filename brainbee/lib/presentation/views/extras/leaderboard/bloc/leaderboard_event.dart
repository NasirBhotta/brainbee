// lib/presentation/views/extras/leaderboard/bloc/leaderboard_event.dart

import 'package:equatable/equatable.dart';

sealed class LeaderboardEvent extends Equatable {
  const LeaderboardEvent();

  @override
  List<Object?> get props => [];
}

class FetchLeaderboard extends LeaderboardEvent {
  final String type; // 'weekly', 'monthly', or 'overall'

  const FetchLeaderboard({required this.type});

  @override
  List<Object?> get props => [type];
}

class RefreshLeaderboard extends LeaderboardEvent {
  final String type;

  const RefreshLeaderboard({required this.type});

  @override
  List<Object?> get props => [type];
}
