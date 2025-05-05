import 'package:flutter/material.dart';
import '../models/class_model.dart';
import '../utils/helpers.dart';

class ClassCard extends StatelessWidget {
  final ClassModel classData;
  final VoidCallback onTap;

  const ClassCard({
    super.key,
    required this.classData,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: Image.network(
                classData.imageUrl,
                height: 120,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    classData.name,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Teacher: ${classData.teacherName}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildStat(Icons.book, '${classData.materialsCount} Materials'),
                      const SizedBox(width: 16),
                      _buildStat(Icons.assignment, '${classData.assignmentsCount} Assignments'),
                      const SizedBox(width: 16),
                      _buildStat(Icons.quiz, '${classData.quizzesCount} Quizzes'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: classData.overallGrade / 100,
                    backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                    valueColor: AlwaysStoppedAnimation(
                      Helpers.getGradeColor(classData.overallGrade),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Overall Grade: ${classData.overallGrade.toStringAsFixed(1)}%',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStat(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}