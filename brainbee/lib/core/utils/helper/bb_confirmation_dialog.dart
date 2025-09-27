import 'package:brainbee/core/models/bb_question.dart';
import 'package:brainbee/core/widgets/popups/bb_confirmation_dialog.dart';
import 'package:brainbee/presentation/views/learn/battle/bb_battle_report_card.dart';
import 'package:flutter/material.dart';

extension DynamicQuitConfirmationDialogExtension on BuildContext {
  Future<void> showDynamicQuitDialog({
    required String title,
    required String message,
    required VoidCallback onConfirm,
    required QuizType quizType,
    String confirmButtonText = "Quit",
    String cancelButtonText = "Cancel",
    VoidCallback? onCancel,
    // Battle properties
    int? battleScore,
    int? opponentScore,
    List<Question>? battleQuestions,
    List<int?>? battleAnswers,
    int? battleTimeSpent,
    // In-app quiz properties
    int? inAppScore,
    int? correctAnswers,
    int? totalQuestions,
    int? inAppTimeSpent,
    String? quizTitle,
    List<int?>? inAppAnswers,
    List<String>? explanations,
    bool barrierDismissible = true,
  }) {
    return showGeneralDialog(
      context: this,
      barrierDismissible: barrierDismissible,
      barrierLabel: "quit_confirmation_dialog",
      pageBuilder: (_, __, ___) => const SizedBox.shrink(),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.2),
            end: const Offset(0, 0),
          ).animate(
            CurvedAnimation(parent: animation, curve: Curves.easeInOut),
          ),
          child: QuitConfirmationDialog(
            title: title,
            message: message,
            onConfirm: onConfirm,
            quizType: quizType,
            confirmButtonText: confirmButtonText,
            cancelButtonText: cancelButtonText,
            onCancel: onCancel,
            // Battle properties
            battleScore: battleScore,
            opponentScore: opponentScore,
            battleQuestions: battleQuestions,
            battleAnswers: battleAnswers,
            battleTimeSpent: battleTimeSpent,
            // In-app quiz properties
            inAppScore: inAppScore,
            correctAnswers: correctAnswers,
            totalQuestions: totalQuestions,
            inAppTimeSpent: inAppTimeSpent,
            quizTitle: quizTitle,
            inAppAnswers: inAppAnswers,
            explanations: explanations,
          ),
        );
      },
    );
  }
}
