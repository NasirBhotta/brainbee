import 'package:brainbee/core/constants/bb_colors.dart';
import 'package:brainbee/presentation/views/dashboard/UI/bb_progress_bar.dart';
import 'package:brainbee/presentation/views/home/UI/bb_coin_popup.dart';
import 'package:brainbee/presentation/views/home/UI/bb_lives_popup.dart';
import 'package:brainbee/presentation/views/home/UI/bb_score_popup.dart';
import 'package:brainbee/presentation/views/home/UI/bb_streak_popup.dart';
import 'package:brainbee/presentation/views/home/bloc/student_bloc.dart';
import 'package:brainbee/presentation/views/home/models/bb_student_model.dart';
import 'package:brainbee/presentation/views/home/quizzes/bloc/quiz_bloc.dart';
import 'package:brainbee/presentation/views/home/quizzes/models/quiz_model.dart';
import 'package:brainbee/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BbSpecificBookQuizSelection extends StatefulWidget {
  final String subject;
  final StudentModel student; // Pass student data if needed

  const BbSpecificBookQuizSelection({
    super.key,
    required this.subject,
    required this.student,
  });

  @override
  State<BbSpecificBookQuizSelection> createState() =>
      _BbSpecificBookQuizSelectionState();
}

class _BbSpecificBookQuizSelectionState
    extends State<BbSpecificBookQuizSelection> {
  late final String _displaySubject;
  late List<String> _desc;

  @override
  void initState() {
    super.initState();
    _displaySubject = widget.subject;

    // Initialize with student data from StudentBloc
    _desc = [
      widget.student.score.toString(),
      widget.student.coins.toString(),
      widget.student.streakScore.toString(),
      '${widget.student.dailyLives}/10',
    ];

    // Load quiz chapters when screen initializes
    context.read<QuizBloc>().add(
      LoadSubjectQuizzes(subject: _displaySubject, grade: widget.student.grade),
    );
  }

  void _onChapterTap(String chapterId, String topicId) {
    // Start quiz directly without unlock mechanism
    // context.read<QuizBloc>().add(
    //   StartQuiz(chapterId: chapterId, topicId: topicId),
    // );
  }

  void _onSelectChapterTap() {
    // Navigate to chapter selection screen (you'll connect this later)
    // Navigator.pushNamed(context, AppRoutes.chapterSelection);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MultiBlocListener(
        listeners: [
          // Listen to StudentBloc for updates
          BlocListener<StudentBloc, StudentState>(
            listener: (context, state) {
              if (state is StudentDataLoaded) {
                setState(() {
                  _desc = [
                    state.student.score.toString(),
                    state.student.coins.toString(),
                    state.student.streakScore.toString(),
                    '${state.student.dailyLives}/10',
                  ];
                });
              }
            },
          ),
          // Listen to QuizBloc for navigation
          BlocListener<QuizBloc, QuizState>(
            listener: (context, state) {
              if (state is QuizStarted) {
                // Navigate to quiz taking screen
                Navigator.pushNamed(
                  context,
                  AppRoutes.quizTaking,
                  arguments: state.quiz,
                );
              } else if (state is QuizError) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(state.message)));
              }
            },
          ),
        ],
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 130,
              pinned: true,
              floating: false,
              backgroundColor: BBColors.secondaryColor, // Your subject color
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh, color: Colors.white),
                  onPressed: () {
                    context.read<QuizBloc>().add(
                      LoadSubjectQuizzes(
                        subject: _displaySubject,
                        grade: widget.student.grade,
                      ),
                    );
                  },
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: Container(color: BBColors.primaryColor),
                expandedTitleScale: 1,
                title: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _displaySubject,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _ProgressBarRow(
                      desc: _desc,
                      onPopupTap: (index) {
                        // You can still show popups using StudentBloc data
                        final studentState = context.read<StudentBloc>().state;
                        if (studentState is StudentDataLoaded) {
                          _onPopupTap(index, studentState);
                        }
                      },
                    ),
                  ],
                ),
                centerTitle: true,
              ),
            ),
            BlocBuilder<QuizBloc, QuizState>(
              builder: (context, state) {
                if (state is QuizLoading) {
                  return const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                if (state is QuizzesLoaded) {
                  return SliverList.builder(
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return _ChapterSelectionHeader(
                          onTap: _onSelectChapterTap,
                        );
                      }

                      final chapterIndex = index - 1;
                      if (chapterIndex < state.chapters.length) {
                        return _ChapterCard(
                          chapter: state.chapters[chapterIndex],
                          onTopicTap: _onChapterTap,
                        );
                      }

                      return const SizedBox.shrink();
                    },
                    itemCount: state.chapters.length + 1,
                  );
                }

                return const SliverFillRemaining(
                  child: Center(child: Text('No chapters available')),
                );
              },
            ),
          ],
        ),
      ),
    );
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
}

class _ProgressBarRow extends StatelessWidget {
  final List<String> desc;
  final void Function(int) onPopupTap;

  const _ProgressBarRow({required this.desc, required this.onPopupTap});

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

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(4, (index) {
        return BbProgressBar(
          color: _color[index],
          imgPath: _imgPath[index],
          desc: desc[index],
          index: index,
          onTap: () => onPopupTap(index),
        );
      }),
    );
  }
}

class _ChapterSelectionHeader extends StatelessWidget {
  final VoidCallback onTap;

  const _ChapterSelectionHeader({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: GestureDetector(
        onTap: onTap,
        child: Row(
          children: [
            Text(
              "Select Chapter to Generate Quizzes",
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
            ),
            const Spacer(),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey.shade400,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}

class _ChapterCard extends StatelessWidget {
  final ParsedChapter chapter;
  final void Function(String chapterId, String topicId) onTopicTap;

  const _ChapterCard({required this.chapter, required this.onTopicTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ExpansionTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: chapter.color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(chapter.icon, color: chapter.color, size: 24),
        ),
        title: Text(
          chapter.chapterTitle,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          "Read More...",
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: BBColors.secondaryColor),
        ),
        children:
            chapter.topics.map((topic) {
              return ListTile(
                leading: const CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.grey,
                  child: Text(
                    "?",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Text(topic.topicTitle),
                // Remove the coin icon and start button
                onTap: () => onTopicTap(chapter.chapterTitle, topic.topicKey),
              );
            }).toList(),
      ),
    );
  }
}

// Models for your quiz data structure
class QuizChapter {
  final String id;
  final String title;
  final IconData icon;
  final Color color;
  final List<QuizTopic> topics;

  QuizChapter({
    required this.id,
    required this.title,
    required this.icon,
    required this.color,
    required this.topics,
  });
}

class QuizTopic {
  final String id;
  final String name;

  QuizTopic({required this.id, required this.name});
}
