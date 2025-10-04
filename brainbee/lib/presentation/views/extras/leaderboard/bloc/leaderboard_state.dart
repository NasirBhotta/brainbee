// lib/presentation/views/extras/leaderboard/bloc/leaderboard_state.dart

import 'package:brainbee/presentation/views/extras/leaderboard/models/bb_leaderboard_model.dart';
import 'package:equatable/equatable.dart';

sealed class LeaderboardState extends Equatable {
  const LeaderboardState();

  @override
  List<Object?> get props => [];
}

class LeaderboardInitial extends LeaderboardState {}

class LeaderboardLoading extends LeaderboardState {}

class LeaderboardLoaded extends LeaderboardState {
  final LeaderboardData data;
  final String type;

  const LeaderboardLoaded({required this.data, required this.type});

  @override
  List<Object?> get props => [data, type];
}

class LeaderboardError extends LeaderboardState {
  final String message;

  const LeaderboardError({required this.message});

  @override
  List<Object?> get props => [message];
}
