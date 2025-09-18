import '../models/chat_session.dart';
import '../models/chat_message.dart';
import '../services/api_services.dart';

class BotRepository {
  final BotApiService apiService;

  BotRepository({required this.apiService});

  /// Ask AI a question and return detailed response
  Future<Map<String, dynamic>> askQuestion({
    required String studentId,
    required String question,
    String? sessionId,
  }) async {
    return await apiService.sendMessage(
      studentId: studentId,
      question: question,
      sessionId: sessionId,
    );
  }

  /// Ask AI a question and return just the AI response text (for backward compatibility)
  Future<String> askQuestionSimple({
    required String studentId,
    required String question,
    String? sessionId,
  }) async {
    final result = await apiService.sendMessage(
      studentId: studentId,
      question: question,
      sessionId: sessionId,
    );
    return result['aiResponse'] ?? 'No response received';
  }

  /// Fetch ALL chat sessions of a student
  Future<List<ChatSession>> fetchHistory({required String studentId}) async {
    print("working");
    return await apiService.getChatHistory(studentId: studentId);
  }

  Future<List<ChatMessage>> fetchSessionMessages(String sessionId) async {
    return await apiService.getSessionMessages(sessionId);
  }
}
