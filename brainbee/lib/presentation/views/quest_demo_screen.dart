import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/utils/quest_helper.dart';
import '../../core/utils/quest_repository.dart';
import '../bloc/quest_bloc.dart';
import 'coin_quest_screen.dart';

class QuestDemoScreen extends StatefulWidget {
  const QuestDemoScreen({super.key});

  @override
  State<QuestDemoScreen> createState() => _QuestDemoScreenState();
}

class _QuestDemoScreenState extends State<QuestDemoScreen> {
  final QuestHelper _questHelper = QuestHelper.instance;
  final QuestRepository _questRepository = QuestRepository.instance;
  
  int _currentBalance = 0;
  bool _notificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadWalletBalance();
    _loadNotificationSettings();
  }

  Future<void> _loadWalletBalance() async {
    final balance = await _questHelper.getWalletBalance();
    setState(() {
      _currentBalance = balance;
    });
  }

  Future<void> _loadNotificationSettings() async {
    final enabled = await _questHelper.areNotificationsEnabled();
    setState(() {
      _notificationsEnabled = enabled;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Quest Demo & Testing',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF6366F1),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.quiz, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BlocProvider(
                    create: (context) => QuestBloc(),
                    child: const CoinQuestScreen(),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWalletSection(),
            const SizedBox(height: 24),
            _buildQuestTriggersSection(),
            const SizedBox(height: 24),
            _buildUtilitySection(),
            const SizedBox(height: 24),
            _buildSettingsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildWalletSection() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: const LinearGradient(
            colors: [Color(0xFFFFD700), Color(0xFFFFA000)],
          ),
        ),
        child: Row(
          children: [
            const Icon(Icons.account_balance_wallet, 
                      color: Colors.white, size: 32),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Current Balance',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    '$_currentBalance coins',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: _loadWalletBalance,
              icon: const Icon(Icons.refresh, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestTriggersSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Test Quest Completion',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Tap these buttons to simulate completing various activities:',
          style: TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 16),
        _buildQuestTriggerGrid(),
      ],
    );
  }

  Widget _buildQuestTriggerGrid() {
    final triggers = [
      {
        'title': 'Daily Login',
        'subtitle': 'Simulate daily app login',
        'icon': Icons.login,
        'color': Colors.blue,
        'action': _questHelper.onDailyLogin,
      },
      {
        'title': 'Complete Lesson',
        'subtitle': 'Simulate lesson completion',
        'icon': Icons.school,
        'color': Colors.green,
        'action': _questHelper.onLessonCompleted,
      },
      {
        'title': 'Take Quiz',
        'subtitle': 'Simulate quiz completion',
        'icon': Icons.quiz,
        'color': Colors.orange,
        'action': _questHelper.onQuizCompleted,
      },
      {
        'title': 'First Lesson',
        'subtitle': 'Complete first lesson ever',
        'icon': Icons.star,
        'color': Colors.purple,
        'action': _questHelper.onFirstLessonCompleted,
      },
      {
        'title': 'Profile Setup',
        'subtitle': 'Complete profile setup',
        'icon': Icons.person,
        'color': Colors.teal,
        'action': _questHelper.onProfileSetupCompleted,
      },
      {
        'title': 'Perfect Score',
        'subtitle': 'Get 100% on quiz',
        'icon': Icons.military_tech,
        'color': Colors.amber,
        'action': _questHelper.onPerfectScoreAchieved,
      },
      {
        'title': 'Learning Streak',
        'subtitle': '5-day learning streak',
        'icon': Icons.local_fire_department,
        'color': Colors.red,
        'action': () => _questHelper.onLearningStreakMaintained(5),
      },
      {
        'title': 'Multi-Subject',
        'subtitle': '3 different subjects',
        'icon': Icons.dashboard,
        'color': Colors.indigo,
        'action': () => _questHelper.onMultiSubjectProgress(3),
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: triggers.length,
      itemBuilder: (context, index) {
        final trigger = triggers[index];
        return Card(
          elevation: 3,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () async {
              await (trigger['action'] as Function)();
              _loadWalletBalance();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Triggered: ${trigger['title']}'),
                  backgroundColor: trigger['color'] as Color,
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    trigger['icon'] as IconData,
                    size: 32,
                    color: trigger['color'] as Color,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    trigger['title'] as String,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    trigger['subtitle'] as String,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildUtilitySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Utility Functions',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () async {
                  final success = await _questHelper.spendCoins(10);
                  if (success) {
                    _loadWalletBalance();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Spent 10 coins successfully!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Insufficient balance!'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.shopping_cart),
                label: const Text('Spend 10 Coins'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () async {
                  await _questRepository.clearAllData();
                  _loadWalletBalance();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('All data cleared!'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                },
                icon: const Icon(Icons.clear_all),
                label: const Text('Reset All'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSettingsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Settings',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text('Quest Notifications'),
            subtitle: const Text('Receive notifications when quests are complete'),
            trailing: Switch(
              value: _notificationsEnabled,
              onChanged: (value) async {
                await _questHelper.setNotificationsEnabled(value);
                setState(() {
                  _notificationsEnabled = value;
                });
              },
            ),
          ),
        ),
      ],
    );
  }
}