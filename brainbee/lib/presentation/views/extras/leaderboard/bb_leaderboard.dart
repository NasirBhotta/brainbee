import 'package:brainbee/core/constants/bb_colors.dart';
import 'package:brainbee/core/utils/bb_screen_extension.dart';
import 'package:brainbee/core/utils/bb_text.dart';
import 'package:brainbee/core/utils/bb_textTheme_extention.dart';
import 'package:brainbee/presentation/views/extras/leaderboard/bb_customgraph.dart';
import 'package:brainbee/presentation/views/extras/leaderboard/bb_segmented_toggle.dart';
import 'package:flutter/material.dart';

class LeaderboardEntry {
  final String id;
  final String name;
  final String classGrade;
  final int score;
  final int position;

  LeaderboardEntry({
    required this.id,
    required this.name,
    required this.classGrade,
    required this.score,
    required this.position,
  });
}

class BBleaderBoard extends StatefulWidget {
  const BBleaderBoard({super.key});

  @override
  State<BBleaderBoard> createState() => _BBleaderBoardState();
}

class _BBleaderBoardState extends State<BBleaderBoard> {
  final List<Map<String, dynamic>> leaderboardData = [
    {
      'id': 'S001',
      'name': 'Ali Raza',
      'classGrade': 'Grade 6',
      'score': 950,
      'position': 1,
    },
    {
      'id': 'S002',
      'name': 'Fatima Noor',
      'classGrade': 'Grade 6',
      'score': 910,
      'position': 2,
    },
    {
      'id': 'S003',
      'name': 'Ahmed Khan',
      'classGrade': 'Grade 6',
      'score': 880,
      'position': 3,
    },
    {
      'id': 'S004',
      'name': 'Sara Malik',
      'classGrade': 'Grade 6',
      'score': 860,
      'position': 4,
    },
    {
      'id': 'S005',
      'name': 'Usman Tariq',
      'classGrade': 'Grade 6',
      'score': 830,
      'position': 5,
    },
  ];

  bool _isloding = true;
  bool _hasError = false;
  final bool _isError = false;
  List<LeaderboardEntry>? studentData;

  @override
  void initState() {
    super.initState();

    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() {
      _isloding = true;
      _hasError = false;
    });
    await Future.delayed(const Duration(seconds: 2));

    if (_isError) {
      setState(() {
        _isloding = false;
        _hasError = true;
      });
      return;
    } else {
      setState(() {
        _isloding = false;
        _hasError = false;
        studentData = [];
      });

      studentData = [
        LeaderboardEntry(
          id: 'S001',
          name: 'Ali Raza',
          classGrade: 'Grade 6',
          score: 950,
          position: 1,
        ),
        LeaderboardEntry(
          id: 'S002',
          name: 'Fatima Noor',
          classGrade: 'Grade 6',
          score: 910,
          position: 2,
        ),
        LeaderboardEntry(
          id: 'S003',
          name: 'Ahmed Khan',
          classGrade: 'Grade 6',
          score: 880,
          position: 3,
        ),
        LeaderboardEntry(
          id: 'S004',
          name: 'Sara Malik',
          classGrade: 'Grade 6',
          score: 860,
          position: 4,
        ),
        LeaderboardEntry(
          id: 'S005',
          name: 'Usman Tariq',
          classGrade: 'Grade 6',
          score: 830,
          position: 5,
        ),
      ];

      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: BBColors.lightGrayBG,

        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: BBColors.borderGray, height: 1),
        ),
        title: BBText(
          data: "LeaderBoard",
          style: context.textStyle.titleMedium,
        ),
        centerTitle: true,
      ),

      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isloding) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(BBColors.secondaryColor),
        ),
      );
    }
    if (_hasError) {
      return _buildErrorState();
    }
    return _buildClassList();
  }

  Widget _buildClassList() {
    return RefreshIndicator(
      onRefresh: _fetchData,
      child: ListView(
        children: [
          BBSegmentedToggle(
            onOptionSelected: (timeToggleOption) {},
            initialOption: TimeToggleOption.weekly,
          ),
          SizedBox(
            height: context.screenHeight * 0.5,
            child: PodiumScreen(
              data:
                  studentData?.where((people) {
                    return people.position >= 1 && people.position <= 3;
                  }).toList(),
            ),
          ),
          ...studentData!.asMap().entries.map((e) {
            var index = e.key;
            return _buildListTile(e.value, index);
          }),
        ],
      ),
    );
  }

  Widget _buildListTile(LeaderboardEntry item, int index) {
    int position = index + 1;
    bool isTopThree = position <= 3;

    IconData crownIcon;
    Color crownColor;

    if (position == 1) {
      crownIcon = Icons.emoji_events;
      crownColor = Colors.amber;
    } else if (position == 2) {
      crownIcon = Icons.emoji_events;
      crownColor = Colors.grey;
    } else if (position == 3) {
      crownIcon = Icons.emoji_events;
      crownColor = Colors.brown;
    } else {
      crownIcon = Icons.emoji_events_outlined;
      crownColor = Colors.transparent;
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: BBColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 233, 232, 232),
              shape: BoxShape.circle,
              boxShadow: [
                if (position <= 3)
                  const BoxShadow(
                    color: BBColors.lightGrayBG,
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
              ],
            ),
            child: BBText(
              data: "$position",
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: BBColors.bodyText,
              ),
            ),
          ),
          const SizedBox(width: 10),

          CircleAvatar(
            radius: 28,
            backgroundColor: BBColors.secondaryColor.withOpacity(0.2),
            child: Text(
              item.name.isNotEmpty ? item.name[0].toUpperCase() : '?',
              style: context.textStyle.titleLarge?.copyWith(
                color: BBColors.primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BBText(
                  data: item.name,
                  style: context.textStyle.labelLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                BBText(
                  data: "${item.score} points",
                  style: context.textStyle.labelMedium?.copyWith(
                    color: BBColors.disabledText,
                  ),
                ),
              ],
            ),
          ),

          if (isTopThree) Icon(crownIcon, color: crownColor, size: 28),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return const SizedBox.shrink();
  }
}
