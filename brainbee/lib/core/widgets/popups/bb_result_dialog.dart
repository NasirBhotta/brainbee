import 'package:flutter/material.dart';
import 'package:brainbee/core/constants/bb_colors.dart';
import 'package:brainbee/core/utils/bb_text.dart';
import 'package:brainbee/core/widgets/popups/bb_model_button.dart';

enum ResultType { win, lose, tie }

class ResultDialog extends StatelessWidget {
  final String title;
  final ResultType resultType;
  final int userScore;
  final int opponentScore;
  final String userScoreLabel;
  final String opponentScoreLabel;
  final String actionButtonText;
  final VoidCallback onActionPressed;
  final VoidCallback onCrossPressed;
  final Color? primaryColor;
  final Widget? headerIcon;
  final String? customResultMessage;

  const ResultDialog({
    super.key,
    required this.title,
    required this.resultType,
    required this.userScore,
    required this.opponentScore,
    required this.onActionPressed,
    this.userScoreLabel = "Your Score",
    this.opponentScoreLabel = "Opponent",
    this.actionButtonText = "Done",
    this.primaryColor,
    this.headerIcon,
    this.customResultMessage,
    required this.onCrossPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Stack(
        children: [
          Center(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              decoration: BoxDecoration(
                color: BBColors.lightGrayBG,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Title
                  Center(
                    child: BBText(
                      data: title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Result Badge
                  Center(child: _buildResultBadge(context)),
                  const SizedBox(height: 20),

                  // Score Section
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: (primaryColor ?? BBColors.primaryColor)
                            .withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        BBText(
                          data: "Final Scores",
                          style: Theme.of(
                            context,
                          ).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: primaryColor ?? BBColors.primaryColor,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildScoreRows(context),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Action Button
                  Row(
                    children: [
                      const Expanded(child: SizedBox.shrink()),
                      buildStudyModeButton(
                        context,
                        label: actionButtonText,
                        onTap: onActionPressed,
                      ),
                      const Expanded(child: SizedBox.shrink()),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Close Button
          Align(
            alignment: const Alignment(0.95, -0.375),
            child: InkWell(
              onTap: onCrossPressed,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                decoration: BoxDecoration(
                  color: BBColors.lightGrayBG,
                  borderRadius: BorderRadius.circular(2),
                  boxShadow: const [
                    BoxShadow(
                      color: BBColors.disabledText,
                      spreadRadius: 0.5,
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.close,
                  size: 20,
                  color: BBColors.primaryColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultBadge(BuildContext context) {
    final ResultConfig config = _getResultConfig();

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: config.backgroundColor,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: config.borderColor, width: 1),
      ),
      child: BBText(
        data: customResultMessage ?? config.message,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: config.textColor,
        ),
      ),
    );
  }

  Widget _buildScoreRows(BuildContext context) {
    return Column(
      children: [
        _buildScoreRow(context, userScoreLabel, userScore, Colors.blue),
        const SizedBox(height: 12),
        _buildScoreRow(context, opponentScoreLabel, opponentScore, Colors.red),
      ],
    );
  }

  Widget _buildScoreRow(
    BuildContext context,
    String label,
    int score,
    Color color,
  ) {
    return Row(
      children: [
        Expanded(
          child: BBText(
            data: "$label:",
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
          ),
          child: BBText(
            data: score.toString(),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
      ],
    );
  }

  ResultConfig _getResultConfig() {
    switch (resultType) {
      case ResultType.win:
        return ResultConfig(
          message: "You Win! 🏆",
          backgroundColor: Colors.green.withValues(alpha: 0.1),
          borderColor: Colors.green.withValues(alpha: 0.3),
          textColor: Colors.green.shade700,
        );
      case ResultType.tie:
        return ResultConfig(
          message: "It's a Tie! 🤝",
          backgroundColor: Colors.amber.withValues(alpha: 0.1),
          borderColor: Colors.amber.withValues(alpha: 0.3),
          textColor: Colors.amber.shade700,
        );
      case ResultType.lose:
        return ResultConfig(
          message: "You Lost! 😔",
          backgroundColor: Colors.red.withValues(alpha: 0.1),
          borderColor: Colors.red.withValues(alpha: 0.3),
          textColor: Colors.red.shade700,
        );
    }
  }
}

class ResultConfig {
  final String message;
  final Color backgroundColor;
  final Color borderColor;
  final Color textColor;

  ResultConfig({
    required this.message,
    required this.backgroundColor,
    required this.borderColor,
    required this.textColor,
  });
}

// Extension method for easy usage
extension ResultDialogExtension on BuildContext {
  Future<void> showResultDialog({
    required String title,
    required ResultType resultType,
    required int userScore,
    required int opponentScore,
    required VoidCallback onActionPressed,
    required VoidCallback onCrossPressed,
    required VoidCallback onPressedOutside,
    String userScoreLabel = "Your Score",
    String opponentScoreLabel = "Opponent",
    String actionButtonText = "Done",
    Color? primaryColor,
    Widget? headerIcon,
    String? customResultMessage,
    bool barrierDismissible = true,
    Duration transitionDuration = const Duration(milliseconds: 300),
  }) {
    return showGeneralDialog(
      context: this,
      barrierDismissible: barrierDismissible,
      barrierLabel: "result",
      pageBuilder: (_, __, ___) => const SizedBox.shrink(),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.2),
            end: const Offset(0, 0),
          ).animate(
            CurvedAnimation(parent: animation, curve: Curves.easeInOut),
          ),
          child: ResultDialog(
            title: title,
            resultType: resultType,
            userScore: userScore,
            opponentScore: opponentScore,
            onActionPressed: onActionPressed,
            userScoreLabel: userScoreLabel,
            opponentScoreLabel: opponentScoreLabel,
            actionButtonText: actionButtonText,
            primaryColor: primaryColor,
            headerIcon: headerIcon,
            customResultMessage: customResultMessage,
            onCrossPressed: onCrossPressed,
          ),
        );
      },
    ).then((_) {
      onPressedOutside();
    });
  }
}
