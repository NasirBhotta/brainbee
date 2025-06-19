import 'package:flutter/material.dart';

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
  final Color? primaryColor;
  final Color? backgroundColor;
  final Widget? headerIcon;
  final String? customResultMessage;
  final double? dialogWidth;
  final double? maxWidth;

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
    this.backgroundColor,
    this.headerIcon,
    this.customResultMessage,
    this.dialogWidth = 0.85,
    this.maxWidth = 400,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: Colors.transparent,
        elevation: 0,
        child: Container(
          width: MediaQuery.of(context).size.width * (dialogWidth ?? 0.85),
          constraints: BoxConstraints(maxWidth: maxWidth ?? 400),
          decoration: BoxDecoration(
            color: backgroundColor ?? Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [_buildHeader(context), _buildContent(context)],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 15),
      decoration: BoxDecoration(
        color: primaryColor ?? Theme.of(context).primaryColor,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (headerIcon != null)
            Positioned(
              right: 15,
              top: 0,
              bottom: 0,
              child: Opacity(opacity: 0.2, child: headerIcon!),
            ),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 25, 24, 15),
      child: Column(
        children: [
          _buildResultBadge(context),
          const SizedBox(height: 25),
          _buildScoreSection(context),
          const SizedBox(height: 25),
          _buildActionButton(context),
        ],
      ),
    );
  }

  Widget _buildResultBadge(BuildContext context) {
    final ResultConfig config = _getResultConfig();

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
      decoration: BoxDecoration(
        color: config.backgroundColor,
        borderRadius: BorderRadius.circular(50),
        border: Border.all(color: config.borderColor, width: 1),
      ),
      child: Text(
        customResultMessage ?? config.message,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: config.textColor,
        ),
      ),
    );
  }

  Widget _buildScoreSection(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildScoreCard(userScoreLabel, userScore, Colors.blue),
        Container(
          height: 70,
          width: 1,
          color: Colors.grey.withValues(alpha: 0.2),
        ),
        _buildScoreCard(opponentScoreLabel, opponentScore, Colors.red),
      ],
    );
  }

  Widget _buildScoreCard(String label, int score, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
          ),
          child: Text(
            score.toString(),
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(BuildContext context) {
    final Color buttonColor = primaryColor ?? Theme.of(context).primaryColor;

    return Container(
      width: double.infinity,
      height: 50,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            buttonColor,
            buttonColor.withValues(alpha: 0.8),
            buttonColor.withValues(alpha: 0.9),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(50),
        boxShadow: [
          BoxShadow(
            color: buttonColor.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(50),
          onTap: onActionPressed,
          child: Center(
            child: Text(
              actionButtonText,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                fontSize: 16,
                color: Colors.white,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      ),
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
          message: "It's a Tie!",
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
    String userScoreLabel = "Your Score",
    String opponentScoreLabel = "Opponent",
    String actionButtonText = "Done",
    Color? primaryColor,
    Color? backgroundColor,
    Widget? headerIcon,
    String? customResultMessage,
    double? dialogWidth,
    double? maxWidth,
    bool barrierDismissible = true,
    Duration transitionDuration = const Duration(milliseconds: 300),
  }) {
    return showGeneralDialog(
      context: this,
      barrierDismissible: barrierDismissible,
      barrierLabel: "Dismiss",
      barrierColor: Colors.black.withValues(alpha: 0.7),
      transitionDuration: transitionDuration,
      pageBuilder: (context, animation, secondaryAnimation) {
        return AnimatedBuilder(
          animation: animation,
          builder: (context, child) {
            return Transform.scale(
              scale: Curves.easeOutBack.transform(animation.value),
              child: Opacity(opacity: animation.value, child: child),
            );
          },
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
            backgroundColor: backgroundColor,
            headerIcon: headerIcon,
            customResultMessage: customResultMessage,
            dialogWidth: dialogWidth,
            maxWidth: maxWidth,
          ),
        );
      },
    );
  }
}
