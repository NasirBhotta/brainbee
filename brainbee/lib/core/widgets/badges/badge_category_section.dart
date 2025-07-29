import 'package:brainbee/core/widgets/badges/badge_item.dart';
import 'package:brainbee/presentation/views/extras/badges/models/badge_model.dart';
import 'package:flutter/material.dart';

class BadgeCategorySection extends StatelessWidget {
  final BbBadgeCategory category;
  final List<BbBadge> badges;
  final Function(BbBadge) onBadgeTap;

  const BadgeCategorySection({
    super.key,
    required this.category,
    required this.badges,
    required this.onBadgeTap,
  });

  @override
  Widget build(BuildContext context) {
    if (badges.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Icon(_getCategoryIcon(), color: _getCategoryColor(), size: 20),
              const SizedBox(width: 8),
              Text(
                _getCategoryTitle(),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: _getCategoryColor().withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${badges.where((b) => b.isEarned).length}/${badges.length}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _getCategoryColor(),
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.85,
            ),
            itemCount: badges.length,
            itemBuilder: (context, index) {
              final badge = badges[index];
              return BadgeItem(badge: badge, onTap: () => onBadgeTap(badge));
            },
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  String _getCategoryTitle() {
    switch (category) {
      case BbBadgeCategory.score:
        return 'Score Badges';
      case BbBadgeCategory.streak:
        return 'Streak Badges';
      case BbBadgeCategory.achievement:
        return 'Achievement Badges';
      case BbBadgeCategory.milestone:
        return 'Milestone Badges';
      case BbBadgeCategory.participation:
        return 'Participation Badges';
    }
  }

  IconData _getCategoryIcon() {
    switch (category) {
      case BbBadgeCategory.score:
        return Icons.star;
      case BbBadgeCategory.streak:
        return Icons.local_fire_department;
      case BbBadgeCategory.achievement:
        return Icons.emoji_events;
      case BbBadgeCategory.milestone:
        return Icons.flag;
      case BbBadgeCategory.participation:
        return Icons.group;
    }
  }

  Color _getCategoryColor() {
    switch (category) {
      case BbBadgeCategory.score:
        return Colors.amber;
      case BbBadgeCategory.streak:
        return Colors.orange;
      case BbBadgeCategory.achievement:
        return Colors.yellow[700]!;
      case BbBadgeCategory.milestone:
        return Colors.blue;
      case BbBadgeCategory.participation:
        return Colors.green;
    }
  }
}
