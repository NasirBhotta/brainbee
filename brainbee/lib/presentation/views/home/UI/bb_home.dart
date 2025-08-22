import 'dart:ui';

import 'package:brainbee/core/constants/bb_colors.dart';
import 'package:brainbee/core/utils/bb_screen_extension.dart';
import 'package:brainbee/core/utils/bb_text.dart';
import 'package:brainbee/core/utils/bb_textTheme_extention.dart';
import 'package:brainbee/core/utils/helper/bb_getinitials.dart';
import 'package:brainbee/presentation/views/dashboard/UI/bb_progress_bar.dart';
import 'package:brainbee/presentation/views/dashboard/UI/bb_quizzes_display.dart';
import 'package:brainbee/presentation/views/home/UI/bb_coin_popup.dart';
import 'package:brainbee/presentation/views/home/UI/bb_lives_popup.dart';
import 'package:brainbee/presentation/views/home/UI/bb_notification_center.dart';
import 'package:brainbee/presentation/views/home/UI/bb_score_popup.dart';
import 'package:brainbee/presentation/views/home/UI/bb_streak_popup.dart';
import 'package:brainbee/presentation/views/home/models/bb_student_model.dart';
import 'package:brainbee/presentation/views/settings/UI/bb_settings.dart';
import 'package:flutter/material.dart';

class BBhome extends StatefulWidget {
  final StudentModel student;
  const BBhome({super.key, required this.student});

  @override
  State<BBhome> createState() => _BBhomeState();
}

class _BBhomeState extends State<BBhome> {
  // Static data - moved to class level for better performance
  static const List<String> _imgPath = [
    'assets/trophy.png',
    'assets/coin.png',
    'assets/fire.png',
    'assets/heart.png',
  ];

  static const List<Color> _color = [
    BBColors.orangeAccent,
    BBColors.yellowAccent,
    BBColors.secondaryColor,
    BBColors.alertRed,
  ];

  static const List<Map<String, dynamic>> _quizzes = [
    {
      'title': 'Mathematics',
      'description': 'Quiz level 1 - Basic and Mixed Operations',
      'imagePath1': 'assets/bg1.png',
      'imagePath2': 'assets/quiz1.png',
      'color': BBColors.progressColor1,
    },
    {
      'title': 'Physics',
      'description': 'Quiz level 1 - Science Process Skills',
      'imagePath1': 'assets/bg2.png',
      'imagePath2': 'assets/quiz2.png',
      'color': BBColors.progressColor2,
    },
    {
      'title': 'Biology',
      'description': 'Quiz level 1 - Introduction to Biology',
      'imagePath1': 'assets/bg3.png',
      'imagePath2': 'assets/quiz3.png',
      'color': BBColors.progressColor3,
    },
    {
      'title': 'Chemistry',
      'description': 'Quiz level 1 - Introduction to Chemistry',
      'imagePath1': 'assets/bg4.png',
      'imagePath2': 'assets/quiz4.png',
      'color': BBColors.progressColor4,
    },
  ];

  // Cache these values to avoid recalculating on every build
  late final List<String> _desc;
  late final String _displayName;
  late final String _initials;

  @override
  void initState() {
    super.initState();
    _desc = [
      widget.student.score.toString(),
      widget.student.coins.toString(),
      widget.student.streakScore.toString(),
      '${widget.student.dailyLives}/10',
    ];

    _displayName =
        widget.student.firstName != ''
            ? "${widget.student.firstName} ${widget.student.lastName}"
            : 'UserName';

    _initials =
        widget.student.firstName != ''
            ? getIntials(widget.student.firstName)
            : 'U';
  }

  void _onPopupTap(int index) {
    switch (index) {
      case 0:
        showScoreGoalsPopup(context, widget.student);
        break;
      case 1:
        showCoinsPopup(context, widget.student);
        break;
      case 2:
        showStreakPopup(context, widget.student.streakScore.toString());
        break;
      case 3:
        showLivesPopup(context, widget.student.dailyLives.toString());
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 130,
          pinned: true,
          floating: false,
          backgroundColor: Colors.transparent,
          elevation: 0,
          flexibleSpace: ClipRRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: FlexibleSpaceBar(
                background: _AppBarBackground(
                  displayName: _displayName,
                  initials: _initials,
                ),
                expandedTitleScale: 1,
                title: _ProgressBarRow(desc: _desc, onPopupTap: _onPopupTap),
                centerTitle: true,
              ),
            ),
          ),
        ),
        SliverList.builder(
          itemBuilder: (context, index) {
            if (index == 0) {
              return const _PromotionCard();
            }

            final quiz = _quizzes[index - 1];
            return BbQuizzesDisplay(
              title: quiz['title']!,
              description: quiz['description']!,
              imagePath1: quiz['imagePath1']!,
              imagePath2: quiz['imagePath2']!,
              color: quiz['color']!,
            );
          },
          itemCount: _quizzes.length + 1,
        ),
      ],
    );
  }
}

// Extracted widgets for better performance and cleaner code
class _AppBarBackground extends StatelessWidget {
  final String displayName;
  final String initials;

  const _AppBarBackground({required this.displayName, required this.initials});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 10, right: 10),
      color: Colors.transparent,
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              Text(
                "Good Evening",
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontSize: 10),
              ),
              const Expanded(child: SizedBox.shrink()),
              Text(
                displayName,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 50),
              const Expanded(child: SizedBox.shrink()),
            ],
          ),
          const Expanded(child: SizedBox.shrink()),
          Column(
            children: [
              Row(
                children: [
                  const SizedBox(height: 150),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const BBNotificationCenter(),
                        ),
                      );
                    },
                    child: const Icon(
                      Icons.notifications,
                      size: 20,
                      color: BBColors.disabledText,
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const BBSettings(),
                        ),
                      );
                    },
                    child: CircleAvatar(
                      backgroundColor: Colors.green[700],
                      child: Text(
                        initials,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProgressBarRow extends StatelessWidget {
  final List<String> desc;
  final void Function(int) onPopupTap;

  const _ProgressBarRow({required this.desc, required this.onPopupTap});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(4, (index) {
        return BbProgressBar(
          color: _BBhomeState._color[index],
          imgPath: _BBhomeState._imgPath[index],
          desc: desc[index],
          index: index,
          onTap: () => onPopupTap(index),
        );
      }),
    );
  }
}

class _PromotionCard extends StatelessWidget {
  const _PromotionCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      height: context.screenHeight * 0.25,
      width: double.infinity,
      child: Stack(
        children: [
          Align(
            alignment: Alignment.center,
            child: Container(
              width: context.screenWidth,
              height: context.screenHeight * 0.18,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: BBColors.white,
                image: const DecorationImage(
                  image: AssetImage('assets/promotionbg.png'),
                  fit: BoxFit.cover,
                ),
              ),
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 17),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 15,
                children: [
                  SizedBox(
                    width: context.screenWidth * 0.5,
                    child: BBText(
                      data: "Bookmark 6 Questions",
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: BBColors.white,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      color: BBColors.white,
                    ),
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.zero,
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: BBText(
                        data: "Claim Now",
                        style: context.textStyle.titleMedium?.copyWith(
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: SizedBox(
              height: context.screenHeight * 0.5,
              width: context.screenWidth * 0.5,
              child: Image.asset('assets/promotion.png', fit: BoxFit.contain),
            ),
          ),
        ],
      ),
    );
  }
}
