// lib/core/widgets/badges/badge_icon_widget.dart
import 'package:brainbee/core/constants/bb_colors.dart';
import 'package:brainbee/core/utils/badge_utills/badge_utills.dart';
import 'package:brainbee/presentation/views/extras/achievements/badges/models/badge_model.dart';
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

        // Lock overlay for unearned badges
        if (!badge.isEarned)
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.7),
              borderRadius: BorderRadius.circular(size / 2),
            ),
            child: Icon(
              Icons.lock_outline,
              color: Colors.grey.shade600,
              size: size * 0.4,
            ),
          ),

        // Earned indicator
        if (showEarnedIndicator && badge.isEarned)
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                color: BBColors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                Icons.check_circle,
                color: BBColors.successGreen,
                size: size * 0.3,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildBadgeIcon() {
    Widget iconWidget;

    if (badge.iconAsset != null) {
      // Use local asset if available
      iconWidget = Image.asset(
        badge.iconAsset!,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => _buildFallbackIcon(),
      );
    } else {
      // Use network image
      iconWidget = Image.network(
        badge.iconUrl,
        fit: BoxFit.contain,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
              value:
                  loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                      : null,
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) => _buildFallbackIcon(),
      );
    }

    return iconWidget;
  }

  Widget _buildFallbackIcon() {
    final iconData = BadgeUtils.getCategoryIcon(badge.category);
    final iconColor = _getCategoryColor();

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color:
            badge.isEarned ? iconColor.withOpacity(0.1) : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(size / 2),
      ),
      child: Icon(
        iconData,
        color: badge.isEarned ? iconColor : Colors.grey.shade500,
        size: size * 0.5,
      ),
    );
  }

  Color _getCategoryColor() {
    switch (badge.category) {
      case BbBadgeCategory.score:
        return Colors.amber;
      case BbBadgeCategory.streak:
        return Colors.orange;
      case BbBadgeCategory.achievement:
        return Colors.amber;
      case BbBadgeCategory.milestone:
        return BBColors.primaryColor;
      case BbBadgeCategory.participation:
        return BBColors.successGreen;
    }
  }
}
