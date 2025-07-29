import 'dart:async';
import 'package:brainbee/core/utils/quest_extensions.dart';

import '../models/quest.dart';

import 'api_service.dart';

class QuestResetService {
  static final QuestResetService _instance = QuestResetService._internal();
  factory QuestResetService() => _instance;
  QuestResetService._internal();

  final ApiService _apiService = ApiService();
  Timer? _resetTimer;

  void startResetTimer(String userId, Function(List<Quest>) onQuestsReset) {
    _resetTimer?.cancel();

    // Check for resets every hour
    _resetTimer = Timer.periodic(Duration(hours: 1), (timer) async {
      await _checkAndResetQuests(userId, onQuestsReset);
    });
  }

  void stopResetTimer() {
    _resetTimer?.cancel();
    _resetTimer = null;
  }

  Future<void> _checkAndResetQuests(
    String userId,
    Function(List<Quest>) onQuestsReset,
  ) async {
    try {
      final quests = await _apiService.getQuests(userId);
      final questsToReset = quests.where((quest) => quest.shouldReset).toList();

      if (questsToReset.isNotEmpty) {
        final resetQuests = <Quest>[];
        for (final quest in questsToReset) {
          final resetQuest = quest.copyWith(
            status: QuestStatus.incomplete,
            claimedAt: null,
            completedAt: null,
            resetTime: _calculateNextReset(quest.type),
          );
          resetQuests.add(resetQuest);

          // Update quest status in backend
          await _apiService.updateQuestStatus(
            userId,
            quest.id,
            QuestStatus.incomplete,
          );
        }

        onQuestsReset(resetQuests);
      }
    } catch (e) {
      print('Error checking quest resets: $e');
    }
  }

  DateTime _calculateNextReset(QuestType type) {
    final now = DateTime.now();
    switch (type) {
      case QuestType.daily:
        return DateTime(now.year, now.month, now.day + 1);
      case QuestType.weekly:
        final daysUntilMonday = (DateTime.monday - now.weekday) % 7;
        return DateTime(now.year, now.month, now.day + daysUntilMonday + 7);
      case QuestType.oneTime:
        return now; // One-time quests don't reset
    }
  }
}
