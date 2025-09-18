part of 'bot_bloc.dart';

sealed class BotState extends Equatable {
  const BotState();

  @override
  List<Object> get props => [];
}

final class BotInitial extends BotState {}

final class LoadHistoryInProgress extends BotState {}

final class LoadHistorySuccess extends BotState {
  final List<ChatSession> chatSession;

  const LoadHistorySuccess(this.chatSession);

  @override
  List<Object> get props => [chatSession];
}

final class LoadHistoryFailure extends BotState {
  final String error;

  const LoadHistoryFailure(this.error);

  @override
  List<Object> get props => [error];
}

final class SendMessageInProgress extends BotState {}

final class SendMessageSuccess extends BotState {
  final String response;
  final String sessionId;

  const SendMessageSuccess(this.response, this.sessionId);

  @override
  List<Object> get props => [response];
}

final class SendMessageFailure extends BotState {
  final String error;

  const SendMessageFailure(this.error);

  @override
  List<Object> get props => [error];
}

final class SessionSpecificChatLoading extends BotState {}

final class SessionSpecificChatLoaded extends BotState {
  final List<ChatMessage> chat;

  const SessionSpecificChatLoaded({required this.chat});

  @override
  List<Object> get props => [chat];
}

final class SessionSpecificChatFailure extends BotState {
  final String error;

  const SessionSpecificChatFailure(this.error);

  @override
  List<Object> get props => [error];
}
