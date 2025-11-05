import 'package:brainbee/presentation/views/bot/UI/bb_initial_bot_screen.dart';
import 'package:brainbee/presentation/views/class/UI/bb_class.dart';
import 'package:brainbee/presentation/views/extras/Rewards/UI/reward_catalog.dart';
import 'package:brainbee/presentation/views/extras/achievements/badges/UI/bb_badge_view.dart';
import 'package:brainbee/presentation/views/extras/bb_extrapopup.dart';
import 'package:brainbee/presentation/views/extras/coinquests/UI/bb_coin_quests.dart';
import 'package:brainbee/presentation/views/extras/leaderboard/bb_leaderboard.dart';
import 'package:brainbee/presentation/views/extras/score_&_reportcard/reportcard/bb_reportcard.dart';
import 'package:brainbee/presentation/views/extras/score_&_reportcard/scorecard/bb_scorecard.dart';
import 'package:brainbee/presentation/views/home/UI/bb_home.dart';
import 'package:brainbee/presentation/views/learn/Books/bb_select_book.dart';
import 'package:brainbee/presentation/views/learn/battle/UI/bb_book_selection.dart';
import 'package:brainbee/presentation/views/learn/bb_learn_popup.dart';
import 'package:brainbee/presentation/views/learn/flashcards/bb_selectBook_flashcards.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:brainbee/core/constants/bb_colors.dart';
import 'package:brainbee/core/utils/bb_screen_extension.dart';
import 'package:brainbee/presentation/views/home/bloc/student_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

class BBDashboard extends StatefulWidget {
  const BBDashboard({super.key});

  @override
  State<BBDashboard> createState() => _BBDashboardState();
}

class _BBDashboardState extends State<BBDashboard>
    with TickerProviderStateMixin {
  int selectedScreen = 0;
  int previousScreen = 0;
  List<Widget> dashBoardScreens = [];

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

  // This will be populated in the build method with the actual userId
  List<Map<String, dynamic>> extraPopUP = [];

  late AnimationController _shimmerController;
  late Animation<double> _shimmerAnimation;

  @override
  void initState() {
    super.initState();

    context.read<StudentBloc>().add(StudentFetchData());

    // Initialize shimmer animation
    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _shimmerAnimation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.easeInOut),
    );
    _shimmerController.repeat();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  // Helper method to build extraPopUP list with userId
  List<Map<String, dynamic>> _buildExtraPopUp(String userId) {
    return [
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
        'navigateTo': BBCoinQuestScreen(userId: userId),
      },
      {
        'title': 'Badges',
        'imgPath': 'assets/text-book.png',
        'navigateTo': BadgesScreen(studentId: userId),
      },
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<StudentBloc, StudentState>(
        listener: (context, state) {
          if (state is StudentDataError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error loading student data'),
                backgroundColor: Colors.red,
                action: SnackBarAction(
                  label: 'Retry',
                  onPressed: () {
                    context.read<StudentBloc>().add(StudentFetchData());
                  },
                ),
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is StudentDataLoading) {
            return _buildShimmerUI();
          } else if (state is StudentDataLoaded) {
            print("updated goal is ${state.student.toJson()}");

            // Build extraPopUP with the actual userId
            extraPopUP = _buildExtraPopUp(state.student.id);

            dashBoardScreens = [
              BBhome(student: state.student),
              BBhome(student: state.student),
              const BbInitialBotScreen(),
              const BBClass(),
              BBhome(student: state.student),
            ];
            return _buildActualDashboard(state);
          } else if (state is StudentDataError) {
            return _buildErrorScreen(state.message);
          }

          return _buildShimmerUI();
        },
      ),
    );
  }

  Widget _buildShimmerUI() {
    return Stack(
      children: [
        // Shimmer content area
        Positioned.fill(
          bottom: kBottomNavigationBarHeight,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: MediaQuery.of(context).padding.top + 16),

                // Header section
                Row(
                  children: [
                    _buildShimmerContainer(
                      height: 50,
                      width: 50,
                      isCircular: true,
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildShimmerContainer(height: 20, width: 120),
                          SizedBox(height: 8),
                          _buildShimmerContainer(height: 16, width: 200),
                        ],
                      ),
                    ),
                    _buildShimmerContainer(
                      height: 40,
                      width: 40,
                      isCircular: true,
                    ),
                  ],
                ),

                SizedBox(height: 24),

                // Progress/Stats cards
                Row(
                  children: [
                    Expanded(child: _buildShimmerCard(height: 100)),
                    SizedBox(width: 12),
                    Expanded(child: _buildShimmerCard(height: 100)),
                  ],
                ),

                SizedBox(height: 20),

                // Quick actions section
                _buildShimmerContainer(height: 24, width: 150),
                SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(child: _buildShimmerCard(height: 80)),
                    SizedBox(width: 8),
                    Expanded(child: _buildShimmerCard(height: 80)),
                    SizedBox(width: 8),
                    Expanded(child: _buildShimmerCard(height: 80)),
                  ],
                ),

                SizedBox(height: 20),

                // Recent activity section
                _buildShimmerContainer(height: 24, width: 180),
                SizedBox(height: 16),

                _buildShimmerCard(height: 120),
                SizedBox(height: 12),
                _buildShimmerCard(height: 120),
                SizedBox(height: 12),
                _buildShimmerCard(height: 120),

                SizedBox(height: 100), // Extra space for floating button
              ],
            ),
          ),
        ),

        // Bottom navigation with shimmer
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Container(
            height: kBottomNavigationBarHeight,
            decoration: BoxDecoration(
              color: BBColors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(5, (index) {
                if (index == 2) {
                  // Empty space for floating button
                  return SizedBox(width: 70);
                }
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildShimmerContainer(height: 24, width: 24),
                    SizedBox(height: 4),
                    _buildShimmerContainer(height: 10, width: 40),
                  ],
                );
              }),
            ),
          ),
        ),

        // Floating button shimmer
        Positioned(
          bottom: kBottomNavigationBarHeight - 45,
          left: MediaQuery.of(context).size.width / 2 - 35,
          child: _buildShimmerContainer(
            height: 70,
            width: 70,
            isCircular: true,
          ),
        ),
      ],
    );
  }

  Widget _buildShimmerCard({required double height}) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: AnimatedBuilder(
          animation: _shimmerAnimation,
          builder: (context, child) {
            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Colors.grey[200]!,
                    Colors.grey[100]!,
                    Colors.grey[200]!,
                  ],
                  stops:
                      [
                        _shimmerAnimation.value - 0.3,
                        _shimmerAnimation.value,
                        _shimmerAnimation.value + 0.3,
                      ].map((stop) => stop.clamp(0.0, 1.0)).toList(),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildShimmerContainer({
    required double height,
    required double width,
    bool isCircular = false,
  }) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius:
            isCircular
                ? BorderRadius.circular(height / 2)
                : BorderRadius.circular(8),
      ),
      child: ClipRRect(
        borderRadius:
            isCircular
                ? BorderRadius.circular(height / 2)
                : BorderRadius.circular(8),
        child: AnimatedBuilder(
          animation: _shimmerAnimation,
          builder: (context, child) {
            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Colors.grey[200]!,
                    Colors.grey[100]!,
                    Colors.grey[200]!,
                  ],
                  stops:
                      [
                        _shimmerAnimation.value - 0.3,
                        _shimmerAnimation.value,
                        _shimmerAnimation.value + 0.3,
                      ].map((stop) => stop.clamp(0.0, 1.0)).toList(),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildActualDashboard(StudentDataLoaded state) {
    return Stack(
      children: [
        Positioned.fill(
          bottom: kBottomNavigationBarHeight,
          child:
              selectedScreen == 0 || selectedScreen == 3 || selectedScreen == 2
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
    );
  }

  Widget _buildErrorScreen(String message) {
    print("Error occurred: $message");
    return Container(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.error_outline, size: 60, color: Colors.red),
            ),
            SizedBox(height: 24),
            Text(
              'Oops! Something went wrong',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 12),
            Text(
              message.isEmpty ? 'Unable to load student data' : message,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                color: Colors.grey[600],
                fontSize: 16,
                height: 1.5,
              ),
            ),
            SizedBox(height: 32),
            Container(
              width: double.infinity,
              constraints: BoxConstraints(maxWidth: 200),
              child: ElevatedButton(
                onPressed: () {
                  context.read<StudentBloc>().add(StudentFetchData());
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: BBColors.primaryColor,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Try Again',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
