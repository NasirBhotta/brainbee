import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/quest_model.dart';
import '../models/wallet_model.dart';

class QuestRepository {
  static const String _questsKey = 'coin_quests';
  static const String _walletKey = 'student_wallet';
  static const String _lastResetCheckKey = 'last_reset_check';

  static QuestRepository? _instance;
  static QuestRepository get instance => _instance ??= QuestRepository._();
  QuestRepository._();

  // Get all quests
  Future<List<Quest>> getQuests() async {
    final prefs = await SharedPreferences.getInstance();
    await _checkAndResetQuests(); // Check for resets before returning quests
    
    final questsJson = prefs.getStringList(_questsKey);
    if (questsJson == null) {
      // Initialize with sample quests if none exist
      final sampleQuests = _getSampleQuests();
      await _saveQuests(sampleQuests);
      return sampleQuests;
    }

    return questsJson
        .map((json) => Quest.fromJson(jsonDecode(json)))
        .toList();
  }

  // Save quests to local storage
  Future<void> _saveQuests(List<Quest> quests) async {
    final prefs = await SharedPreferences.getInstance();
    final questsJson = quests
        .map((quest) => jsonEncode(quest.toJson()))
        .toList();
    await prefs.setStringList(_questsKey, questsJson);
  }

  // Update a specific quest
  Future<void> updateQuest(Quest updatedQuest) async {
    final quests = await getQuests();
    final index = quests.indexWhere((quest) => quest.id == updatedQuest.id);
    if (index != -1) {
      quests[index] = updatedQuest;
      await _saveQuests(quests);
    }
  }

  // Mark quest as complete
  Future<Quest> markQuestComplete(String questId) async {
    final quests = await getQuests();
    final questIndex = quests.indexWhere((quest) => quest.id == questId);
    
    if (questIndex == -1) {
      throw Exception('Quest not found');
    }

    final updatedQuest = quests[questIndex].copyWith(
      status: QuestStatus.complete,
      completedAt: DateTime.now(),
    );

    quests[questIndex] = updatedQuest;
    await _saveQuests(quests);
    
    return updatedQuest;
  }

  // Claim quest rewards
  Future<Quest> claimQuest(String questId) async {
    final quests = await getQuests();
    final questIndex = quests.indexWhere((quest) => quest.id == questId);
    
    if (questIndex == -1) {
      throw Exception('Quest not found');
    }

    final quest = quests[questIndex];
    
    if (quest.status != QuestStatus.complete) {
      throw Exception('Quest is not ready to be claimed');
    }

    if (quest.status == QuestStatus.claimed) {
      throw Exception('Quest has already been claimed');
    }

    // Update quest status
    final updatedQuest = quest.copyWith(
      status: QuestStatus.claimed,
      claimedAt: DateTime.now(),
    );

    quests[questIndex] = updatedQuest;
    await _saveQuests(quests);

    // Update wallet
    await addCoinsToWallet(quest.coinReward);

    return updatedQuest;
  }

  // Get student wallet
  Future<Wallet> getWallet({String studentId = 'default_student'}) async {
    final prefs = await SharedPreferences.getInstance();
    final walletJson = prefs.getString(_walletKey);
    
    if (walletJson == null) {
      final wallet = Wallet.empty(studentId);
      await _saveWallet(wallet);
      return wallet;
    }

    return Wallet.fromJson(jsonDecode(walletJson));
  }

  // Save wallet to local storage
  Future<void> _saveWallet(Wallet wallet) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_walletKey, jsonEncode(wallet.toJson()));
  }

  // Add coins to wallet
  Future<Wallet> addCoinsToWallet(int coins) async {
    final wallet = await getWallet();
    final updatedWallet = wallet.addCoins(coins);
    await _saveWallet(updatedWallet);
    return updatedWallet;
  }

  // Spend coins from wallet
  Future<Wallet> spendCoinsFromWallet(int coins) async {
    final wallet = await getWallet();
    final updatedWallet = wallet.spendCoins(coins);
    await _saveWallet(updatedWallet);
    return updatedWallet;
  }

  // Check and reset quests based on their type and reset schedule
  Future<void> _checkAndResetQuests() async {
    final prefs = await SharedPreferences.getInstance();
    final lastCheck = prefs.getInt(_lastResetCheckKey) ?? 0;
    final now = DateTime.now().millisecondsSinceEpoch;
    
    // Check every hour for resets
    if (now - lastCheck < 3600000) return;

    final quests = await _getQuestsWithoutReset();
    bool hasChanges = false;

    for (int i = 0; i < quests.length; i++) {
      final quest = quests[i];
      
      if (quest.shouldReset) {
        quests[i] = quest.copyWith(
          status: QuestStatus.incomplete,
          completedAt: null,
          claimedAt: null,
          lastResetAt: DateTime.now(),
        );
        hasChanges = true;
      }
    }

    if (hasChanges) {
      await _saveQuests(quests);
    }

    await prefs.setInt(_lastResetCheckKey, now);
  }

  // Get quests without triggering reset check (internal use)
  Future<List<Quest>> _getQuestsWithoutReset() async {
    final prefs = await SharedPreferences.getInstance();
    final questsJson = prefs.getStringList(_questsKey);
    
    if (questsJson == null) {
      final sampleQuests = _getSampleQuests();
      await _saveQuests(sampleQuests);
      return sampleQuests;
    }

    return questsJson
        .map((json) => Quest.fromJson(jsonDecode(json)))
        .toList();
  }

  // Generate sample quests for initial setup
  List<Quest> _getSampleQuests() {
    final now = DateTime.now();
    return [
      // Daily Quests
      Quest(
        id: 'daily_login',
        title: 'Daily Login',
        description: 'Log in to the app today',
        coinReward: 10,
        type: QuestType.daily,
        status: QuestStatus.incomplete,
        iconPath: 'assets/fire.png',
        createdAt: now,
        lastResetAt: now,
      ),
      Quest(
        id: 'daily_lesson',
        title: 'Complete a Lesson',
        description: 'Complete any lesson today',
        coinReward: 25,
        type: QuestType.daily,
        status: QuestStatus.incomplete,
        iconPath: 'assets/trophy.png',
        createdAt: now,
        lastResetAt: now,
      ),
      Quest(
        id: 'daily_quiz',
        title: 'Take a Quiz',
        description: 'Take and complete a quiz',
        coinReward: 20,
        type: QuestType.daily,
        status: QuestStatus.incomplete,
        iconPath: 'assets/compass.png',
        createdAt: now,
        lastResetAt: now,
      ),
      
      // Weekly Quests
      Quest(
        id: 'weekly_streak',
        title: 'Weekly Learning Streak',
        description: 'Complete lessons for 5 days this week',
        coinReward: 100,
        type: QuestType.weekly,
        status: QuestStatus.incomplete,
        iconPath: 'assets/fire.png',
        createdAt: now,
        lastResetAt: now,
      ),
      Quest(
        id: 'weekly_subjects',
        title: 'Multi-Subject Mastery',
        description: 'Complete lessons in 3 different subjects',
        coinReward: 75,
        type: QuestType.weekly,
        status: QuestStatus.incomplete,
        iconPath: 'assets/trophy.png',
        createdAt: now,
        lastResetAt: now,
      ),
      
      // One-time Quests
      Quest(
        id: 'first_lesson',
        title: 'First Lesson Completed',
        description: 'Complete your very first lesson',
        coinReward: 50,
        type: QuestType.oneTime,
        status: QuestStatus.incomplete,
        iconPath: 'assets/trophy.png',
        createdAt: now,
      ),
      Quest(
        id: 'profile_setup',
        title: 'Profile Setup',
        description: 'Complete your profile setup',
        coinReward: 30,
        type: QuestType.oneTime,
        status: QuestStatus.incomplete,
        iconPath: 'assets/heart.png',
        createdAt: now,
      ),
      Quest(
        id: 'first_perfect_score',
        title: 'Perfect Score Achievement',
        description: 'Get 100% on any quiz',
        coinReward: 80,
        type: QuestType.oneTime,
        status: QuestStatus.incomplete,
        iconPath: 'assets/trophy.png',
        createdAt: now,
      ),
    ];
  }

  // Force refresh quests (useful for testing)
  Future<void> refreshQuests() async {
    await _checkAndResetQuests();
  }

  // Clear all data (for testing purposes)
  Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_questsKey);
    await prefs.remove(_walletKey);
    await prefs.remove(_lastResetCheckKey);
  }
}