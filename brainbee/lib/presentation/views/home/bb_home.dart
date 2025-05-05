import 'package:brainbee/core/constants/bb_colors.dart';
import 'package:brainbee/core/utils/bb_screen_extension.dart';
import 'package:brainbee/core/utils/bb_text.dart';
import 'package:brainbee/core/utils/bb_textTheme_extention.dart';
import 'package:brainbee/presentation/views/dashboard/bb_progress_bar.dart';
import 'package:brainbee/presentation/views/dashboard/bb_quizzes_display.dart';
import 'package:brainbee/presentation/views/home/bb_coin_popup.dart';
import 'package:brainbee/presentation/views/home/bb_lives_popup.dart';
import 'package:brainbee/presentation/views/home/bb_notification_center.dart';
import 'package:brainbee/presentation/views/home/bb_score_popup.dart';
import 'package:brainbee/presentation/views/home/bb_streak_popup.dart';
import 'package:brainbee/presentation/views/settings/bb_settings.dart';
import 'package:flutter/material.dart';

class BBhome extends StatefulWidget {
  const BBhome({super.key});

  @override
  State<BBhome> createState() => _BBhomeState();
}

class _BBhomeState extends State<BBhome> {
  List<String> imgPath = [
    'assets/trophy.png',
    'assets/coin.png',
    'assets/fire.png',
    'assets/heart.png',
  ];
  List<Color> color = [
    BBColors.orangeAccent,
    BBColors.yellowAccent,
    BBColors.secondaryColor,
    BBColors.alertRed,
  ];
  List<String> desc = ['10', '1', '0', '5/5'];

  List<Map<String, String>> quizzes = [
    {
      'title': 'Mathematics',
      'description': 'Quiz level 1 - Basic and Mixed Operations',
      'imagePath1': 'assets/bg1.png',
      'imagePath2': 'assets/quiz1.png',
    },
    {
      'title': 'Physics',
      'description': 'Quiz level 1 - Science Process Skills',
      'imagePath1': 'assets/bg2.png',
      'imagePath2': 'assets/quiz2.png',
    },
    {
      'title': 'Biology',
      'description': 'Quiz level 1 - Introduction to Biology',
      'imagePath1': 'assets/bg3.png',
      'imagePath2': 'assets/quiz3.png',
    },
    {
      'title': 'Chemistry',
      'description': 'Quiz level 1 - Introduction to Chemistry',
      'imagePath1': 'assets/bg4.png',
      'imagePath2': 'assets/quiz4.png',
    },
  ];
  List<Function> popUpFunctions = [
    showScoreGoalsPopup,
    showCoinsPopup,
    showStreakPopup,
    showLivesPopup,
  ];
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

          flexibleSpace: FlexibleSpaceBar(
            background: Container(
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
                        "Nasir Bhutta",
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
                                  builder:
                                      (context) => const BBNotificationCenter(),
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
                              child: const Text(
                                'N',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            expandedTitleScale: 1,
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(4, (index) {
                return BbProgressBar(
                  color: color[index],
                  imgPath: imgPath[index],
                  desc: desc[index],
                  index: index,
                  onTap: () {
                    popUpFunctions[index](context);
                  },
                );
              }),
            ),
            centerTitle: true,
          ),
        ),
        SliverList.builder(
          itemBuilder: (_, index) {
            return index == 0
                ? Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),

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
                          padding: const EdgeInsets.symmetric(
                            vertical: 6,
                            horizontal: 17,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            spacing: 15,
                            children: [
                              SizedBox(
                                width: context.screenWidth * 0.5,
                                child: BBText(
                                  data: "Bookmark 6 Questions",
                                  style: Theme.of(
                                    context,
                                  ).textTheme.titleSmall?.copyWith(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                    color: BBColors.white,
                                  ),
                                ),
                              ),

                              // SizedBox(
                              //   width: context.screenWidth * 0.7,
                              //   child: LinearProgressIndicator(
                              //     value: 0.5,
                              //     backgroundColor: BBColors.lightGrayBG,
                              //     color: BBColors.primaryColor,
                              //     borderRadius: BorderRadius.circular(12),
                              //   ),
                              // ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 18,
                                ),
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
                                    style: context.textStyle.titleMedium
                                        ?.copyWith(fontSize: 14),
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
                          child: Image.asset(
                            'assets/promotion.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
                : BbQuizzesDisplay(
                  title: quizzes[index - 1]['title']!,
                  description: quizzes[index - 1]['description']!,
                  imagePath1: quizzes[index - 1]['imagePath1']!,
                  imagePath2: quizzes[index - 1]['imagePath2']!,
                );
          },
          itemCount: quizzes.length + 1,
        ),
      ],
    );
  }
}
