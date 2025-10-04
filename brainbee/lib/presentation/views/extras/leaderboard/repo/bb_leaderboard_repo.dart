import 'package:brainbee/presentation/views/extras/leaderboard/models/bb_leaderboard_model.dart';

abstract class LeaderboardRepository {
  Future<LeaderboardData> getLeaderboard(String type);
}
