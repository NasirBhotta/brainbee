// lib/presentation/views/extras/scorecard/bb_recommendation_screen.dart

import 'package:brainbee/core/constants/bb_colors.dart';
import 'package:brainbee/core/utils/bb_screen_extension.dart';
import 'package:brainbee/core/utils/bb_text.dart';
import 'package:brainbee/core/utils/bb_textTheme_extention.dart';
import 'package:brainbee/core/utils/helper/bb_token.dart';
import 'package:brainbee/presentation/views/extras/score_&_reportcard/scorecard/bloc/recommendation/bloc/recommendation_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'model/recommendation_model/recommendation_model.dart';
import 'services/recommendation_service/recommendation_service.dart';

class BBRecommendationScreen extends StatelessWidget {
  const BBRecommendationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getTokenAndUser(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final studentId = snapshot.data!.user!.id;

        return BlocProvider(
          create:
              (context) =>
                  RecommendationBloc(service: RecommendationService())
                    ..add(LoadRecommendations(studentId)),
          child: _RecommendationScreenContent(studentId: studentId),
        );
      },
    );
  }
}

class _RecommendationScreenContent extends StatefulWidget {
  final String studentId;

  const _RecommendationScreenContent({required this.studentId});

  @override
  State<_RecommendationScreenContent> createState() =>
      _RecommendationScreenContentState();
}

class _RecommendationScreenContentState
    extends State<_RecommendationScreenContent>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back),
        ),
        title: BBText(
          data: "Personalized Recommendations",
          style: context.textStyle.titleMedium,
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<RecommendationBloc>().add(
                RefreshRecommendations(widget.studentId),
              );
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            width: context.screenWidth,
            height: 1,
            color: BBColors.borderGray,
          ),
        ),
      ),
      body: BlocBuilder<RecommendationBloc, RecommendationState>(
        builder: (context, state) {
          if (state is RecommendationLoading) {
            return _buildLoadingState();
          }

          if (state is RecommendationError) {
            return _buildErrorState(context, state.message);
          }

          if (state is RecommendationEmpty) {
            return _buildEmptyState(context);
          }

          if (state is RecommendationLoaded) {
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
          Text("Generating personalized recommendations..."),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: BBColors.alertRed),
            const SizedBox(height: 16),
            const Text("Failed to load recommendations"),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                context.read<RecommendationBloc>().add(
                  LoadRecommendations(widget.studentId),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: BBColors.primaryBlue,
                foregroundColor: Colors.white,
              ),
              child: const Text("Retry"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.psychology_outlined,
              size: 80,
              color: BBColors.disabledText.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            BBText(
              data: "No recommendations yet",
              style: context.textStyle.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            BBText(
              data:
                  "Complete some quizzes to get personalized recommendations based on your performance",
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

  Widget _buildBody(BuildContext context, RecommendationResponse data) {
    return Column(
      children: [
        _buildHeader(context, data),
        _buildTabBar(),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildTopicsTab(context, data.topics),
              _buildFlashcardsTab(context, data.flashcards),
              _buildQuizzesTab(context, data.quizzes),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, RecommendationResponse data) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [BBColors.primaryBlue.withOpacity(0.8), BBColors.primaryBlue],
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    BBText(
                      data: "AI-Powered Learning",
                      style: context.textStyle.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    BBText(
                      data: "Based on your performance & learning patterns",
                      style: context.textStyle.bodySmall?.copyWith(
                        color: Colors.white.withOpacity(0.9),
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
              _buildHeaderStat(
                context,
                Icons.topic_outlined,
                "${data.topics.length}",
                "Topics",
              ),
              _buildHeaderStat(
                context,
                Icons.style_outlined,
                "${data.flashcards.length}",
                "Flashcards",
              ),
              _buildHeaderStat(
                context,
                Icons.quiz_outlined,
                "${data.quizzes.length}",
                "Quizzes",
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderStat(
    BuildContext context,
    IconData icon,
    String value,
    String label,
  ) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 24),
        const SizedBox(height: 4),
        BBText(
          data: value,
          style: context.textStyle.titleLarge?.copyWith(
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
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: BBColors.borderGray, width: 1),
        ),
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: BBColors.primaryBlue,
        unselectedLabelColor: BBColors.disabledText,
        indicatorColor: BBColors.primaryBlue,
        indicatorWeight: 3,
        tabs: const [
          Tab(text: "Topics"),
          Tab(text: "Flashcards"),
          Tab(text: "Quizzes"),
        ],
      ),
    );
  }

  Widget _buildTopicsTab(BuildContext context, List<String> topics) {
    if (topics.isEmpty) {
      return _buildTabEmptyState(
        "No topic recommendations",
        Icons.topic_outlined,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: topics.length,
      itemBuilder: (context, index) {
        return _buildTopicCard(context, topics[index], index);
      },
    );
  }

  Widget _buildTopicCard(BuildContext context, String topicKey, int index) {
    final parts = topicKey.split('::');
    final title = parts.length >= 3 ? parts[2] : topicKey;
    final chapter = parts.length >= 2 ? "Chapter ${parts[1]}" : "";

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: BBColors.borderGray),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: BBColors.primaryBlue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: BBText(
              data: "${index + 1}",
              style: context.textStyle.titleSmall?.copyWith(
                color: BBColors.primaryBlue,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        title: BBText(
          data: title,
          style: context.textStyle.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle:
            chapter.isNotEmpty
                ? BBText(
                  data: chapter,
                  style: context.textStyle.bodySmall?.copyWith(
                    color: BBColors.disabledText,
                  ),
                )
                : null,
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: BBColors.disabledText,
        ),
        onTap: () {
          // Navigate to topic practice
        },
      ),
    );
  }

  Widget _buildFlashcardsTab(
    BuildContext context,
    List<FlashcardRecommendation> flashcards,
  ) {
    if (flashcards.isEmpty) {
      return _buildTabEmptyState(
        "No flashcard recommendations",
        Icons.style_outlined,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: flashcards.length,
      itemBuilder: (context, index) {
        return _buildFlashcardCard(context, flashcards[index]);
      },
    );
  }

  Widget _buildFlashcardCard(
    BuildContext context,
    FlashcardRecommendation flashcard,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: BBColors.primaryBlue.withOpacity(0.05),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.style, color: BBColors.primaryBlue, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: BBText(
                    data: flashcard.front,
                    style: context.textStyle.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                _buildDifficultyBadge(flashcard.difficulty),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              flashcard.back,
              style: context.textStyle.bodyMedium,
              maxLines: 3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuizzesTab(
    BuildContext context,
    List<QuizRecommendation> quizzes,
  ) {
    if (quizzes.isEmpty) {
      return _buildTabEmptyState(
        "No quiz recommendations",
        Icons.quiz_outlined,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: quizzes.length,
      itemBuilder: (context, index) {
        return _buildQuizCard(context, quizzes[index]);
      },
    );
  }

  Widget _buildQuizCard(BuildContext context, QuizRecommendation quiz) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
              quiz.isAttempted
                  ? BBColors.successGreen.withOpacity(0.3)
                  : BBColors.borderGray,
        ),
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
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: BBColors.primaryBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.quiz,
                    color: BBColors.primaryBlue,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      BBText(
                        data: quiz.displayName,
                        style: context.textStyle.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.help_outline,
                            size: 14,
                            color: BBColors.disabledText,
                          ),
                          const SizedBox(width: 4),
                          BBText(
                            data: "${quiz.numQuestions} questions",
                            style: context.textStyle.bodySmall?.copyWith(
                              color: BBColors.disabledText,
                            ),
                          ),
                          const SizedBox(width: 12),
                          _buildDifficultyBadge(
                            _getDifficultyValue(quiz.difficultyTarget),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (quiz.isAttempted)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: BBColors.successGreen.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.check_circle,
                          size: 14,
                          color: BBColors.successGreen,
                        ),
                        const SizedBox(width: 4),
                        BBText(
                          data: "Attempted",
                          style: context.textStyle.bodySmall?.copyWith(
                            color: BBColors.successGreen,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton.icon(
              onPressed: () {
                // Navigate to quiz
              },
              icon: Icon(
                quiz.isAttempted ? Icons.replay : Icons.play_arrow,
                size: 18,
              ),
              label: Text(quiz.isAttempted ? "Retry Quiz" : "Start Quiz"),
              style: ElevatedButton.styleFrom(
                backgroundColor: BBColors.primaryBlue,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 44),
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

  Widget _buildDifficultyBadge(double difficulty) {
    final color =
        difficulty < 0.4
            ? BBColors.successGreen
            : difficulty < 0.7
            ? BBColors.orangeAccent
            : BBColors.alertRed;

    final label =
        difficulty < 0.4
            ? "Easy"
            : difficulty < 0.7
            ? "Medium"
            : "Hard";

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: BBText(
        data: label,
        style: context.textStyle.bodySmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  double _getDifficultyValue(String target) {
    switch (target.toLowerCase()) {
      case 'easy':
        return 0.3;
      case 'medium':
        return 0.5;
      case 'hard':
        return 0.8;
      default:
        return 0.5;
    }
  }

  Widget _buildTabEmptyState(String message, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: BBColors.disabledText.withOpacity(0.5)),
          const SizedBox(height: 16),
          BBText(
            data: message,
            style: context.textStyle.bodyMedium?.copyWith(
              color: BBColors.disabledText,
            ),
          ),
        ],
      ),
    );
  }
}
