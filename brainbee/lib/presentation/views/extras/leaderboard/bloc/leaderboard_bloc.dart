// lib/presentation/views/extras/leaderboard/bloc/leaderboard_bloc.dart

import 'package:brainbee/presentation/views/extras/leaderboard/repo/bb_leaderboard_repo.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:brainbee/presentation/views/extras/leaderboard/bloc/leaderboard_event.dart';
import 'package:brainbee/presentation/views/extras/leaderboard/bloc/leaderboard_state.dart';

class LeaderboardBloc extends Bloc<LeaderboardEvent, LeaderboardState> {
  final LeaderboardRepository repository;

  LeaderboardBloc({required this.repository}) : super(LeaderboardInitial()) {
    on<FetchLeaderboard>(_onFetchLeaderboard);
    on<RefreshLeaderboard>(_onRefreshLeaderboard);
  }

  Future<void> _onFetchLeaderboard(
    FetchLeaderboard event,
    Emitter<LeaderboardState> emit,
  ) async {
    emit(LeaderboardLoading());
    try {
      final data = await repository.getLeaderboard(event.type);
      emit(LeaderboardLoaded(data: data, type: event.type));
    } catch (e) {
      emit(LeaderboardError(message: e.toString()));
    }
  }

  Future<void> _onRefreshLeaderboard(
    RefreshLeaderboard event,
    Emitter<LeaderboardState> emit,
  ) async {
    try {
      final data = await repository.getLeaderboard(event.type);
      emit(LeaderboardLoaded(data: data, type: event.type));
    } catch (e) {
      emit(LeaderboardError(message: e.toString()));
    }
  }
}
