import 'package:equatable/equatable.dart';
import '../models/quest.dart';

abstract class QuestState extends Equatable {
  const QuestState();

  @override
  List<Object?> get props => [];
}

class QuestInitial extends QuestState {}

class QuestLoading extends QuestState {}

class QuestLoaded extends QuestState {
  final List<Quest> quests;
  final int currentCoins;

  const QuestLoaded(this.quests, this.currentCoins);

  @override
  List<Object> get props => [quests, currentCoins];
}

class QuestError extends QuestState {
  final String message;

  const QuestError(this.message);

  @override
  List<Object> get props => [message];
}

class QuestClaiming extends QuestState {
  final List<Quest> quests;
  final int currentCoins;
  final String claimingQuestId;

  const QuestClaiming(this.quests, this.currentCoins, this.claimingQuestId);

  @override
  List<Object> get props => [quests, currentCoins, claimingQuestId];
}

class QuestClaimed extends QuestState {
  final List<Quest> quests;
  final int newCoins;
  final int coinsAdded;

  const QuestClaimed(this.quests, this.newCoins, this.coinsAdded);

  @override
  List<Object> get props => [quests, newCoins, coinsAdded];
}
