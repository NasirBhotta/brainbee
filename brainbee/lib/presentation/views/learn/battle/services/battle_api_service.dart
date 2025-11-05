// lib/presentation/views/learn/battle/services/battle_api_service.dart

import 'dart:convert';
import 'package:brainbee/core/models/token_user.dart';
import 'package:http/http.dart' as http;
import 'package:socket_io_client/socket_io_client.dart' as IO;

class BattleApiService {
  final String baseUrl;
  final String wsUrl;
  final Future<TokenUserData> Function() getToken;

  IO.Socket? _socket;
  String? _currentRoomId;

  BattleApiService({
    required this.baseUrl,
    required this.wsUrl,
    required this.getToken,
  });

  Future<String> token() async {
    final tokenUserData = await getToken();
    return tokenUserData.token ?? '';
  }

  // Get auth headers
  Future<Map<String, String>> _getHeaders() async {
    final tokenValue = await token();
    print("in battle token is $tokenValue");
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $tokenValue',
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
    final headers = await _getHeaders();
    final response = await http.get(uri, headers: headers);

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
    final headers = await _getHeaders();

    final response = await http.post(
      uri,
      headers: headers,
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
    final headers = await _getHeaders();

    final response = await http.put(
      uri,
      headers: headers,
      body: jsonEncode(data),
    );

    if (response.statusCode >= 400) {
      throw Exception('PUT request failed: ${response.body}');
    }

    return response;
  }

  Future<http.Response> delete(String endpoint) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    final headers = await _getHeaders();

    final response = await http.delete(uri, headers: headers);

    if (response.statusCode >= 400) {
      throw Exception('DELETE request failed: ${response.body}');
    }

    return response;
  }

  // WebSocket Methods using Socket.IO
  Future<IO.Socket> connectWebSocket(String roomId) async {
    final tokenValue = await token();

    // Disconnect existing socket if any
    if (_socket != null) {
      _socket!.disconnect();
      _socket!.dispose();
    }

    print('🔌 Connecting to WebSocket: $wsUrl/battle');
    print('🔑 Token: ${tokenValue.substring(0, 20)}...');
    print('🏠 Room ID: $roomId');

    // Create Socket.IO connection
    _socket = IO.io(
      '$wsUrl/battle',
      IO.OptionBuilder()
          .setTransports(['websocket']) // Use websocket transport
          .disableAutoConnect() // Manual connection control
          .setAuth({'token': tokenValue})
          .setExtraHeaders({'Authorization': 'Bearer $tokenValue'})
          .enableForceNew() // Force new connection
          .setReconnectionDelay(1000)
          .setReconnectionDelayMax(5000)
          .setReconnectionAttempts(5)
          .build(),
    );

    _currentRoomId = roomId;

    // Setup connection handlers
    _socket!.onConnect((_) {
      print('✅ Socket.IO connected successfully');
      print('📍 Socket ID: ${_socket!.id}');

      // Join the room after connection
      if (_currentRoomId != null) {
        _socket!.emit('join_room', {'roomId': _currentRoomId});
        print('🚪 Emitted join_room for: $_currentRoomId');
      }
    });

    _socket!.onConnectError((data) {
      print('❌ Connection Error: $data');
    });

    _socket!.onError((data) {
      print('❌ Socket Error: $data');
    });

    _socket!.onDisconnect((reason) {
      print('🔌 Socket disconnected: $reason');
    });

    // Listen for room join confirmation
    _socket!.on('joined_room', (data) {
      print('✅ Successfully joined room: ${data['roomId']}');
    });

    // Listen for errors
    _socket!.on('error', (data) {
      print('❌ Room error: ${data['message']}');
    });

    // Connect the socket
    _socket!.connect();

    return _socket!;
  }

  void sendWebSocketMessage(Map<String, dynamic> message) {
    if (_socket != null && _socket!.connected) {
      _socket!.emit('send_message', message);
    } else {
      throw Exception('WebSocket not connected');
    }
  }

  Stream<dynamic> get webSocketStream {
    if (_socket == null) {
      throw Exception('WebSocket not connected');
    }

    // Create a stream controller to handle Socket.IO events
    return Stream.empty(); // This will be handled differently - see below
  }

  // Better approach: Subscribe to specific events
  void onRoomUpdate(Function(dynamic) callback) {
    _socket?.on('room_update', callback);
  }

  void onMessage(Function(dynamic) callback) {
    _socket?.on('message', callback);
  }

  void onUserMessage(Function(dynamic) callback) {
    _socket?.on('user_message', callback);
  }

  // Remove event listeners
  void offRoomUpdate() {
    _socket?.off('room_update');
  }

  void offMessage() {
    _socket?.off('message');
  }

  void offUserMessage() {
    _socket?.off('user_message');
  }

  void closeWebSocket() {
    if (_currentRoomId != null) {
      _socket?.emit('leave_room', {'roomId': _currentRoomId});
    }
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
    _currentRoomId = null;
  }

  bool get isWebSocketConnected => _socket?.connected ?? false;

  IO.Socket? get socket => _socket;

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
