// lib/presentation/views/extras/leaderboard/repo/leaderboard_repository_impl.dart

import 'dart:convert';

import 'package:brainbee/presentation/views/extras/leaderboard/models/bb_leaderboard_model.dart';
import 'package:brainbee/presentation/views/extras/leaderboard/repo/bb_leaderboard_repo.dart';
import 'package:brainbee/presentation/views/extras/leaderboard/services/bb_leaderboard_api_service.dart';

class LeaderboardRepositoryImpl implements LeaderboardRepository {
  final LeaderboardApiService apiService;

  LeaderboardRepositoryImpl({required this.apiService});

  @override
  Future<LeaderboardData> getLeaderboard(String type) async {
    try {
      final response = await apiService.getLeaderboard(type);
      final Map<String, dynamic> jsonData = jsonDecode(response.body);
      final leaderboardResponse = LeaderboardResponse.fromJson(jsonData);
      return leaderboardResponse.data;
    } on LeaderboardApiException catch (e) {
      throw Exception('Failed to load leaderboard: ${e.message}');
    } catch (e) {
      throw Exception('Failed to load leaderboard: $e');
    }
  }
}
