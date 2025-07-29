// lib/services/badge_api_service.dart
import 'dart:async';
import 'dart:math';
import 'package:brainbee/presentation/views/extras/badges/models/badge_response.dart';
import 'package:http/http.dart' as http;
import '../models/badge_model.dart';

abstract class BadgeApiService {
  Future<BadgeResponse> getBadges(String studentId);
}

class BadgeApiServiceImpl implements BadgeApiService {
  final http.Client _client;
  final String _baseUrl;

  BadgeApiServiceImpl({http.Client? client, String? baseUrl})
    : _client = client ?? http.Client(),
      _baseUrl = baseUrl ?? 'https://api.yourapp.com/v1';

  @override
  Future<BadgeResponse> getBadges(String studentId) async {
    try {
      // For now, using dummy data. Replace with actual API call later
      return await _getDummyBadges(studentId);

      // Actual API implementation (uncomment when ready):
      /*
      final response = await _client.get(
        Uri.parse('$_baseUrl/students/$studentId/badges'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await _getAuthToken()}',
        },
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body) as Map<String, dynamic>;
        return BadgeResponse.fromJson(jsonData);
      } else if (response.statusCode == 404) {
        return const BadgeResponse(
          badges: [],
          success: true,
          message: 'No badges found for this student',
        );
      } else {
        throw BadgeApiException(
          'Failed to load badges: ${response.statusCode}',
          response.statusCode,
        );
      }
      */
    } on TimeoutException {
      throw const BadgeApiException(
        'Request timeout. Please check your internet connection.',
        408,
      );
    } on http.ClientException {
      throw const BadgeApiException(
        'Could not load badges. Please check your internet connection and try again.',
        -1,
      );
    } catch (e) {
      if (e is BadgeApiException) rethrow;
      throw BadgeApiException(
        'An unexpected error occurred: ${e.toString()}',
        -1,
      );
    }
  }

  // Dummy data method - remove when connecting to actual backend
  Future<BadgeResponse> _getDummyBadges(String studentId) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));

    // Simulate random failures for testing
    final random = Random();
    if (random.nextInt(10) == 0) {
      throw const BadgeApiException(
        'Could not load badges. Please check your internet connection and try again.',
        500,
      );
    }

    final dummyBadges = [
      BbBadge(
        id: '1',
        name: 'Score 10',
        description: 'Score 10 points in a single game',
        iconUrl: 'https://example.com/score10.png',
        iconAsset: 'assets/badges/score_10.png',
        category: BbBadgeCategory.score,
        status: BbBadgeStatus.earned,
        earnedDate: DateTime.now().subtract(const Duration(days: 5)),
        earningCriteria: 'Score 10 or more points in any single game session',
        requiredValue: 10,
      ),
      BbBadge(
        id: '2',
        name: 'Score 50',
        description: 'Score 50 points in a single game',
        iconUrl: 'https://example.com/score50.png',
        iconAsset: 'assets/badges/score_50.png',
        category: BbBadgeCategory.score,
        status: BbBadgeStatus.earned,
        earnedDate: DateTime.now().subtract(const Duration(days: 2)),
        earningCriteria: 'Score 50 or more points in any single game session',
        requiredValue: 50,
      ),
      BbBadge(
        id: '3',
        name: 'Score 100',
        description: 'Score 100 points in a single game',
        iconUrl: 'https://example.com/score100.png',
        iconAsset: 'assets/badges/score_100.png',
        category: BbBadgeCategory.score,
        status: BbBadgeStatus.unearned,
        earningCriteria: 'Score 100 or more points in any single game session',
        requiredValue: 100,
      ),
      BbBadge(
        id: '4',
        name: '3-Day Streak',
        description: 'Play for 3 consecutive days',
        iconUrl: 'https://example.com/streak3.png',
        iconAsset: 'assets/badges/streak_3.png',
        category: BbBadgeCategory.streak,
        status: BbBadgeStatus.earned,
        earnedDate: DateTime.now().subtract(const Duration(days: 1)),
        earningCriteria: 'Play the game for 3 consecutive days',
        requiredValue: 3,
      ),
      BbBadge(
        id: '5',
        name: '7-Day Streak',
        description: 'Play for 7 consecutive days',
        iconUrl: 'https://example.com/streak7.png',
        iconAsset: 'assets/badges/streak_7.png',
        category: BbBadgeCategory.streak,
        status: BbBadgeStatus.unearned,
        earningCriteria: 'Play the game for 7 consecutive days',
        requiredValue: 7,
      ),
      BbBadge(
        id: '6',
        name: 'First Victory',
        description: 'Win your first game',
        iconUrl: 'https://example.com/first_victory.png',
        iconAsset: 'assets/badges/first_victory.png',
        category: BbBadgeCategory.achievement,
        status: BbBadgeStatus.earned,
        earnedDate: DateTime.now().subtract(const Duration(days: 10)),
        earningCriteria: 'Complete and win your first game',
      ),
      BbBadge(
        id: '7',
        name: 'Perfect Score',
        description: 'Get a perfect score in any game',
        iconUrl: 'https://example.com/perfect_score.png',
        iconAsset: 'assets/badges/perfect_score.png',
        category: BbBadgeCategory.achievement,
        status: BbBadgeStatus.unearned,
        earningCriteria: 'Achieve a perfect score (100%) in any game mode',
      ),
      BbBadge(
        id: '8',
        name: '100 Games Played',
        description: 'Play 100 games total',
        iconUrl: 'https://example.com/games_100.png',
        iconAsset: 'assets/badges/games_100.png',
        category: BbBadgeCategory.milestone,
        status: BbBadgeStatus.unearned,
        earningCriteria: 'Complete a total of 100 games',
        requiredValue: 100,
      ),
    ];

    return BadgeResponse(
      badges: dummyBadges,
      success: true,
      message: 'Badges loaded successfully',
    );
  }

  Future<String> _getAuthToken() async {
    // Implement your auth token retrieval logic here
    // This could be from SharedPreferences, secure storage, etc.
    return 'your_auth_token_here';
  }

  void dispose() {
    _client.close();
  }
}

// Custom exception for API errors
class BadgeApiException implements Exception {
  final String message;
  final int statusCode;

  const BadgeApiException(this.message, this.statusCode);

  @override
  String toString() => 'BadgeApiException: $message (Status: $statusCode)';
}
