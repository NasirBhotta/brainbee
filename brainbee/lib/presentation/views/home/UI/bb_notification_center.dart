import 'package:brainbee/core/utils/bb_text.dart';
import 'package:brainbee/core/utils/bb_textTheme_extention.dart';
import 'package:brainbee/presentation/views/home/UI/parentGoal/bloc/parentgoals_bloc.dart';
import 'package:brainbee/presentation/views/home/UI/parentGoal/models/parent_model.dart';
import 'package:brainbee/presentation/views/home/UI/parent_goal_detail.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// Import your parent goals bloc and model

class BBNotificationCenter extends StatelessWidget {
  const BBNotificationCenter({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ParentGoalsBloc()..add(FetchParentGoals()),
      child: const _NotificationCenterView(),
    );
  }
}

class _NotificationCenterView extends StatelessWidget {
  const _NotificationCenterView();

  @override
  Widget build(BuildContext context) {
    // Static notifications (badges, achievements, etc.)
    final List<StaticNotification> staticNotifications = [
      StaticNotification(
        message: 'Congratulations! You received a new badge Score 10.',
        timeAgo: '6 months ago',
        icon: Icons.emoji_events,
        iconColor: Colors.amber,
      ),
    ];

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: BBText(
          data: 'Notifications',
          style: context.textStyle.titleMedium,
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: Colors.grey[300]),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          context.read<ParentGoalsBloc>().add(FetchParentGoals());
        },
        child: BlocBuilder<ParentGoalsBloc, ParentGoalsState>(
          builder: (context, state) {
            if (state is ParentGoalsLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is ParentGoalsError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 60, color: Colors.red[300]),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: BBText(
                        data: state.message,
                        style: context.textStyle.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        context.read<ParentGoalsBloc>().add(FetchParentGoals());
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            final parentGoals =
                state is ParentGoalsLoaded ? state.goals : <ParentGoal>[];

            // Combine parent goals with static notifications
            final totalItems = parentGoals.length + staticNotifications.length;

            if (totalItems == 0) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.notifications_none,
                      size: 80,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    BBText(
                      data: 'No notifications yet',
                      style: context.textStyle.bodyLarge?.copyWith(
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              );
            }

            return ListView.separated(
              itemCount: totalItems,
              separatorBuilder:
                  (context, index) =>
                      Divider(height: 1, thickness: 1, color: Colors.grey[300]),
              itemBuilder: (context, index) {
                // Show parent goals first
                if (index < parentGoals.length) {
                  return ParentGoalNotificationItem(goal: parentGoals[index]);
                } else {
                  // Then show static notifications
                  return StaticNotificationItem(
                    notification:
                        staticNotifications[index - parentGoals.length],
                  );
                }
              },
            );
          },
        ),
      ),
    );
  }
}

class ParentGoalNotificationItem extends StatelessWidget {
  final ParentGoal goal;

  const ParentGoalNotificationItem({super.key, required this.goal});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ParentGoalDetailScreen(goal: goal),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color:
                    goal.isCompleted ? Colors.green[100] : Colors.orange[100],
                shape: BoxShape.circle,
              ),
              child: Icon(
                goal.isCompleted ? Icons.check_circle : Icons.flag,
                color:
                    goal.isCompleted ? Colors.green[700] : Colors.orange[700],
                size: 30,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: BBText(
                          data:
                              'Your parent ${goal.parentId.fullName} set a new goal for you',
                          style: context.textStyle.bodyMedium?.copyWith(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (goal.isCompleted)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green[100],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Completed',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.green[700],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  BBText(
                    data: goal.title,
                    style: context.textStyle.bodySmall?.copyWith(
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    goal.getTimeAgo(),
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.blue[400],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}

class StaticNotificationItem extends StatelessWidget {
  final StaticNotification notification;

  const StaticNotificationItem({super.key, required this.notification});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: notification.iconColor.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              notification.icon,
              color: notification.iconColor,
              size: 30,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BBText(
                  data: notification.message,
                  style: context.textStyle.bodyMedium?.copyWith(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  notification.timeAgo,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.blue[400],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class StaticNotification {
  final String message;
  final String timeAgo;
  final IconData icon;
  final Color iconColor;

  StaticNotification({
    required this.message,
    required this.timeAgo,
    required this.icon,
    required this.iconColor,
  });
}
