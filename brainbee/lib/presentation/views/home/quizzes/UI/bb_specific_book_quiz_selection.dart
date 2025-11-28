import 'package:brainbee/core/constants/bb_colors.dart';
import 'package:brainbee/core/widgets/quiz%20generation/bb_chapter_card.dart';
import 'package:brainbee/presentation/views/dashboard/UI/bb_progress_bar.dart';
import 'package:brainbee/presentation/views/home/UI/bb_coin_popup.dart';
import 'package:brainbee/presentation/views/home/UI/bb_lives_popup.dart';
import 'package:brainbee/presentation/views/home/UI/bb_score_popup.dart';
import 'package:brainbee/presentation/views/home/UI/bb_streak_popup.dart';
import 'package:brainbee/presentation/views/home/bloc/student_bloc.dart';
import 'package:brainbee/presentation/views/home/models/bb_student_model.dart';
import 'package:brainbee/presentation/views/home/quizzes/bloc/quiz_bloc.dart';
import 'package:brainbee/presentation/views/home/quizzes/models/book_model.dart';
import 'package:brainbee/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BbSpecificBookQuizSelection extends StatefulWidget {
  final String bookId;
  final String subject;
  final StudentModel student;

  const BbSpecificBookQuizSelection({
    required this.bookId,
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

    print(
      "Selected subject in BbSpecificBookQuizSelection: ${widget.subject.split(" ")}",
    );

    final subject = widget.subject.split(" ").first;
    _displaySubject = subject;

    _desc = [
      widget.student.score.toString(),
      widget.student.coins.toString(),
      widget.student.streakScore.toString(),
      '${widget.student.dailyLives}/10',
    ];

    context.read<QuizBloc>().add(
      LoadSubjectQuizzes(subject: _displaySubject, grade: widget.student.grade),
    );
  }

  void _onTopicTap(Topic topic) {
    Navigator.pushNamed(
      context,
      AppRoutes.quizzesList,
      arguments: [topic, widget.student, widget.bookId],
    );
  }

  void _onSelectChapterTap() {
    Navigator.pushNamed(
      context,
      AppRoutes.chapterSelection,
      arguments: widget.student,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MultiBlocListener(
        listeners: [
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

          BlocListener<QuizBloc, QuizState>(
            listener: (context, state) {
              if (state is QuizStarted) {
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
              centerTitle: true,
              title: Text(
                _displaySubject,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              floating: false,
              backgroundColor: BBColors.secondaryColor,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () => Navigator.pop(context),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh, color: Colors.black),
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
                background: Container(color: BBColors.white),
                expandedTitleScale: 1,
                title: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 10),
                    _ProgressBarRow(
                      desc: _desc,
                      onPopupTap: (index) {
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
                if (state is BookDataLoading) {
                  return const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                if (state is BookDataLoaded) {
                  return SliverList.builder(
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return _ChapterSelectionHeader(
                          onTap: _onSelectChapterTap,
                        );
                      }

                      final chapterIndex = index - 1;
                      if (chapterIndex < state.bookData.chapters.length) {
                        return BbChapterCard.fromChapter(
                          chapter: state.bookData.chapters[chapterIndex],
                          onTopicTap: _onTopicTap,
                        );
                      }

                      return const SizedBox.shrink();
                    },
                    itemCount: state.bookData.chapters.length + 1,
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
