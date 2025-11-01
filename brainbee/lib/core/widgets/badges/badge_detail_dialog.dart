// lib/core/widgets/badges/badge_detail_dialog.dart
import 'package:brainbee/core/constants/bb_colors.dart';
import 'package:brainbee/core/utils/bb_date_formatter.dart';
import 'package:brainbee/core/widgets/badges/badge_icon_widget.dart';
import 'package:flutter/material.dart';
import 'package:brainbee/presentation/views/extras/achievements/badges/models/badge_model.dart';
import 'package:google_fonts/google_fonts.dart';

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
            BadgeIconWidget(
              badge: badge,
              size: 100,
              showEarnedIndicator: false,
            ),
            const SizedBox(height: 16),

            // Badge Name
            Text(
              badge.name,
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: BBColors.darkHeading,
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
                style: GoogleFonts.poppins(
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
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: BBColors.bodyText,
              ),
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
                        style: GoogleFonts.poppins(
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
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                    ),
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
                  color: BBColors.successGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: BBColors.successGreen.withOpacity(0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.check_circle_outline,
                          size: 16,
                          color: BBColors.successGreen,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Earned On',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: BBColors.successGreen,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      DateFormatter.formatBadgeDetailDate(badge.earnedDate!),
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: BBColors.successGreen,
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
                  backgroundColor: BBColors.primaryColor,
                  foregroundColor: BBColors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Close',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
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
