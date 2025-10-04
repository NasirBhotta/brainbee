// lib/presentation/views/extras/reportcard/report_card_screen.dart

import 'package:brainbee/core/constants/bb_colors.dart';
import 'package:brainbee/core/utils/bb_screen_extension.dart';
import 'package:brainbee/core/utils/bb_text.dart';
import 'package:brainbee/core/utils/bb_textTheme_extention.dart';
import 'package:brainbee/presentation/views/extras/score_&_reportcard/reportcard/bb_book_analytics.dart';
import 'package:brainbee/presentation/views/extras/score_&_reportcard/scorecard/bloc/book_score_bloc.dart';
import 'package:brainbee/presentation/views/extras/score_&_reportcard/scorecard/model/bb_book_score.model.dart';
import 'package:brainbee/presentation/views/extras/score_&_reportcard/scorecard/repo/score_repo_impl.dart';
import 'package:brainbee/presentation/views/extras/score_&_reportcard/scorecard/services/score_api_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ReportCardScreen extends StatelessWidget {
  const ReportCardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create:
          (context) => BookScoreBloc(
            repository: ScoreRepositoryImpl(apiService: ScoreApiService()),
          )..add(LoadOverallScore()),
      child: const _ReportCardScreenContent(),
    );
  }
}

class _ReportCardScreenContent extends StatelessWidget {
  const _ReportCardScreenContent();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BBColors.white,
      appBar: AppBar(
        backgroundColor: BBColors.white,
        elevation: 0.5,
        centerTitle: true,
        title: BBText(
          data: 'Report Card',
          style: context.textStyle.titleMedium,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: BBColors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: BBColors.borderGray, height: 1.0),
        ),
      ),
      body: BlocBuilder<BookScoreBloc, BookScoreState>(
        builder: (context, state) {
          if (state is OverallScoreLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is OverallScoreError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: BBColors.alertRed,
                  ),
                  const SizedBox(height: 16),
                  const Text("Failed to load report card"),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed:
                        () => context.read<BookScoreBloc>().add(
                          LoadOverallScore(),
                        ),
                    child: const Text("Retry"),
                  ),
                ],
              ),
            );
          }

          if (state is OverallScoreEmpty) {
            return const Center(child: Text("No scores available yet"));
          }

          if (state is OverallScoreLoaded) {
            return _buildReportCard(context, state.data);
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildReportCard(BuildContext context, OverallScoreData data) {
    // Convert SubjectScore to display format
    final grades =
        data.subjectScores.asMap().entries.map((entry) {
          return SubjectGrade(
            number: entry.key + 1,
            subject: entry.value.subject,
            score: entry.value.score,
            grade: _getGradeFromScore(entry.value.score),
            bookId: entry.value.id,
          );
        }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: context.screenWidth,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: BBColors.borderGray.withValues(alpha: 0.5),
                width: 1,
              ),
            ),
          ),
          child: BBText(
            data: 'Report Card',
            style: context.textStyle.headlineMedium?.copyWith(
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: BBColors.borderGray, width: 1),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 30,
                  child: BBText(
                    data: '#',
                    style: context.textStyle.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Expanded(
                  child: BBText(
                    data: 'SUBJECT',
                    style: context.textStyle.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 50),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      BBText(
                        data: 'SCORE',
                        textAlign: TextAlign.center,
                        style: context.textStyle.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      BBText(
                        data: 'GRADE',
                        textAlign: TextAlign.center,
                        style: context.textStyle.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child:
              grades.isEmpty
                  ? const Center(child: Text("No subjects available"))
                  : ListView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: grades.length,
                    itemBuilder: (context, index) {
                      final subject = grades[index];
                      return Column(
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => BBBookAnalytics(
                                        bookId: subject.bookId,
                                        bookTitle: subject.subject,
                                      ),
                                ),
                              );
                            },
                            child: SubjectGradeRow(
                              subject: subject,
                              index: index,
                            ),
                          ),
                          if (index < grades.length - 1)
                            Divider(
                              height: 1,
                              thickness: 1,
                              color: BBColors.borderGray.withValues(alpha: 0.2),
                              indent: 24,
                              endIndent: 24,
                            ),
                        ],
                      );
                    },
                  ),
        ),
      ],
    );
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
}

class SubjectGradeRow extends StatelessWidget {
  final SubjectGrade subject;
  final int index;

  const SubjectGradeRow({
    super.key,
    required this.subject,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    Color subjectColor;
    final subjectLower = subject.subject.toLowerCase();

    if (subjectLower.contains('math')) {
      subjectColor = BBColors.progressColor1;
    } else if (subjectLower.contains('science') ||
        subjectLower.contains('biology') ||
        subjectLower.contains('physics') ||
        subjectLower.contains('chemistry')) {
      subjectColor = BBColors.progressColor2;
    } else if (subjectLower.contains('english')) {
      subjectColor = BBColors.progressColor3;
    } else if (subjectLower.contains('history')) {
      subjectColor = BBColors.progressColor4;
    } else {
      subjectColor = BBColors.progressColor1;
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 15),
      child: Row(
        children: [
          SizedBox(
            width: 30,
            child: BBText(
              data: '${subject.number}',
              style: context.textStyle.bodyMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Expanded(
            child: BBText(
              data: subject.subject,
              style: context.textStyle.bodyMedium?.copyWith(
                fontWeight: FontWeight.w400,
                color: BBColors.primaryColor,
              ),
            ),
          ),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: subjectColor.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: subject.score / 100,
              child: Container(
                decoration: BoxDecoration(
                  color: BBColors.primaryColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                BBText(
                  data: '${subject.score}%',
                  textAlign: TextAlign.center,
                  style: context.textStyle.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w400,
                    color: BBColors.bodyText,
                  ),
                ),
                BBText(
                  data: subject.grade,
                  textAlign: TextAlign.center,
                  style: context.textStyle.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SubjectGrade {
  final int number;
  final String subject;
  final int score;
  final String grade;
  final String bookId;

  SubjectGrade({
    required this.number,
    required this.subject,
    required this.score,
    required this.grade,
    required this.bookId,
  });
}
