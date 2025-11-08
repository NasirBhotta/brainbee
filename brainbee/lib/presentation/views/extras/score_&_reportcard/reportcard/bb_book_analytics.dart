// lib/presentation/views/extras/reportcard/bb_book_analytics.dart

import 'package:brainbee/core/constants/bb_colors.dart';
import 'package:brainbee/core/utils/bb_screen_extension.dart';
import 'package:brainbee/core/utils/bb_text.dart';
import 'package:brainbee/core/utils/bb_textTheme_extention.dart';
import 'package:brainbee/presentation/views/extras/score_&_reportcard/scorecard/bloc/book_score_bloc.dart';
import 'package:brainbee/presentation/views/extras/score_&_reportcard/scorecard/model/bb_spefic_book_score_model.dart';
import 'package:brainbee/presentation/views/extras/score_&_reportcard/scorecard/repo/score_repo_impl.dart';
import 'package:brainbee/presentation/views/extras/score_&_reportcard/scorecard/services/score_api_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class BBBookAnalytics extends StatelessWidget {
  final String bookId;
  final String bookTitle;

  const BBBookAnalytics({
    super.key,
    required this.bookId,
    required this.bookTitle,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create:
          (context) => BookScoreBloc(
            repository: ScoreRepositoryImpl(apiService: ScoreApiService()),
          )..add(LoadBookScore(bookId)),
      child: _BBBookAnalyticsContent(bookTitle: bookTitle),
    );
  }
}

class _BBBookAnalyticsContent extends StatelessWidget {
  final String bookTitle;

  const _BBBookAnalyticsContent({required this.bookTitle});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: BBColors.lightGrayBG,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back),
        ),
        title: BBText(
          data: "Analytics for $bookTitle",
          style: context.textStyle.titleMedium,
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            width: context.screenWidth,
            height: 1,
            color: BBColors.borderGray,
          ),
        ),
      ),
      body: BlocBuilder<BookScoreBloc, BookScoreState>(
        builder: (context, state) {
          if (state is BookScoreLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is BookScoreError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: BBColors.alertRed,
                  ),
                  const SizedBox(height: 16),
                  const Text("Failed to load analytics"),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed:
                        () => context.read<BookScoreBloc>().add(
                          LoadBookScore(bookTitle),
                        ),
                    child: const Text("Retry"),
                  ),
                ],
              ),
            );
          }

          if (state is BookScoreLoaded) {
            return _buildBody(context, state.data);
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, BookScoreData data) {
    // Calculate difficulty breakdown from quiz scores
    final difficultyData = _calculateDifficultyBreakdownWithCount(data);

    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: context.screenWidth * 0.05,
          vertical: 16,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BBText(data: data.title, style: context.textStyle.titleLarge),
            const SizedBox(height: 8),
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: _getGradeFromScore(data.averageScore),
                    style: context.textStyle.displayLarge,
                  ),
                  WidgetSpan(
                    child: SizedBox(width: context.screenWidth * 0.02),
                  ),
                  TextSpan(
                    text: "${data.averageScore}%",
                    style: context.textStyle.headlineLarge?.copyWith(
                      fontSize: 22,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            BBText(
              data: "${data.quizzesCompleted} Quizzes Completed",
              style: context.textStyle.labelSmall?.copyWith(
                fontSize: 10,
                color: BBColors.disabledText,
                letterSpacing: -0.1,
              ),
            ),
            BBText(
              data: "${data.totalActivities} Total Activities",
              style: context.textStyle.labelSmall?.copyWith(
                fontSize: 10,
                color: BBColors.disabledText,
                letterSpacing: -0.1,
              ),
            ),
            const SizedBox(height: 24),
            Align(
              alignment: Alignment.center,
              child: BBText(
                data: "RESULTS BY DIFFICULTY",
                style: context.textStyle.labelSmall?.copyWith(letterSpacing: 1),
              ),
            ),
            const SizedBox(height: 8),
            _buildDifficultyChart(difficultyData),
            const SizedBox(height: 16),
            _buildDifficultyLegend(context, difficultyData),
            const SizedBox(height: 32),
            Align(
              alignment: Alignment.center,
              child: BBText(
                data: "PERFORMANCE BY CHAPTER",
                style: context.textStyle.labelSmall?.copyWith(letterSpacing: 1),
              ),
            ),
            const SizedBox(height: 16),
            _buildChapterScoresList(data.chapterScores),
          ],
        ),
      ),
    );
  }

  Widget _buildDifficultyChart(List<QuizDifficultyWithCount> data) {
    return SizedBox(
      height: 200,
      child: SfCircularChart(
        margin: EdgeInsets.zero,
        series: <CircularSeries>[
          RadialBarSeries<QuizDifficultyWithCount, String>(
            gap: '1.5',
            maximumValue: 100,
            cornerStyle: CornerStyle.bothCurve,
            dataSource: data,
            xValueMapper: (QuizDifficultyWithCount data, _) => data.difficulty,
            yValueMapper: (QuizDifficultyWithCount data, _) => data.percentage,
            pointColorMapper: (QuizDifficultyWithCount data, _) => data.color,
            radius: '80%',
            innerRadius: '60%',
            trackOpacity: 0.1,
          ),
        ],
      ),
    );
  }

  Widget _buildChapterScoresList(List<ChapterScoreData> chapters) {
    if (chapters.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Text("No chapter data available"),
        ),
      );
    }

    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: chapters.length,
      itemBuilder: (context, index) {
        final chapter = chapters[index];
        final status = _getMasteryStatus(chapter.score);

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              _getMasteryColor(status).withValues(alpha: 0.8),
                              _getMasteryColor(status),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: BBText(
                            data: chapter.chapterNumber.toString(),
                            style: context.textStyle.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            BBText(
                              data: chapter.title,
                              style: context.textStyle.labelMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: _getMasteryColor(status),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                BBText(
                                  data: status,
                                  style: context.textStyle.labelSmall?.copyWith(
                                    color: _getMasteryColor(status),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      _buildScoreCircle(context, chapter.score),
                    ],
                  ),
                ),
                Container(
                  height: 4,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        _getMasteryColor(status).withValues(alpha: 0.6),
                        _getMasteryColor(status),
                      ],
                      stops: [0.0, chapter.score / 100],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildScoreCircle(BuildContext context, int score) {
    final color = _getScoreColor(score);
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        border: Border.all(color: color.withValues(alpha: 0.2), width: 3),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 4,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 50,
            height: 50,
            child: CircularProgressIndicator(
              value: score / 100,
              strokeWidth: 3,
              backgroundColor: Colors.grey.withValues(alpha: 0.1),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
          BBText(
            data: "$score%",
            style: context.textStyle.labelSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  // Helper methods
  String _getGradeFromScore(int score) {
    if (score >= 90) return "A+";
    if (score >= 80) return "A";
    if (score >= 70) return "B+";
    if (score >= 60) return "B";
    if (score >= 50) return "C+";
    if (score >= 40) return "C";
    if (score >= 30) return "D";
    return "F";
  }

  Color _getScoreColor(int score) {
    if (score >= 80) return BBColors.successGreen;
    if (score >= 60) return BBColors.orangeAccent;
    return BBColors.alertRed;
  }

  String _getMasteryStatus(int score) {
    if (score >= 80) return 'Mastered';
    if (score >= 60) return 'In Progress';
    return 'Needs Work';
  }

  Color _getMasteryColor(String status) {
    switch (status) {
      case 'Mastered':
        return BBColors.successGreen;
      case 'In Progress':
        return BBColors.orangeAccent;
      case 'Needs Work':
        return BBColors.alertRed;
      default:
        return BBColors.disabledText;
    }
  }

  // Calculate difficulty breakdown from quiz scores
  // Since backend doesn't provide difficulty levels, we'll estimate:
  // 80-100: Easy, 60-79: Medium, 0-59: Hard
  // Calculate difficulty breakdown from quiz scores with actual difficulty targets
  Widget _buildDifficultyLegend(
    BuildContext context,
    List<QuizDifficultyWithCount> data,
  ) {
    final difficultyData = data;

    return Column(
      children:
          difficultyData.map((item) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Container(
                    height: 10,
                    width: 10,
                    decoration: BoxDecoration(
                      color: item.color,
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  const SizedBox(width: 8),
                  BBText(
                    data: item.difficulty,
                    style: context.textStyle.labelMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 4),
                  BBText(
                    data: "(${item.count})",
                    style: context.textStyle.labelSmall?.copyWith(
                      color: BBColors.disabledText,
                    ),
                  ),
                  const Spacer(),
                  BBText(
                    data: "${item.percentage}%",
                    style: context.textStyle.labelMedium?.copyWith(
                      fontWeight: FontWeight.w200,
                      color: item.color,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
    );
  }

  // Enhanced difficulty calculation with counts
  List<QuizDifficultyWithCount> _calculateDifficultyBreakdownWithCount(
    BookScoreData data,
  ) {
    Map<String, List<int>> difficultyScores = {
      'easy': [],
      'medium': [],
      'hard': [],
    };

    for (var chapter in data.chapterScores) {
      for (var quiz in chapter.quizScores) {
        final difficulty = quiz.difficultyTarget.toLowerCase();
        if (difficultyScores.containsKey(difficulty)) {
          difficultyScores[difficulty]!.add(quiz.score);
        }
      }
    }

    int calculateAverage(List<int> scores) {
      if (scores.isEmpty) return 0;
      return (scores.reduce((a, b) => a + b) / scores.length).round();
    }

    return [
      QuizDifficultyWithCount(
        'Easy',
        calculateAverage(difficultyScores['easy']!),
        BBColors.successGreen,
        difficultyScores['easy']!.length,
      ),
      QuizDifficultyWithCount(
        'Medium',
        calculateAverage(difficultyScores['medium']!),
        BBColors.orangeAccent,
        difficultyScores['medium']!.length,
      ),
      QuizDifficultyWithCount(
        'Hard',
        calculateAverage(difficultyScores['hard']!),
        BBColors.alertRed,
        difficultyScores['hard']!.length,
      ),
    ];
  }
}

class QuizDifficultyWithCount {
  final String difficulty;
  final int percentage;
  final Color color;
  final int count;

  QuizDifficultyWithCount(
    this.difficulty,
    this.percentage,
    this.color,
    this.count,
  );
}
