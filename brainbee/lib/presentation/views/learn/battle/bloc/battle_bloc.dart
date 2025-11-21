import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:brainbee/presentation/views/learn/battle/models/battle_models.dart';
import 'package:brainbee/presentation/views/learn/battle/models/battle_stat_model.dart';
import 'package:brainbee/presentation/views/learn/battle/repository/battle_repository.dart';
import 'package:equatable/equatable.dart';

part 'battle_event.dart';
part 'battle_state.dart';

class BattleBloc extends Bloc<BattleEvent, BattleState> {
  final BattleRepository repository;
  StreamSubscription? _roomUpdatesSubscription;
  String? _currentUserId;
  String? get currentUserId => _currentUserId;

  BattleBloc({required this.repository}) : super(BattleInitial()) {
    on<CreateBattleRoomEvent>(_onCreateBattleRoom);
    on<JoinBattleRoomEvent>(_onJoinBattleRoom);
    on<FindRandomOpponentEvent>(_onFindRandomOpponent);
    on<CancelBattleSearchEvent>(_onCancelBattleSearch);
    on<MarkReadyEvent>(_onMarkReady);
    on<StartBattleEvent>(_onStartBattle);
    on<SubmitAnswerEvent>(_onSubmitAnswer);
    on<LeaveBattleEvent>(_onLeaveBattle);
    on<RoomUpdateReceivedEvent>(_onRoomUpdateReceived);
    on<OpponentAnsweredEvent>(_onOpponentAnswered);
    on<GetBattleResultEvent>(_onGetBattleResult);
    on<LoadBattleHistoryEvent>(_onLoadBattleHistory);
    on<FetchBattleStatsEvent>(_onFetchBattleStats);
    on<FetchBattleHistoryEvent>(_onFetchBattleHistory);
    on<SetCurrentUserIdEvent>(_onSetCurrentUserId);
  }

  Future<void> _onSetCurrentUserId(
    SetCurrentUserIdEvent event,
    Emitter<BattleState> emit,
  ) async {
    _currentUserId = event.userId;
  }

  Future<void> _onCreateBattleRoom(
    CreateBattleRoomEvent event,
    Emitter<BattleState> emit,
  ) async {
    emit(BattleLoading());
    try {
      final room = await repository.createBattleRoom(
        subject: event.subject,
        mode: event.mode,
        chapters: event.chapters,
      );
      _currentUserId = room.host.id;
      print('🆔 Set currentUserId (host/create): $_currentUserId');
      await _connectToRoom(room.roomId);

      if (event.mode == BattleMode.random) {
        if (room.status == BattleStatus.matched && room.opponent != null) {
          emit(BattleOpponentFound(room: room));
        } else {
          emit(BattleSearching(room: room));
        }
      } else {
        emit(BattleRoomCreated(room: room));
      }
    } catch (e) {
      emit(BattleError(message: e.toString()));
    }
  }

  Future<void> _onJoinBattleRoom(
    JoinBattleRoomEvent event,
    Emitter<BattleState> emit,
  ) async {
    emit(BattleLoading());
    try {
      final room = await repository.joinBattleRoom(
        invitationCode: event.invitationCode,
      );
      _currentUserId = room.opponent?.id;
      print('🆔 Set currentUserId (opponent/join): $_currentUserId');
      await _connectToRoom(room.roomId);

      if (room.opponent != null) {
        emit(BattleOpponentFound(room: room));
      } else {
        emit(BattleSearching(room: room));
      }
    } catch (e) {
      emit(BattleError(message: e.toString()));
    }
  }

  Future<void> _onFindRandomOpponent(
    FindRandomOpponentEvent event,
    Emitter<BattleState> emit,
  ) async {
    emit(BattleLoading());
    try {
      final room = await repository.findRandomOpponent(
        subject: event.subject,
        chapters: event.chapters,
      );

      if (room.opponent != null && room.status == BattleStatus.matched) {
        _currentUserId = room.opponent!.id;
        print('🆔 Set currentUserId (opponent/random-join): $_currentUserId');
      } else {
        _currentUserId = room.host.id;
        print('🆔 Set currentUserId (host/random-create): $_currentUserId');
      }

      await _connectToRoom(room.roomId);

      if (room.status == BattleStatus.matched && room.opponent != null) {
        emit(BattleOpponentFound(room: room));
      } else {
        emit(BattleSearching(room: room));
      }
    } catch (e) {
      emit(BattleError(message: e.toString()));
    }
  }

  Future<void> _onCancelBattleSearch(
    CancelBattleSearchEvent event,
    Emitter<BattleState> emit,
  ) async {
    try {
      await repository.cancelBattleSearch(roomId: event.roomId);
      _disconnectFromRoom();
      emit(BattleCancelled(message: 'Battle search cancelled'));
    } catch (e) {
      emit(BattleError(message: e.toString()));
    }
  }

  Future<void> _onMarkReady(
    MarkReadyEvent event,
    Emitter<BattleState> emit,
  ) async {
    try {
      await repository.markReady(roomId: event.roomId);
    } catch (e) {
      emit(BattleError(message: e.toString()));
    }
  }

  Future<void> _onStartBattle(
    StartBattleEvent event,
    Emitter<BattleState> emit,
  ) async {
    try {
      await repository.startBattle(roomId: event.roomId);
    } catch (e) {
      emit(BattleError(message: e.toString()));
    }
  }

  Future<void> _onSubmitAnswer(
    SubmitAnswerEvent event,
    Emitter<BattleState> emit,
  ) async {
    if (state is! BattleInProgress) return;
    final currentState = state as BattleInProgress;
    try {
      final newScore = await repository.submitAnswer(
        roomId: event.roomId,
        questionIndex: event.questionIndex,
        selectedOptionIndex: event.selectedOptionIndex,
        timeSpent: event.timeSpent,
      );
      emit(currentState.copyWith(userScore: newScore));
    } catch (e) {
      emit(BattleError(message: e.toString()));
    }
  }

  Future<void> _onLeaveBattle(
    LeaveBattleEvent event,
    Emitter<BattleState> emit,
  ) async {
    try {
      await repository.leaveBattle(roomId: event.roomId);
      _disconnectFromRoom();
      emit(BattleCancelled(message: 'Left the battle'));
    } catch (e) {
      emit(BattleError(message: e.toString()));
    }
  }

  Future<void> _onRoomUpdateReceived(
    RoomUpdateReceivedEvent event,
    Emitter<BattleState> emit,
  ) async {
    final update = event.update;
    print('✅ WebSocket Update: $update');
    final type = update['type'] as String?;

    switch (type) {
      case 'opponent_joined':
        if ((state is BattleRoomCreated ||
                state is BattleSearching ||
                state is BattleOpponentFound) &&
            update.containsKey('opponent')) {
          final currentState = state as dynamic;
          final room = (currentState.room as BattleRoom).copyWith(
            opponent: BattlePlayer.fromJson(update['opponent']),
            status: BattleStatus.matched,
          );
          emit(BattleOpponentFound(room: room));
        }
        break;

      case 'room_update':
        if (update.containsKey('room')) {
          final updatedRoom = BattleRoom.fromJson(update['room']);
          if (state is BattleSearching || state is BattleOpponentFound) {
            emit(BattleOpponentFound(room: updatedRoom));
          }
        }
        break;

      case 'player_ready':
        if ((state is BattleOpponentFound || state is BattleReady) &&
            update.containsKey('playerId')) {
          final String readyPlayerId = update['playerId'] as String;
          final BattleRoom room =
              (state is BattleReady)
                  ? (state as BattleReady).room
                  : (state as BattleOpponentFound).room;

          bool prevHostReady = false;
          bool prevOpponentReady = false;
          if (state is BattleReady) {
            prevHostReady = (state as BattleReady).isHostReady;
            prevOpponentReady = (state as BattleReady).isOpponentReady;
          }

          final bool isHostNowReady =
              (readyPlayerId == room.host.id) ? true : prevHostReady;
          final bool isOpponentNowReady =
              (readyPlayerId == room.opponent?.id) ? true : prevOpponentReady;

          emit(
            BattleReady(
              room: room,
              isHostReady: isHostNowReady,
              isOpponentReady: isOpponentNowReady,
            ),
          );
        }
        break;

      case 'battle_started':
        if (update.containsKey('roomId')) {
          add(StartBattleEvent(roomId: update['roomId']));
        }
        break;

      case 'battle_data_ready':
        if (state is BattleReady && update.containsKey('data')) {
          final quizData = BattleQuizData.fromJson(update['data']);
          emit(
            BattleInProgress(
              room: (state as BattleReady).room,
              quizData: quizData,
              currentQuestionIndex: 0,
              userScore: 0,
              opponentScore: 0,
            ),
          );
        }
        break;

      case 'opponent_answered':
        // FIX: Handle opponent score update
        if (state is BattleInProgress &&
            update.containsKey('score') &&
            update.containsKey('playerId')) {
          final String answeringPlayerId = update['playerId'] as String;
          final int newScore = update['score'] as int;

          // Only update if it's the opponent's answer, not our own
          if (answeringPlayerId != _currentUserId) {
            print('📊 Opponent score update: $newScore');
            add(
              OpponentAnsweredEvent(
                questionIndex: update['questionIndex'] ?? 0,
                score: newScore,
              ),
            );
          }
        }
        break;

      case 'battle_completed':
        // FIX: Add delay before fetching results to avoid race condition
        if (update.containsKey('roomId')) {
          final roomId = update['roomId'] as String;
          print('🏁 Battle completed event received for room: $roomId');
          // Delay to ensure backend has saved the results
          await Future.delayed(const Duration(milliseconds: 500));
          add(GetBattleResultEvent(roomId: roomId));
        }
        break;

      case 'opponent_left':
        _disconnectFromRoom();
        emit(BattleCancelled(message: 'Opponent left the battle'));
        break;

      case 'joined_room':
        print('✅ Joined room: ${update['roomId']}');
        break;

      case 'error':
        emit(BattleError(message: update['message'] ?? 'WebSocket error'));
        break;
    }
  }

  Future<void> _onOpponentAnswered(
    OpponentAnsweredEvent event,
    Emitter<BattleState> emit,
  ) async {
    if (state is! BattleInProgress) return;
    final currentState = state as BattleInProgress;
    // FIX: Actually emit the updated state
    emit(currentState.copyWith(opponentScore: event.score));
  }

  // FIX: Add retry logic for getting battle result
  Future<void> _onGetBattleResult(
    GetBattleResultEvent event,
    Emitter<BattleState> emit,
  ) async {
    // Don't fetch if already completed
    if (state is BattleCompleted) return;

    int retries = 3;
    Exception? lastError;

    while (retries > 0) {
      try {
        final result = await repository.getBattleResult(roomId: event.roomId);
        emit(BattleCompleted(result: result));
        _disconnectFromRoom();
        return;
      } catch (e) {
        lastError = e as Exception;
        retries--;
        print('⚠️ Failed to get battle result, retries left: $retries');
        if (retries > 0) {
          await Future.delayed(const Duration(seconds: 1));
        }
      }
    }

    // All retries failed
    emit(BattleError(message: 'Failed to get battle result: $lastError'));
  }

  Future<void> _onLoadBattleHistory(
    LoadBattleHistoryEvent event,
    Emitter<BattleState> emit,
  ) async {
    emit(BattleLoading());
    try {
      final history = await repository.getBattleHistory(
        limit: event.limit,
        offset: event.offset,
      );
      emit(BattleHistoryLoaded(history: history));
    } catch (e) {
      emit(BattleError(message: e.toString()));
    }
  }

  Future<void> _onFetchBattleStats(
    FetchBattleStatsEvent event,
    Emitter<BattleState> emit,
  ) async {
    try {
      emit(BattleLoading());
      final statsData = await repository.getBattleStatistics();
      final stats = BattleStats.fromJson(statsData);
      emit(BattleStatsLoaded(stats: stats));
    } catch (e) {
      emit(BattleError(message: 'Error loading battle stats: $e'));
    }
  }

  Future<void> _onFetchBattleHistory(
    FetchBattleHistoryEvent event,
    Emitter<BattleState> emit,
  ) async {
    try {
      emit(BattleLoading());
      final rooms = await repository.getBattleHistory(limit: 20);
      final history =
          rooms
              .where((room) => room.status == BattleStatus.completed)
              .map((room) => _convertRoomToHistoryItem(room))
              .toList();
      emit(BattleHistoryItemsLoaded(history: history));
    } catch (e) {
      emit(BattleError(message: 'Error loading battle history: $e'));
    }
  }

  BattleHistoryItem _convertRoomToHistoryItem(BattleRoom room) {
    final bool isHost = _currentUserId == room.host.id;
    final currentUser = isHost ? room.host : room.opponent!;
    final opponent = isHost ? room.opponent : room.host;
    final yourScore = currentUser.currentScore;
    final opponentScore = opponent?.currentScore ?? 0;

    String result;
    if (yourScore > opponentScore) {
      result = 'win';
    } else if (yourScore < opponentScore) {
      result = 'loss';
    } else {
      result = 'draw';
    }

    return BattleHistoryItem(
      id: room.roomId,
      opponentUsername: opponent?.username ?? '@User',
      opponentInitial: opponent?.avatarInitial ?? 'U',
      result: result,
      date: _formatDate(room.startedAt ?? room.createdAt),
      yourScore: yourScore,
      opponentScore: opponentScore,
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Today';
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inDays == 0) return 'Today';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays} days ago';
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<void> _connectToRoom(String roomId) async {
    repository.connectToRoom(roomId);
    _roomUpdatesSubscription = repository.getRoomUpdates().listen(
      (update) => add(RoomUpdateReceivedEvent(update: update)),
      onError:
          (e) => add(
            RoomUpdateReceivedEvent(
              update: {'type': 'error', 'message': e.toString()},
            ),
          ),
    );
  }

  void _disconnectFromRoom() {
    _roomUpdatesSubscription?.cancel();
    _roomUpdatesSubscription = null;
    repository.disconnectFromRoom();
  }

  @override
  Future<void> close() {
    _disconnectFromRoom();
    return super.close();
  }
}
