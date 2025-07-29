import 'package:equatable/equatable.dart';
import '../models/quest.dart';

abstract class QuestEvent extends Equatable {
  const QuestEvent();

  @override
  List<Object?> get props => [];
}

class LoadQuests extends QuestEvent {
  final String userId;

  const LoadQuests(this.userId);

  @override
  List<Object> get props => [userId];
}

class RefreshQuests extends QuestEvent {
  final String userId;

  const RefreshQuests(this.userId);

  @override
  List<Object> get props => [userId];
}

class ClaimQuest extends QuestEvent {
  final String userId;
  final Quest quest;

  const ClaimQuest(this.userId, this.quest);

  @override
  List<Object> get props => [userId, quest];
}

class QuestStatusUpdated extends QuestEvent {
  final Quest quest;

  const QuestStatusUpdated(this.quest);

  @override
  List<Object> get props => [quest];
}

class StartQuestPolling extends QuestEvent {
  final String userId;

  const StartQuestPolling(this.userId);

  @override
  List<Object> get props => [userId];
}

class StopQuestPolling extends QuestEvent {}
