// lib/presentation/views/extras/achievements/badges/repo/badge_repository_impl.dart

import 'dart:convert';

import 'package:brainbee/presentation/views/extras/achievements/badges/models/badge_model.dart';
import 'package:brainbee/presentation/views/extras/achievements/badges/services/badge_api_services.dart';
import 'package:brainbee/repositories/badge_repository.dart';

class BadgeRepositoryImpl implements BadgeRepository {
  final BadgeApiService apiService;

  BadgeRepositoryImpl({required this.apiService});

  @override
  Future<List<BbBadge>> getAllBadgesForStudent(String studentId) async {
    try {
      final response = await apiService.getAllBadgesForStudent(studentId);
      final Map<String, dynamic> jsonData = jsonDecode(response.body);

      if (jsonData['status'] == 'success' && jsonData['data'] != null) {
        final List<dynamic> badgesJson = jsonData['data'];
        return badgesJson.map((json) => BbBadge.fromJson(json)).toList();
      } else {
        throw Exception('Invalid response format');
      }
    } on BadgeApiException catch (e) {
      throw Exception('Failed to load badges: ${e.message}');
    } catch (e) {
      throw Exception('Failed to load badges: $e');
    }
  }

  @override
  Future<List<BbBadge>> refreshBadges(String studentId) async {
    try {
      final response = await apiService.refreshBadges(studentId);
      final Map<String, dynamic> jsonData = jsonDecode(response.body);

      if (jsonData['status'] == 'success' && jsonData['data'] != null) {
        final List<dynamic> badgesJson = jsonData['data'];
        return badgesJson.map((json) => BbBadge.fromJson(json)).toList();
      } else {
        throw Exception('Invalid response format');
      }
    } on BadgeApiException catch (e) {
      throw Exception('Failed to refresh badges: ${e.message}');
    } catch (e) {
      throw Exception('Failed to refresh badges: $e');
    }
  }
}
