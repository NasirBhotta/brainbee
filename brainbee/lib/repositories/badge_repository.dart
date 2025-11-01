// lib/presentation/views/extras/achievements/badges/repo/badge_repository.dart

import 'package:brainbee/presentation/views/extras/achievements/badges/models/badge_model.dart';

abstract class BadgeRepository {
  Future<List<BbBadge>> getAllBadgesForStudent(String studentId);
  Future<List<BbBadge>> refreshBadges(String studentId);
}
