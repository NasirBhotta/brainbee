import 'package:brainbee/core/constants/bb_colors.dart';
import 'package:brainbee/core/utils/bb_screen_extension.dart';
import 'package:brainbee/core/utils/bb_text.dart';
import 'package:brainbee/core/utils/bb_textTheme_extention.dart';
import 'package:brainbee/presentation/views/extras/reportcard/bb_book_analytics.dart';
import 'package:flutter/material.dart';

class ReportCardScreen extends StatelessWidget {
  const ReportCardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<SubjectGrade> grades = [
      SubjectGrade(number: 1, subject: 'Mathematics', score: 80, grade: 'A'),
      SubjectGrade(number: 2, subject: 'Science', score: 100, grade: 'A'),
      SubjectGrade(number: 3, subject: 'English', score: 92, grade: 'A'),
      SubjectGrade(number: 4, subject: 'History', score: 78, grade: 'B'),
      SubjectGrade(number: 5, subject: 'Art', score: 85, grade: 'A'),
      SubjectGrade(
        number: 6,
        subject: 'Physical Education',
        score: 95,
        grade: 'A',
      ),
    ];

    return Scaffold(
      backgroundColor: BBColors.white,
      appBar: AppBar(
        backgroundColor: BBColors.white,
        elevation: 0.5,
        centerTitle: true,
        title: BBText(
          data: 'Report Card for Year 6',
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
      body: Column(
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
                          data: 'YEAR\nGRADE',
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
            child: ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: grades.length,
              itemBuilder: (context, index) {
                final subject = grades[index];
                return Column(
                  children: [
                    GestureDetector(onTap: () {Navigator.push(context, MaterialPageRoute(builder: (context) => const BBBookAnalytics(),));},child: SubjectGradeRow(subject: subject, index: index)),
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
      ),
    );
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
    if (subject.subject == 'Mathematics') {
      subjectColor = BBColors.progressColor1;
    } else if (subject.subject == 'Science') {
      subjectColor = BBColors.progressColor2;
    } else if (subject.subject == 'English') {
      subjectColor = BBColors.progressColor3;
    } else if (subject.subject == 'History') {
      subjectColor = BBColors.progressColor4;
    } else if (subject.subject == 'Art') {
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

  SubjectGrade({
    required this.number,
    required this.subject,
    required this.score,
    required this.grade,
  });
}
