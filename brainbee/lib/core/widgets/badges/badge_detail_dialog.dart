import 'package:brainbee/core/utils/bb_date_formatter.dart';
import 'package:flutter/material.dart';
import 'package:brainbee/presentation/views/extras/badges/models/badge_model.dart';

class BadgeDetailDialog extends StatelessWidget {
  final BbBadge badge;

  const BadgeDetailDialog({super.key, required this.badge});

  static Future<void> show(BuildContext context, BbBadge badge) {
    return showDialog(
      context: context,
      builder: (context) => BadgeDetailDialog(badge: badge),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Badge Icon
            SizedBox(width: 100, height: 100, child: _buildBadgeIcon()),
            const SizedBox(height: 16),

            // Badge Name
            Text(
              badge.name,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),

            // Badge Category
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: _getCategoryColor().withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                badge.categoryDisplayName,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: _getCategoryColor(),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Badge Description
            Text(
              badge.description,
              style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),

            // Earning Criteria
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 16,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Earning Criteria',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    badge.earningCriteria,
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                  ),
                ],
              ),
            ),

            // Earned Date (if applicable)
            if (badge.isEarned && badge.earnedDate != null) ...[
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.check_circle_outline,
                          size: 16,
                          color: Colors.green.shade600,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Earned On',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.green.shade800,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      DateFormatter.formatBadgeDetailDate(badge.earnedDate!),
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.green.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 24),

            // Close Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Close',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadgeIcon() {
    Widget iconWidget;

    if (badge.iconAsset != null) {
      iconWidget = Image.asset(
        badge.iconAsset!,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => _buildFallbackIcon(),
      );
    } else {
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

    return iconWidget;
  }

  Widget _buildFallbackIcon() {
    IconData iconData;
    Color iconColor = _getCategoryColor();

    switch (badge.category) {
      case BbBadgeCategory.score:
        iconData = Icons.star;
        break;
      case BbBadgeCategory.streak:
        iconData = Icons.local_fire_department;
        break;
      case BbBadgeCategory.achievement:
        iconData = Icons.emoji_events;
        break;
      case BbBadgeCategory.milestone:
        iconData = Icons.flag;
        break;
      case BbBadgeCategory.participation:
        iconData = Icons.group;
        iconColor = iconColor;
        break;
    }

    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: iconColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(50),
      ),
      child: Icon(iconData, color: iconColor, size: 50),
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
        return Colors.blue;
      case BbBadgeCategory.participation:
        return Colors.purple;
    }
  }
}
