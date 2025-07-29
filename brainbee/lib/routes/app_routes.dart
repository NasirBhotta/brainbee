import 'package:brainbee/presentation/views/extras/badges/UI/bb_badge_detail.dart';
import 'package:brainbee/presentation/views/extras/badges/UI/bb_badge_view.dart';
import 'package:brainbee/presentation/views/extras/badges/models/badge_model.dart';
import 'package:flutter/material.dart';

class AppRoutes {
  static const String badgeView = '/badge-view';
  static const String badgeDetail = '/badge-detail';

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      badgeView: (context) => const BadgesScreen(studentId: 'S001'),
      badgeDetail: (context) {
        final badge = ModalRoute.of(context)!.settings.arguments as BbBadge;
        return BadgeDetailScreen(badge: badge);
      },
    };
  }

  static void navigateToBadgeView(BuildContext context) {
    Navigator.pushNamed(context, badgeView);
  }

  static void navigateToBadgeDetail(BuildContext context, BbBadge badge) {
    Navigator.pushNamed(context, badgeDetail, arguments: badge);
  }

  static void navigateToBadgeDetailAsDialog(
    BuildContext context,
    BbBadge badge,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.all(16),
            child: Container(
              constraints: const BoxConstraints(maxHeight: 600),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: BadgeDetailScreen(badge: badge),
              ),
            ),
          ),
    );
  }
}
