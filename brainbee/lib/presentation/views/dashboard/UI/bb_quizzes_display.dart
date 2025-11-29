import 'package:brainbee/core/constants/bb_colors.dart';
import 'package:brainbee/core/utils/bb_custom_progressbar.dart';
import 'package:brainbee/core/utils/bb_screen_extension.dart';
import 'package:brainbee/core/utils/bb_text.dart';
import 'package:brainbee/presentation/views/home/bloc/student_bloc.dart';
import 'package:brainbee/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BbQuizzesDisplay extends StatefulWidget {
  final String bookId;
  final String title;
  final String description;
  final String imagePath1;
  final String imagePath2;
  final Color color;
  final int? score; // ✅ Added score parameter
  final double? progress; // ✅ Added progress parameter
  final int? quizzesCompleted; // ✅ Added
  final int? totalQuizzes; // ✅ Added

  const BbQuizzesDisplay({
    super.key,
    required this.bookId,
    required this.title,
    required this.description,
    required this.imagePath1,
    required this.imagePath2,
    required this.color,
    this.score, // ✅ Optional score
    this.progress, // ✅ Optional progress
    this.quizzesCompleted, // ✅ Added
    this.totalQuizzes, // ✅ Added
  });

  @override
  State<BbQuizzesDisplay> createState() => _BbQuizzesDisplayState();
}

class _BbQuizzesDisplayState extends State<BbQuizzesDisplay> {
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<StudentBloc, StudentState>(
      listener: (context, state) {
        if (state is StudentDataError) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      builder: (context, state) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          height: context.screenHeight * 0.18,
          width: context.screenWidth,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(widget.imagePath1),
              fit: BoxFit.cover,
            ),
            borderRadius: BorderRadius.circular(10),
            color: BBColors.white,
          ),
          child: Stack(
            children: [
              Positioned(
                left: context.screenWidth * 0.025,
                top: context.screenHeight * 0.01,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _getScoreColor(widget.score!),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: _getScoreColor(widget.score!).withOpacity(0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star, color: Colors.white, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        "${widget.score}%",
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                child: Row(
                  spacing: 15,
                  children: [
                    SizedBox(
                      height: context.screenHeight * 0.3,
                      width: context.screenWidth * 0.35,
                      child: Transform.translate(
                        offset: const Offset(0, 5),
                        child: Image.asset(widget.imagePath2, fit: BoxFit.fill),
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        spacing: 10,
                        children: [
                          BBText(
                            data: widget.title,
                            style: Theme.of(
                              context,
                            ).textTheme.titleMedium?.copyWith(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: BBColors.white,
                            ),
                          ),
                          BBText(
                            data: widget.description,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: BBColors.white,
                            ),
                          ),

                          // ✅ Use dynamic progress if available
                          SizedBox(
                            width: context.screenWidth * 0.5,
                            child: CustomProgressBar(
                              progress: widget.progress ?? 0.0,
                              color: widget.color,
                            ),
                          ),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: BBColors.white,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  "${_getCompletionPercentage(widget.quizzesCompleted, widget.totalQuizzes)}% Complete",
                                  style: TextStyle(
                                    color: widget.color,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                              Container(
                                margin: const EdgeInsets.only(right: 15),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 7,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  border: Border.all(
                                    color: BBColors.white,
                                    width: 1.5,
                                  ),
                                ),
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                    minimumSize: const Size(0, 0),
                                    padding: EdgeInsets.zero,
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                  ),
                                  onPressed: () {
                                    if (state is StudentDataLoaded) {
                                      final student = state.student;
                                      Navigator.pushNamed(
                                        context,
                                        AppRoutes.quizTaking,
                                        arguments: [student, widget.bookId],
                                      );
                                    } else {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Student data not loaded yet.',
                                          ),
                                        ),
                                      );
                                    }
                                  },
                                  child: BBText(
                                    data: "Take Quiz",
                                    style: Theme.of(
                                      context,
                                    ).textTheme.labelLarge?.copyWith(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: BBColors.white,
                                    ),
                                  ),
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
            ],
          ),
        );
      },
    );
  }

  Color _getScoreColor(int score) {
    if (score >= 80) return BBColors.successGreen;
    if (score >= 60) return BBColors.orangeAccent;
    return BBColors.alertRed;
  }

  int _getCompletionPercentage(int? completed, int? total) {
    if (completed == null || total == null || total == 0) return 0;
    return ((completed / total) * 100).round();
  }
}
