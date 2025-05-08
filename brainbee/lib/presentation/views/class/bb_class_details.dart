import 'package:brainbee/core/constants/bb_colors.dart';
import 'package:brainbee/core/utils/bb_text.dart';
import 'package:brainbee/presentation/views/class/bb_class.dart';
import 'package:flutter/material.dart';

class ClassDetailScreen extends StatelessWidget {
  final EnrolledClass classItem;

  const ClassDetailScreen({super.key, required this.classItem});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: _getSubjectColor(classItem.subject),
        elevation: 0,
        title: BBText(
          data: classItem.name,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _getSubjectColor(classItem.subject),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  BBText(
                    data: 'Teacher: ${classItem.teacher}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoSection(context, 'Details'),
                  _buildInfoItem(context, 'Schedule', classItem.schedule),
                  _buildInfoItem(
                    context,
                    'Students',
                    classItem.totalStudents.toString(),
                  ),
                  const SizedBox(height: 24),
                  _buildInfoSection(context, 'Progress'),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildProgressIndicator(
                        classItem.completedAssignments,
                        classItem.totalAssignments,
                      ),
                      const SizedBox(width: 12),
                      BBText(
                        data:
                            '${classItem.completedAssignments}/${classItem.totalAssignments} Assignments',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[800],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildInfoSection(context, 'Actions'),
                  const SizedBox(height: 12),
                  _buildActionButton(
                    context,
                    'View Materials',
                    Icons.book,
                    Colors.blueAccent,
                    () {},
                  ),
                  const SizedBox(height: 12),
                  _buildActionButton(
                    context,
                    'Assignments',
                    Icons.assignment,
                    Colors.orangeAccent,
                    () {},
                  ),
                  const SizedBox(height: 12),
                  _buildActionButton(
                    context,
                    'Forum',
                    Icons.forum,
                    Colors.purpleAccent,
                    () {},
                  ),
                  const SizedBox(height: 12),
                  _buildActionButton(
                    context,
                    'Contact Teacher',
                    Icons.email,
                    Colors.green,
                    () {},
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection(BuildContext context, String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BBText(
          data: title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: Colors.grey[900],
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        Divider(color: Colors.grey[300], thickness: 1),
      ],
    );
  }

  Widget _buildInfoItem(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: BBText(
              data: label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[700],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: BBText(
              data: value,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey[800]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
        decoration: BoxDecoration(
          color: BBColors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: BBColors.black.withValues(alpha: 0.08),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: BBText(
                data: title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: BBColors.bodyText,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: BBColors.disabledText,
              size: 14,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressIndicator(int completed, int total) {
    double progress = total > 0 ? completed / total : 0;
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: BBColors.white,
        boxShadow: [
          BoxShadow(
            color: BBColors.black.withValues(alpha: 0.08),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: CircularProgressIndicator(
        value: progress,
        strokeWidth: 3,
        backgroundColor: BBColors.borderGray,
        valueColor: AlwaysStoppedAnimation<Color>(
          _getSubjectColor(classItem.subject),
        ),
      ),
    );
  }

  Color _getSubjectColor(String subject) {
    switch (subject.toLowerCase()) {
      case 'mathematics':
        return BBColors.progressColor1;
      case 'science':
        return BBColors.progressColor2;
      case 'english':
        return BBColors.progressColor3;
      case 'history':
        return BBColors.progressColor4;
      default:
        return BBColors.progressColor4;
    }
  }
}
