import 'package:brainbee/core/utils/bb_date_formatter.dart';
import 'package:brainbee/presentation/views/extras/achievements/badges/models/badge_model.dart';
import 'package:flutter/material.dart';

class BadgeItem extends StatelessWidget {
  final BbBadge badge;
  final VoidCallback? onTap;

  const BadgeItem({super.key, required this.badge, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: badge.isEarned ? onTap : null,
      child: Container(
        decoration: BoxDecoration(
          color: badge.isEarned ? Colors.white : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: badge.isEarned ? Colors.blue.shade200 : Colors.grey.shade300,
            width: badge.isEarned ? 2 : 1,
          ),
          boxShadow:
              badge.isEarned
                  ? [
                    BoxShadow(
                      color: Colors.blue.shade100,
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                  : [],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Badge Icon
              SizedBox(width: 60, height: 60, child: _buildBadgeIcon()),
              const SizedBox(height: 8),
              // Badge Name
              Text(
                badge.name,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: badge.isEarned ? Colors.black87 : Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              // Earned Date (if earned)
              if (badge.isEarned && badge.earnedDate != null) ...[
                const SizedBox(height: 4),
                Text(
                  DateFormatter.formatBadgeDate(badge.earnedDate!),
                  style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ),
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
          return const Center(child: CircularProgressIndicator(strokeWidth: 2));
        },
        errorBuilder: (context, error, stackTrace) => _buildFallbackIcon(),
      );
    }

    return Stack(
      children: [
        iconWidget,
        if (!badge.isEarned)
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.7),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Icon(
              Icons.lock_outline,
              color: Colors.grey.shade600,
              size: 24,
            ),
          ),
      ],
    );
  }

  Widget _buildFallbackIcon() {
    IconData iconData;
    Color iconColor;

    switch (badge.category) {
      case BbBadgeCategory.score:
        iconData = Icons.star;
        iconColor = Colors.amber;
        break;
      case BbBadgeCategory.streak:
        iconData = Icons.local_fire_department;
        iconColor = Colors.orange;
        break;
      case BbBadgeCategory.achievement:
        iconData = Icons.emoji_events;
        iconColor = Colors.amber;
        break;
      case BbBadgeCategory.milestone:
        iconData = Icons.flag;
        iconColor = Colors.blue;
        break;
      case BbBadgeCategory.participation:
        iconData = Icons.group;
        iconColor = Colors.green;
        break;
    }

    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color:
            badge.isEarned ? iconColor.withOpacity(0.1) : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Icon(
        iconData,
        color: badge.isEarned ? iconColor : Colors.grey.shade500,
        size: 32,
      ),
    );
  }
}
