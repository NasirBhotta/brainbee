import 'package:brainbee/core/utils/bb_text.dart';
import 'package:brainbee/core/utils/bb_textTheme_extention.dart';
import 'package:flutter/material.dart';

class Notification {
  final String message;
  final String timeAgo;
  final bool hasIcon;

  Notification({
    required this.message,
    required this.timeAgo,
    this.hasIcon = true,
  });
}

class BBNotificationCenter extends StatelessWidget {
  const BBNotificationCenter({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Notification> notifications = [
      Notification(
        message: 'Congratulations! You received a new badge Score 10.',
        timeAgo: '6 months ago',
      ),
      Notification(
        message:
            'Your Parents set a new goals to you. Click to view the goalsYour Parents set a new goals to you. Click to view the goals',
        timeAgo: '6 months ago',
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
      body: ListView.separated(
        itemCount: notifications.length,
        separatorBuilder:
            (context, index) =>
                Divider(height: 1, thickness: 1, color: Colors.grey[300]),
        itemBuilder: (context, index) {
          return NotificationItem(notification: notifications[index]);
        },
      ),
    );
  }
}

class NotificationItem extends StatelessWidget {
  final Notification notification;

  const NotificationItem({super.key, required this.notification});

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
              color: Colors.lightGreen[100],
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Image.asset('assets/star-medal.png', scale: 12),
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
