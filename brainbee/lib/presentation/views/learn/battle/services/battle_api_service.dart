// lib/presentation/views/learn/battle/services/battle_api_service.dart

import 'dart:async';
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

  // StreamController to broadcast Socket.IO events
  final StreamController<Map<String, dynamic>> _eventStreamController =
      StreamController<Map<String, dynamic>>.broadcast();

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
          .setTransports(['websocket'])
          .disableAutoConnect()
          .setAuth({'token': tokenValue})
          .setExtraHeaders({'Authorization': 'Bearer $tokenValue'})
          .enableForceNew()
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
      _eventStreamController.add({
        'type': 'error',
        'message': 'Connection error: $data',
      });
    });

    _socket!.onError((data) {
      print('❌ Socket Error: $data');
      _eventStreamController.add({
        'type': 'error',
        'message': 'Socket error: $data',
      });
    });

    _socket!.onDisconnect((reason) {
      print('🔌 Socket disconnected: $reason');
      _eventStreamController.add({'type': 'disconnected', 'message': reason});
    });

    // ===== CRITICAL: Listen to all Socket.IO events and forward to stream =====

    // Listen for room join confirmation
    _socket!.on('joined_room', (data) {
      print('✅ Successfully joined room: ${data['roomId']}');
      _eventStreamController.add({
        'type': 'joined_room',
        'roomId': data['roomId'],
      });
    });

    // Listen for room updates - THIS IS THE KEY EVENT
    _socket!.on('room_update', (data) {
      print('🔄 Room update received: $data');

      // Forward the event to the stream
      if (data is Map) {
        _eventStreamController.add(Map<String, dynamic>.from(data));
      } else {
        print('⚠️ Unexpected room_update format: $data');
      }
    });

    // Listen for opponent joined
    _socket!.on('opponent_joined', (data) {
      print('👥 Opponent joined: $data');
      _eventStreamController.add({
        'type': 'opponent_joined',
        'opponent': data['opponent'],
      });
    });

    // Listen for player ready
    _socket!.on('player_ready', (data) {
      print('✅ Player ready: $data');
      _eventStreamController.add({
        'type': 'player_ready',
        'playerId': data['playerId'],
      });
    });

    // Listen for battle started
    _socket!.on('battle_started', (data) {
      print('🎮 Battle started: $data');
      _eventStreamController.add({
        'type': 'battle_started',
        'roomId': data['roomId'],
      });
    });

    // Listen for opponent answered
    _socket!.on('opponent_answered', (data) {
      print('📝 Opponent answered: $data');
      _eventStreamController.add({
        'type': 'opponent_answered',
        'questionIndex': data['questionIndex'],
        'score': data['score'],
      });
    });

    // Listen for battle completed
    _socket!.on('battle_completed', (data) {
      print('🏁 Battle completed: $data');
      _eventStreamController.add({
        'type': 'battle_completed',
        'roomId': data['roomId'],
      });
    });

    // Listen for opponent left
    _socket!.on('opponent_left', (data) {
      print('👋 Opponent left: $data');
      _eventStreamController.add({'type': 'opponent_left'});
    });

    // Listen for generic messages
    _socket!.on('message', (data) {
      print('💬 Message received: $data');
      if (data is Map) {
        _eventStreamController.add(Map<String, dynamic>.from(data));
      }
    });

    // Listen for errors
    _socket!.on('error', (data) {
      print('❌ Room error: ${data['message']}');
      _eventStreamController.add({'type': 'error', 'message': data['message']});
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

  // Stream of all Socket.IO events
  Stream<Map<String, dynamic>> get webSocketStream {
    return _eventStreamController.stream;
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

  // Dispose method to clean up resources
  void dispose() {
    closeWebSocket();
    _eventStreamController.close();
  }

  // Battle-specific endpoints (keep all existing ones)

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

  Future<http.Response> joinBattleRoom({required String invitationCode}) async {
    return await post(
      '/api/student/battle/join',
      data: {'invitationCode': invitationCode},
    );
  }

  Future<http.Response> findRandomOpponent({
    required String subject,
    List<String>? chapters,
  }) async {
    return await post(
      '/api/student/battle/find-random',
      data: {'subject': subject, if (chapters != null) 'chapters': chapters},
    );
  }

  Future<http.Response> cancelBattleSearch({required String roomId}) async {
    return await post('/api/student/battle/$roomId/cancel', data: {});
  }

  Future<http.Response> markReady({required String roomId}) async {
    return await post('/api/student/battle/$roomId/ready', data: {});
  }

  Future<http.Response> startBattle({required String roomId}) async {
    return await post('/api/student/battle/$roomId/start', data: {});
  }

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

  Future<http.Response> getBattleResult({required String roomId}) async {
    return await get('/api/student/battle/$roomId/result');
  }

  Future<http.Response> getBattleHistory({int? limit, int? offset}) async {
    return await get(
      '/api/student/battle/history',
      queryParams: {
        if (limit != null) 'limit': limit.toString(),
        if (offset != null) 'offset': offset.toString(),
      },
    );
  }

  Future<http.Response> getBattleStatistics() async {
    return await get('/api/student/battle/statistics');
  }

  Future<http.Response> leaveBattle({required String roomId}) async {
    return await post('/api/student/battle/$roomId/leave', data: {});
  }
}
