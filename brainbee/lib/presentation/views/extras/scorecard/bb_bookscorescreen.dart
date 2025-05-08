import 'package:brainbee/core/constants/bb_colors.dart';
import 'package:brainbee/core/utils/bb_screen_extension.dart';
import 'package:brainbee/core/utils/bb_text.dart';
import 'package:brainbee/core/utils/bb_textTheme_extention.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class BBBookScoreScreen extends StatefulWidget {
  final String bookId;
  final String bookTitle;

  const BBBookScoreScreen({
    super.key,
    required this.bookId,
    required this.bookTitle,
  });

  @override
  State<BBBookScoreScreen> createState() => _BBBookScoreScreenState();
}

class _BBBookScoreScreenState extends State<BBBookScoreScreen> {
  late BookScore _bookScore;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadBookScore();
  }

  Future<void> _loadBookScore() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      // Simulating API call with delay
      await Future.delayed(const Duration(seconds: 1));

      // Mock data for demonstration
      _bookScore = _getMockBookScore();

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
    }
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
          data: widget.bookTitle,
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
    if (_isLoading) {
      return _buildLoadingState();
    }

    if (_hasError) {
      return _buildErrorState();
    }

    return RefreshIndicator(
      onRefresh: _loadBookScore,
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
              _buildBookScoreHeader(),
              const SizedBox(height: 24),
              _buildProgressSection(),
              const SizedBox(height: 24),
              _buildScoreBreakdownSection(),
              const SizedBox(height: 24),
              _buildChapterScoresSection(),
              const SizedBox(height: 24),
              _buildRecommendationsSection(),
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
          Text("Loading book score details..."),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: BBColors.alertRed),
          const SizedBox(height: 16),
          const Text("Failed to load book score details"),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _loadBookScore,
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

  Widget _buildBookScoreHeader() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _getScoreColor(_bookScore.overallScore).withOpacity(0.8),
            _getScoreColor(_bookScore.overallScore),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _getScoreColor(_bookScore.overallScore).withOpacity(0.3),
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
            // Book cover
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
                  _bookScore.coverImage != null
                      ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          _bookScore.coverImage!,
                          fit: BoxFit.cover,
                        ),
                      )
                      : const Center(
                        child: Icon(Icons.book, color: Colors.grey, size: 40),
                      ),
            ),
            const SizedBox(width: 20),
            // Book details and score
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _bookScore.title,
                    style: context.textStyle.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  BBText(
                    data: _bookScore.author,
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
                              data: _getGradeFromScore(_bookScore.overallScore),
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
                        data: "${_bookScore.overallScore}%",
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

  Widget _buildProgressSection() {
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
                  icon: Icons.bookmark_border,
                  label: "Pages Read",
                  value: "${_bookScore.pagesRead}/${_bookScore.totalPages}",
                  progress: _bookScore.pagesRead / _bookScore.totalPages,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildProgressItem(
                  icon: Icons.timer_outlined,
                  label: "Study Time",
                  value: "${_bookScore.studyHours} hrs",
                  progress:
                      _bookScore.studyHours / 20, // Assuming 20 hours is max
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildProgressItem(
                  icon: Icons.check_circle_outline,
                  label: "Quizzes",
                  value:
                      "${_bookScore.quizzesCompleted}/${_bookScore.totalQuizzes}",
                  progress:
                      _bookScore.quizzesCompleted / _bookScore.totalQuizzes,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressItem({
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
                value: progress,
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

  Widget _buildScoreBreakdownSection() {
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
              ColumnSeries<ScoreCategory, String>(
                dataSource: _bookScore.categoryScores,
                xValueMapper: (ScoreCategory data, _) => data.category,
                yValueMapper: (ScoreCategory data, _) => data.score,
                pointColorMapper:
                    (ScoreCategory data, _) => _getScoreColor(data.score),
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

  Widget _buildChapterScoresSection() {
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
        ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: _bookScore.chapterScores.length,
          itemBuilder: (context, index) {
            final chapter = _bookScore.chapterScores[index];
            return _buildChapterScoreItem(chapter);
          },
        ),
      ],
    );
  }

  Widget _buildChapterScoreItem(ChapterScore chapter) {
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
          // Quiz scores
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
          // Practice button
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

  Widget _buildRecommendationsSection() {
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
          ...List.generate(
            _bookScore.recommendations.length,
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
                      data: _bookScore.recommendations[index],
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

  // Sample data
  BookScore _getMockBookScore() {
    return BookScore(
      id: "book-001",
      title: "Advanced Mathematics: Algebra & Calculus",
      author: "Dr. Robert Johnson",
      overallScore: 78,
      coverImage: null, // Replace with actual image URL
      pagesRead: 185,
      totalPages: 320,
      studyHours: 12,
      quizzesCompleted: 8,
      totalQuizzes: 12,
      categoryScores: [
        ScoreCategory("Comprehension", 82),
        ScoreCategory("Application", 75),
        ScoreCategory("Problem Solving", 65),
        ScoreCategory("Theory", 90),
      ],
      chapterScores: [
        ChapterScore(
          chapterNumber: 1,
          title: "Fundamentals of Algebra",
          score: 85,
          completed: true,
          quizScores: [
            QuizScore("Basic Equations", 90),
            QuizScore("Polynomials", 85),
            QuizScore("Word Problems", 80),
          ],
        ),
        ChapterScore(
          chapterNumber: 2,
          title: "Advanced Algebraic Expressions",
          score: 78,
          completed: true,
          quizScores: [
            QuizScore("Factoring", 85),
            QuizScore("Quadratic Equations", 70),
            QuizScore("Functions", 80),
          ],
        ),
        ChapterScore(
          chapterNumber: 3,
          title: "Introduction to Calculus",
          score: 65,
          completed: false,
          quizScores: [QuizScore("Limits", 70), QuizScore("Derivatives", 60)],
        ),
        ChapterScore(
          chapterNumber: 4,
          title: "Integration Techniques",
          score: 0,
          completed: false,
          quizScores: [],
        ),
      ],
      recommendations: [
        "Focus on practicing more problems in the Calculus section to improve your problem-solving skills.",
        "Revisit the derivative concepts in Chapter 3 to strengthen your understanding.",
        "Spend at least 30 minutes daily on solving integration problems to prepare for Chapter 4.",
        "Complete the remaining quizzes in Chapter 3 before moving to Chapter 4.",
      ],
    );
  }
}

// Data models
class BookScore {
  final String id;
  final String title;
  final String author;
  final int overallScore;
  final String? coverImage;
  final int pagesRead;
  final int totalPages;
  final int studyHours;
  final int quizzesCompleted;
  final int totalQuizzes;
  final List<ScoreCategory> categoryScores;
  final List<ChapterScore> chapterScores;
  final List<String> recommendations;

  BookScore({
    required this.id,
    required this.title,
    required this.author,
    required this.overallScore,
    this.coverImage,
    required this.pagesRead,
    required this.totalPages,
    required this.studyHours,
    required this.quizzesCompleted,
    required this.totalQuizzes,
    required this.categoryScores,
    required this.chapterScores,
    required this.recommendations,
  });
}

class ScoreCategory {
  final String category;
  final int score;

  ScoreCategory(this.category, this.score);
}

class ChapterScore {
  final int chapterNumber;
  final String title;
  final int score;
  final bool completed;
  final List<QuizScore> quizScores;

  ChapterScore({
    required this.chapterNumber,
    required this.title,
    required this.score,
    required this.completed,
    required this.quizScores,
  });
}

class QuizScore {
  final String title;
  final int score;

  QuizScore(this.title, this.score);
}
