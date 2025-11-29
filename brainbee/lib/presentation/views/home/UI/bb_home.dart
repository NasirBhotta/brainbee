import 'dart:ui';

import 'package:brainbee/core/constants/bb_colors.dart';
import 'package:brainbee/core/utils/bb_screen_extension.dart';
import 'package:brainbee/core/utils/bb_text.dart';
import 'package:brainbee/core/utils/bb_textTheme_extention.dart';
import 'package:brainbee/core/utils/helper/bb_getinitials.dart';
import 'package:brainbee/core/utils/helper/bb_time_greeting.dart';
import 'package:brainbee/presentation/views/dashboard/UI/bb_progress_bar.dart';
import 'package:brainbee/presentation/views/dashboard/UI/bb_quizzes_display.dart';
import 'package:brainbee/presentation/views/home/UI/bb_coin_popup.dart';
import 'package:brainbee/presentation/views/home/UI/bb_lives_popup.dart';
import 'package:brainbee/presentation/views/home/UI/bb_notification_center.dart';
import 'package:brainbee/presentation/views/home/UI/bb_score_popup.dart';
import 'package:brainbee/presentation/views/home/UI/bb_streak_popup.dart';
import 'package:brainbee/presentation/views/home/bloc/student_bloc.dart';
import 'package:brainbee/presentation/views/home/models/bb_student_model.dart';
import 'package:brainbee/presentation/views/settings/UI/bb_settings.dart';
import 'package:brainbee/presentation/views/settings/model/book_model.dart';
import 'package:brainbee/presentation/views/extras/score_&_reportcard/scorecard/bloc/book_score_bloc.dart';
import 'package:brainbee/presentation/views/extras/score_&_reportcard/scorecard/repo/score_repo_impl.dart';
import 'package:brainbee/presentation/views/extras/score_&_reportcard/scorecard/services/score_api_service.dart';
import 'package:brainbee/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BBhome extends StatefulWidget {
  final StudentModel student;
  const BBhome({super.key, required this.student});

  @override
  State<BBhome> createState() => _BBhomeState();
}

class _BBhomeState extends State<BBhome> {
  late String _greeting;

  // Static data for visual assets mapping
  static const Map<String, Map<String, dynamic>> _subjectAssets = {
    'mathematics': {
      'imagePath1': 'assets/bg1.png',
      'imagePath2': 'assets/quiz1.png',
      'color': BBColors.progressColor1,
    },
    'physics': {
      'imagePath1': 'assets/bg2.png',
      'imagePath2': 'assets/quiz2.png',
      'color': BBColors.progressColor2,
    },
    'chemistry': {
      'imagePath1': 'assets/bg4.png',
      'imagePath2': 'assets/quiz4.png',
      'color': BBColors.progressColor4,
    },
    'biology': {
      'imagePath1': 'assets/bg3.png',
      'imagePath2': 'assets/quiz3.png',
      'color': BBColors.progressColor3,
    },
  };

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

  late List<String> _desc;
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

    // ✅ Set initial greeting based on current time
    _greeting = TimeGreeting.getGreeting();

    // ✅ Optional: Update greeting every minute
    _startGreetingTimer();
  }

  // ✅ Timer to update greeting automatically
  void _startGreetingTimer() {
    // Update greeting every minute to catch time changes
    Future.delayed(const Duration(minutes: 1), () {
      if (mounted) {
        setState(() {
          _greeting = TimeGreeting.getGreeting();
        });
        _startGreetingTimer(); // Restart timer
      }
    });
  }

  void _onPopupTap(int index, StudentDataLoaded state) {
    switch (index) {
      case 0:
        showScoreGoalsPopup(context, state.student);
        break;
      case 1:
        showCoinsPopup(context, state.student);
        break;
      case 2:
        showStreakPopup(context, state.student.streakScore.toString());
        break;
      case 3:
        showLivesPopup(context, state.student.dailyLives.toString());
        break;
    }
  }

  // Helper method to get asset mapping for a subject
  Map<String, dynamic> _getSubjectAssets(String bookTitle) {
    final titleLower = bookTitle.toLowerCase();

    // Check each subject keyword
    for (var entry in _subjectAssets.entries) {
      if (titleLower.contains(entry.key)) {
        return entry.value;
      }
    }

    // Default fallback
    return {
      'imagePath1': 'assets/bg1.png',
      'imagePath2': 'assets/quiz1.png',
      'color': BBColors.progressColor1,
    };
  }

  // Helper method to calculate quiz completion percentage

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create:
          (context) => BookScoreBloc(
            repository: ScoreRepositoryImpl(apiService: ScoreApiService()),
          )..add(LoadOverallScore()),
      child: BlocConsumer<StudentBloc, StudentState>(
        listener: (context, state) {
          if (state is StudentDataError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, studentState) {
          if (studentState is StudentDataLoaded) {
            _desc = [
              studentState.student.score.toString(),
              studentState.student.coins.toString(),
              studentState.student.streakScore.toString(),
              '∞/∞',
            ];
          }

          return RefreshIndicator.adaptive(
            onRefresh: () {
              return Future.delayed(const Duration(milliseconds: 500), () {
                context.read<StudentBloc>().add(StudentFetchData());
                context.read<BookScoreBloc>().add(RefreshOverallScore());
              });
            },
            child: CustomScrollView(
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
                          greeting: _greeting,
                        ),
                        expandedTitleScale: 1,
                        title: _ProgressBarRow(
                          desc: _desc,
                          onPopupTap: (index) {
                            if (studentState is StudentDataLoaded) {
                              _onPopupTap(index, studentState);
                            }
                          },
                        ),
                        centerTitle: true,
                      ),
                    ),
                  ),
                ),
                if (studentState is StudentDataLoaded)
                  _buildDynamicContent(studentState)
                else
                  SliverToBoxAdapter(
                    child: const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDynamicContent(StudentDataLoaded studentState) {
    return BlocBuilder<BookScoreBloc, BookScoreState>(
      builder: (context, scoreState) {
        return SliverList(
          delegate: SliverChildBuilderDelegate((context, index) {
            // First item - Promotion Card
            if (index == 0) {
              return _PromotionCard(studentState);
            }

            // Subsequent items - Book Cards
            final bookIndex = index - 1;

            if (bookIndex < studentState.student.selectedBooks.length) {
              final book = studentState.student.selectedBooks[bookIndex];
              final assets = _getSubjectAssets(book.bookTitle);

              // Get score data if available
              int? averageScore;
              int? quizzesCompleted;
              int? totalQuizzes;

              if (scoreState is OverallScoreLoaded) {
                final subjectScore = scoreState.data.subjectScores.firstWhere(
                  (s) => s.id == book.id,
                  orElse: () => null as dynamic,
                );

                averageScore = subjectScore.averageScore; // ✅ Use averageScore
                quizzesCompleted = subjectScore.completed;
                totalQuizzes = subjectScore.total;
              }

              return _DynamicBookCard(
                bookId: book.id,
                title: book.bookTitle,
                description: 'Start your learning journey',
                imagePath1: assets['imagePath1']!,
                imagePath2: assets['imagePath2']!,
                color: assets['color']!,
                score: averageScore, // ✅ Pass averageScore
                quizzesCompleted: quizzesCompleted,
                totalQuizzes: totalQuizzes,
                isLoading: scoreState is OverallScoreLoading,
              );
            }

            // Show empty state if no books registered
            if (bookIndex == 0 && studentState.student.selectedBooks.isEmpty) {
              return _EmptyBooksState();
            }

            return null;
          }, childCount: studentState.student.selectedBooks.length + 1),
        );
      },
    );
  }
}

// Extracted widgets for better performance and cleaner code
class _AppBarBackground extends StatelessWidget {
  final String displayName;
  final String initials;
  final String greeting;
  const _AppBarBackground({
    required this.displayName,
    required this.initials,
    required this.greeting,
  });

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
                greeting,
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
  final StudentDataLoaded state;
  const _PromotionCard(this.state);

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
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          AppRoutes.coinQuests,
                          arguments: state.student.id,
                        );
                      },
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

class _DynamicBookCard extends StatelessWidget {
  final String bookId;
  final String title;
  final String description;
  final String imagePath1;
  final String imagePath2;
  final Color color;
  final int? score;
  final int? quizzesCompleted;
  final int? totalQuizzes;
  final bool isLoading;

  const _DynamicBookCard({
    required this.bookId,
    required this.title,
    required this.description,
    required this.imagePath1,
    required this.imagePath2,
    required this.color,
    this.score,
    this.quizzesCompleted,
    this.totalQuizzes,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Score and Quiz stats row above the card
          if ((score != null || quizzesCompleted != null) && !isLoading)
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 8, right: 4),
              child: Row(
                children: [
                  // Score badge
                  // if (score != null)
                  //   Container(
                  //     padding: const EdgeInsets.symmetric(
                  //       horizontal: 12,
                  //       vertical: 6,
                  //     ),
                  //     decoration: BoxDecoration(
                  //       color: _getScoreColor(score!),
                  //       borderRadius: BorderRadius.circular(20),
                  //       boxShadow: [
                  //         BoxShadow(
                  //           color: _getScoreColor(score!).withOpacity(0.3),
                  //           blurRadius: 4,
                  //           offset: const Offset(0, 2),
                  //         ),
                  //       ],
                  //     ),
                  //     child: Row(
                  //       mainAxisSize: MainAxisSize.min,
                  //       children: [
                  //         const Icon(Icons.star, color: Colors.white, size: 14),
                  //         const SizedBox(width: 4),
                  //         Text(
                  //           "$score%",
                  //           style: const TextStyle(
                  //             color: Colors.white,
                  //             fontWeight: FontWeight.bold,
                  //             fontSize: 12,
                  //           ),
                  //         ),
                  //       ],
                  //     ),
                  //   ),
                  if (score != null && quizzesCompleted != null)
                    const SizedBox(width: 8),

                  // Quiz completion badge
                  // if (quizzesCompleted != null && totalQuizzes != null)
                  //   Container(
                  //     padding: const EdgeInsets.symmetric(
                  //       horizontal: 12,
                  //       vertical: 6,
                  //     ),
                  //     decoration: BoxDecoration(
                  //       color: Colors.white,
                  //       borderRadius: BorderRadius.circular(20),
                  //       border: Border.all(color: color, width: 1.5),
                  //       boxShadow: [
                  //         BoxShadow(
                  //           color: Colors.black.withOpacity(0.05),
                  //           blurRadius: 4,
                  //           offset: const Offset(0, 2),
                  //         ),
                  //       ],
                  //     ),
                  //     child: Row(
                  //       mainAxisSize: MainAxisSize.min,
                  //       children: [
                  //         Icon(Icons.quiz_outlined, color: color, size: 14),
                  //         const SizedBox(width: 4),
                  //         Text(
                  //           "$quizzesCompleted/$totalQuizzes Quizzes",
                  //           style: TextStyle(
                  //             color: color,
                  //             fontWeight: FontWeight.w600,
                  //             fontSize: 11,
                  //           ),
                  //         ),
                  //       ],
                  //     ),
                  //   ),
                  const Spacer(),

                  // Quiz completion percentage (not total score)
                ],
              ),
            ),

          // Loading indicator
          if (isLoading)
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 8),
              child: Row(
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "Loading progress...",
                    style: TextStyle(color: Colors.grey[600], fontSize: 11),
                  ),
                ],
              ),
            ),

          // Base card with BbQuizzesDisplay
          BbQuizzesDisplay(
            bookId: bookId,
            title: title,
            description: description,
            imagePath1: imagePath1,
            imagePath2: imagePath2,
            color: color,
            score: score,
            progress:
                totalQuizzes != null && totalQuizzes! > 0
                    ? (quizzesCompleted ?? 0) / totalQuizzes!
                    : 0.0,
            quizzesCompleted: quizzesCompleted,
            totalQuizzes: totalQuizzes,
          ),
        ],
      ),
    );
  }

  Color _getScoreColor(int score) {
    if (score >= 80) return BBColors.successGreen;
    if (score >= 60) return BBColors.orangeAccent;
    return BBColors.alertRed;
  }

  // Helper to calculate completion percentage for the card
  int _getCompletionPercentage(int? completed, int? total) {
    if (completed == null || total == null || total == 0) return 0;
    return ((completed / total) * 100).round();
  }
}

class _EmptyBooksState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: Colors.blue[50],
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.school_outlined, size: 64, color: Colors.blue[400]),
            const SizedBox(height: 16),
            BBText(
              data: "No Subjects Registered",
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.blue[700],
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            BBText(
              data: "Please register your subjects to start taking quizzes",
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: Colors.blue[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
