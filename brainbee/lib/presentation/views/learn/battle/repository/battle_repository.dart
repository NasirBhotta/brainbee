// lib/presentation/views/learn/battle/repositories/battle_repository.dart

import 'dart:convert';
import 'package:brainbee/presentation/views/learn/battle/models/battle_models.dart';
import 'package:brainbee/presentation/views/learn/battle/services/battle_api_service.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

abstract class BattleRepository {
  // Room Management
  Future<BattleRoom> createBattleRoom({
    required String subject,
    required BattleMode mode,
    List<String>? chapters,
  });

  Future<BattleRoom> joinBattleRoom({required String invitationCode});

  Future<BattleRoom> findRandomOpponent({
    required String subject,
    List<String>? chapters,
  });

  Future<void> cancelBattleSearch({required String roomId});

  Future<void> markReady({required String roomId});

  Future<BattleQuizData> startBattle({required String roomId});

  // Battle Gameplay
  Future<void> submitAnswer({
    required String roomId,
    required int questionIndex,
    required int? selectedOptionIndex,
    required int timeSpent,
  });

  Future<BattleResult> getBattleResult({required String roomId});

  Future<void> leaveBattle({required String roomId});

  // History & Statistics
  Future<List<BattleRoom>> getBattleHistory({int? limit, int? offset});

  Future<Map<String, dynamic>> getBattleStatistics();

  // WebSocket
  WebSocketChannel connectToRoom(String roomId);
  Stream<dynamic> getRoomUpdates();
  void sendRoomMessage(Map<String, dynamic> message);
  void disconnectFromRoom();
  bool get isConnected;
}

class BattleRepositoryImpl implements BattleRepository {
  final BattleApiService apiService;

  BattleRepositoryImpl({required this.apiService});

  @override
  Future<BattleRoom> createBattleRoom({
    required String subject,
    required BattleMode mode,
    List<String>? chapters,
  }) async {
    try {
      final response = await apiService.createBattleRoom(
        subject: subject,
        mode: _battleModeToString(mode),
        chapters: chapters,
      );

      final data = jsonDecode(response.body);
      return BattleRoom.fromJson(data['data']);
    } catch (e) {
      throw Exception('Failed to create battle room: $e');
    }
  }

  @override
  Future<BattleRoom> joinBattleRoom({required String invitationCode}) async {
    try {
      final response = await apiService.joinBattleRoom(
        invitationCode: invitationCode,
      );

      final data = jsonDecode(response.body);
      return BattleRoom.fromJson(data['data']);
    } catch (e) {
      throw Exception('Failed to join battle room: $e');
    }
  }

  @override
  Future<BattleRoom> findRandomOpponent({
    required String subject,
    List<String>? chapters,
  }) async {
    try {
      final response = await apiService.findRandomOpponent(
        subject: subject,
        chapters: chapters,
      );

      final data = jsonDecode(response.body);
      return BattleRoom.fromJson(data['data']);
    } catch (e) {
      throw Exception('Failed to find random opponent: $e');
    }
  }

  @override
  Future<void> cancelBattleSearch({required String roomId}) async {
    try {
      await apiService.cancelBattleSearch(roomId: roomId);
    } catch (e) {
      throw Exception('Failed to cancel battle search: $e');
    }
  }

  @override
  Future<void> markReady({required String roomId}) async {
    try {
      await apiService.markReady(roomId: roomId);
    } catch (e) {
      throw Exception('Failed to mark ready: $e');
    }
  }

  @override
  Future<BattleQuizData> startBattle({required String roomId}) async {
    try {
      final response = await apiService.startBattle(roomId: roomId);

      final data = jsonDecode(response.body);
      return BattleQuizData.fromJson(data['data']);
    } catch (e) {
      throw Exception('Failed to start battle: $e');
    }
  }

  @override
  Future<void> submitAnswer({
    required String roomId,
    required int questionIndex,
    required int? selectedOptionIndex,
    required int timeSpent,
  }) async {
    try {
      await apiService.submitBattleAnswer(
        roomId: roomId,
        questionIndex: questionIndex,
        selectedOptionIndex: selectedOptionIndex,
        timeSpent: timeSpent,
      );
    } catch (e) {
      throw Exception('Failed to submit answer: $e');
    }
  }

  @override
  Future<BattleResult> getBattleResult({required String roomId}) async {
    try {
      final response = await apiService.getBattleResult(roomId: roomId);

      final data = jsonDecode(response.body);
      return BattleResult.fromJson(data['data']);
    } catch (e) {
      throw Exception('Failed to get battle result: $e');
    }
  }

  @override
  Future<void> leaveBattle({required String roomId}) async {
    try {
      await apiService.leaveBattle(roomId: roomId);
    } catch (e) {
      throw Exception('Failed to leave battle: $e');
    }
  }

  @override
  Future<List<BattleRoom>> getBattleHistory({int? limit, int? offset}) async {
    try {
      final response = await apiService.getBattleHistory(
        limit: limit,
        offset: offset,
      );

      final data = jsonDecode(response.body);
      final List<dynamic> battles = data['data'] ?? [];

      return battles.map((battle) => BattleRoom.fromJson(battle)).toList();
    } catch (e) {
      throw Exception('Failed to get battle history: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> getBattleStatistics() async {
    try {
      final response = await apiService.getBattleStatistics();

      final data = jsonDecode(response.body);
      return data['data'] ?? {};
    } catch (e) {
      throw Exception('Failed to get battle statistics: $e');
    }
  }

  @override
  WebSocketChannel connectToRoom(String roomId) {
    return apiService.connectWebSocket(roomId);
  }

  @override
  Stream<dynamic> getRoomUpdates() {
    return apiService.webSocketStream.map((message) {
      return jsonDecode(message);
    });
  }

  @override
  void sendRoomMessage(Map<String, dynamic> message) {
    apiService.sendWebSocketMessage(message);
  }

  @override
  void disconnectFromRoom() {
    apiService.closeWebSocket();
  }

  @override
  bool get isConnected => apiService.isWebSocketConnected;

  // Helper method to convert BattleMode enum to string
  String _battleModeToString(BattleMode mode) {
    switch (mode) {
      case BattleMode.random:
        return 'random';
      case BattleMode.invitation:
        return 'invitation';
      case BattleMode.wholeBook:
        return 'wholeBook';
      case BattleMode.byChapter:
        return 'byChapter';
    }
  }
}
