import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:brainbee/presentation/views/learn/battle/models/battle_models.dart';
import 'package:brainbee/presentation/views/learn/battle/repository/battle_repository.dart';
import 'package:equatable/equatable.dart';

part 'battle_event.dart';
part 'battle_state.dart';

class BattleBloc extends Bloc<BattleEvent, BattleState> {
  final BattleRepository repository;
  StreamSubscription? _roomUpdatesSubscription;

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

      // Connect to WebSocket for real-time updates
      _connectToRoom(room.roomId);

      if (event.mode == BattleMode.random) {
        emit(BattleSearching(room: room));
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

      _connectToRoom(room.roomId);
      emit(BattleOpponentFound(room: room));
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

      _connectToRoom(room.roomId);
      emit(BattleSearching(room: room));
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

  Future<void> _onRoomUpdateReceived(
    RoomUpdateReceivedEvent event,
    Emitter<BattleState> emit,
  ) async {
    final update = event.update;

    // Handle different WebSocket event structures
    final eventType = update['event'] as String?;
    final data = update['data'] as Map<String, dynamic>?;

    if (eventType == 'room_update' && data != null) {
      final type = data['type'] as String?;

      switch (type) {
        case 'opponent_joined':
          if (state is BattleRoomCreated || state is BattleSearching) {
            final currentState = state as dynamic;
            final room = (currentState.room as BattleRoom).copyWith(
              opponent: BattlePlayer.fromJson(data['opponent']),
              status: BattleStatus.matched,
            );
            emit(BattleOpponentFound(room: room));
          }
          break;

        case 'player_ready':
          if (state is BattleOpponentFound || state is BattleReady) {
            final currentState = state as dynamic;
            final room = currentState.room as BattleRoom;
            final playerId = data['playerId'] as String;

            emit(
              BattleReady(
                room: room,
                isHostReady:
                    playerId == room.host.id
                        ? true
                        : (state is BattleReady
                            ? (state as BattleReady).isHostReady
                            : false),
                isOpponentReady:
                    playerId == room.opponent?.id
                        ? true
                        : (state is BattleReady
                            ? (state as BattleReady).isOpponentReady
                            : false),
              ),
            );
          }
          break;

        case 'battle_started':
          add(StartBattleEvent(roomId: data['roomId']));
          break;

        case 'opponent_answered':
          add(
            OpponentAnsweredEvent(
              questionIndex: data['questionIndex'],
              score: data['score'],
            ),
          );
          break;

        case 'battle_completed':
          add(GetBattleResultEvent(roomId: data['roomId']));
          break;

        case 'opponent_left':
          emit(BattleCancelled(message: 'Opponent left the battle'));
          break;
      }
    } else if (eventType == 'joined_room') {
      // Successfully joined room via WebSocket
      print('Successfully joined room: ${data?['roomId']}');
    } else if (eventType == 'error') {
      emit(BattleError(message: data?['message'] ?? 'WebSocket error'));
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

  void _connectToRoom(String roomId) {
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
