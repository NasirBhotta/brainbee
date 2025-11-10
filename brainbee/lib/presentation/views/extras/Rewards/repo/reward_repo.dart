import 'package:brainbee/presentation/views/extras/Rewards/models/reward.dart';
import 'package:brainbee/presentation/views/extras/Rewards/services/api_services.dart';

class RewardRepository {
  final RewardApiService _apiService = RewardApiService();

  /// Fetch all available rewards from backend
  Future<List<RewardModel>> fetchRewards() async {
    try {
      final response = await _apiService.getRequest(endpoint: '/rewards');

      if (response['status'] == 'success') {
        final List<dynamic> rewardsJson = response['data']['rewards'];
        return rewardsJson
            .map((json) => RewardModel.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception(response['message'] ?? 'Failed to load rewards');
      }
    } catch (e) {
      print('Error fetching rewards: $e');
      rethrow;
    }
  }

  /// Get user's current coin balance
  Future<int> getUserCoins() async {
    try {
      final response = await _apiService.getRequest(endpoint: '/rewards/coins');

      if (response['status'] == 'success') {
        return response['data']['coins'] ?? 0;
      } else {
        throw Exception(response['message'] ?? 'Failed to get coins');
      }
    } catch (e) {
      print('Error getting user coins: $e');
      rethrow;
    }
  }

  /// Redeem a reward
  Future<Map<String, dynamic>> redeemReward({
    required String rewardId,
    String? userInput,
  }) async {
    try {
      final response = await _apiService.postRequest(
        endpoint: '/rewards/redeem',
        body: {
          'rewardId': rewardId,
          if (userInput != null) 'userInput': userInput,
        },
      );

      if (response['status'] == 'success') {
        return {
          'message':
              response['data']['message'] ?? 'Reward redeemed successfully!',
          'remainingCoins': response['data']['remainingCoins'] ?? 0,
          'redemptionDetails': response['data']['redemptionDetails'],
        };
      } else {
        throw Exception(response['message'] ?? 'Failed to redeem reward');
      }
    } catch (e) {
      print('Error redeeming reward: $e');
      rethrow;
    }
  }

  /// Get user's redemption history
  Future<List<RewardModel>> getRedemptionHistory() async {
    try {
      final response = await _apiService.getRequest(
        endpoint: '/rewards/history',
      );

      if (response['status'] == 'success') {
        final List<dynamic> historyJson = response['data']['history'];
        return historyJson
            .map((json) => RewardModel.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception(response['message'] ?? 'Failed to load history');
      }
    } catch (e) {
      print('Error fetching history: $e');
      rethrow;
    }
  }
}
