import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/chat_session.dart';

class BotApiService {
  final String sendUrl = "http://localhost:5000/api/ai/chatbot";
  final String historyUrl = "http://localhost:5000/api/ai/chatbot/history";

  /// Send a message to chatbot and get AI response
  Future<String> sendMessage({
    required String studentId,
    required String question,
    String? sessionId, // optional (existing session)
  }) async {
    try {
      final response = await http.post(
        Uri.parse(sendUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "student_id": studentId,
          "question": question,
          "session_id": sessionId, // backend decides if new or existing session
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['answer'] ?? "No answer received";
      } else {
        return "Error: ${response.statusCode}";
      }
    } catch (e) {
      return "Exception: $e";
    }
  }

  /// Fetch ALL chat sessions of a student
  Future<List<ChatSession>> getChatHistory({required String studentId}) async {
    try {
      final response = await http.post(
        Uri.parse(historyUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"student_id": studentId}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        return data.map((session) => ChatSession.fromJson(session)).toList();
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }
}
