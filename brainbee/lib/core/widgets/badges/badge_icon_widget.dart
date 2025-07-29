// lib/widgets/badge_icon_widget.dart
import 'package:brainbee/presentation/views/extras/badges/models/badge_model.dart';
import 'package:flutter/material.dart';

class BadgeIconWidget extends StatelessWidget {
  final BbBadge badge;
  final double size;
  final bool showEarnedIndicator;

  const BadgeIconWidget({
    super.key,
    required this.badge,
    required this.size,
    this.showEarnedIndicator = true,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Badge icon
        SizedBox(width: size, height: size, child: _buildBadgeIcon()),
        if (showEarnedIndicator && badge.isEarned)
          Positioned(
            bottom: 0,
            right: 0,
            child: Icon(
              Icons.check_circle,
              color: Colors.green,
              size: size * 0.3,
            ),
          ),
      ],
    );
  }

  Widget _buildBadgeIcon() {
    // Logic to build the badge icon based on the badge properties
    if (badge.iconAsset != null) {
      return Image.asset(badge.iconAsset!, fit: BoxFit.contain);
    } else {
      return Image.network(badge.iconUrl, fit: BoxFit.contain);
    }
  }
}
