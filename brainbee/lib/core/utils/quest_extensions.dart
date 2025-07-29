import 'package:brainbee/presentation/views/extras/coinquests/models/quest.dart';

extension QuestTypeExtensions on QuestType {
  String get displayName {
    switch (this) {
      case QuestType.daily:
        return 'Daily';
      case QuestType.weekly:
        return 'Weekly';
      case QuestType.oneTime:
        return 'One-Time';
    }
  }

  Duration get resetDuration {
    switch (this) {
      case QuestType.daily:
        return Duration(days: 1);
      case QuestType.weekly:
        return Duration(days: 7);
      case QuestType.oneTime:
        return Duration.zero;
    }
  }
}

extension QuestValidation on Quest {
  bool get isExpired {
    if (type == QuestType.oneTime) return false;
    if (resetTime == null) return false;
    return DateTime.now().isAfter(resetTime!);
  }

  bool get shouldReset {
    if (type == QuestType.oneTime) return false;
    if (status != QuestStatus.claimed) return false;
    return isExpired;
  }
}
