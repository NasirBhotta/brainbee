import '../models/chat_session.dart';
import '../services/api_services.dart';

class BotRepository {
  final BotApiService apiService;

  BotRepository({required this.apiService});

  /// Ask AI a question and return the answer
  Future<String> askQuestion({
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

  /// Fetch ALL chat sessions of a student
  Future<List<ChatSession>> fetchHistory({required String studentId}) async {
    return await apiService.getChatHistory(studentId: studentId);
  }
}
