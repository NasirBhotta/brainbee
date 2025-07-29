import 'package:brainbee/core/models/wallet.dart';
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
  final Wallet wallet;

  const QuestLoaded(this.quests, this.wallet);

  @override
  List<Object> get props => [quests, wallet];
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

  const QuestClaiming(this.quests, this.wallet, this.claimingQuestId);

  @override
  List<Object> get props => [quests, wallet, claimingQuestId];
}

class QuestClaimed extends QuestState {
  final List<Quest> quests;
  final Wallet wallet;
  final int coinsAdded;

  const QuestClaimed(this.quests, this.wallet, this.coinsAdded);

  @override
  List<Object> get props => [quests, wallet, coinsAdded];
}
