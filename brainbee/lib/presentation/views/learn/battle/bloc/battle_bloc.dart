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
  String? _currentUserId; // Store current user ID for comparison

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
    // New handlers for stats
    on<FetchBattleStatsEvent>(_onFetchBattleStats);
    on<FetchBattleHistoryEvent>(_onFetchBattleHistory);
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

      // Store current user ID (host)
      _currentUserId = room.host.id;

      // Connect to WebSocket for real-time updates
      await _connectToRoom(room.roomId);

      print("it is comming here");
      if (event.mode == BattleMode.random) {
        // Check if opponent already matched (shouldn't happen for create, but be safe)
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

      print('🔍 JOINED ROOM DATA:');
      print('   Host: ${room.host.username}');
      print('   Opponent: ${room.opponent?.username ?? "NULL"}');
      print('   Status: ${room.status}');

      // Store current user ID (opponent)
      _currentUserId = room.opponent?.id;

      await _connectToRoom(room.roomId);

      // Check if room has opponent data
      if (room.opponent != null) {
        emit(BattleOpponentFound(room: room));
      } else {
        // If no opponent data yet, emit searching state
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

      _currentUserId = room.host.id;
      await _connectToRoom(room.roomId);

      // ✅ Check if opponent is already found
      if (room.status == BattleStatus.matched && room.opponent != null) {
        print('🎯 Opponent already matched! Emitting BattleOpponentFound');
        emit(BattleOpponentFound(room: room));
      } else {
        print('🔍 No opponent yet, emitting BattleSearching');
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
      // Wait for WebSocket update to confirm both players are ready
    } catch (e) {
      emit(BattleError(message: e.toString()));
    }
  }

  Future<void> _onStartBattle(
    StartBattleEvent event,
    Emitter<BattleState> emit,
  ) async {
    try {
      final quizData = await repository.startBattle(roomId: event.roomId);

      if (state is BattleReady) {
        final currentState = state as BattleReady;
        emit(
          BattleInProgress(
            room: currentState.room,
            quizData: quizData,
            currentQuestionIndex: 0,
            userScore: 0,
            opponentScore: 0,
          ),
        );
      }
    } catch (e) {
      emit(BattleError(message: e.toString()));
    }
  }

  Future<void> _onSubmitAnswer(
    SubmitAnswerEvent event,
    Emitter<BattleState> emit,
  ) async {
    try {
      await repository.submitAnswer(
        roomId: event.roomId,
        questionIndex: event.questionIndex,
        selectedOptionIndex: event.selectedOptionIndex,
        timeSpent: event.timeSpent,
      );
      // Score update will come through WebSocket
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

  // lib/presentation/views/learn/battle/bloc/battle_bloc.dart

  Future<void> _onRoomUpdateReceived(
    RoomUpdateReceivedEvent event,
    Emitter<BattleState> emit,
  ) async {
    final update = event.update;
    print('✅ WebSocket Update Received by BLoC: $update');
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
        print('🔄 Processing room_update in BLoC');

        // Check if this update contains room data with opponent
        if (update.containsKey('room')) {
          final roomData = update['room'];
          final updatedRoom = BattleRoom.fromJson(roomData);

          print(
            '   Updated room opponent: ${updatedRoom.opponent?.username ?? "NULL"}',
          );

          if (state is BattleSearching || state is BattleOpponentFound) {
            emit(BattleOpponentFound(room: updatedRoom));
          }
        }
        break;
      case 'player_ready':
        if ((state is BattleOpponentFound || state is BattleReady) &&
            update.containsKey('playerId')) {
          final String playerId = update['playerId'] as String;

          // Safely obtain the room from the concrete state type
          final BattleRoom room =
              (state is BattleReady)
                  ? (state as BattleReady).room
                  : (state as BattleOpponentFound).room;

          // 1. Determine the PREVIOUS ready state.
          bool previousHostReady = false;
          bool previousOpponentReady = false;
          if (state is BattleReady) {
            final readyState = state as BattleReady;
            previousHostReady = readyState.isHostReady;
            previousOpponentReady = readyState.isOpponentReady;
          }

          // 2. Calculate the NEW ready state based on the event.
          final bool isHostNowReady =
              (playerId == room.host.id) ? true : previousHostReady;
          final bool isOpponentNowReady =
              (playerId == room.opponent?.id) ? true : previousOpponentReady;

          // 3. Emit the new BattleReady state.
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

      case 'opponent_answered':
        if (update.containsKey('score') &&
            update.containsKey('questionIndex')) {
          add(
            OpponentAnsweredEvent(
              questionIndex: update['questionIndex'],
              score: update['score'],
            ),
          );
        }
        break;

      case 'battle_completed':
        if (update.containsKey('roomId')) {
          add(GetBattleResultEvent(roomId: update['roomId']));
        }
        break;

      case 'opponent_left':
        _disconnectFromRoom();
        emit(BattleCancelled(message: 'Opponent left the battle'));
        break;

      case 'joined_room':
        print('✅ Successfully joined room via WebSocket: ${update['roomId']}');
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
    if (state is BattleInProgress) {
      final currentState = state as BattleInProgress;
      emit(
        BattleInProgress(
          room: currentState.room,
          quizData: currentState.quizData,
          currentQuestionIndex: currentState.currentQuestionIndex,
          userScore: currentState.userScore,
          opponentScore: event.score,
        ),
      );
    }
  }

  Future<void> _onGetBattleResult(
    GetBattleResultEvent event,
    Emitter<BattleState> emit,
  ) async {
    try {
      final result = await repository.getBattleResult(roomId: event.roomId);
      emit(BattleCompleted(result: result));
      _disconnectFromRoom();
    } catch (e) {
      emit(BattleError(message: e.toString()));
    }
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

  // New handler for fetching battle stats
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

  // New handler for fetching battle history (stats-specific)
  Future<void> _onFetchBattleHistory(
    FetchBattleHistoryEvent event,
    Emitter<BattleState> emit,
  ) async {
    try {
      emit(BattleLoading());

      // Fetch battle history with limit
      final rooms = await repository.getBattleHistory(limit: 20);

      // Convert BattleRoom to BattleHistoryItem
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

  /// Convert BattleRoom to BattleHistoryItem
  BattleHistoryItem _convertRoomToHistoryItem(BattleRoom room) {
    // Determine if current user is host or opponent
    final bool isHost = _currentUserId == room.host.id;

    // Get current user and opponent
    final currentUser = isHost ? room.host : room.opponent!;
    final opponent = isHost ? room.opponent : room.host;

    // Get scores from BattlePlayer's currentScore
    final yourScore = currentUser.currentScore;
    final opponentScore = opponent?.currentScore ?? 0;

    // Determine result based on scores
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
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  Future<void> _connectToRoom(String roomId) async {
    repository.connectToRoom(roomId);
    _roomUpdatesSubscription = repository.getRoomUpdates().listen(
      (update) {
        add(RoomUpdateReceivedEvent(update: update));
      },
      onError: (error) {
        add(
          RoomUpdateReceivedEvent(
            update: {'type': 'error', 'message': error.toString()},
          ),
        );
      },
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
