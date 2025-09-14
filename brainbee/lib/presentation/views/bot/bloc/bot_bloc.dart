import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:brainbee/presentation/views/bot/models/chat_message.dart';
import 'package:brainbee/presentation/views/bot/models/chat_session.dart';
import 'package:brainbee/presentation/views/bot/repository/chat_repository.dart';
import 'package:equatable/equatable.dart';

part 'bot_event.dart';
part 'bot_state.dart';

class BotBloc extends Bloc<BotEvent, BotState> {
  final BotRepository repository;

  BotBloc({required this.repository}) : super(BotInitial()) {
    on<LoadHistory>(_onLoadHistory);
    on<SendMessage>(_onSendMessage);
  }

  /// Dummy sessions for testing (replace later with API call)
  final List<ChatSession> dummySessions = [
    ChatSession(
      id: "chat_1",
      studentId: "6883d69eed4b4da8e4cfd921",
      messages: [
        ChatMessage(
          sender: "student",
          content: "Hi, explain Newton's First Law.",
          timestamp: DateTime.parse("2025-09-13T11:00:00.000Z"),
        ),
        ChatMessage(
          sender: "ai",
          content:
              "Newton's First Law states that an object will remain at rest or move in a straight line at constant speed unless acted upon by a force.",
          timestamp: DateTime.parse("2025-09-13T11:00:03.000Z"),
        ),
      ],
      createdAt: DateTime.parse("2025-09-13T11:00:00.000Z"),
    ),
    ChatSession(
      id: "chat_2",
      studentId: "6883d69eed4b4da8e4cfd921",
      messages: [
        ChatMessage(
          sender: "student",
          content: "What is morphology?",
          timestamp: DateTime.parse("2025-09-14T09:30:00.000Z"),
        ),
        ChatMessage(
          sender: "ai",
          content:
              "Morphology is the study of the form and structure of organisms.",
          timestamp: DateTime.parse("2025-09-14T09:30:05.000Z"),
        ),
      ],
      createdAt: DateTime.parse("2025-09-14T09:30:00.000Z"),
    ),
  ];

  FutureOr<void> _onLoadHistory(
    LoadHistory event,
    Emitter<BotState> emit,
  ) async {
    emit(LoadHistoryInProgress());

    try {
      // Simulate delay for demo
      await Future.delayed(const Duration(seconds: 1));

      // TODO: Replace with API call when ready
      // final response = await repository.fetchHistory(studentId: event.studentId);

      final response =
          dummySessions
              .where((session) => session.studentId == event.studentId)
              .toList();

      print("dummy sessions: ${dummySessions.map((e) => e.studentId)}");
      print(
        "response is ${dummySessions.where((session) => session.studentId == event.studentId).toList()}",
      );
      emit(LoadHistorySuccess(response));
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
      // Optimistically append message to dummy session (for demo only)
      final newMessage = ChatMessage(
        sender: "student",
        content: event.question,
        timestamp: DateTime.now(),
      );

      dummySessions.first.messages.add(newMessage);

      // TODO: Replace with real API call
      final response = ChatMessage(
        sender: "ai",
        content: "This is a dummy AI response for '${event.question}'.",
        timestamp: DateTime.now().add(const Duration(seconds: 1)),
      );

      dummySessions.first.messages.add(response);

      emit(SendMessageSuccess(response.content));
    } catch (e) {
      emit(SendMessageFailure('Failed to send message: ${e.toString()}'));
    }
  }
}
