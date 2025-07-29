import 'package:brainbee/presentation/views/extras/badges/UI/navigation/badge_navigator.dart';
import 'package:flutter/material.dart';

class MenuBadgeTile extends StatelessWidget {
  const MenuBadgeTile({super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(
          Icons.workspace_premium,
          color: Colors.blue,
          size: 24,
        ),
      ),
      title: const Text(
        'View Badges',
        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
      ),
      subtitle: const Text(
        'See your achievements and progress',
        style: TextStyle(fontSize: 14, color: Colors.grey),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: Colors.grey,
      ),
      onTap: () => BadgeNavigator.showBadgeViewFromMenu(context),
    );
  }
}
