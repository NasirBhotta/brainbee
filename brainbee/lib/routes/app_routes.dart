import 'package:brainbee/presentation/views/dashboard/UI/bb_dashboard.dart';
import 'package:brainbee/presentation/views/extras/achievements/badges/UI/bb_badge_detail.dart';
import 'package:brainbee/presentation/views/extras/achievements/badges/UI/bb_badge_view.dart';
import 'package:brainbee/presentation/views/extras/achievements/badges/models/badge_model.dart';
import 'package:brainbee/presentation/views/extras/coinquests/UI/bb_coin_quests.dart';
import 'package:brainbee/presentation/views/home/UI/bb_edit_goals.dart';
import 'package:brainbee/presentation/views/home/models/bb_student_model.dart';
import 'package:brainbee/presentation/views/home/quizzes/UI/bb_list_chapters_topics.dart';
import 'package:brainbee/presentation/views/home/quizzes/UI/bb_quizzes_list.dart';
import 'package:brainbee/presentation/views/home/quizzes/UI/bb_specific_book_quiz_selection.dart';
import 'package:brainbee/presentation/views/home/quizzes/models/book_model.dart';
import 'package:brainbee/presentation/views/learn/flashcards/bb_generate_flashcards.dart';
import 'package:brainbee/presentation/views/onboarding/bb_combined_onbaord.dart';
import 'package:brainbee/routes/dummy_bood_data.dart';
import 'package:flutter/material.dart';

class AppRoutes {
  // Route names
  static const String splash = '/';
  static const String auth = '/auth';
  static const String home = '/home';
  static const String badgeView = '/badge-view';
  static const String badgeDetail = '/badge-detail';
  static const String editGoals = '/edit-goals';
  static const String coinQuests = '/coin-quests';
  static const String quizTaking = '/quiz-taking';
  static const String quizzesList = '/quizzes-list';
  static const String quizGeneration = '/quiz-generation';
  static const String chapterSelection = '/chapter-selection';
  static const String flashCardScreen = '/flashcard-generation';

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      auth: (context) => const BbCombinedOnbaord(),
      home: (context) => const BBDashboard(),
      badgeView: (context) => const BadgesScreen(studentId: 'S001'),
      editGoals: (context) {
        final student =
            ModalRoute.of(context)!.settings.arguments as StudentModel;
        return BBEditGoals(student: student);
      },
      badgeDetail: (context) {
        final badge = ModalRoute.of(context)!.settings.arguments as BbBadge;
        return BadgeDetailScreen(badge: badge);
      },

      coinQuests: (context) {
        final userId = ModalRoute.of(context)!.settings.arguments as String;
        return BBCoinQuestScreen(userId: userId);
      },

      quizTaking: (context) {
        final student =
            ModalRoute.of(context)!.settings.arguments as StudentModel;
        return BbSpecificBookQuizSelection(
          student: student,
          subject: 'Biology',
        );
      },

      quizzesList: (context) {
        final topic = ModalRoute.of(context)!.settings.arguments as Topic;
        return BbQuizzesListScreen(topic: topic);
      },

      chapterSelection: (context) {
        return BbChapterSectionsScreen(bookData: bookData);
      },

      flashCardScreen: (context) {
        return BBFlashCardsScreen();
      },
    };
  }

  // Navigation methods
  static void navigateToAuth(BuildContext context) {
    Navigator.pushReplacementNamed(context, auth);
  }

  static void navigateToHome(BuildContext context) {
    Navigator.pushReplacementNamed(context, home);
  }

  static void navigateToBadgeView(BuildContext context) {
    Navigator.pushNamed(context, badgeView);
  }

  static void navigateToBadgeDetail(BuildContext context, BbBadge badge) {
    Navigator.pushNamed(context, badgeDetail, arguments: badge);
  }

  static void navigateToBadgeDetailAsDialog(
    BuildContext context,
    BbBadge badge,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.all(16),
            child: Container(
              constraints: const BoxConstraints(maxHeight: 600),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: BadgeDetailScreen(badge: badge),
              ),
            ),
          ),
    );
  }
}
