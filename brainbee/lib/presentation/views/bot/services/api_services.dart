import 'dart:convert';
import 'package:brainbee/presentation/views/bot/models/chat_session.dart';
import 'package:http/http.dart' as http;

class BotApiService {
  final String sendUrl = "http://localhost:5000/api/ai/chatbot";
  final String historyUrl = "http://localhost:5000/api/ai/chatbot/history";

  /// Send a new question and get the AI answer
  Future<String> sendMessage({
    required String studentId,
    required String subject,
    required String question,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(sendUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "student_id": studentId,
          "subject": subject,
          "question": question,
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

  /// Fetch chat history for a student
  Future<ChatSession?> getChatHistory({required String studentId}) async {
    try {
      final response = await http.post(
        Uri.parse(historyUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"student_id": studentId}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return ChatSession.fromJson(data);
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }
}
