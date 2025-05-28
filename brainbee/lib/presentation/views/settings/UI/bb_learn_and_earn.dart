import 'dart:ui';

import 'package:brainbee/core/constants/bb_colors.dart';
import 'package:flutter/material.dart';

class LearnAndEarnScreen extends StatefulWidget {
  const LearnAndEarnScreen({super.key});

  @override
  State<LearnAndEarnScreen> createState() => _LearnAndEarnScreenState();
}

class _LearnAndEarnScreenState extends State<LearnAndEarnScreen> {
  int totalPoints = 1250;
  int currentStreak = 7;

  final List<Map<String, dynamic>> achievements = [
    {
      'title': 'Reading Master',
      'description': 'Read 50 chapters',
      'points': 500,
      'completed': true,
      'icon': Icons.book,
    },
    {
      'title': 'Quiz Champion',
      'description': 'Score 100% in 10 quizzes',
      'points': 300,
      'completed': true,
      'icon': Icons.quiz,
    },
    {
      'title': 'Study Streak',
      'description': 'Study for 30 consecutive days',
      'points': 800,
      'completed': false,
      'icon': Icons.local_fire_department,
    },
    {
      'title': 'Perfect Score',
      'description': 'Get 100% in 5 tests',
      'points': 400,
      'completed': false,
      'icon': Icons.star,
    },
    {
      'title': 'Early Bird',
      'description': 'Study before 8 AM for 10 days',
      'points': 200,
      'completed': true,
      'icon': Icons.wb_sunny,
    },
  ];

  final List<Map<String, dynamic>> dailyTasks = [
    {
      'title': 'Complete 3 lessons',
      'points': 50,
      'completed': true,
      'icon': Icons.school,
    },
    {
      'title': 'Take a practice quiz',
      'points': 30,
      'completed': false,
      'icon': Icons.quiz,
    },
    {
      'title': 'Read for 30 minutes',
      'points': 40,
      'completed': true,
      'icon': Icons.book_online,
    },
    {
      'title': 'Review notes',
      'points': 25,
      'completed': false,
      'icon': Icons.note,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Learn and Earn'),
        backgroundColor: BBColors.secondaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Points and Streak Cards
            Row(
              children: [
                Expanded(
                  child: _buildStatsCard(
                    'Total Points',
                    totalPoints.toString(),
                    Icons.star,
                    const Color(0xFFFFD700),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatsCard(
                    'Current Streak',
                    '$currentStreak days',
                    Icons.local_fire_department,
                    const Color(0xFFFF5722),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Daily Tasks Section
            const Text(
              'Daily Tasks',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),

            ...dailyTasks.map((task) => _buildTaskCard(task)),

            const SizedBox(height: 24),

            // Achievements Section
            const Text(
              'Achievements',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),

            ...achievements.map(
              (achievement) => _buildAchievementCard(achievement),
            ),

            const SizedBox(height: 24),

            // Redeem Points Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  _showRedeemDialog();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: BBColors.secondaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Redeem Points',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCard(
    String title,
    String value,
    IconData icon,
    Color iconColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, size: 32, color: iconColor),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          Text(title, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _buildTaskCard(Map<String, dynamic> task) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
              task['completed'] ? BBColors.secondaryColor : Colors.grey[300]!,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color:
                  task['completed']
                      ? BBColors.secondaryColor
                      : Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              task['icon'],
              color: task['completed'] ? Colors.white : Colors.grey[600],
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task['title'],
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                    decoration:
                        task['completed'] ? TextDecoration.lineThrough : null,
                  ),
                ),
                Text(
                  '+${task['points']} points',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          if (task['completed'])
            const Icon(Icons.check_circle, color: Color(0xFF4CAF50), size: 24),
        ],
      ),
    );
  }

  Widget _buildAchievementCard(Map<String, dynamic> achievement) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
              achievement['completed']
                  ? const Color(0xFFFFD700)
                  : Colors.grey[300]!,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color:
                  achievement['completed']
                      ? const Color(0xFFFFD700)
                      : Colors.grey[200],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              achievement['icon'],
              color: achievement['completed'] ? Colors.white : Colors.grey[600],
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  achievement['title'],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  achievement['description'],
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                const SizedBox(height: 4),
                Text(
                  '${achievement['points']} points',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF4CAF50),
                  ),
                ),
              ],
            ),
          ),
          if (achievement['completed'])
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: BBColors.secondaryColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'Earned',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'In Progress',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[600],
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showRedeemDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Redeem Points',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'You have $totalPoints points available to redeem.',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              const Text(
                'Available Rewards:',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              ),
              const SizedBox(height: 12),
              _buildRewardOption('Study Guide PDF', 500),
              _buildRewardOption('Premium Features (1 month)', 1000),
              _buildRewardOption('Certificate of Achievement', 1500),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel', style: TextStyle(color: Colors.grey[600])),
            ),
          ],
        );
      },
    );
  }

  Widget _buildRewardOption(String title, int points) {
    bool canRedeem = totalPoints >= points;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color:
            canRedeem
                ? BBColors.secondaryColor.withOpacity(0.1)
                : Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: canRedeem ? BBColors.secondaryColor : Colors.grey[300]!,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: canRedeem ? Colors.black87 : Colors.grey[600],
              ),
            ),
          ),
          Text(
            '$points pts',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: canRedeem ? BBColors.secondaryColor : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}
