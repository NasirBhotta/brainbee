import 'dart:async';
import 'package:brainbee/presentation/views/extras/coinquests/bloc/quest_event.dart';
import 'package:brainbee/presentation/views/extras/coinquests/bloc/quest_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/quest.dart';

import '../services/api_service.dart';
import '../services/notification_service.dart';

class QuestBloc extends Bloc<QuestEvent, QuestState> {
  final ApiService _apiService;
  final NotificationService _notificationService;
  Timer? _pollingTimer;
  DateTime _lastQuestCheck = DateTime.now();

  QuestBloc(this._apiService, this._notificationService)
    : super(QuestInitial()) {
    on<LoadQuests>(_onLoadQuests);
    on<RefreshQuests>(_onRefreshQuests);
    on<ClaimQuest>(_onClaimQuest);
    on<QuestStatusUpdated>(_onQuestStatusUpdated);
    on<StartQuestPolling>(_onStartQuestPolling);
    on<StopQuestPolling>(_onStopQuestPolling);
  }

  Future<void> _onLoadQuests(LoadQuests event, Emitter<QuestState> emit) async {
    emit(QuestLoading());
    try {
      final quests = await _apiService.getQuests(event.userId);
      final wallet = await _apiService.getWallet(event.userId);
      emit(QuestLoaded(quests, wallet));
    } catch (e) {
      emit(QuestError(e.toString()));
    }
  }

  Future<void> _onRefreshQuests(
    RefreshQuests event,
    Emitter<QuestState> emit,
  ) async {
    try {
      final quests = await _apiService.getQuests(event.userId);
      final wallet = await _apiService.getWallet(event.userId);
      emit(QuestLoaded(quests, wallet));
    } catch (e) {
      emit(QuestError(e.toString()));
    }
  }

  Future<void> _onClaimQuest(ClaimQuest event, Emitter<QuestState> emit) async {
    final currentState = state;
    if (currentState is! QuestLoaded) return;

    emit(
      QuestClaiming(currentState.quests, currentState.wallet, event.quest.id),
    );

    try {
      final result = await _apiService.claimQuest(event.userId, event.quest.id);

      if (result['success'] == true) {
        // Update quest status
        final updatedQuests =
            currentState.quests.map((q) {
              if (q.id == event.quest.id) {
                return q.copyWith(
                  status: QuestStatus.claimed,
                  claimedAt: DateTime.now(),
                );
              }
              return q;
            }).toList();

        // Update wallet
        final updatedWallet = currentState.wallet.copyWith(
          balance: result['newBalance'],
          lastUpdated: DateTime.now(),
        );

        // Cancel notification for this quest
        await _notificationService.cancelQuestNotification(event.quest.id);

        emit(QuestClaimed(updatedQuests, updatedWallet, result['coinsAdded']));

        // After showing success state, go back to loaded state
        await Future.delayed(Duration(seconds: 2));
        emit(QuestLoaded(updatedQuests, updatedWallet));
      } else {
        emit(QuestError('Failed to claim quest'));
      }
    } catch (e) {
      emit(QuestError(e.toString()));
    }
  }

  Future<void> _onQuestStatusUpdated(
    QuestStatusUpdated event,
    Emitter<QuestState> emit,
  ) async {
    final currentState = state;
    if (currentState is! QuestLoaded) return;

    final updatedQuests =
        currentState.quests.map((q) {
          if (q.id == event.quest.id) {
            return event.quest;
          }
          return q;
        }).toList();

    emit(QuestLoaded(updatedQuests, currentState.wallet));

    // Show notification if quest is now complete
    if (event.quest.status == QuestStatus.complete) {
      await _notificationService.showQuestCompleteNotification(event.quest);
    }
  }

  Future<void> _onStartQuestPolling(
    StartQuestPolling event,
    Emitter<QuestState> emit,
  ) async {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(Duration(seconds: 30), (timer) async {
      try {
        final updatedQuests = await _apiService.checkQuestUpdates(
          event.userId,
          _lastQuestCheck,
        );
        _lastQuestCheck = DateTime.now();

        for (final quest in updatedQuests) {
          add(QuestStatusUpdated(quest));
        }
      } catch (e) {
        print('Polling error: $e');
      }
    });
  }

  void _onStopQuestPolling(StopQuestPolling event, Emitter<QuestState> emit) {
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  @override
  Future<void> close() {
    _pollingTimer?.cancel();
    return super.close();
  }
}
