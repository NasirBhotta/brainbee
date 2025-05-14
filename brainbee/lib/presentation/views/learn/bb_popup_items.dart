import 'package:brainbee/core/utils/bb_screen_extension.dart';
import 'package:brainbee/core/utils/bb_text.dart';
import 'package:brainbee/presentation/views/Books/bb_books.dart';
import 'package:brainbee/presentation/views/battle/bb_battle.dart';
import 'package:brainbee/presentation/views/extras/Certificates/bb_certificates.dart';
import 'package:brainbee/presentation/views/extras/Rewards/bb_rewards.dart';
import 'package:brainbee/presentation/views/extras/badges/bb_badges.dart';
import 'package:brainbee/presentation/views/extras/coinquests/bb_coin_quests.dart';
import 'package:brainbee/presentation/views/extras/leaderboard/bb_leaderboard.dart';
import 'package:brainbee/presentation/views/extras/reportcard/bb_reportcard.dart';
import 'package:brainbee/presentation/views/extras/scorecard/bb_scorecard.dart';
import 'package:brainbee/presentation/views/flashcards/bb_flashcards.dart';
import 'package:brainbee/presentation/views/practice/bb_practice.dart';
import 'package:flutter/material.dart';

enum BottomBarType { learn, extra }

class BBPopupItems extends StatelessWidget {
  final String? title;
  final String? imgPath;
  final int? index;
  late BottomBarType barType;
  BBPopupItems({
    super.key,
    required this.title,
    required this.imgPath,
    required this.index,
    required this.barType,
  });

  List<Widget> learnPopUpWidgets = [
    const BBBattle(),
    const BBPractice(),
    BBFlashcards(),
    const BBBooks(),
  ];
  List<Widget> extraPopUpWidgets = [
    const BBOverallScoreScreen(),
    const ReportCardScreen(),
    const BBleaderBoard(),
    const BbRewards(),
    const BbCoinQuests(),
    const BbBadges(),
    const BbCertificates(),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) {
                  if (BottomBarType.learn == barType) {
                    return learnPopUpWidgets[index!];
                  }
                  return extraPopUpWidgets[index!];
                },
              ),
            );
          },
          child: Container(
            height: context.screenHeight * 0.075,
            width: context.screenWidth * 0.16,
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(40),
              color: const Color.fromARGB(179, 135, 219, 139),

              boxShadow: const [
                BoxShadow(
                  color: Color.fromARGB(115, 135, 219, 139),
                  blurRadius: 5,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Image.asset(imgPath ?? "assets/battle.png"),
          ),
        ),
        BBText(
          data: title ?? "nothing",
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontSize: 12,
            fontWeight: FontWeight.w300,
          ),
        ),
      ],
    );
  }
}
