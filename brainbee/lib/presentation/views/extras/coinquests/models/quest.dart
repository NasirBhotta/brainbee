import 'package:equatable/equatable.dart';

enum QuestType { daily, weekly, oneTime }

enum QuestStatus { incomplete, complete, claimed }

class Quest extends Equatable {
  final String id;
  final String questId;
  final String title;
  final String description;
  final int coinReward;
  final QuestType type;
  final QuestStatus status;
  final String? iconUrl;
  final DateTime? resetTime;
  final DateTime? completedAt;
  final DateTime? claimedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Quest({
    required this.id,
    required this.questId,
    required this.title,
    required this.description,
    required this.coinReward,
    required this.type,
    required this.status,
    this.iconUrl,
    this.resetTime,
    this.completedAt,
    this.claimedAt,
    this.createdAt,
    this.updatedAt,
  });

  Quest copyWith({
    String? id,
    String? questId,
    String? title,
    String? description,
    int? coinReward,
    QuestType? type,
    QuestStatus? status,
    String? iconUrl,
    DateTime? resetTime,
    DateTime? completedAt,
    DateTime? claimedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Quest(
      id: id ?? this.id,
      questId: questId ?? this.questId,
      title: title ?? this.title,
      description: description ?? this.description,
      coinReward: coinReward ?? this.coinReward,
      type: type ?? this.type,
      status: status ?? this.status,
      iconUrl: iconUrl ?? this.iconUrl,
      resetTime: resetTime ?? this.resetTime,
      completedAt: completedAt ?? this.completedAt,
      claimedAt: claimedAt ?? this.claimedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'questId': questId,
      'title': title,
      'description': description,
      'coinReward': coinReward,
      'type': type.name,
      'status': status.name,
      'iconUrl': iconUrl,
      'resetTime': resetTime?.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'claimedAt': claimedAt?.toIso8601String(),
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory Quest.fromJson(Map<String, dynamic> json) {
    return Quest(
      id: json['_id'] ?? json['id'] ?? '',
      questId: json['questId'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      coinReward: json['coinReward'] ?? 0,
      type: _parseQuestType(json['type']),
      status: _parseQuestStatus(json['status']),
      iconUrl: json['iconUrl'],
      resetTime:
          json['resetTime'] != null ? DateTime.parse(json['resetTime']) : null,
      completedAt:
          json['completedAt'] != null
              ? DateTime.parse(json['completedAt'])
              : null,
      claimedAt:
          json['claimedAt'] != null ? DateTime.parse(json['claimedAt']) : null,
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt:
          json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  static QuestType _parseQuestType(dynamic type) {
    if (type == null) return QuestType.daily;

    final typeStr = type.toString().toLowerCase();

    switch (typeStr) {
      case 'daily':
        return QuestType.daily;
      case 'weekly':
        return QuestType.weekly;
      case 'onetime':
      case 'one_time':
        return QuestType.oneTime;
      default:
        return QuestType.daily;
    }
  }

  static QuestStatus _parseQuestStatus(dynamic status) {
    if (status == null) return QuestStatus.incomplete;

    final statusStr = status.toString().toLowerCase();

    switch (statusStr) {
      case 'incomplete':
        return QuestStatus.incomplete;
      case 'complete':
        return QuestStatus.complete;
      case 'claimed':
        return QuestStatus.claimed;
      default:
        return QuestStatus.incomplete;
    }
  }

  bool get canClaim => status == QuestStatus.complete;
  bool get isClaimed => status == QuestStatus.claimed;
  bool get isIncomplete => status == QuestStatus.incomplete;

  @override
  List<Object?> get props => [
    id,
    questId,
    title,
    description,
    coinReward,
    type,
    status,
    iconUrl,
    resetTime,
    completedAt,
    claimedAt,
    createdAt,
    updatedAt,
  ];
}
