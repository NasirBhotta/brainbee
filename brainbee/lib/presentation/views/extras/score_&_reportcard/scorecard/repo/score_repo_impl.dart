// lib/presentation/views/extras/scorecard/repository/score_repository_impl.dart

import 'dart:convert';

import 'package:brainbee/presentation/views/extras/score_&_reportcard/scorecard/model/bb_book_score.model.dart';
import 'package:brainbee/presentation/views/extras/score_&_reportcard/scorecard/model/bb_spefic_book_score_model.dart';
import 'package:brainbee/presentation/views/extras/score_&_reportcard/scorecard/repo/score_repo.dart';
import 'package:brainbee/presentation/views/extras/score_&_reportcard/scorecard/services/score_api_service.dart';

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
  Future<BookScoreData> getBookScore(String bookId) async {
    try {
      final response = await apiService.getBookScore(bookId);
      final Map<String, dynamic> jsonData = jsonDecode(response.body);
      final bookScoreResponse = BookScoreResponse.fromJson(jsonData);
      return bookScoreResponse.data;
    } on ScoreApiException catch (e) {
      throw Exception('Failed to load book score: ${e.message}');
    } catch (e) {
      throw Exception('Failed to load book score: $e');
    }
  }
}
