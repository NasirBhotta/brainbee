part of 'battle_bloc.dart';

abstract class BattleEvent extends Equatable {
  const BattleEvent();

  @override
  List<Object?> get props => [];
}

class CreateBattleRoomEvent extends BattleEvent {
  final String subject;
  final BattleMode mode;
  final List<String>? chapters;

  const CreateBattleRoomEvent({
    required this.subject,
    required this.mode,
    this.chapters,
  });

  @override
  List<Object?> get props => [subject, mode, chapters];
}

class JoinBattleRoomEvent extends BattleEvent {
  final String invitationCode;

  const JoinBattleRoomEvent({required this.invitationCode});

  @override
  List<Object?> get props => [invitationCode];
}

class FindRandomOpponentEvent extends BattleEvent {
  final String subject;
  final List<String>? chapters;

  const FindRandomOpponentEvent({required this.subject, this.chapters});

  @override
  List<Object?> get props => [subject, chapters];
}

class CancelBattleSearchEvent extends BattleEvent {
  final String roomId;

  const CancelBattleSearchEvent({required this.roomId});

  @override
  List<Object?> get props => [roomId];
}

class MarkReadyEvent extends BattleEvent {
  final String roomId;

  const MarkReadyEvent({required this.roomId});

  @override
  List<Object?> get props => [roomId];
}

class StartBattleEvent extends BattleEvent {
  final String roomId;

  const StartBattleEvent({required this.roomId});

  @override
  List<Object?> get props => [roomId];
}

class SubmitAnswerEvent extends BattleEvent {
  final String roomId;
  final int questionIndex;
  final int? selectedOptionIndex;
  final int timeSpent;

  const SubmitAnswerEvent({
    required this.roomId,
    required this.questionIndex,
    required this.selectedOptionIndex,
    required this.timeSpent,
  });

  @override
  List<Object?> get props => [
    roomId,
    questionIndex,
    selectedOptionIndex,
    timeSpent,
  ];
}

class LeaveBattleEvent extends BattleEvent {
  final String roomId;

  const LeaveBattleEvent({required this.roomId});

  @override
  List<Object?> get props => [roomId];
}

class RoomUpdateReceivedEvent extends BattleEvent {
  final Map<String, dynamic> update;

  const RoomUpdateReceivedEvent({required this.update});

  @override
  List<Object?> get props => [update];
}

class OpponentAnsweredEvent extends BattleEvent {
  final int questionIndex;
  final int score;

  const OpponentAnsweredEvent({
    required this.questionIndex,
    required this.score,
  });

  @override
  List<Object?> get props => [questionIndex, score];
}

class GetBattleResultEvent extends BattleEvent {
  final String roomId;

  const GetBattleResultEvent({required this.roomId});

  @override
  List<Object?> get props => [roomId];
}

class LoadBattleHistoryEvent extends BattleEvent {
  final int? limit;
  final int? offset;

  const LoadBattleHistoryEvent({this.limit, this.offset});

  @override
  List<Object?> get props => [limit, offset];
}
