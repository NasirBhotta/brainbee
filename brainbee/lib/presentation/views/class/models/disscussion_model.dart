class DiscussionTopic {
  final String id;
  final String title;
  final String createdBy;
  final DateTime createdAt;
  final int messageCount;
  final bool isGeneral;

  DiscussionTopic({
    required this.id,
    required this.title,
    required this.createdBy,
    required this.createdAt,
    required this.messageCount,
    this.isGeneral = false,
  });

  factory DiscussionTopic.fromJson(Map<String, dynamic> json) {
    return DiscussionTopic(
      id: json['id'] as String,
      title: json['title'] as String,
      createdBy: json['createdBy'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      messageCount: json['messageCount'] as int,
      isGeneral: json['isGeneral'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'createdBy': createdBy,
    'createdAt': createdAt.toIso8601String(),
    'messageCount': messageCount,
    'isGeneral': isGeneral,
  };
}

class DiscussionMessage {
  final String id;
  final String senderId;
  final String senderName;
  final String senderRole;
  final String message;
  final DateTime timestamp;
  final String? topicId;

  DiscussionMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.senderRole,
    required this.message,
    required this.timestamp,
    this.topicId,
  });

  factory DiscussionMessage.fromJson(Map<String, dynamic> json) {
    return DiscussionMessage(
      id: json['id'] as String,
      senderId: json['senderId'] as String,
      senderName: json['senderName'] as String,
      senderRole: json['senderRole'] as String,
      message: json['message'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      topicId: json['topicId'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'senderId': senderId,
    'senderName': senderName,
    'senderRole': senderRole,
    'message': message,
    'timestamp': timestamp.toIso8601String(),
    'topicId': topicId,
  };
}
