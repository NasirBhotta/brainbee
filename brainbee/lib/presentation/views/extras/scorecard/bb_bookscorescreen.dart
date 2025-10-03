// lib/presentation/views/extras/scorecard/bb_bookscorescreen.dart

import 'package:brainbee/core/constants/bb_colors.dart';
import 'package:brainbee/core/utils/bb_screen_extension.dart';
import 'package:brainbee/core/utils/bb_text.dart';
import 'package:brainbee/core/utils/bb_textTheme_extention.dart';
import 'package:brainbee/presentation/views/extras/scorecard/bloc/book_score_bloc.dart';
import 'package:brainbee/presentation/views/extras/scorecard/model/bb_spefic_book_score_model.dart';
import 'package:brainbee/presentation/views/extras/scorecard/repo/score_repo_impl.dart';
import 'package:brainbee/presentation/views/extras/scorecard/services/score_api_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class BBBookScoreScreen extends StatelessWidget {
  final String bookId;
  final String bookTitle;

  const BBBookScoreScreen({
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
      child: _BBBookScoreScreenContent(bookTitle: bookTitle),
    );
  }
}

class _BBBookScoreScreenContent extends StatelessWidget {
  final String bookTitle;

  const _BBBookScoreScreenContent({required this.bookTitle});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: BBColors.lightGrayBG,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back),
        ),
        title: BBText(data: bookTitle, style: context.textStyle.titleMedium),
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
            return _buildLoadingState();
          }

          if (state is BookScoreError) {
            return _buildErrorState(context, state.message);
          }

          if (state is BookScoreLoaded) {
            return _buildBody(context, state.data);
          }

          return const SizedBox.shrink();
        },
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
          Text("Loading book score details..."),
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
          const Text("Failed to load book score details"),
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
              final bookId =
                  (context.read<BookScoreBloc>().state as BookScoreError)
                          .message
                          .contains('bookId')
                      ? ''
                      : context.read<BookScoreBloc>().state.toString();
              // You'll need to pass bookId properly - this is a simplified version
              context.read<BookScoreBloc>().add(LoadBookScore(bookId));
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

  Widget _buildBody(BuildContext context, BookScoreData data) {
    return RefreshIndicator(
      onRefresh: () async {
        final bloc = context.read<BookScoreBloc>();
        if (bloc.state is BookScoreLoaded) {
          final bookId = (bloc.state as BookScoreLoaded).data.id;
          bloc.add(RefreshBookScore(bookId));
          await bloc.stream.firstWhere((state) => state is! BookScoreLoading);
        }
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
              _buildBookScoreHeader(context, data),
              const SizedBox(height: 24),
              _buildProgressSection(context, data),
              const SizedBox(height: 24),
              _buildScoreBreakdownSection(context, data),
              const SizedBox(height: 24),
              _buildChapterScoresSection(context, data),
              const SizedBox(height: 24),
              _buildRecommendationsSection(context, data),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBookScoreHeader(BuildContext context, BookScoreData data) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _getScoreColor(data.overallScore).withOpacity(0.8),
            _getScoreColor(data.overallScore),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _getScoreColor(data.overallScore).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 80,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child:
                  data.coverImage != null
                      ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          data.coverImage!,
                          fit: BoxFit.cover,
                          errorBuilder:
                              (_, __, ___) => const Center(
                                child: Icon(
                                  Icons.book,
                                  color: Colors.grey,
                                  size: 40,
                                ),
                              ),
                        ),
                      )
                      : const Center(
                        child: Icon(Icons.book, color: Colors.grey, size: 40),
                      ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data.title,
                    style: context.textStyle.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  if (data.author.isNotEmpty)
                    BBText(
                      data: data.author,
                      style: context.textStyle.bodyMedium?.copyWith(
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.star,
                              color: Colors.white,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            BBText(
                              data: _getGradeFromScore(data.overallScore),
                              style: context.textStyle.labelLarge?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      BBText(
                        data: "${data.overallScore}%",
                        style: context.textStyle.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressSection(BuildContext context, BookScoreData data) {
    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BBText(
            data: "Your Progress",
            style: context.textStyle.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildProgressItem(
                  context: context,
                  icon: Icons.assignment_outlined,
                  label: "Activities",
                  value: "${data.totalActivities}",
                  progress: data.totalActivities > 0 ? 1.0 : 0.0,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildProgressItem(
                  context: context,
                  icon: Icons.timer_outlined,
                  label: "Study Time",
                  value: "${data.studyHours} hrs",
                  progress:
                      data.studyHours > 0
                          ? (data.studyHours / 20).clamp(0.0, 1.0)
                          : 0.0,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildProgressItem(
                  context: context,
                  icon: Icons.check_circle_outline,
                  label: "Quizzes",
                  value: "${data.quizzesCompleted}/${data.totalQuizzes}",
                  progress:
                      data.totalQuizzes > 0
                          ? data.quizzesCompleted / data.totalQuizzes
                          : 0.0,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressItem({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String value,
    required double progress,
  }) {
    print("study hours are $value");
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: BBColors.lightGrayBG,
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              CircularProgressIndicator(
                value: progress.clamp(0.0, 1.0),
                backgroundColor: Colors.grey.withOpacity(0.2),
                valueColor: const AlwaysStoppedAnimation<Color>(
                  BBColors.primaryBlue,
                ),
                strokeWidth: 5,
              ),
              Icon(icon, color: BBColors.primaryBlue, size: 24),
            ],
          ),
        ),
        const SizedBox(height: 8),
        BBText(
          data: value,
          style: context.textStyle.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        BBText(
          data: label,
          style: context.textStyle.bodySmall?.copyWith(
            color: BBColors.disabledText,
          ),
        ),
      ],
    );
  }

  Widget _buildScoreBreakdownSection(BuildContext context, BookScoreData data) {
    // Generate mock category scores based on overall score
    // You can enhance this later when backend provides real category data
    final categories = _generateMockCategoryScores(data.overallScore);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BBText(
          data: "Score Breakdown",
          style: context.textStyle.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
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
              ColumnSeries<CategoryScore, String>(
                dataSource: categories,
                xValueMapper: (CategoryScore data, _) => data.category,
                yValueMapper: (CategoryScore data, _) => data.score,
                pointColorMapper:
                    (CategoryScore data, _) => _getScoreColor(data.score),
                borderRadius: BorderRadius.circular(4),
                dataLabelSettings: const DataLabelSettings(
                  isVisible: true,
                  labelPosition: ChartDataLabelPosition.outside,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildChapterScoresSection(BuildContext context, BookScoreData data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BBText(
          data: "Chapter Performance",
          style: context.textStyle.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        if (data.chapterScores.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: BBText(
                data: "No chapter data available yet",
                style: context.textStyle.bodyMedium?.copyWith(
                  color: BBColors.disabledText,
                ),
              ),
            ),
          )
        else
          ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: data.chapterScores.length,
            itemBuilder: (context, index) {
              final chapter = data.chapterScores[index];
              return _buildChapterScoreItem(context, chapter);
            },
          ),
      ],
    );
  }

  Widget _buildChapterScoreItem(
    BuildContext context,
    ChapterScoreData chapter,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        title: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  BBText(
                    data: "Chapter ${chapter.chapterNumber}: ${chapter.title}",
                    style: context.textStyle.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (chapter.completed)
                    BBText(
                      data: "Completed",
                      style: context.textStyle.bodySmall?.copyWith(
                        color: BBColors.successGreen,
                      ),
                    )
                  else
                    BBText(
                      data: "In Progress",
                      style: context.textStyle.bodySmall?.copyWith(
                        color: BBColors.orangeAccent,
                      ),
                    ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: _getScoreColor(chapter.score).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: BBText(
                data: "${chapter.score}%",
                style: context.textStyle.labelMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: _getScoreColor(chapter.score),
                ),
              ),
            ),
          ],
        ),
        children: [
          if (chapter.quizScores.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: BBText(
                data: "No quiz attempts yet",
                style: context.textStyle.bodySmall?.copyWith(
                  color: BBColors.disabledText,
                ),
              ),
            )
          else
            ...chapter.quizScores.map(
              (quiz) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: _getScoreColor(quiz.score),
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: BBText(
                        data: quiz.title,
                        style: context.textStyle.bodyMedium,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: _getScoreColor(quiz.score).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: BBText(
                        data: "${quiz.score}%",
                        style: context.textStyle.bodySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: _getScoreColor(quiz.score),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () {
              // Navigate to chapter practice
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: BBColors.primaryBlue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text("Practice This Chapter"),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationsSection(
    BuildContext context,
    BookScoreData data,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: BBColors.lightGrayBG,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.lightbulb_outline, color: BBColors.primaryBlue),
              const SizedBox(width: 8),
              BBText(
                data: "Personalized Recommendations",
                style: context.textStyle.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (data.recommendations.isEmpty)
            BBText(
              data:
                  "Keep up the great work! Complete more activities to get personalized recommendations.",
              style: context.textStyle.bodyMedium?.copyWith(
                color: BBColors.disabledText,
              ),
            )
          else
            ...List.generate(
              data.recommendations.length,
              (index) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: BBColors.primaryBlue.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          "${index + 1}",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: BBColors.primaryBlue,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: BBText(
                        data: data.recommendations[index],
                        style: context.textStyle.bodyMedium,
                      ),
                    ),
                  ],
                ),
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

  // Generate mock category scores based on overall score
  // This is a placeholder until backend provides real category data
  List<CategoryScore> _generateMockCategoryScores(int overallScore) {
    return [
      CategoryScore(
        category: "Comprehension",
        score: (overallScore + 5).clamp(0, 100),
      ),
      CategoryScore(
        category: "Application",
        score: (overallScore - 5).clamp(0, 100),
      ),
      CategoryScore(
        category: "Problem Solving",
        score: (overallScore - 10).clamp(0, 100),
      ),
      CategoryScore(
        category: "Theory",
        score: (overallScore + 10).clamp(0, 100),
      ),
    ];
  }
}
