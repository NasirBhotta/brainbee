import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:brainbee/presentation/views/bot/models/chat_message.dart';
import 'package:brainbee/presentation/views/bot/models/chat_session.dart';
import 'package:brainbee/presentation/views/bot/repository/chat_repository.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'bot_event.dart';
part 'bot_state.dart';

class BotBloc extends Bloc<BotEvent, BotState> {
  final BotRepository repository;

  BotBloc({required this.repository}) : super(BotInitial()) {
    on<LoadHistory>(_onLoadHistory);
    on<SendMessage>(_onSendMessage);
    on<LoadSessionSpecificChat>(_onLoadSessionSpecificChat);
  }

  FutureOr<void> _onLoadHistory(
    LoadHistory event,
    Emitter<BotState> emit,
  ) async {
    emit(LoadHistoryInProgress());

    try {
      final response = await repository.fetchHistory(
        studentId: event.studentId,
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
      final result = await repository.askQuestion(
        question: event.question,
        studentId: event.studentId,
        sessionId: event.sessionId,
      );

      print("result is $result");
      if (result['success']) {
        final answer = result['answer'] as String;
        final sessionId = result['sessionId'] as String;
        final question = result['question'] as String;

        emit(SendMessageSuccess(answer, sessionId));
      } else {
        emit(SendMessageFailure(result['error'] ?? "Unknown error"));
      }
    } catch (e) {
      emit(SendMessageFailure('Failed to send message: ${e.toString()}'));
    }
  }

  FutureOr<void> _onLoadSessionSpecificChat(
    LoadSessionSpecificChat event,
    Emitter<BotState> emit,
  ) async {
    emit(SessionSpecificChatLoading());

    try {
      final messages = await repository.fetchSessionMessages(event.sessionId);
      emit(SessionSpecificChatLoaded(chat: messages));
    } catch (e) {
      emit(
        SessionSpecificChatFailure(
          'Failed to load session chat: ${e.toString()}',
        ),
      );
    }
  }
}
