import 'package:brainbee/presentation/views/bot/models/chat_session.dart';
import 'package:brainbee/presentation/views/bot/services/api_services.dart';

class BotRepository {
  final BotApiService apiService;

  BotRepository({required this.apiService});

  /// Ask AI a question and get the answer as a String
  Future<String> askQuestion({
    required String studentId,
    required String subject,
    required String question,
  }) async {
    return await apiService.sendMessage(
      studentId: studentId,
      subject: subject,
      question: question,
    );
  }

  /// Fetch full chat history wrapped in a ChatSession
  Future<ChatSession?> fetchHistory({required String studentId}) async {
    return await apiService.getChatHistory(studentId: studentId);
  }
}
