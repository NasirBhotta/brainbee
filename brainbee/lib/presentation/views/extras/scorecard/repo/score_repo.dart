// lib/presentation/views/extras/scorecard/repository/score_repository.dart

import 'package:brainbee/presentation/views/extras/scorecard/model/bb_book_score.model.dart';

abstract class ScoreRepository {
  Future<OverallScoreData> getOverallScore();
  Future<dynamic> getBookScore(String bookId);
}
