part of 'discussion_bloc.dart';

abstract class DiscussionEvent extends Equatable {
  const DiscussionEvent();
  @override
  List<Object?> get props => [];
}

class FetchTopicsEvent extends DiscussionEvent {
  final String classId;
  const FetchTopicsEvent({required this.classId});
  @override
  List<Object?> get props => [classId];
}

class FetchMessagesEvent extends DiscussionEvent {
  final String topicId;
  const FetchMessagesEvent({required this.topicId});
  @override
  List<Object?> get props => [topicId];
}

class SendMessageEvent extends DiscussionEvent {
  final String topicId;
  final String message;
  const SendMessageEvent({required this.topicId, required this.message});
  @override
  List<Object?> get props => [topicId, message];
}

class RefreshMessagesEvent extends DiscussionEvent {
  final String topicId;
  const RefreshMessagesEvent({required this.topicId});
  @override
  List<Object?> get props => [topicId];
}
