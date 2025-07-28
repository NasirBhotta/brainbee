import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../core/models/quest_model.dart';
import '../../core/models/wallet_model.dart';
import '../../core/utils/quest_repository.dart';
import '../../core/utils/notification_service.dart';

// Events
abstract class QuestEvent extends Equatable {
  const QuestEvent();

  @override
  List<Object?> get props => [];
}

class LoadQuests extends QuestEvent {}

class RefreshQuests extends QuestEvent {}

class CompleteQuest extends QuestEvent {
  final String questId;
  
  const CompleteQuest(this.questId);
  
  @override
  List<Object> get props => [questId];
}

class ClaimQuest extends QuestEvent {
  final String questId;
  
  const ClaimQuest(this.questId);
  
  @override
  List<Object> get props => [questId];
}

class LoadWallet extends QuestEvent {}

// States
abstract class QuestState extends Equatable {
  const QuestState();

  @override
  List<Object?> get props => [];
}

class QuestInitial extends QuestState {}

class QuestLoading extends QuestState {}

class QuestLoaded extends QuestState {
  final List<Quest> quests;
  final Wallet wallet;

  const QuestLoaded({
    required this.quests,
    required this.wallet,
  });

  @override
  List<Object> get props => [quests, wallet];

  QuestLoaded copyWith({
    List<Quest>? quests,
    Wallet? wallet,
  }) {
    return QuestLoaded(
      quests: quests ?? this.quests,
      wallet: wallet ?? this.wallet,
    );
  }
}

class QuestError extends QuestState {
  final String message;

  const QuestError(this.message);

  @override
  List<Object> get props => [message];
}

class QuestClaiming extends QuestState {
  final List<Quest> quests;
  final Wallet wallet;
  final String claimingQuestId;

  const QuestClaiming({
    required this.quests,
    required this.wallet,
    required this.claimingQuestId,
  });

  @override
  List<Object> get props => [quests, wallet, claimingQuestId];
}

class QuestClaimed extends QuestState {
  final List<Quest> quests;
  final Wallet wallet;
  final Quest claimedQuest;
  final int coinsEarned;

  const QuestClaimed({
    required this.quests,
    required this.wallet,
    required this.claimedQuest,
    required this.coinsEarned,
  });

  @override
  List<Object> get props => [quests, wallet, claimedQuest, coinsEarned];
}

// BLoC
class QuestBloc extends Bloc<QuestEvent, QuestState> {
  final QuestRepository _questRepository;
  final NotificationService _notificationService;

  QuestBloc({
    QuestRepository? questRepository,
    NotificationService? notificationService,
  })  : _questRepository = questRepository ?? QuestRepository.instance,
        _notificationService = notificationService ?? NotificationService.instance,
        super(QuestInitial()) {
    on<LoadQuests>(_onLoadQuests);
    on<RefreshQuests>(_onRefreshQuests);
    on<CompleteQuest>(_onCompleteQuest);
    on<ClaimQuest>(_onClaimQuest);
    on<LoadWallet>(_onLoadWallet);
  }

  Future<void> _onLoadQuests(LoadQuests event, Emitter<QuestState> emit) async {
    try {
      emit(QuestLoading());
      
      final quests = await _questRepository.getQuests();
      final wallet = await _questRepository.getWallet();
      
      emit(QuestLoaded(quests: quests, wallet: wallet));
    } catch (e) {
      emit(QuestError('Failed to load quests: ${e.toString()}'));
    }
  }

  Future<void> _onRefreshQuests(RefreshQuests event, Emitter<QuestState> emit) async {
    try {
      final currentState = state;
      
      await _questRepository.refreshQuests();
      final quests = await _questRepository.getQuests();
      final wallet = await _questRepository.getWallet();
      
      if (currentState is QuestLoaded) {
        emit(currentState.copyWith(quests: quests, wallet: wallet));
      } else {
        emit(QuestLoaded(quests: quests, wallet: wallet));
      }
    } catch (e) {
      emit(QuestError('Failed to refresh quests: ${e.toString()}'));
    }
  }

  Future<void> _onCompleteQuest(CompleteQuest event, Emitter<QuestState> emit) async {
    try {
      final currentState = state;
      if (currentState is! QuestLoaded) return;

      final completedQuest = await _questRepository.markQuestComplete(event.questId);
      
      // Update the quest list
      final updatedQuests = currentState.quests.map((quest) {
        return quest.id == event.questId ? completedQuest : quest;
      }).toList();

      emit(currentState.copyWith(quests: updatedQuests));

      // Send notification
      await _notificationService.showQuestCompleteNotification(completedQuest);
    } catch (e) {
      emit(QuestError('Failed to complete quest: ${e.toString()}'));
    }
  }

  Future<void> _onClaimQuest(ClaimQuest event, Emitter<QuestState> emit) async {
    try {
      final currentState = state;
      if (currentState is! QuestLoaded) return;

      // Show claiming state
      emit(QuestClaiming(
        quests: currentState.quests,
        wallet: currentState.wallet,
        claimingQuestId: event.questId,
      ));

      final claimedQuest = await _questRepository.claimQuest(event.questId);
      final updatedWallet = await _questRepository.getWallet();
      
      // Update the quest list
      final updatedQuests = currentState.quests.map((quest) {
        return quest.id == event.questId ? claimedQuest : quest;
      }).toList();

      emit(QuestClaimed(
        quests: updatedQuests,
        wallet: updatedWallet,
        claimedQuest: claimedQuest,
        coinsEarned: claimedQuest.coinReward,
      ));

      // Send coin reward notification
      await _notificationService.showCoinRewardNotification(claimedQuest.coinReward);

    } catch (e) {
      final currentState = this.state;
      if (currentState is QuestClaiming) {
        emit(QuestLoaded(quests: currentState.quests, wallet: currentState.wallet));
      }
      emit(QuestError('Failed to claim quest: ${e.toString()}'));
    }
  }

  Future<void> _onLoadWallet(LoadWallet event, Emitter<QuestState> emit) async {
    try {
      final currentState = state;
      if (currentState is QuestLoaded) {
        final wallet = await _questRepository.getWallet();
        emit(currentState.copyWith(wallet: wallet));
      }
    } catch (e) {
      emit(QuestError('Failed to load wallet: ${e.toString()}'));
    }
  }

  // Helper method to get quests by type
  List<Quest> getQuestsByType(QuestType type) {
    final currentState = state;
    if (currentState is QuestLoaded) {
      return currentState.quests.where((quest) => quest.type == type).toList();
    }
    return [];
  }

  // Helper method to get wallet balance
  int get walletBalance {
    final currentState = state;
    if (currentState is QuestLoaded) {
      return currentState.wallet.balance;
    }
    return 0;
  }
}