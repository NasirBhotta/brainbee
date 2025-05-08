import 'package:brainbee/core/constants/bb_colors.dart';
import 'package:brainbee/core/utils/bb_screen_extension.dart';
import 'package:brainbee/core/utils/bb_text.dart';
import 'package:brainbee/core/utils/bb_textTheme_extention.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class BBBookAnalytics extends StatefulWidget {
  const BBBookAnalytics({super.key});

  @override
  State<BBBookAnalytics> createState() => _BBBookAnalyticsState();
}

class _BBBookAnalyticsState extends State<BBBookAnalytics> {
  late List<QuizDifficulty> _difficultyChartData;
  late List<ChapterScore> _chapterScoreData;

  @override
  void initState() {
    super.initState();
    _difficultyChartData = _getDifficultyData();
    _chapterScoreData = _getChapterScoreData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: BBColors.lightGrayBG,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back),
        ),
        title: BBText(
          data: "Analytics for Mathematics",
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
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: context.screenWidth * 0.05,
          vertical: 16,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: "Mathematics", // add subject variable here
                    style: context.textStyle.titleLarge,
                  ),
                  WidgetSpan(
                    child: SizedBox(width: context.screenWidth * 0.02),
                  ),
                  TextSpan(text: "year 6", style: context.textStyle.labelSmall),
                ],
              ),
            ),
            const SizedBox(height: 8),
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: "A", // add grade variable here
                    style: context.textStyle.displayLarge,
                  ),
                  WidgetSpan(
                    child: SizedBox(width: context.screenWidth * 0.02),
                  ),
                  TextSpan(
                    text: "80%",
                    style: context.textStyle.headlineLarge?.copyWith(
                      fontSize: 22,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: "10", // add grade variable here
                    style: context.textStyle.labelSmall?.copyWith(
                      fontSize: 10,
                      color: BBColors.disabledText,
                      letterSpacing: -0.1,
                    ),
                  ),
                  WidgetSpan(
                    child: SizedBox(width: context.screenWidth * 0.01),
                  ),
                  TextSpan(
                    text: "Questions Answered",
                    style: context.textStyle.labelSmall?.copyWith(
                      fontSize: 10,
                      color: BBColors.disabledText,
                      letterSpacing: -0.1,
                    ),
                  ),
                ],
              ),
            ),
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: "2", // add grade variable here
                    style: context.textStyle.labelSmall?.copyWith(
                      fontSize: 10,
                      color: BBColors.disabledText,
                      letterSpacing: -0.1,
                    ),
                  ),
                  WidgetSpan(
                    child: SizedBox(width: context.screenWidth * 0.01),
                  ),
                  TextSpan(
                    text: "Sets Submitted",
                    style: context.textStyle.labelSmall?.copyWith(
                      fontSize: 10,
                      color: BBColors.disabledText,
                      letterSpacing: -0.1,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Results by Difficulty Section
            Align(
              alignment: Alignment.center,
              child: BBText(
                data: "RESULTS BY DIFFICULTY",
                style: context.textStyle.labelSmall?.copyWith(letterSpacing: 1),
              ),
            ),
            const SizedBox(height: 8),
            _buildDifficultyChart(),
            const SizedBox(height: 16),
            _buildDifficultyLegend(),
            const SizedBox(height: 32),
            // Chapter Performance Section
            Align(
              alignment: Alignment.center,
              child: BBText(
                data: "PERFORMANCE BY CHAPTER",
                style: context.textStyle.labelSmall?.copyWith(letterSpacing: 1),
              ),
            ),
            const SizedBox(height: 16),
            _buildChapterScoresList(),
          ],
        ),
      ),
    );
  }

  Widget _buildDifficultyChart() {
    return SizedBox(
      height: 200,
      child: SfCircularChart(
        margin: EdgeInsets.zero,
        series: <CircularSeries>[
          RadialBarSeries<QuizDifficulty, String>(
            gap: '1.5',
            maximumValue: 100,
            cornerStyle: CornerStyle.bothCurve,
            dataSource: _difficultyChartData,
            xValueMapper: (QuizDifficulty data, _) => data.difficulty,
            yValueMapper: (QuizDifficulty data, _) => data.percentage,
            pointColorMapper: (QuizDifficulty data, _) => data.color,
            radius: '80%',
            innerRadius: '60%',
            trackOpacity: 0.1,
          ),
        ],
      ),
    );
  }

  Widget _buildDifficultyLegend() {
    return Column(
      children: [
        Row(
          children: [
            Container(
              height: 10,
              width: 10,
              decoration: BoxDecoration(
                color: BBColors.successGreen,
                borderRadius: BorderRadius.circular(5),
              ),
            ),
            const SizedBox(width: 8),
            BBText(
              data: "Easy",
              style: context.textStyle.labelMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            BBText(
              data: "88%",
              style: context.textStyle.labelMedium?.copyWith(
                fontWeight: FontWeight.w200,
                color: BBColors.successGreen,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Container(
              height: 10,
              width: 10,
              decoration: BoxDecoration(
                color: BBColors.orangeAccent,
                borderRadius: BorderRadius.circular(5),
              ),
            ),
            const SizedBox(width: 8),
            BBText(
              data: "Medium",
              style: context.textStyle.labelMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            BBText(
              data: "55%",
              style: context.textStyle.labelMedium?.copyWith(
                fontWeight: FontWeight.w200,
                color: BBColors.orangeAccent,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Container(
              height: 10,
              width: 10,
              decoration: BoxDecoration(
                color: BBColors.alertRed,
                borderRadius: BorderRadius.circular(5),
              ),
            ),
            const SizedBox(width: 8),
            BBText(
              data: "Hard",
              style: context.textStyle.labelMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            BBText(
              data: "32%",
              style: context.textStyle.labelMedium?.copyWith(
                fontWeight: FontWeight.w200,
                color: BBColors.alertRed,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildChapterScoresList() {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: _chapterScoreData.length,
      itemBuilder: (context, index) {
        final chapter = _chapterScoreData[index];
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
                // Chapter info section
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      // Chapter number with gradient background
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              _getMasteryColor(
                                chapter.status,
                              ).withValues(alpha: 0.8),
                              _getMasteryColor(chapter.status),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: BBText(
                            data: chapter.chapterNo.toString(),
                            style: context.textStyle.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Topic name and status
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            BBText(
                              data: chapter.topicName,
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
                                    color: _getMasteryColor(chapter.status),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                BBText(
                                  data: chapter.status,
                                  style: context.textStyle.labelSmall?.copyWith(
                                    color: _getMasteryColor(chapter.status),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      // Score with circular progress indicator
                      _buildScoreCircle(chapter.score),
                    ],
                  ),
                ),
                // Progress indicator at bottom
                Container(
                  height: 4,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        _getMasteryColor(chapter.status).withValues(alpha: 0.6),
                        _getMasteryColor(chapter.status),
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

  Widget _buildScoreCircle(int score) {
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
      child: Center(
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
      ),
    );
  }

  Color _getScoreColor(int score) {
    if (score >= 80) return BBColors.successGreen;
    if (score >= 60) return BBColors.orangeAccent;
    return BBColors.alertRed;
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

  List<QuizDifficulty> _getDifficultyData() {
    final List<QuizDifficulty> chartdata = [
      QuizDifficulty('Easy', 88, BBColors.successGreen),
      QuizDifficulty('Medium', 55, BBColors.orangeAccent),
      QuizDifficulty('Hard', 32, BBColors.alertRed),
    ];
    return chartdata;
  }

  List<ChapterScore> _getChapterScoreData() {
    return [
      ChapterScore(1, 'Numbers and Operations', 92, 'Mastered'),
      ChapterScore(2, 'Fractions and Decimals', 78, 'In Progress'),
      ChapterScore(3, 'Geometry', 85, 'Mastered'),
      ChapterScore(4, 'Measurements', 95, 'Mastered'),
      ChapterScore(5, 'Data and Statistics', 65, 'In Progress'),
      ChapterScore(6, 'Algebra', 45, 'Needs Work'),
    ];
  }
}

class QuizDifficulty {
  final String difficulty;
  final int percentage;
  final Color color;

  QuizDifficulty(this.difficulty, this.percentage, this.color);
}

class ChapterScore {
  final int chapterNo;
  final String topicName;
  final int score;
  final String status; // 'Mastered', 'In Progress', 'Needs Work'

  ChapterScore(this.chapterNo, this.topicName, this.score, this.status);
}
