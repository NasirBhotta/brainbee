import 'chat_message.dart';

class ChatSession {
  final String studentId;
  final List<ChatMessage> history;

  ChatSession({required this.studentId, required this.history});

  factory ChatSession.fromJson(Map<String, dynamic> json) {
    return ChatSession(
      studentId: json['student_id'] ?? '',
      history:
          (json['history'] as List? ?? [])
              .map((msg) => ChatMessage.fromJson(msg))
              .toList(),
    );
  }
}
