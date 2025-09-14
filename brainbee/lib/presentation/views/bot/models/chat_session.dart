import 'chat_message.dart';

class ChatSession {
  final String id; // session _id from MongoDB
  final String studentId;
  final DateTime createdAt;
  final List<ChatMessage> messages;

  ChatSession({
    required this.id,
    required this.studentId,
    required this.createdAt,
    required this.messages,
  });

  factory ChatSession.fromJson(Map<String, dynamic> json) {
    return ChatSession(
      id: json['_id'] ?? '',
      studentId: json['student'] ?? json['studentId'] ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      messages:
          (json['messages'] as List? ?? [])
              .map((msg) => ChatMessage.fromJson(msg))
              .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    "_id": id,
    "student": studentId,
    "createdAt": createdAt.toIso8601String(),
    "messages": messages.map((m) => m.toJson()).toList(),
  };
}
