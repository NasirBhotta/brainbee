import 'dart:convert';
import 'package:brainbee/core/models/token_user.dart';
import 'package:brainbee/presentation/views/auth/models/user_model.dart';
import 'package:brainbee/presentation/views/bot/models/chat_message.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/chat_session.dart';

import 'package:brainbee/config/api_config.dart';

class BotApiService {
  final String sendUrl = "${BBApiConfig.baseUrl}/api/openai/chatbot";
  final String historyUrl =
      "${BBApiConfig.baseUrl}/api/openai/chatbot/sessions";

  /// Send a message to chatbot and get AI response
  Future<TokenUserData> getTokenAndUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      final userData = prefs.getString('user_data');

      UserModel? user;
      if (userData != null && userData.isNotEmpty) {
        try {
          final userMap = jsonDecode(userData);
          user = UserModel.fromJson(userMap);
        } catch (e) {
          await removeTokenAndUser();
        }
      }

      return TokenUserData(token: token, user: user);
    } catch (e) {
      return TokenUserData(token: null, user: null);
    }
  }

  Future<void> removeTokenAndUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
      await prefs.remove('user_data');
    } catch (e) {
      throw Exception("Error removing token and user: $e");
    }
  }

  Future<Map<String, dynamic>> sendMessage({
    required String studentId,
    required String question,
    String? sessionId,
  }) async {
    try {
      final tokenUserData = await getTokenAndUser();
      final token = tokenUserData.token;

      print("token is $token");
      if (token == null || token.isEmpty) {
        throw Exception("Authentication token not found");
      }

      final response = await http.post(
        Uri.parse(sendUrl),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({"question": question, "session_id": sessionId}),
      );

      print("Response status code: ${response.statusCode}");
      print("Response body: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        return {
          'success': true,
          'sessionId': data['session_id'],
          'question': data['question'],
          'answer': data['answer'],
        };
      } else {
        return {
          'success': false,
          'error': 'Error: ${response.statusCode}',
          'answer': 'Failed to get response',
        };
      }
    } catch (e) {
      print("Exception in sendMessage: $e");
      return {
        'success': false,
        'error': 'Exception: $e',
        'answer': 'Failed to send message',
      };
    }
  }

  /// Fetch ALL chat sessions of a student
  Future<List<ChatSession>> getChatHistory({required String studentId}) async {
    try {
      final tokenUserData = await getTokenAndUser();
      final token = tokenUserData.token;

      print("token will $token");
      if (token == null || token.isEmpty) {
        throw Exception("Authentication token not found");
      }

      final response = await http.get(
        Uri.parse(historyUrl),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        print("response status code is ${response.statusCode}");
        final data = jsonDecode(response.body)['sessions'] as List;

        return data.map((session) => ChatSession.fromJson(session)).toList();
      } else {
        return [];
      }
    } catch (e) {
      print("error is $e");
      return [];
    }
  }

  Future<List<ChatMessage>> getSessionMessages(String sessionId) async {
    print("the session id $sessionId");
    try {
      final tokenUserData = await getTokenAndUser();
      final token = tokenUserData.token;

      if (token == null || token.isEmpty) {
        throw Exception("Authentication token not found");
      }

      final response = await http.get(
        Uri.parse("$historyUrl/$sessionId"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final messages = data['session']['messages'] as List;
        return messages.map((m) => ChatMessage.fromJson(m)).toList();
      } else {
        throw Exception(
          "Failed to fetch session messages: ${response.statusCode}",
        );
      }
    } catch (e) {
      print("error in getSessionMessages: $e");
      rethrow;
    }
  }
}
