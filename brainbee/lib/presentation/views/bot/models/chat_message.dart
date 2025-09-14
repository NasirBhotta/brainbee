class ChatMessage {
  final String sender; // "student" or "ai"
  final String content;
  final DateTime timestamp;

  ChatMessage({
    required this.sender,
    required this.content,
    required this.timestamp,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      sender: json['sender'] ?? '',
      content: json['content'] ?? '',
      timestamp: DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    "sender": sender,
    "content": content,
    "timestamp": timestamp.toIso8601String(),
  };
}
