import 'package:brainbee/core/constants/bb_colors.dart';
import 'package:brainbee/core/utils/bb_text.dart';
import 'package:brainbee/core/utils/bb_textTheme_extention.dart';
import 'package:brainbee/presentation/views/class/bb_class_details.dart';
import 'package:flutter/material.dart';

class EnrolledClass {
  final int id;
  final String name;
  final String subject;
  final String teacher;
  final String imageUrl;
  final String schedule;
  final int totalStudents;
  final int completedAssignments;
  final int totalAssignments;

  EnrolledClass({
    required this.id,
    required this.name,
    required this.subject,
    required this.teacher,
    required this.imageUrl,
    required this.schedule,
    required this.totalStudents,
    required this.totalAssignments,
    required this.completedAssignments,
  });
}

class BBClass extends StatefulWidget {
  const BBClass({super.key});

  @override
  State<BBClass> createState() => _BBClassState();
}

class _BBClassState extends State<BBClass> {
  bool _isLoading = true;
  bool _hasError = false;
  List<EnrolledClass>? _enrolledClasses;

  @override
  void initState() {
    super.initState();
    _fetchEnrolledClasses();
  }

  Future<void> _fetchEnrolledClasses() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    await Future.delayed(const Duration(seconds: 2));

    final bool shouldSimulateError =
        ModalRoute.of(context)?.settings.arguments == 'simulateError';
    final bool shouldSimulateNoClasses =
        ModalRoute.of(context)?.settings.arguments == 'simulateNoClasses';

    if (shouldSimulateError) {
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
      return;
    }

    if (shouldSimulateNoClasses) {
      setState(() {
        _isLoading = false;
        _enrolledClasses = [];
      });
      return;
    }

    final mockClasses = [
      EnrolledClass(
        id: 1,
        name: 'Mathematics',
        subject: 'Mathematics',
        teacher: 'Mr. Johnson',
        imageUrl: 'assets/images/math.png',
        schedule: 'Mon, Wed, Fri - 10:00 AM',
        totalStudents: 30,
        totalAssignments: 12,
        completedAssignments: 5,
      ),
      EnrolledClass(
        id: 2,
        name: 'Science',
        subject: 'Science',
        teacher: 'Mrs. Williams',
        imageUrl: 'assets/images/science.png',
        schedule: 'Tue, Thu - 1:30 PM',
        totalStudents: 25,
        totalAssignments: 10,
        completedAssignments: 8,
      ),
      EnrolledClass(
        id: 3,
        name: 'English Literature',
        subject: 'English',
        teacher: 'Ms. Davis',
        imageUrl: 'assets/images/english.png',
        schedule: 'Mon, Wed - 3:00 PM',
        totalStudents: 28,
        totalAssignments: 15,
        completedAssignments: 10,
      ),
      EnrolledClass(
        id: 4,
        name: 'World History',
        subject: 'History',
        teacher: 'Mr. Brown',
        imageUrl: 'assets/images/history.png',
        schedule: 'Tue, Thu - 11:00 AM',
        totalStudents: 22,
        totalAssignments: 8,
        completedAssignments: 3,
      ),
    ];

    setState(() {
      _isLoading = false;
      _enrolledClasses = mockClasses;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: BBColors.lightGrayBG,
        title: BBText(
          data: 'My Classes',
          style: context.textStyle.titleMedium?.copyWith(),
        ),
        centerTitle: true,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(BBColors.secondaryColor),
        ),
      );
    }

    if (_hasError) {
      return _buildErrorState();
    }

    if (_enrolledClasses == null || _enrolledClasses!.isEmpty) {
      return _buildNoClassesState();
    }

    return _buildClassList();
  }

  Widget _buildClassList() {
    return RefreshIndicator(
      onRefresh: _fetchEnrolledClasses,
      color: BBColors.secondaryColor,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          BBText(
            data: 'Enrolled Classes',
            style: context.textStyle.titleMedium?.copyWith(fontSize: 16),
          ),
          const SizedBox(height: 16),
          ..._enrolledClasses!.map((classItem) => _buildClassCard(classItem)),
        ],
      ),
    );
  }

  Widget _buildClassCard(EnrolledClass classItem) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ClassDetailScreen(classItem: classItem),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: _getSubjectColor(classItem.subject),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 80,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                color: Colors.white.withOpacity(0.1),
              ),
              child: Center(
                child: BBText(
                  data: classItem.subject.toUpperCase(),
                  style: context.textStyle.titleSmall?.copyWith(
                    color: BBColors.white,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 6,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  BBText(
                    data: classItem.name,
                    style: context.textStyle.titleMedium?.copyWith(
                      color: BBColors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  BBText(
                    data: 'Teacher: ${classItem.teacher}',
                    style: context.textStyle.bodyMedium?.copyWith(
                      color: BBColors.white.withValues(alpha: 0.85),
                    ),
                  ),
                  const SizedBox(height: 4),
                  BBText(
                    data: classItem.schedule,
                    style: context.textStyle.bodySmall?.copyWith(
                      color: BBColors.white.withOpacity(0.85),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          _buildProgressIndicator(
                            classItem.completedAssignments,
                            classItem.totalAssignments,
                          ),
                          const SizedBox(width: 10),
                          BBText(
                            data:
                                '${classItem.completedAssignments}/${classItem.totalAssignments}',
                            style: context.textStyle.bodySmall?.copyWith(
                              color: BBColors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: BBColors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: BBText(
                          data: 'View',
                          style: context.textStyle.bodySmall?.copyWith(
                            color: BBColors.white,
                            fontWeight: FontWeight.w600,
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
    );
  }

  Widget _buildProgressIndicator(int completed, int total) {
    double progress = total > 0 ? completed / total : 0;
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: BBColors.white.withValues(alpha: 0.1),
      ),
      child: CircularProgressIndicator(
        value: progress,
        strokeWidth: 3,
        backgroundColor: BBColors.white.withValues(alpha: 0.3),
        valueColor: const AlwaysStoppedAnimation<Color>(BBColors.white),
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

  Widget _buildNoClassesState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.school_outlined,
            size: 80,
            color: BBColors.disabledText,
          ),
          const SizedBox(height: 16),
          Text(
            'You are not enrolled in any classes',
            style: context.textStyle.titleMedium?.copyWith(
              color: BBColors.bodyText,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Check out available classes to enroll',
            style: context.textStyle.bodyMedium?.copyWith(
              color: BBColors.disabledText,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: BBColors.primaryColor,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: BBText(
              data: 'Browse Classes',
              style: context.textStyle.labelLarge?.copyWith(
                color: BBColors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 80, color: BBColors.alertRed),
          const SizedBox(height: 16),
          BBText(
            data: 'Failed to retrieve classes',
            style: context.textStyle.titleMedium?.copyWith(
              color: BBColors.darkHeading,
            ),
          ),
          const SizedBox(height: 8),
          BBText(
            data: 'Please check your connection and try again',
            style: context.textStyle.bodyMedium?.copyWith(
              color: BBColors.bodyText,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              OutlinedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: BBColors.bodyText,
                  side: const BorderSide(color: BBColors.borderGray),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: BBText(
                  data: 'Cancel',
                  style: context.textStyle.labelLarge?.copyWith(
                    color: BBColors.bodyText,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: _fetchEnrolledClasses,
                style: ElevatedButton.styleFrom(
                  backgroundColor: BBColors.primaryColor,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: BBText(
                  data: 'Retry',
                  style: context.textStyle.labelLarge?.copyWith(
                    color: BBColors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
