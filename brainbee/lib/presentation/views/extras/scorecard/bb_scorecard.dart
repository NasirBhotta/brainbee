import 'package:brainbee/core/constants/bb_colors.dart';
import 'package:brainbee/core/utils/bb_screen_extension.dart';
import 'package:brainbee/core/utils/bb_text.dart';
import 'package:brainbee/core/utils/bb_textTheme_extention.dart';
import 'package:brainbee/presentation/views/extras/scorecard/bb_bookscorescreen.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class BBOverallScoreScreen extends StatefulWidget {
  const BBOverallScoreScreen({super.key});

  @override
  State<BBOverallScoreScreen> createState() => _BBOverallScoreScreenState();
}

class _BBOverallScoreScreenState extends State<BBOverallScoreScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late List<SubjectScore> _subjectScoreData;
  late List<WeakPoint> _weakPointsData;
  bool _isLoading = true;
  bool _hasError = false;
  bool _hasNoScores = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      // Simulating data fetch with a delay
      await Future.delayed(const Duration(seconds: 1));

      // Mock data for demonstration
      _subjectScoreData = _getSubjectScoreData();
      _weakPointsData = _getWeakPointsData();

      // Check if scores are available
      if (_subjectScoreData.isEmpty) {
        setState(() {
          _isLoading = false;
          _hasNoScores = true;
        });
        return;
      }

      setState(() {
        _isLoading = false;
        _hasNoScores = false;
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

    if (_hasNoScores) {
      return _buildNoScoresState();
    }

    return RefreshIndicator(
      onRefresh: _loadData,
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
              _buildOverallScoreCard(),
              const SizedBox(height: 24),
              _buildTabBar(),
              const SizedBox(height: 16),
              _buildTabContent(),
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

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: BBColors.alertRed),
          const SizedBox(height: 16),
          const Text("Failed to retrieve your overall score"),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _loadData,
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

  Widget _buildNoScoresState() {
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

  Widget _buildOverallScoreCard() {
    final int overallScore = _calculateOverallScore();
    final String grade = _getGradeFromScore(overallScore);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _getScoreColor(overallScore).withOpacity(0.8),
            _getScoreColor(overallScore),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _getScoreColor(overallScore).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Decorative circles in background
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
          // Content
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Score and grade
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
                                data: "$overallScore%",
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
                    // Circular progress indicator
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
                            value: overallScore / 100,
                            strokeWidth: 8,
                            backgroundColor: Colors.white.withOpacity(0.1),
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                          BBText(
                            data: "$overallScore",
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
                // Stats row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem(
                      icon: Icons.book_outlined,
                      label: "Books",
                      value: "${_subjectScoreData.length}",
                    ),
                    _buildStatItem(
                      icon: Icons.check_circle_outline,
                      label: "Quizzes",
                      value: "27",
                    ),
                    _buildStatItem(
                      icon: Icons.timer_outlined,
                      label: "Hours",
                      value: "14",
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

  Widget _buildTabContent() {
    return SizedBox(
      height: context.screenHeight * 0.5, // Adjust as needed
      child: TabBarView(
        controller: _tabController,
        children: [_buildSubjectBreakdown(), _buildImprovementAreas()],
      ),
    );
  }

  Widget _buildSubjectBreakdown() {
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
        // Chart
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
                dataSource: _subjectScoreData,
                xValueMapper: (SubjectScore data, _) => data.subject,
                yValueMapper: (SubjectScore data, _) => data.score,
                pointColorMapper:
                    (SubjectScore data, _) => _getScoreColor(data.score),
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
        // Subject list
        Expanded(
          child: ListView.builder(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.zero,
            itemCount: _subjectScoreData.length,
            itemBuilder: (context, index) {
              final subject = _subjectScoreData[index];
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
                  bookId: subject.id.toString(),
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
            // Subject icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _getScoreColor(subject.score).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Icon(
                  _getSubjectIcon(subject.subject),
                  color: _getScoreColor(subject.score),
                  size: 20,
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Subject name and details
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
            // Score
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getScoreColor(subject.score).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: BBText(
                    data: "${subject.score}%",
                    style: context.textStyle.labelMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: _getScoreColor(subject.score),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                BBText(
                  data: _getGradeFromScore(subject.score),
                  style: context.textStyle.bodySmall?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: _getScoreColor(subject.score),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImprovementAreas() {
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
            itemCount: _weakPointsData.length,
            itemBuilder: (context, index) {
              final weakPoint = _weakPointsData[index];
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
          // Header
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
          // Content
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
    switch (subject) {
      case "Mathematics":
        return Icons.calculate_outlined;
      case "Science":
        return Icons.science_outlined;
      case "English":
        return Icons.menu_book_outlined;
      case "History":
        return Icons.public_outlined;
      case "Geography":
        return Icons.map_outlined;
      default:
        return Icons.book_outlined;
    }
  }

  int _calculateOverallScore() {
    if (_subjectScoreData.isEmpty) return 0;

    int totalScore = 0;
    for (var subject in _subjectScoreData) {
      totalScore += subject.score;
    }

    return totalScore ~/ _subjectScoreData.length;
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

  List<SubjectScore> _getSubjectScoreData() {
    return [
      SubjectScore(1, "Mathematics", 88, 18, 20),
      SubjectScore(2, "Science", 76, 15, 20),
      SubjectScore(3, "English", 92, 10, 10),
      SubjectScore(4, "History", 65, 8, 10),
      SubjectScore(5, "Geography", 45, 5, 15),
    ];
  }

  List<WeakPoint> _getWeakPointsData() {
    return [
      WeakPoint("Geography - Map Reading", 45, [
        "Review the basic principles of map coordinates and scales",
        "Practice with interactive map exercises in the Geography section",
        "Complete at least 3 map reading quizzes this week",
      ]),
      WeakPoint("Mathematics - Algebra", 55, [
        "Focus on equation solving techniques in the Algebra chapter",
        "Watch the tutorial videos on algebraic expressions",
        "Practice with step-by-step problem solving in the exercises",
      ]),
      WeakPoint("History - Modern Era", 58, [
        "Review the timeline of major events in the Modern Era chapter",
        "Use flashcards to memorize key dates and figures",
        "Take the chapter quiz again after reviewing the material",
      ]),
    ];
  }
}

class SubjectScore {
  final int id;
  final String subject;
  final int score;
  final int completed;
  final int total;

  SubjectScore(this.id, this.subject, this.score, this.completed, this.total);
}

class WeakPoint {
  final String topic;
  final int score;
  final List<String> suggestions;

  WeakPoint(this.topic, this.score, this.suggestions);
}
