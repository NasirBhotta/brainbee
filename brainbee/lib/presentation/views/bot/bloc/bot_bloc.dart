import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:brainbee/presentation/views/bot/models/chat_session.dart';
import 'package:brainbee/presentation/views/bot/models/chat_message.dart';
import 'package:brainbee/presentation/views/bot/repository/chat_repository.dart';
import 'package:equatable/equatable.dart';

part 'bot_event.dart';
part 'bot_state.dart';

class BotBloc extends Bloc<BotEvent, BotState> {
  final BotRepository repository;

  // Simulated API response for testing purposes
  final dummyResponse = {
    "_id": "650a8e6a2c39d2a123456789",
    "student": "650a8d9f2c39d2a123456788",
    "messages": [
      {
        "sender": "student",
        "content": "Hi, explain Newton's First Law.",
        "timestamp": "2025-09-13T11:00:00.000Z",
      },
      {
        "sender": "ai",
        "content":
            "Newton's First Law states that an object will remain at rest or move in a straight line at constant speed unless acted upon by a force.",
        "timestamp": "2025-09-13T11:00:03.000Z",
      },
      {
        "sender": "student",
        "content": "Give me a real-life example.",
        "timestamp": "2025-09-13T11:01:10.000Z",
      },
      {
        "sender": "ai",
        "content":
            "For example, a soccer ball will not move until someone kicks it.",
        "timestamp": "2025-09-13T11:01:15.000Z",
      },
    ],
    "context": {
      "book": "650a8f1b2c39d2a123456790",
      "chapter": "650a8f7c2c39d2a123456791",
      "topic": "Newton Laws of Motion",
    },
    "createdAt": "2025-09-13T11:00:00.000Z",
  };

  BotBloc({required this.repository}) : super(BotInitial()) {
    on<LoadHistory>(_onLoadHistory);
    on<SendMessage>(_onSendMessage);
  }

  FutureOr<void> _onLoadHistory(
    LoadHistory event,
    Emitter<BotState> emit,
  ) async {
    emit(LoadHistoryInProgress());

    try {
      // Add delay for demonstration
      await Future.delayed(const Duration(seconds: 2));

      final response = await repository.fetchHistory(
        studentId: event.studentId,
      );

      if (response != null) {
        emit(LoadHistorySuccess(response));
      } else {
        // If no response, create a dummy session for testing
        final dummySession = ChatSession.fromJson({
          'student_id': event.studentId,
          'history': dummyResponse['messages'],
        });
        emit(LoadHistorySuccess(dummySession));
      }
    } catch (e) {
      emit(LoadHistoryFailure('Failed to load chat history: ${e.toString()}'));
    }
  }

  FutureOr<void> _onSendMessage(
    SendMessage event,
    Emitter<BotState> emit,
  ) async {
    emit(SendMessageInProgress());

    try {
      final response = await repository.askQuestion(
        studentId: event.studentId,
        subject: event.subject,
        question: event.question,
      );

      emit(SendMessageSuccess(response));
    } catch (e) {
      emit(SendMessageFailure('Failed to send message: ${e.toString()}'));
    }
  }
}
