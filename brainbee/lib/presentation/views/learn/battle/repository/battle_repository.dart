// lib/presentation/views/learn/battle/repositories/battle_repository.dart

import 'dart:convert';
import 'package:brainbee/presentation/views/learn/battle/models/battle_models.dart';
import 'package:brainbee/presentation/views/learn/battle/services/battle_api_service.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

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

  Future<void> startBattle({required String roomId});

  // Battle Gameplay
  Future<int> submitAnswer({
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
  Future<IO.Socket> connectToRoom(String roomId);
  Stream<Map<String, dynamic>> getRoomUpdates();
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
      print('✅ Room created: ${data['data']}');
      return BattleRoom.fromJson(data['data']);
    } catch (e) {
      print('❌ Failed to create battle room: $e');
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
      print('✅ Joined room: ${data['data']}');
      return BattleRoom.fromJson(data['data']);
    } catch (e) {
      print('❌ Failed to join battle room: $e');
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
      print('✅ Found random opponent: ${data['data']}');
      return BattleRoom.fromJson(data['data']);
    } catch (e) {
      print('❌ Failed to find random opponent: $e');
      throw Exception('Failed to find random opponent: $e');
    }
  }

  @override
  Future<void> cancelBattleSearch({required String roomId}) async {
    try {
      await apiService.cancelBattleSearch(roomId: roomId);
      print('✅ Cancelled battle search for room: $roomId');
    } catch (e) {
      print('❌ Failed to cancel battle search: $e');
      throw Exception('Failed to cancel battle search: $e');
    }
  }

  @override
  Future<void> markReady({required String roomId}) async {
    try {
      await apiService.markReady(roomId: roomId);
      print('✅ Marked ready for room: $roomId');
    } catch (e) {
      print('❌ Failed to mark ready: $e');
      throw Exception('Failed to mark ready: $e');
    }
  }

  @override
  Future<void> startBattle({required String roomId}) async {
    try {
      // The response is now simple, we don't need to parse it.
      await apiService.startBattle(roomId: roomId);
      print('✅ Start battle request sent successfully.');
    } catch (e) {
      print('❌ Failed to send start battle request: $e');
      throw Exception('Failed to send start battle request: $e');
    }
  }

  @override
  Future<int> submitAnswer({
    required String roomId,
    required int questionIndex,
    required int? selectedOptionIndex,
    required int timeSpent,
  }) async {
    try {
      final response = await apiService.submitBattleAnswer(
        roomId: roomId,
        questionIndex: questionIndex,
        selectedOptionIndex: selectedOptionIndex,
        timeSpent: timeSpent,
      );
      final data = jsonDecode(response.body);
      print('✅ Answer submitted, new score: ${data['data']['currentScore']}');
      return data['data']['currentScore'] as int;
    } catch (e) {
      print('❌ Failed to submit answer: $e');
      throw Exception('Failed to submit answer: $e');
    }
  }

  @override
  Future<BattleResult> getBattleResult({required String roomId}) async {
    try {
      final response = await apiService.getBattleResult(roomId: roomId);

      final data = jsonDecode(response.body);
      print('✅ Got battle result: ${data['data']}');
      return BattleResult.fromJson(data['data']);
    } catch (e) {
      print('❌ Failed to get battle result: $e');
      throw Exception('Failed to get battle result: $e');
    }
  }

  @override
  Future<void> leaveBattle({required String roomId}) async {
    try {
      await apiService.leaveBattle(roomId: roomId);
      print('✅ Left battle room: $roomId');
    } catch (e) {
      print('❌ Failed to leave battle: $e');
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
      print('❌ Failed to get battle history: $e');
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
      print('❌ Failed to get battle statistics: $e');
      throw Exception('Failed to get battle statistics: $e');
    }
  }

  @override
  Future<IO.Socket> connectToRoom(String roomId) async {
    print('🔌 Connecting to room: $roomId');
    return await apiService.connectWebSocket(roomId);
  }

  @override
  Stream<Map<String, dynamic>> getRoomUpdates() {
    print('📡 Setting up room updates stream');
    return apiService.webSocketStream;
  }

  @override
  void sendRoomMessage(Map<String, dynamic> message) {
    apiService.sendWebSocketMessage(message);
  }

  @override
  void disconnectFromRoom() {
    print('🔌 Disconnecting from room');
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
      case BattleMode.byTopic:
        return 'byTopic';
      case BattleMode.byChapter:
        return 'byChapter';
    }
  }
}
