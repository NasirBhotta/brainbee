// lib/presentation/views/learn/battle/services/battle_api_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/io.dart';

class BattleApiService {
  final String baseUrl;
  final String wsUrl;
  final String Function() getToken;

  WebSocketChannel? _channel;

  BattleApiService({
    required this.baseUrl,
    required this.wsUrl,
    required this.getToken,
  });

  // Get auth headers
  Map<String, String> _getHeaders() {
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${getToken()}',
    };
  }

  // HTTP Methods
  Future<http.Response> get(
    String endpoint, {
    Map<String, String>? queryParams,
  }) async {
    final uri = Uri.parse(
      '$baseUrl$endpoint',
    ).replace(queryParameters: queryParams);

    final response = await http.get(uri, headers: _getHeaders());

    if (response.statusCode >= 400) {
      throw Exception('GET request failed: ${response.body}');
    }

    return response;
  }

  Future<http.Response> post(
    String endpoint, {
    required Map<String, dynamic> data,
  }) async {
    final uri = Uri.parse('$baseUrl$endpoint');

    final response = await http.post(
      uri,
      headers: _getHeaders(),
      body: jsonEncode(data),
    );

    if (response.statusCode >= 400) {
      throw Exception('POST request failed: ${response.body}');
    }

    return response;
  }

  Future<http.Response> put(
    String endpoint, {
    required Map<String, dynamic> data,
  }) async {
    final uri = Uri.parse('$baseUrl$endpoint');

    final response = await http.put(
      uri,
      headers: _getHeaders(),
      body: jsonEncode(data),
    );

    if (response.statusCode >= 400) {
      throw Exception('PUT request failed: ${response.body}');
    }

    return response;
  }

  Future<http.Response> delete(String endpoint) async {
    final uri = Uri.parse('$baseUrl$endpoint');

    final response = await http.delete(uri, headers: _getHeaders());

    if (response.statusCode >= 400) {
      throw Exception('DELETE request failed: ${response.body}');
    }

    return response;
  }

  // WebSocket Methods
  WebSocketChannel connectWebSocket(String roomId) {
    final token = getToken();
    _channel = IOWebSocketChannel.connect(
      '$wsUrl/battle?token=$token&roomId=$roomId',
    );
    return _channel!;
  }

  void sendWebSocketMessage(Map<String, dynamic> message) {
    if (_channel != null) {
      _channel!.sink.add(jsonEncode(message));
    } else {
      throw Exception('WebSocket not connected');
    }
  }

  Stream<dynamic> get webSocketStream {
    if (_channel == null) {
      throw Exception('WebSocket not connected');
    }
    return _channel!.stream;
  }

  void closeWebSocket() {
    _channel?.sink.close();
    _channel = null;
  }

  bool get isWebSocketConnected => _channel != null;

  // Battle-specific endpoints

  /// Create a new battle room
  /// POST /api/student/battle/create
  Future<http.Response> createBattleRoom({
    required String subject,
    required String mode,
    List<String>? chapters,
  }) async {
    return await post(
      '/api/student/battle/create',
      data: {
        'subject': subject,
        'mode': mode,
        if (chapters != null) 'chapters': chapters,
      },
    );
  }

  /// Join an existing battle room with invitation code
  /// POST /api/student/battle/join
  Future<http.Response> joinBattleRoom({required String invitationCode}) async {
    return await post(
      '/api/student/battle/join',
      data: {'invitationCode': invitationCode},
    );
  }

  /// Find a random opponent
  /// POST /api/student/battle/find-random
  Future<http.Response> findRandomOpponent({
    required String subject,
    List<String>? chapters,
  }) async {
    return await post(
      '/api/student/battle/find-random',
      data: {'subject': subject, if (chapters != null) 'chapters': chapters},
    );
  }

  /// Cancel battle search
  /// POST /api/student/battle/:roomId/cancel
  Future<http.Response> cancelBattleSearch({required String roomId}) async {
    return await post('/api/student/battle/$roomId/cancel', data: {});
  }

  /// Mark player as ready
  /// POST /api/student/battle/:roomId/ready
  Future<http.Response> markReady({required String roomId}) async {
    return await post('/api/student/battle/$roomId/ready', data: {});
  }

  /// Start the battle (when both players are ready)
  /// POST /api/student/battle/:roomId/start
  Future<http.Response> startBattle({required String roomId}) async {
    return await post('/api/student/battle/$roomId/start', data: {});
  }

  /// Submit an answer during battle
  /// POST /api/student/battle/:roomId/answer
  Future<http.Response> submitBattleAnswer({
    required String roomId,
    required int questionIndex,
    required int? selectedOptionIndex,
    required int timeSpent,
  }) async {
    return await post(
      '/api/student/battle/$roomId/answer',
      data: {
        'questionIndex': questionIndex,
        'selectedOptionIndex': selectedOptionIndex,
        'timeSpent': timeSpent,
      },
    );
  }

  /// Get battle result
  /// GET /api/student/battle/:roomId/result
  Future<http.Response> getBattleResult({required String roomId}) async {
    return await get('/api/student/battle/$roomId/result');
  }

  /// Get battle history
  /// GET /api/student/battle/history?limit=20&offset=0
  Future<http.Response> getBattleHistory({int? limit, int? offset}) async {
    return await get(
      '/api/student/battle/history',
      queryParams: {
        if (limit != null) 'limit': limit.toString(),
        if (offset != null) 'offset': offset.toString(),
      },
    );
  }

  /// Get battle statistics
  /// GET /api/student/battle/statistics
  Future<http.Response> getBattleStatistics() async {
    return await get('/api/student/battle/statistics');
  }

  /// Leave battle room
  /// POST /api/student/battle/:roomId/leave
  Future<http.Response> leaveBattle({required String roomId}) async {
    return await post('/api/student/battle/$roomId/leave', data: {});
  }
}
