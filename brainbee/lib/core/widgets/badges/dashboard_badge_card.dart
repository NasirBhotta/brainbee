// this file need to be updated and synchronize with other code
import 'package:brainbee/presentation/views/extras/achievements/badges/UI/navigation/badge_navigator.dart';
import 'package:brainbee/presentation/views/extras/achievements/badges/bloc/badge_bloc.dart';
import 'package:brainbee/presentation/views/extras/achievements/badges/bloc/badge_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DashboardBadgeCard extends StatelessWidget {
  const DashboardBadgeCard({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BadgeBloc, BadgeState>(
      builder: (context, state) {
        return GestureDetector(
          onTap: () => BadgeNavigator.showBadgeViewFromMenu(context),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.workspace_premium,
                        color: Colors.blue,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'My Badges',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Colors.grey,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (state is BadgeLoaded) ...[
                  Text(
                    '${state.badges.where((b) => b.isEarned && !b.isExpired).length} earned',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value:
                        state.badges.isNotEmpty
                            ? state.badges
                                    .where((b) => b.isEarned && !b.isExpired)
                                    .length /
                                state.badges.where((b) => !b.isExpired).length
                            : 0,
                    backgroundColor: Colors.grey[200],
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Colors.blue,
                    ),
                  ),
                ] else if (state is BadgeLoading ||
                    state is BadgeRefreshing) ...[
                  const Text(
                    'Loading...',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ] else if (state is BadgeError) ...[
                  const Text(
                    'Error loading badges',
                    style: TextStyle(fontSize: 14, color: Colors.red),
                  ),
                ] else ...[
                  const Text(
                    'Tap to view your badges',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
