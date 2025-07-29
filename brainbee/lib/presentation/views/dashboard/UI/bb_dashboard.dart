import 'package:brainbee/core/constants/bb_colors.dart';
import 'package:brainbee/core/utils/bb_screen_extension.dart';
import 'package:brainbee/presentation/views/bot/UI/bb_initial_bot_screen.dart';

import 'package:brainbee/presentation/views/class/UI/bb_class.dart';
import 'package:brainbee/presentation/views/extras/Certificates/bb_certificates.dart';
import 'package:brainbee/presentation/views/extras/Rewards/UI/reward_catalog.dart';
import 'package:brainbee/presentation/views/extras/Rewards/bb_rewards.dart';
import 'package:brainbee/presentation/views/extras/badges/UI/bb_badge_view.dart';
import 'package:brainbee/presentation/views/extras/badges/bb_badges.dart';
import 'package:brainbee/presentation/views/extras/bb_extrapopup.dart';
import 'package:brainbee/presentation/views/extras/coinquests/UI/bb_coin_quests.dart';
import 'package:brainbee/presentation/views/extras/leaderboard/bb_leaderboard.dart';
import 'package:brainbee/presentation/views/extras/reportcard/bb_reportcard.dart';
import 'package:brainbee/presentation/views/extras/scorecard/bb_scorecard.dart';

import 'package:brainbee/presentation/views/home/bb_home.dart';
import 'package:brainbee/presentation/views/learn/Books/bb_select_book.dart';

import 'package:brainbee/presentation/views/learn/battle/bb_book_selection.dart';
import 'package:brainbee/presentation/views/learn/bb_learn_popup.dart';
import 'package:brainbee/presentation/views/learn/flashcards/bb_selectBook_flashcards.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BBDashboard extends StatefulWidget {
  const BBDashboard({super.key});

  @override
  State<BBDashboard> createState() => _BBDashboardState();
}

class _BBDashboardState extends State<BBDashboard> {
  int selectedScreen = 0;
  int previousScreen = 0;
  List<Widget> dashBoardScreens = [
    const BBhome(),
    const BBhome(),
    const BbInitialBotScreen(),
    const BBClass(),
    const BBhome(),
  ];
  List<Map<String, dynamic>> learnPopUp = [
    {
      'title': 'Battle',
      'imgPath': 'assets/battle.png',
      'navigateTo': BBBookSelectionForBattle(),
    },
    {
      'title': 'FlashCards',
      'imgPath': 'assets/flash-card.png',
      'navigateTo': BBFlashcards(),
    },
    {
      'title': 'Books',
      'imgPath': 'assets/text-book.png',
      'navigateTo': BbSelectBook(),
    },
  ];
  List<Map<String, dynamic>> extraPopUP = [
    {
      'title': 'Score',
      'imgPath': 'assets/battle.png',
      'navigateTo': BBOverallScoreScreen(),
    },
    {
      'title': 'Report Card',
      'imgPath': 'assets/exercise.png',
      'navigateTo': ReportCardScreen(),
    },
    {
      'title': 'Leaderboard',
      'imgPath': 'assets/flash-card.png',
      'navigateTo': BBleaderBoard(),
    },
    {
      'title': 'Rewards',
      'imgPath': 'assets/text-book.png',
      'navigateTo': RewardCatalogScreen(),
    },
    {
      'title': 'Coin Quests',
      'imgPath': 'assets/text-book.png',
      'navigateTo': BBCoinQuestScreen(userId: "S001"),
    },
    {
      'title': 'Badges',
      'imgPath': 'assets/text-book.png',
      'navigateTo': BadgesScreen(studentId: "S001"),
    },
    {
      'title': 'Certificates',
      'imgPath': 'assets/text-book.png',
      'navigateTo': BbCertificates(),
    },
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            bottom: kBottomNavigationBarHeight,
            child:
                selectedScreen == 0 ||
                        selectedScreen == 3 ||
                        selectedScreen == 2
                    ? dashBoardScreens[selectedScreen]
                    : dashBoardScreens[previousScreen],
          ),

          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: BottomNavigationBar(
              currentIndex: selectedScreen,
              backgroundColor: BBColors.white,
              elevation: 0,
              onTap: (value) {
                setState(() {
                  previousScreen = selectedScreen;
                  selectedScreen = value;
                });
                if (value == 1) {
                  showSlidingPopup(
                    context,
                    learnPopUp,
                    onDismiss: () {
                      setState(() {
                        selectedScreen = previousScreen;
                      });
                    },
                  );
                } else if (value == 4) {
                  showExtraPopup(
                    context,
                    extraPopUP,
                    onDismiss: () {
                      setState(() {
                        selectedScreen = previousScreen;
                      });
                    },
                  );
                }
              },
              selectedLabelStyle: GoogleFonts.poppins(fontSize: 10),
              showUnselectedLabels: true,
              unselectedLabelStyle: GoogleFonts.poppins(fontSize: 10),
              unselectedItemColor: BBColors.bodyText,
              selectedItemColor: BBColors.bodyText,
              type: BottomNavigationBarType.fixed,
              items: [
                BottomNavigationBarItem(
                  icon: Image(
                    image: const AssetImage("assets/home.png"),
                    height: context.screenHeight * 0.025,
                    color:
                        selectedScreen == 0
                            ? BBColors.primaryColor
                            : BBColors.borderGray,
                  ),
                  label: "Home",
                ),
                BottomNavigationBarItem(
                  icon: Image(
                    image: const AssetImage("assets/open-book.png"),
                    height: context.screenHeight * 0.025,
                    color:
                        selectedScreen == 1
                            ? BBColors.primaryColor
                            : BBColors.borderGray,
                  ),
                  label: "Learn",
                ),
                BottomNavigationBarItem(
                  icon: Container(
                    height: context.screenHeight * 0.025,
                    width: context.screenHeight * 0.025,
                    color: Colors.transparent,
                  ),
                  label: '',
                ),
                BottomNavigationBarItem(
                  icon: Image(
                    image: const AssetImage("assets/presentation.png"),
                    height: context.screenHeight * 0.025,
                    color:
                        selectedScreen == 3
                            ? BBColors.primaryColor
                            : BBColors.borderGray,
                  ),
                  label: "Class",
                ),
                BottomNavigationBarItem(
                  icon: Image(
                    image: const AssetImage("assets/badge.png"),
                    height: context.screenHeight * 0.025,
                    color:
                        selectedScreen == 4
                            ? BBColors.primaryColor
                            : BBColors.borderGray,
                  ),
                  label: "Extras",
                ),
              ],
            ),
          ),

          Positioned(
            bottom: kBottomNavigationBarHeight - 45,
            left: MediaQuery.of(context).size.width / 2 - 35,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  previousScreen = selectedScreen;
                  selectedScreen = 2;
                });
              },
              child: Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,

                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Center(child: Image.asset('assets/Bot.png')),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
