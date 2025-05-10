import 'package:brainbee/core/constants/bb_colors.dart';
import 'package:brainbee/core/utils/bb_screen_extension.dart';

import 'package:brainbee/presentation/views/class/bb_class.dart';
import 'package:brainbee/presentation/views/extras/bb_extrapopup.dart';

import 'package:brainbee/presentation/views/home/bb_home.dart';
import 'package:brainbee/presentation/views/learn/bb_learn_popup.dart';
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
    const BBClass(),
    const BBhome(),
  ];
  List<Map<String, String>> learnPopUp = [
    {'title': 'Battle', 'imgPath': 'assets/battle.png'},
    {'title': 'Practice', 'imgPath': 'assets/exercise.png'},
    {'title': 'FlashCards', 'imgPath': 'assets/flash-card.png'},
    {'title': 'Books', 'imgPath': 'assets/text-book.png'},
  ];
  List<Map<String, String>> extraPopUP = [
    {'title': 'Score', 'imgPath': 'assets/battle.png'},
    {'title': 'Report Card', 'imgPath': 'assets/exercise.png'},
    {'title': 'Leaderboard', 'imgPath': 'assets/flash-card.png'},
    {'title': 'Rewards', 'imgPath': 'assets/text-book.png'},
    {'title': 'Coin Quests', 'imgPath': 'assets/text-book.png'},
    {'title': 'Badges', 'imgPath': 'assets/text-book.png'},
    {'title': 'Certificates', 'imgPath': 'assets/text-book.png'},
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
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
          } else if (value == 3) {
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
                      : BBColors.darkHeading,
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
                      : BBColors.darkHeading,
            ),
            label: "Learn",
          ),
          BottomNavigationBarItem(
            icon: Image(
              image: const AssetImage("assets/presentation.png"),
              height: context.screenHeight * 0.025,
              color:
                  selectedScreen == 2
                      ? BBColors.primaryColor
                      : BBColors.darkHeading,
            ),
            label: "Class",
          ),
          BottomNavigationBarItem(
            icon: Image(
              image: const AssetImage("assets/badge.png"),
              height: context.screenHeight * 0.025,
              color:
                  selectedScreen == 3
                      ? BBColors.primaryColor
                      : BBColors.darkHeading,
            ),
            label: "Extras",
          ),
        ],
      ),
      body:
          selectedScreen == 0 || selectedScreen == 2
              ? dashBoardScreens[selectedScreen]
              : dashBoardScreens[previousScreen],
    );
  }
}
