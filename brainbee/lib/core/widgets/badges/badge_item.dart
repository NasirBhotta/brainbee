// lib/core/widgets/badges/badge_item.dart
import 'package:brainbee/core/constants/bb_colors.dart';
import 'package:brainbee/core/utils/bb_date_formatter.dart';
import 'package:brainbee/core/widgets/badges/badge_icon_widget.dart';
import 'package:brainbee/presentation/views/extras/achievements/badges/models/badge_model.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
          color: badge.isEarned ? BBColors.white : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color:
                badge.isEarned
                    ? BBColors.primaryColor.withOpacity(0.3)
                    : Colors.grey.shade300,
            width: badge.isEarned ? 2 : 1,
          ),
          boxShadow:
              badge.isEarned
                  ? [
                    BoxShadow(
                      color: BBColors.primaryColor.withOpacity(0.1),
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
              BadgeIconWidget(
                badge: badge,
                size: 60,
                showEarnedIndicator: false,
              ),
              const SizedBox(height: 8),

              // Badge Name
              Text(
                badge.name,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color:
                      badge.isEarned
                          ? BBColors.darkHeading
                          : Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              // Earned Date or Progress
              if (badge.isEarned && badge.earnedDate != null) ...[
                const SizedBox(height: 4),
                Text(
                  DateFormatter.formatBadgeDate(badge.earnedDate!),
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    color: Colors.grey.shade600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ] else if (!badge.isEarned && badge.currentProgress > 0) ...[
                const SizedBox(height: 4),
                Text(
                  '${badge.currentProgress}/${badge.targetValue}',
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    color: BBColors.primaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
