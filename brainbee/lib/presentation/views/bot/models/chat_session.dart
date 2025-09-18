import 'chat_message.dart';

class ChatSession {
  final String id; // session _id from MongoDB
  final String title;
  final DateTime createdAt;
  final DateTime lastActivity;
  final int messageCount;

  ChatSession({
    required this.id,
    required this.title,
    required this.createdAt,
    required this.lastActivity,
    required this.messageCount,
  });

  factory ChatSession.fromJson(Map<String, dynamic> json) {
    return ChatSession(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      lastActivity:
          DateTime.tryParse(json['lastActivity'] ?? '') ?? DateTime.now(),
      messageCount: json['messageCount'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    "_id": id,
    "title": title,
    "createdAt": createdAt.toIso8601String(),
    "lastActivity": lastActivity.toIso8601String(),
    "messageCount": messageCount,
  };
}
