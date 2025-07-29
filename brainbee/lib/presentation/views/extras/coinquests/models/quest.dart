import 'package:equatable/equatable.dart';

enum QuestType { daily, weekly, oneTime }

enum QuestStatus { incomplete, complete, claimed }

class Quest extends Equatable {
  final String id;
  final String title;
  final String description;
  final int coinReward;
  final QuestType type;
  final QuestStatus status;
  final String? iconUrl;
  final DateTime? resetTime;
  final DateTime? completedAt;
  final DateTime? claimedAt;

  const Quest({
    required this.id,
    required this.title,
    required this.description,
    required this.coinReward,
    required this.type,
    required this.status,
    this.iconUrl,
    this.resetTime,
    this.completedAt,
    this.claimedAt,
  });

  Quest copyWith({
    String? id,
    String? title,
    String? description,
    int? coinReward,
    QuestType? type,
    QuestStatus? status,
    String? iconUrl,
    DateTime? resetTime,
    DateTime? completedAt,
    DateTime? claimedAt,
  }) {
    return Quest(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      coinReward: coinReward ?? this.coinReward,
      type: type ?? this.type,
      status: status ?? this.status,
      iconUrl: iconUrl ?? this.iconUrl,
      resetTime: resetTime ?? this.resetTime,
      completedAt: completedAt ?? this.completedAt,
      claimedAt: claimedAt ?? this.claimedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'coinReward': coinReward,
      'type': type.name,
      'status': status.name,
      'iconUrl': iconUrl,
      'resetTime': resetTime?.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'claimedAt': claimedAt?.toIso8601String(),
    };
  }

  factory Quest.fromJson(Map<String, dynamic> json) {
    return Quest(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      coinReward: json['coinReward'],
      type: QuestType.values.firstWhere((e) => e.name == json['type']),
      status: QuestStatus.values.firstWhere((e) => e.name == json['status']),
      iconUrl: json['iconUrl'],
      resetTime:
          json['resetTime'] != null ? DateTime.parse(json['resetTime']) : null,
      completedAt:
          json['completedAt'] != null
              ? DateTime.parse(json['completedAt'])
              : null,
      claimedAt:
          json['claimedAt'] != null ? DateTime.parse(json['claimedAt']) : null,
    );
  }

  bool get canClaim => status == QuestStatus.complete;
  bool get isClaimed => status == QuestStatus.claimed;
  bool get isIncomplete => status == QuestStatus.incomplete;

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    coinReward,
    type,
    status,
    iconUrl,
    resetTime,
    completedAt,
    claimedAt,
  ];
}
