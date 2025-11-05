part of 'battle_bloc.dart';

abstract class BattleState extends Equatable {
  const BattleState();

  @override
  List<Object?> get props => [];
}

class BattleInitial extends BattleState {}

class BattleLoading extends BattleState {}

class BattleRoomCreated extends BattleState {
  final BattleRoom room;

  const BattleRoomCreated({required this.room});

  @override
  List<Object?> get props => [room];
}

class BattleSearching extends BattleState {
  final BattleRoom room;

  const BattleSearching({required this.room});

  @override
  List<Object?> get props => [room];
}

class BattleOpponentFound extends BattleState {
  final BattleRoom room;

  const BattleOpponentFound({required this.room});

  @override
  List<Object?> get props => [room];
}

class BattleReady extends BattleState {
  final BattleRoom room;
  final bool isHostReady;
  final bool isOpponentReady;

  const BattleReady({
    required this.room,
    required this.isHostReady,
    required this.isOpponentReady,
  });

  @override
  List<Object?> get props => [room, isHostReady, isOpponentReady];
}

class BattleInProgress extends BattleState {
  final BattleRoom room;
  final BattleQuizData quizData;
  final int currentQuestionIndex;
  final int userScore;
  final int opponentScore;

  const BattleInProgress({
    required this.room,
    required this.quizData,
    required this.currentQuestionIndex,
    required this.userScore,
    required this.opponentScore,
  });

  @override
  List<Object?> get props => [
    room,
    quizData,
    currentQuestionIndex,
    userScore,
    opponentScore,
  ];
}

class BattleCompleted extends BattleState {
  final BattleResult result;

  const BattleCompleted({required this.result});

  @override
  List<Object?> get props => [result];
}

class BattleCancelled extends BattleState {
  final String message;

  const BattleCancelled({required this.message});

  @override
  List<Object?> get props => [message];
}

class BattleHistoryLoaded extends BattleState {
  final List<BattleRoom> history;

  const BattleHistoryLoaded({required this.history});

  @override
  List<Object?> get props => [history];
}

class BattleError extends BattleState {
  final String message;

  const BattleError({required this.message});

  @override
  List<Object?> get props => [message];
}
