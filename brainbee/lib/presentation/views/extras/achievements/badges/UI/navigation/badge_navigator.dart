import 'package:brainbee/presentation/views/extras/achievements/badges/models/badge_model.dart';
import 'package:brainbee/routes/app_routes.dart';
import 'package:flutter/material.dart';

class BadgeNavigator {
  static void showBadgeView(BuildContext context) {
    AppRoutes.navigateToBadgeView(context);
  }

  static void showBadgeDetail(
    BuildContext context,
    BbBadge badge, {
    bool asDialog = false,
  }) {
    if (asDialog) {
      AppRoutes.navigateToBadgeDetailAsDialog(context, badge);
    } else {
      AppRoutes.navigateToBadgeDetail(context, badge);
    }
  }

  static void showBadgeViewFromMenu(BuildContext context) {
    // This method can be called from the main menu/dashboard
    Navigator.pushNamed(context, AppRoutes.badgeView);
  }
}
