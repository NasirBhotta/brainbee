import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/grade_model.dart';
import '../services/grade_service.dart';
import '../utils/helpers.dart';

class ClassGradesTab extends StatelessWidget {
  final String classId;

  const ClassGradesTab({super.key, required this.classId});

  @override
  Widget build(BuildContext context) {
    return Consumer<GradeService>(
      builder: (context, gradeService, child) {
        final grades = mockGrades.where((g) => g.classId == classId).toList();
        final performanceTrend = mockPerformanceTrend;

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Performance Trend',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 200,
                      child: LineChart(
                        LineChartData(
                          gridData: FlGridData(show: false),
                          titlesData: FlTitlesData(show: false),
                          borderData: FlBorderData(show: false),
                          lineBarsData: [
                            LineChartBarData(
                              spots: performanceTrend.dataPoints
                                  .map((point) => FlSpot(
                                      point.date.millisecondsSinceEpoch.toDouble(),
                                      point.score))
                                  .toList(),
                              isCurved: true,
                              color: Colors.blue,
                              barWidth: 3,
                              dotData: FlDotData(show: true),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            ...grades.map((grade) => Card(
              child: ExpansionTile(
                title: Text(grade.title),
                subtitle: Text(
                  '${grade.type} • ${Helpers.formatDate(grade.gradedDate)}',
                ),
                trailing: Text(
                  '${grade.score}/${grade.maxScore}',
                  style: TextStyle(
                    color: Helpers.getGradeColor(grade.percentage),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Feedback: ${grade.feedback}'),
                        const SizedBox(height: 8),
                        ...grade.criteria.map((criterion) => Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              criterion.name,
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                            LinearProgressIndicator(
                              value: criterion.score / criterion.maxScore,
                              backgroundColor: Colors.grey[200],
                              valueColor: AlwaysStoppedAnimation(
                                Helpers.getGradeColor(criterion.percentage),
                              ),
                            ),
                            Text(
                              '${criterion.score}/${criterion.maxScore} - ${criterion.feedback}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            const SizedBox(height: 8),
                          ],
                        )).toList(),
                      ],
                    ),
                  ),
                ],
              ),
            )).toList(),
          ],
        );
      },
    );
  }
}