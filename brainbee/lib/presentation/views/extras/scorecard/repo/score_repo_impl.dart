// lib/presentation/views/extras/scorecard/repository/score_repository_impl.dart

import 'dart:convert';

import 'package:brainbee/presentation/views/extras/scorecard/model/bb_book_score.model.dart';
import 'package:brainbee/presentation/views/extras/scorecard/repo/score_repo.dart';
import 'package:brainbee/presentation/views/extras/scorecard/services/score_api_service.dart';

class ScoreRepositoryImpl implements ScoreRepository {
  final ScoreApiService apiService;

  ScoreRepositoryImpl({required this.apiService});

  @override
  Future<OverallScoreData> getOverallScore() async {
    try {
      final response = await apiService.getOverallScore();
      final Map<String, dynamic> jsonData = jsonDecode(response.body);
      final scoreResponse = OverallScoreResponse.fromJson(jsonData);
      return scoreResponse.data;
    } on ScoreApiException catch (e) {
      throw Exception('Failed to load overall score: ${e.message}');
    } catch (e) {
      throw Exception('Failed to load overall score: $e');
    }
  }

  @override
  Future<dynamic> getBookScore(String bookId) async {
    try {
      final response = await apiService.getBookScore(bookId);
      final Map<String, dynamic> jsonData = jsonDecode(response.body);
      // Return the data portion - you'll need to create BookScore model later
      return jsonData['data'];
    } on ScoreApiException catch (e) {
      throw Exception('Failed to load book score: ${e.message}');
    } catch (e) {
      throw Exception('Failed to load book score: $e');
    }
  }
}
