import 'quest_repository.dart';
import 'notification_service.dart';

/// Helper class to integrate quest completion throughout the app
class QuestHelper {
  static QuestHelper? _instance;
  static QuestHelper get instance => _instance ??= QuestHelper._();
  QuestHelper._();

  final QuestRepository _questRepository = QuestRepository.instance;
  final NotificationService _notificationService = NotificationService.instance;

  /// Call this when a student logs in daily
  Future<void> onDailyLogin() async {
    try {
      await _triggerQuestCompletion('daily_login');
    } catch (e) {
      print('Error completing daily login quest: $e');
    }
  }

  /// Call this when a student completes any lesson
  Future<void> onLessonCompleted() async {
    try {
      await _triggerQuestCompletion('daily_lesson');
    } catch (e) {
      print('Error completing daily lesson quest: $e');
    }
  }

  /// Call this when a student takes a quiz
  Future<void> onQuizCompleted() async {
    try {
      await _triggerQuestCompletion('daily_quiz');
    } catch (e) {
      print('Error completing daily quiz quest: $e');
    }
  }

  /// Call this when a student completes their first lesson ever
  Future<void> onFirstLessonCompleted() async {
    try {
      await _triggerQuestCompletion('first_lesson');
    } catch (e) {
      print('Error completing first lesson quest: $e');
    }
  }

  /// Call this when a student completes their profile setup
  Future<void> onProfileSetupCompleted() async {
    try {
      await _triggerQuestCompletion('profile_setup');
    } catch (e) {
      print('Error completing profile setup quest: $e');
    }
  }

  /// Call this when a student gets a perfect score (100%) on any quiz
  Future<void> onPerfectScoreAchieved() async {
    try {
      await _triggerQuestCompletion('first_perfect_score');
    } catch (e) {
      print('Error completing perfect score quest: $e');
    }
  }

  /// Call this when a student maintains a learning streak (for weekly quests)
  Future<void> onLearningStreakMaintained(int daysCount) async {
    try {
      if (daysCount >= 5) {
        await _triggerQuestCompletion('weekly_streak');
      }
    } catch (e) {
      print('Error completing weekly streak quest: $e');
    }
  }

  /// Call this when a student completes lessons in multiple subjects
  Future<void> onMultiSubjectProgress(int subjectCount) async {
    try {
      if (subjectCount >= 3) {
        await _triggerQuestCompletion('weekly_subjects');
      }
    } catch (e) {
      print('Error completing weekly subjects quest: $e');
    }
  }

  /// Generic method to trigger quest completion by ID
  Future<void> triggerQuestCompletion(String questId) async {
    try {
      await _triggerQuestCompletion(questId);
    } catch (e) {
      print('Error completing quest $questId: $e');
    }
  }

  /// Internal method to handle quest completion logic
  Future<void> _triggerQuestCompletion(String questId) async {
    final quests = await _questRepository.getQuests();
    final quest = quests.firstWhere(
      (q) => q.id == questId,
      orElse: () => throw Exception('Quest not found: $questId'),
    );

    // Only complete if the quest is currently incomplete
    if (quest.isIncomplete) {
      final completedQuest = await _questRepository.markQuestComplete(questId);
      
      // Send notification that quest is ready to claim
      await _notificationService.showQuestCompleteNotification(completedQuest);
    }
  }

  /// Get current wallet balance
  Future<int> getWalletBalance() async {
    final wallet = await _questRepository.getWallet();
    return wallet.balance;
  }

  /// Check if student can afford to spend coins
  Future<bool> canAfford(int coinAmount) async {
    final wallet = await _questRepository.getWallet();
    return wallet.canSpend(coinAmount);
  }

  /// Spend coins from wallet (for in-app purchases, rewards redemption, etc.)
  Future<bool> spendCoins(int coinAmount) async {
    try {
      final wallet = await _questRepository.getWallet();
      if (!wallet.canSpend(coinAmount)) {
        return false;
      }
      
      await _questRepository.spendCoinsFromWallet(coinAmount);
      return true;
    } catch (e) {
      print('Error spending coins: $e');
      return false;
    }
  }

  /// Initialize notification service (call this in your main app initialization)
  Future<void> initializeNotifications() async {
    await _notificationService.initialize();
    await _notificationService.requestPermissions();
  }

  /// Check if notifications are enabled
  Future<bool> areNotificationsEnabled() async {
    return await _notificationService.areNotificationsEnabled();
  }

  /// Enable or disable notifications
  Future<void> setNotificationsEnabled(bool enabled) async {
    await _notificationService.setNotificationsEnabled(enabled);
    // Also update backend with preference
    await _notificationService.updateNotificationPreferences(enabled);
  }
}