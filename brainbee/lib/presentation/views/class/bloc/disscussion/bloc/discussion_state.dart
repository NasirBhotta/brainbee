part of 'discussion_bloc.dart';

abstract class DiscussionState extends Equatable {
  const DiscussionState();
  @override
  List<Object?> get props => [];
}

class DiscussionInitial extends DiscussionState {}

class TopicsLoading extends DiscussionState {}

class TopicsLoaded extends DiscussionState {
  final List<DiscussionTopic> topics;
  final DiscussionTopic generalTopic;
  const TopicsLoaded({required this.topics, required this.generalTopic});
  @override
  List<Object?> get props => [topics, generalTopic];
}

class TopicsEmpty extends DiscussionState {
  final DiscussionTopic generalTopic;
  const TopicsEmpty({required this.generalTopic});
  @override
  List<Object?> get props => [generalTopic];
}

class TopicsError extends DiscussionState {
  final String message;
  final bool isNetworkError;
  const TopicsError({required this.message, this.isNetworkError = false});
  @override
  List<Object?> get props => [message, isNetworkError];
}

class MessagesLoading extends DiscussionState {}

class MessagesLoaded extends DiscussionState {
  final List<DiscussionMessage> messages;
  final String topicId;
  final bool isSending;
  const MessagesLoaded({
    required this.messages,
    required this.topicId,
    this.isSending = false,
  });
  @override
  List<Object?> get props => [messages, topicId, isSending];

  MessagesLoaded copyWith({
    List<DiscussionMessage>? messages,
    String? topicId,
    bool? isSending,
  }) {
    return MessagesLoaded(
      messages: messages ?? this.messages,
      topicId: topicId ?? this.topicId,
      isSending: isSending ?? this.isSending,
    );
  }
}

class MessagesError extends DiscussionState {
  final String message;
  const MessagesError({required this.message});
  @override
  List<Object?> get props => [message];
}

class MessageSent extends DiscussionState {
  final DiscussionMessage message;
  const MessageSent({required this.message});
  @override
  List<Object?> get props => [message];
}

class MessageSendError extends DiscussionState {
  final String error;
  const MessageSendError({required this.error});
  @override
  List<Object?> get props => [error];
}
