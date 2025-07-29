import 'dart:convert';
import 'package:brainbee/core/models/wallet.dart';
import 'package:http/http.dart' as http;
import '../models/quest.dart';

class ApiService {
  static const String baseUrl = 'https://your-backend-url.com/api';

  // Get all quests for a user
  Future<List<Quest>> getQuests(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/quests/$userId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Quest.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load quests');
      }
    } catch (e) {
      // For demo purposes, return dummy data
      return _getDummyQuests();
    }
  }

  // Get user wallet
  Future<Wallet> getWallet(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/wallet/$userId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return Wallet.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to load wallet');
      }
    } catch (e) {
      // For demo purposes, return dummy wallet
      return Wallet(userId: userId, balance: 150, lastUpdated: DateTime.now());
    }
  }

  // Claim quest reward
  Future<Map<String, dynamic>> claimQuest(String userId, String questId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/quests/claim'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'userId': userId, 'questId': questId}),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to claim quest');
      }
    } catch (e) {
      // For demo purposes, simulate successful claim
      await Future.delayed(Duration(milliseconds: 500));
      return {'success': true, 'coinsAdded': 50, 'newBalance': 200};
    }
  }

  // Update quest completion status
  Future<bool> updateQuestStatus(
    String userId,
    String questId,
    QuestStatus status,
  ) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/quests/$questId/status'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'userId': userId, 'status': status.name}),
      );

      return response.statusCode == 200;
    } catch (e) {
      // For demo purposes, return true
      await Future.delayed(Duration(milliseconds: 300));
      return true;
    }
  }

  // Check for quest completion updates (polling)
  Future<List<Quest>> checkQuestUpdates(
    String userId,
    DateTime lastCheck,
  ) async {
    try {
      final response = await http.get(
        Uri.parse(
          '$baseUrl/quests/$userId/updates?since=${lastCheck.toIso8601String()}',
        ),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Quest.fromJson(json)).toList();
      } else {
        return [];
      }
    } catch (e) {
      // For demo purposes, randomly mark a quest as complete
      final quests = await getQuests(userId);
      final incompleteQuests =
          quests.where((q) => q.status == QuestStatus.incomplete).toList();
      if (incompleteQuests.isNotEmpty && DateTime.now().second % 10 == 0) {
        final randomQuest = incompleteQuests.first;
        return [
          randomQuest.copyWith(
            status: QuestStatus.complete,
            completedAt: DateTime.now(),
          ),
        ];
      }
      return [];
    }
  }

  List<Quest> _getDummyQuests() {
    return [
      Quest(
        id: '1',
        title: 'Complete 5 Lessons',
        description: 'Finish 5 lessons in any subject',
        coinReward: 50,
        type: QuestType.daily,
        status: QuestStatus.complete,
        iconUrl: '📚',
        completedAt: DateTime.now().subtract(Duration(minutes: 5)),
      ),
      Quest(
        id: '2',
        title: 'Study for 30 Minutes',
        description: 'Spend at least 30 minutes studying',
        coinReward: 25,
        type: QuestType.daily,
        status: QuestStatus.incomplete,
        iconUrl: '⏰',
      ),
      Quest(
        id: '3',
        title: 'Weekly Quiz Champion',
        description: 'Score 90% or higher on weekly quiz',
        coinReward: 100,
        type: QuestType.weekly,
        status: QuestStatus.complete,
        iconUrl: '🏆',
        completedAt: DateTime.now().subtract(Duration(hours: 2)),
      ),
      Quest(
        id: '4',
        title: 'First Login Bonus',
        description: 'Welcome bonus for new users',
        coinReward: 200,
        type: QuestType.oneTime,
        status: QuestStatus.claimed,
        iconUrl: '🎁',
        claimedAt: DateTime.now().subtract(Duration(days: 1)),
      ),
    ];
  }
}
