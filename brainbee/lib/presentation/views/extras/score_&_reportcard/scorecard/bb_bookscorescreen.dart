// lib/presentation/views/extras/scorecard/bb_bookscorescreen.dart

import 'package:brainbee/core/constants/bb_colors.dart';
import 'package:brainbee/core/utils/bb_screen_extension.dart';
import 'package:brainbee/core/utils/bb_text.dart';
import 'package:brainbee/core/utils/bb_textTheme_extention.dart';
import 'package:brainbee/presentation/views/extras/score_&_reportcard/scorecard/bloc/book_score_bloc.dart';
import 'package:brainbee/presentation/views/extras/score_&_reportcard/scorecard/model/bb_spefic_book_score_model.dart';
import 'package:brainbee/presentation/views/extras/score_&_reportcard/scorecard/recommendation_screen.dart';
import 'package:brainbee/presentation/views/extras/score_&_reportcard/scorecard/repo/score_repo_impl.dart';
import 'package:brainbee/presentation/views/extras/score_&_reportcard/scorecard/services/score_api_service.dart';
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
      child: _BBBookScoreScreenContent(bookTitle: bookTitle, bookId: bookId),
    );
  }
}

class _BBBookScoreScreenContent extends StatelessWidget {
  final String bookTitle;
  final String bookId;

  const _BBBookScoreScreenContent({
    required this.bookTitle,
    required this.bookId,
  });

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
        context.read<BookScoreBloc>().add(RefreshBookScore(bookId));
        await context.read<BookScoreBloc>().stream.firstWhere(
          (state) => state is! BookScoreLoading,
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
    // ✅ Use averageScore instead of overallScore for display
    final String grade = _getGradeFromScore(data.averageScore);

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
          // Decorative circles
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
            padding: const EdgeInsets.all(20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Book Cover
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
                            child: Icon(
                              Icons.book,
                              color: Colors.grey,
                              size: 40,
                            ),
                          ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      BBText(
                        data: "Your Score",
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
                              fontSize: 48,
                            ),
                          ),
                          const SizedBox(width: 12),
                          BBText(
                            data: "${data.averageScore}%",
                            style: context.textStyle.headlineLarge?.copyWith(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 24,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (data.author.isNotEmpty)
                        BBText(
                          data: "by ${data.author}",
                          style: context.textStyle.bodySmall?.copyWith(
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
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
                  value: "${data.studyHours.toStringAsFixed(1)} hrs",
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
          textAlign: TextAlign.center,
        ),
        BBText(
          data: label,
          style: context.textStyle.bodySmall?.copyWith(
            color: BBColors.disabledText,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildScoreBreakdownSection(BuildContext context, BookScoreData data) {
    // Generate category scores from chapter data
    final categories = _generateCategoryScoresFromChapters(data.chapterScores);

    if (categories.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BBText(
          data: "Chapter Score Distribution",
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
              labelRotation: -45,
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
              child: Column(
                children: [
                  Icon(
                    Icons.book_outlined,
                    size: 48,
                    color: BBColors.disabledText.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  BBText(
                    data: "No chapter data available yet",
                    style: context.textStyle.bodyMedium?.copyWith(
                      color: BBColors.disabledText,
                    ),
                  ),
                  const SizedBox(height: 8),
                  BBText(
                    data: "Complete some quizzes to see your chapter progress",
                    style: context.textStyle.bodySmall?.copyWith(
                      color: BBColors.disabledText,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
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
        border: Border.all(
          color: _getScoreColor(chapter.score).withOpacity(0.2),
          width: 1,
        ),
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
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: _getScoreColor(chapter.score).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: BBText(
              data: "${chapter.chapterNumber}",
              style: context.textStyle.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: _getScoreColor(chapter.score),
              ),
            ),
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  BBText(
                    data: chapter.title,
                    style: context.textStyle.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        chapter.completed ? Icons.check_circle : Icons.schedule,
                        size: 14,
                        color:
                            chapter.completed
                                ? BBColors.successGreen
                                : BBColors.orangeAccent,
                      ),
                      const SizedBox(width: 4),
                      BBText(
                        data: chapter.completed ? "Completed" : "In Progress",
                        style: context.textStyle.bodySmall?.copyWith(
                          color:
                              chapter.completed
                                  ? BBColors.successGreen
                                  : BBColors.orangeAccent,
                        ),
                      ),
                    ],
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
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BBText(
                  data: "Quiz Attempts (${chapter.quizScores.length})",
                  style: context.textStyle.labelMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: BBColors.disabledText,
                  ),
                ),
                const SizedBox(height: 8),
                ...chapter.quizScores.map(
                  (quiz) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Icon(
                          Icons.quiz_outlined,
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
              ],
            ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                // Navigate to chapter practice
              },
              icon: const Icon(Icons.play_arrow, size: 18),
              label: const Text("Practice This Chapter"),
              style: ElevatedButton.styleFrom(
                backgroundColor: BBColors.primaryBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationsSection(
    BuildContext context,
    BookScoreData data,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                BBColors.primaryBlue.withOpacity(0.1),
                BBColors.primaryBlue.withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: BBColors.primaryBlue.withOpacity(0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: BBColors.primaryBlue.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.auto_awesome,
                      color: BBColors.primaryBlue,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        BBText(
                          data: "AI-Powered Recommendations",
                          style: context.textStyle.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: BBColors.primaryBlue,
                          ),
                        ),
                        const SizedBox(height: 4),
                        BBText(
                          data: "Get personalized study materials",
                          style: context.textStyle.bodySmall?.copyWith(
                            color: BBColors.disabledText,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Quick Recommendations Preview
              if (data.recommendations.isNotEmpty) ...[
                BBText(
                  data: "Quick Tips:",
                  style: context.textStyle.labelMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                ...data.recommendations.take(2).map((recommendation) {
                  final index = data.recommendations.indexOf(recommendation);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: BBColors.primaryBlue.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              "${index + 1}",
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: BBColors.primaryBlue,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: BBText(
                            data: recommendation,
                            style: context.textStyle.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                if (data.recommendations.length > 2)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: BBText(
                      data:
                          "+${data.recommendations.length - 2} more recommendations",
                      style: context.textStyle.bodySmall?.copyWith(
                        color: BBColors.disabledText,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                const SizedBox(height: 16),
              ] else ...[
                BBText(
                  data:
                      "Complete more activities to unlock personalized recommendations",
                  style: context.textStyle.bodyMedium?.copyWith(
                    color: BBColors.disabledText,
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Main Recommendation Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const BBRecommendationScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.psychology_outlined, size: 20),
                  label: const Text("View All Recommendations"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: BBColors.primaryBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Features Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildFeatureItem(context, Icons.topic_outlined, "Topics"),
                  _buildFeatureItem(
                    context,
                    Icons.style_outlined,
                    "Flashcards",
                  ),
                  _buildFeatureItem(context, Icons.quiz_outlined, "Quizzes"),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Add this helper method to bb_bookscorescreen.dart
  Widget _buildFeatureItem(BuildContext context, IconData icon, String label) {
    return Column(
      children: [
        Icon(icon, size: 24, color: BBColors.primaryBlue.withOpacity(0.7)),
        const SizedBox(height: 4),
        BBText(
          data: label,
          style: context.textStyle.bodySmall?.copyWith(
            color: BBColors.disabledText,
            fontSize: 11,
          ),
        ),
      ],
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

  // ✅ Generate category scores from actual chapter data
  List<CategoryScore> _generateCategoryScoresFromChapters(
    List<ChapterScoreData> chapters,
  ) {
    if (chapters.isEmpty) return [];

    // Take first 5 chapters for the chart
    return chapters.take(5).map((chapter) {
      return CategoryScore(
        category: "Ch ${chapter.chapterNumber}",
        score: chapter.score,
      );
    }).toList();
  }
}

// ✅ CategoryScore class definition
class CategoryScore {
  final String category;
  final int score;

  CategoryScore({required this.category, required this.score});
}
