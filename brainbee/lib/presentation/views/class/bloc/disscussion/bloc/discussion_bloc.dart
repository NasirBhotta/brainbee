import 'package:bloc/bloc.dart';
import 'package:brainbee/presentation/views/class/models/disscussion_model.dart';
import 'package:brainbee/presentation/views/class/repo/disscussion_repo.dart';
import 'package:equatable/equatable.dart';

part 'discussion_event.dart';
part 'discussion_state.dart';

class DiscussionBloc extends Bloc<DiscussionEvent, DiscussionState> {
  final DiscussionRepository repository;
  String? _currentClassId;

  DiscussionBloc({required this.repository}) : super(DiscussionInitial()) {
    on<FetchTopicsEvent>(_onFetchTopics);
    on<FetchMessagesEvent>(_onFetchMessages);
    on<SendMessageEvent>(_onSendMessage);
    on<RefreshMessagesEvent>(_onRefreshMessages);
  }

  Future<void> _onFetchTopics(
    FetchTopicsEvent event,
    Emitter<DiscussionState> emit,
  ) async {
    emit(TopicsLoading());
    _currentClassId = event.classId;

    final generalTopic = DiscussionTopic(
      id: 'general_${event.classId}',
      title: 'General Discussion',
      createdBy: 'System',
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
      messageCount: 0,
      isGeneral: true,
    );

    try {
      final topics = await repository.getTopics(event.classId);
      if (topics.isEmpty) {
        emit(TopicsEmpty(generalTopic: generalTopic));
      } else {
        emit(TopicsLoaded(topics: topics, generalTopic: generalTopic));
      }
    } catch (e) {
      emit(
        TopicsError(
          message: _getErrorMessage(e),
          isNetworkError: _isNetworkError(e),
        ),
      );
    }
  }

  Future<void> _onFetchMessages(
    FetchMessagesEvent event,
    Emitter<DiscussionState> emit,
  ) async {
    emit(MessagesLoading());
    try {
      final messages = await repository.getMessages(event.topicId);
      emit(MessagesLoaded(messages: messages, topicId: event.topicId));
    } catch (e) {
      emit(MessagesError(message: _getErrorMessage(e)));
    }
  }

  Future<void> _onSendMessage(
    SendMessageEvent event,
    Emitter<DiscussionState> emit,
  ) async {
    final currentState = state;
    if (currentState is! MessagesLoaded) return;

    emit(currentState.copyWith(isSending: true));

    // Optimistic update - add message immediately
    final optimisticMsg = DiscussionMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      senderId: 'current_user',
      senderName: 'You',
      senderRole: 'student',
      message: event.message,
      timestamp: DateTime.now(),
      topicId: event.topicId,
    );

    final updatedMessages = [...currentState.messages, optimisticMsg];
    emit(currentState.copyWith(messages: updatedMessages, isSending: true));

    try {
      final sentMessage = await repository.sendMessage(
        event.topicId,
        event.message,
      );
      // Replace optimistic message with server response
      final finalMessages = currentState.messages.toList()..add(sentMessage);
      emit(
        MessagesLoaded(
          messages: finalMessages,
          topicId: event.topicId,
          isSending: false,
        ),
      );
    } catch (e) {
      // Remove optimistic message on failure
      emit(currentState.copyWith(isSending: false));
      emit(MessageSendError(error: _getErrorMessage(e)));
      emit(currentState.copyWith(isSending: false));
    }
  }

  Future<void> _onRefreshMessages(
    RefreshMessagesEvent event,
    Emitter<DiscussionState> emit,
  ) async {
    final currentState = state;
    try {
      final messages = await repository.getMessages(event.topicId);
      emit(MessagesLoaded(messages: messages, topicId: event.topicId));
    } catch (e) {
      if (currentState is MessagesLoaded) {
        emit(currentState); // Keep current messages on refresh failure
      }
    }
  }

  String _getErrorMessage(dynamic e) {
    final str = e.toString().toLowerCase();
    if (str.contains('no internet') || str.contains('network'))
      return 'No internet connection';
    return 'An error occurred. Please try again.';
  }

  bool _isNetworkError(dynamic e) {
    final str = e.toString().toLowerCase();
    return str.contains('no internet') || str.contains('network');
  }
}
