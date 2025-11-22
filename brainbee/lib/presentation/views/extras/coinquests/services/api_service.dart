import 'dart:convert';
import 'package:brainbee/config/api_config.dart';
import 'package:brainbee/core/utils/helper/bb_token.dart';
import 'package:http/http.dart' as http;
import '../models/quest.dart';

class ApiService {
  static const String baseUrl = BBApiConfig.baseUrl;

  /// Get authentication token
  Future<String> token() async {
    final tokenUserData = await getTokenAndUser();
    return tokenUserData.token ?? '';
  }

  /// Get headers with authorization token
  Future<Map<String, String>> _getHeaders() async {
    final authToken = await token();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $authToken',
    };
  }

  /// Get all quests for authenticated user
  Future<List<Quest>> getQuests(String userId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/api/student/quests'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final List<dynamic> data = responseData['data'] ?? responseData;
        return data.map((json) => Quest.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load quests: ${response.statusCode}');
      }
    } catch (e) {
      print('Error loading quests: $e');
      throw Exception('Failed to load quests: $e');
    }
  }

  /// Claim quest reward
  /// This updates both quest status AND student coins on backend
  /// @param questId - The questId field (e.g., "daily_complete_5_lessons")
  Future<Map<String, dynamic>> claimQuest(String userId, String questId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/api/student/quests/claim'),
        headers: headers,
        body: json.encode({'questId': questId}),
      );

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        // Backend returns: { status, message, data: { success, coinsAdded, newBalance, quest } }
        if (result['data'] != null) {
          return result['data'];
        }
        return result;
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to claim quest');
      }
    } catch (e) {
      print('Error claiming quest: $e');
      throw Exception('Failed to claim quest: $e');
    }
  }

  /// Update quest completion status
  Future<bool> updateQuestStatus(
    String userId,
    String questId,
    QuestStatus status,
  ) async {
    try {
      final headers = await _getHeaders();
      final response = await http.put(
        Uri.parse('$baseUrl/api/quests/$questId/status'),
        headers: headers,
        body: json.encode({'status': status.name}),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        print('Failed to update quest status: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Error updating quest status: $e');
      return false;
    }
  }

  /// Check for quest completion updates (polling)
  Future<List<Quest>> checkQuestUpdates(
    String userId,
    DateTime lastCheck,
  ) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse(
          '$baseUrl/api/quests/updates?since=${lastCheck.toIso8601String()}',
        ),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final List<dynamic> data = responseData['data'] ?? responseData;
        return data.map((json) => Quest.fromJson(json)).toList();
      } else {
        print('Failed to check quest updates: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error checking quest updates: $e');
      return [];
    }
  }

  /// Get quest statistics
  Future<Map<String, dynamic>?> getQuestStats(String userId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/api/quests/stats'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return responseData['data']?['stats'];
      } else {
        print('Failed to get quest stats: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error getting quest stats: $e');
      return null;
    }
  }

  /// Manually reset expired quests
  Future<bool> resetExpiredQuests(String userId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/api/quests/reset'),
        headers: headers,
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error resetting quests: $e');
      return false;
    }
  }
}
