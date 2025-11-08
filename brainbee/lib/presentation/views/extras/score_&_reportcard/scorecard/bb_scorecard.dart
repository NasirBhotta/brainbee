// lib/presentation/views/extras/scorecard/bb_overall_score_screen.dart

import 'package:brainbee/core/constants/bb_colors.dart';
import 'package:brainbee/core/utils/bb_screen_extension.dart';
import 'package:brainbee/core/utils/bb_text.dart';
import 'package:brainbee/core/utils/bb_textTheme_extention.dart';
import 'package:brainbee/presentation/views/extras/score_&_reportcard/scorecard/bb_bookscorescreen.dart';
import 'package:brainbee/presentation/views/extras/score_&_reportcard/scorecard/bloc/book_score_bloc.dart';
import 'package:brainbee/presentation/views/extras/score_&_reportcard/scorecard/model/bb_book_score.model.dart';
import 'package:brainbee/presentation/views/extras/score_&_reportcard/scorecard/repo/score_repo_impl.dart';
import 'package:brainbee/presentation/views/extras/score_&_reportcard/scorecard/services/score_api_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class BBOverallScoreScreen extends StatelessWidget {
  const BBOverallScoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create:
          (context) => BookScoreBloc(
            repository: ScoreRepositoryImpl(apiService: ScoreApiService()),
          )..add(LoadOverallScore()),
      child: const _BBOverallScoreScreenContent(),
    );
  }
}

class _BBOverallScoreScreenContent extends StatefulWidget {
  const _BBOverallScoreScreenContent();

  @override
  State<_BBOverallScoreScreenContent> createState() =>
      _BBOverallScoreScreenContentState();
}

class _BBOverallScoreScreenContentState
    extends State<_BBOverallScoreScreenContent>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: BBColors.lightGrayBG,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back),
        ),
        title: BBText(
          data: "Overall Score",
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
          if (state is OverallScoreLoading) {
            return _buildLoadingState();
          }

          if (state is OverallScoreError) {
            return _buildErrorState(context, state.message);
          }

          if (state is OverallScoreEmpty) {
            return _buildNoScoresState(context);
          }

          if (state is OverallScoreLoaded) {
            return _buildBody(context, state.data);
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, OverallScoreData data) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<BookScoreBloc>().add(RefreshOverallScore());
        // Wait for the state to update
        await context.read<BookScoreBloc>().stream.firstWhere(
          (state) => state is! OverallScoreLoading,
        );
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: context.screenWidth * 0.05,
            vertical: 16,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildOverallScoreCard(data),
              const SizedBox(height: 24),
              _buildTabBar(),
              const SizedBox(height: 16),
              _buildTabContent(data),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text("Calculating your overall score..."),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: BBColors.alertRed),
          const SizedBox(height: 16),
          const Text("Failed to retrieve your overall score"),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              context.read<BookScoreBloc>().add(LoadOverallScore());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: BBColors.primaryBlue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text("Retry"),
          ),
        ],
      ),
    );
  }

  Widget _buildNoScoresState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.book_outlined,
            size: 64,
            color: BBColors.disabledText,
          ),
          const SizedBox(height: 16),
          const Text(
            "No scores available",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              "Complete some quizzes and activities to see your overall score",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: BBColors.primaryBlue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text("Explore Books"),
          ),
        ],
      ),
    );
  }

  Widget _buildOverallScoreCard(OverallScoreData data) {
    final String grade = _getGradeFromScore(data.averageScore);
    print("The data of overall score is ${data.subjectScores}");
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _getScoreColor(data.averageScore).withOpacity(0.8),
            _getScoreColor(data.averageScore),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _getScoreColor(data.averageScore).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: -30,
            right: -20,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.1),
              ),
            ),
          ),
          Positioned(
            bottom: -15,
            left: -15,
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.1),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          BBText(
                            data: "Your Overall Score",
                            style: context.textStyle.labelMedium?.copyWith(
                              color: Colors.white.withOpacity(0.9),
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              BBText(
                                data: grade,
                                style: context.textStyle.displayLarge?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 12),
                              BBText(
                                data: "${data.averageScore}%",
                                style: context.textStyle.headlineLarge
                                    ?.copyWith(
                                      color: Colors.white.withOpacity(0.9),
                                      fontSize: 22,
                                      fontWeight: FontWeight.w500,
                                    ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.2),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          CircularProgressIndicator(
                            value: data.averageScore / 100,
                            strokeWidth: 8,
                            backgroundColor: Colors.white.withOpacity(0.1),
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                          BBText(
                            data: "${data.averageScore}",
                            style: context.textStyle.titleLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem(
                      icon: Icons.book_outlined,
                      label: "Books",
                      value: "${data.totalBooks}",
                    ),
                    _buildStatItem(
                      icon: Icons.check_circle_outline,
                      label: "Quizzes",
                      value: "${data.totalQuizzesCompleted}",
                    ),
                    _buildStatItem(
                      icon: Icons.timer_outlined,
                      label: "Hours",
                      value: "${data.totalStudyHours}",
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 20),
        const SizedBox(height: 4),
        BBText(
          data: value,
          style: context.textStyle.titleMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        BBText(
          data: label,
          style: context.textStyle.bodySmall?.copyWith(
            color: Colors.white.withOpacity(0.9),
          ),
        ),
      ],
    );
  }

  Widget _buildTabBar() {
    return Container(
      decoration: BoxDecoration(
        color: BBColors.lightGrayBG,
        borderRadius: BorderRadius.circular(8),
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: BBColors.primaryBlue,
        unselectedLabelColor: BBColors.disabledText,
        indicatorSize: TabBarIndicatorSize.tab,
        indicator: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        tabs: const [
          Tab(text: "Subject Breakdown"),
          Tab(text: "Areas to Improve"),
        ],
      ),
    );
  }

  Widget _buildTabContent(OverallScoreData data) {
    return SizedBox(
      height: context.screenHeight * 0.5,
      child: TabBarView(
        controller: _tabController,
        children: [
          _buildSubjectBreakdown(data.subjectScores),
          _buildImprovementAreas(data.weakPoints),
        ],
      ),
    );
  }

  Widget _buildSubjectBreakdown(List<SubjectScore> subjectScores) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: BBText(
            data: "Your performance by subject",
            style: context.textStyle.labelMedium?.copyWith(
              color: BBColors.disabledText,
              letterSpacing: 0.5,
            ),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 200,
          child: SfCartesianChart(
            primaryXAxis: const CategoryAxis(
              majorGridLines: MajorGridLines(width: 0),
              axisLine: AxisLine(width: 0),
            ),
            primaryYAxis: const NumericAxis(
              minimum: 0,
              maximum: 100,
              interval: 20,
              axisLine: AxisLine(width: 0),
              majorTickLines: MajorTickLines(size: 0),
            ),
            tooltipBehavior: TooltipBehavior(enable: true),
            series: <CartesianSeries>[
              ColumnSeries<SubjectScore, String>(
                dataSource: subjectScores,
                xValueMapper: (SubjectScore data, _) => data.subject,
                yValueMapper: (SubjectScore data, _) => data.averageScore,
                pointColorMapper:
                    (SubjectScore data, _) => _getScoreColor(data.averageScore),
                borderRadius: BorderRadius.circular(4),
                dataLabelSettings: const DataLabelSettings(
                  isVisible: true,
                  labelPosition: ChartDataLabelPosition.outside,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: ListView.builder(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.zero,
            itemCount: subjectScores.length,
            itemBuilder: (context, index) {
              final subject = subjectScores[index];
              return _buildSubjectScoreItem(subject);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSubjectScoreItem(SubjectScore subject) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => BBBookScoreScreen(
                  bookId: subject.id,
                  bookTitle: subject.subject,
                ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _getScoreColor(subject.averageScore).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Icon(
                  _getSubjectIcon(subject.subject),
                  color: _getScoreColor(subject.averageScore),
                  size: 20,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  BBText(
                    data: subject.subject,
                    style: context.textStyle.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  BBText(
                    data:
                        "${subject.completed} of ${subject.total} activities completed",
                    style: context.textStyle.bodySmall?.copyWith(
                      color: BBColors.disabledText,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getScoreColor(
                      subject.averageScore,
                    ).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: BBText(
                    data: "${subject.averageScore}%",
                    style: context.textStyle.labelMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: _getScoreColor(subject.averageScore),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                BBText(
                  data: _getGradeFromScore(subject.averageScore),
                  style: context.textStyle.bodySmall?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: _getScoreColor(subject.averageScore),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImprovementAreas(List<WeakPoint> weakPoints) {
    if (weakPoints.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.emoji_events,
                size: 64,
                color: BBColors.successGreen.withOpacity(0.5),
              ),
              const SizedBox(height: 16),
              BBText(
                data: "Great job!",
                style: context.textStyle.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              BBText(
                data:
                    "You don't have any weak areas at the moment. Keep up the excellent work!",
                style: context.textStyle.bodyMedium?.copyWith(
                  color: BBColors.disabledText,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: BBText(
            data: "Areas that need improvement",
            style: context.textStyle.labelMedium?.copyWith(
              color: BBColors.disabledText,
              letterSpacing: 0.5,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: ListView.builder(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.zero,
            itemCount: weakPoints.length,
            itemBuilder: (context, index) {
              final weakPoint = weakPoints[index];
              return _buildWeakPointItem(weakPoint);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildWeakPointItem(WeakPoint weakPoint) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: BBColors.alertRed.withOpacity(0.05),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.warning_amber_rounded,
                  color: BBColors.alertRed,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: BBText(
                    data: weakPoint.topic,
                    style: context.textStyle.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: BBColors.alertRed.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: BBText(
                    data: "${weakPoint.score}%",
                    style: context.textStyle.labelMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: BBColors.alertRed,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BBText(
                  data: "Improvement Suggestions:",
                  style: context.textStyle.labelMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                ...List.generate(
                  weakPoint.suggestions.length,
                  (index) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.check_circle_outline,
                          color: BBColors.primaryBlue,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: BBText(
                            data: weakPoint.suggestions[index],
                            style: context.textStyle.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () {
                    // Navigate to practice exercises for this topic
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: BBColors.primaryBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text("Practice Now"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getSubjectIcon(String subject) {
    // Extract the main subject name (e.g., "Biology" from "Biology 9th Class")
    final subjectLower = subject.toLowerCase();

    if (subjectLower.contains('math')) {
      return Icons.calculate_outlined;
    } else if (subjectLower.contains('biolog')) {
      return Icons.science_outlined;
    } else if (subjectLower.contains('chemistry')) {
      return Icons.science_outlined;
    } else if (subjectLower.contains('physics')) {
      return Icons.science_outlined;
    } else if (subjectLower.contains('english')) {
      return Icons.menu_book_outlined;
    } else if (subjectLower.contains('history')) {
      return Icons.public_outlined;
    } else if (subjectLower.contains('geography')) {
      return Icons.map_outlined;
    } else {
      return Icons.book_outlined;
    }
  }

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
}
