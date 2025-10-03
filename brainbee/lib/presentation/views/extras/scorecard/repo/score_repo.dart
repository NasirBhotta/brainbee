// lib/presentation/views/extras/scorecard/repository/score_repository.dart

import 'package:brainbee/presentation/views/extras/scorecard/model/bb_book_score.model.dart';
import 'package:brainbee/presentation/views/extras/scorecard/model/bb_spefic_book_score_model.dart';

abstract class ScoreRepository {
  Future<OverallScoreData> getOverallScore();
  Future<BookScoreData> getBookScore(String bookId);
}
