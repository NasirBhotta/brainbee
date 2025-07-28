import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'quest_model.g.dart';

enum QuestType {
  @JsonValue('daily')
  daily,
  @JsonValue('weekly')
  weekly,
  @JsonValue('one_time')
  oneTime,
}

enum QuestStatus {
  @JsonValue('incomplete')
  incomplete,
  @JsonValue('complete')
  complete,
  @JsonValue('claimed')
  claimed,
}

@JsonSerializable()
class Quest extends Equatable {
  final String id;
  final String title;
  final String description;
  final int coinReward;
  final QuestType type;
  final QuestStatus status;
  final String iconPath;
  final DateTime createdAt;
  final DateTime? completedAt;
  final DateTime? claimedAt;
  final DateTime? lastResetAt;

  const Quest({
    required this.id,
    required this.title,
    required this.description,
    required this.coinReward,
    required this.type,
    required this.status,
    required this.iconPath,
    required this.createdAt,
    this.completedAt,
    this.claimedAt,
    this.lastResetAt,
  });

  factory Quest.fromJson(Map<String, dynamic> json) => _$QuestFromJson(json);
  Map<String, dynamic> toJson() => _$QuestToJson(this);

  Quest copyWith({
    String? id,
    String? title,
    String? description,
    int? coinReward,
    QuestType? type,
    QuestStatus? status,
    String? iconPath,
    DateTime? createdAt,
    DateTime? completedAt,
    DateTime? claimedAt,
    DateTime? lastResetAt,
  }) {
    return Quest(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      coinReward: coinReward ?? this.coinReward,
      type: type ?? this.type,
      status: status ?? this.status,
      iconPath: iconPath ?? this.iconPath,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      claimedAt: claimedAt ?? this.claimedAt,
      lastResetAt: lastResetAt ?? this.lastResetAt,
    );
  }

  bool get isClaimable => status == QuestStatus.complete;
  
  bool get isClaimed => status == QuestStatus.claimed;
  
  bool get isIncomplete => status == QuestStatus.incomplete;

  bool get shouldReset {
    if (type == QuestType.oneTime) return false;
    if (lastResetAt == null) return false;
    
    final now = DateTime.now();
    switch (type) {
      case QuestType.daily:
        return now.difference(lastResetAt!).inDays >= 1;
      case QuestType.weekly:
        return now.difference(lastResetAt!).inDays >= 7;
      case QuestType.oneTime:
        return false;
    }
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        coinReward,
        type,
        status,
        iconPath,
        createdAt,
        completedAt,
        claimedAt,
        lastResetAt,
      ];
}