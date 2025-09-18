part of 'bot_bloc.dart';

sealed class BotEvent extends Equatable {
  const BotEvent();

  @override
  List<Object> get props => [];
}

class LoadHistory extends BotEvent {
  final String studentId;

  const LoadHistory({required this.studentId});

  @override
  List<Object> get props => [studentId];
}

class SendMessage extends BotEvent {
  final String studentId;
  final String? sessionId;
  final String question;

  const SendMessage({
    required this.studentId,
    required this.question,
    this.sessionId,
  });

  @override
  List<Object> get props => [studentId, question];
}

class LoadSessionSpecificChat extends BotEvent {
  final String sessionId;

  const LoadSessionSpecificChat({required this.sessionId});

  @override
  List<Object> get props => [sessionId];
}
