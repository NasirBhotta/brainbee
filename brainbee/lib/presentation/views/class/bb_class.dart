import 'package:brainbee/core/constants/bb_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
        name: 'Mathematics 101',
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
        name: 'Science Process Skills',
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
        title: Text(
          'My Classes',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(color: BBColors.white),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: BBColors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
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
          Text(
            'Enrolled Classes',
            style: Theme.of(context).textTheme.titleMedium,
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
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: BBColors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 100,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
                color: _getSubjectColor(classItem.subject),
              ),
              child: Center(
                child: Text(
                  classItem.subject.substring(0, 1),
                  style: GoogleFonts.poppins(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: BBColors.white,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    classItem.name,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Teacher: ${classItem.teacher}',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: BBColors.bodyText),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    classItem.schedule,
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: BBColors.bodyText),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildProgressIndicator(
                        classItem.completedAssignments,
                        classItem.totalAssignments,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '${classItem.completedAssignments}/${classItem.totalAssignments} assignments',
                        style: Theme.of(context).textTheme.bodySmall,
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
    final double progress = total > 0 ? completed / total : 0;

    return SizedBox(
      width: 100,
      child: Stack(
        children: [
          Container(
            height: 8,
            decoration: BoxDecoration(
              color: BBColors.borderGray,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          FractionallySizedBox(
            widthFactor: progress,
            child: Container(
              height: 8,
              decoration: BoxDecoration(
                color: BBColors.successGreen,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getSubjectColor(String subject) {
    switch (subject.toLowerCase()) {
      case 'mathematics':
        return BBColors.primaryBlue;
      case 'science':
        return BBColors.successGreen;
      case 'english':
        return BBColors.violetAccent;
      case 'history':
        return BBColors.orangeAccent;
      default:
        return BBColors.secondaryColor;
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
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: BBColors.bodyText),
          ),
          const SizedBox(height: 8),
          Text(
            'Check out available classes to enroll',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: BBColors.disabledText),
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
            child: Text(
              'Browse Classes',
              style: Theme.of(
                context,
              ).textTheme.labelLarge?.copyWith(color: BBColors.white),
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
          Text(
            'Failed to retrieve classes',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: BBColors.darkHeading),
          ),
          const SizedBox(height: 8),
          Text(
            'Please check your connection and try again',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: BBColors.bodyText),
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
                child: Text(
                  'Cancel',
                  style: Theme.of(
                    context,
                  ).textTheme.labelLarge?.copyWith(color: BBColors.bodyText),
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
                child: Text(
                  'Retry',
                  style: Theme.of(
                    context,
                  ).textTheme.labelLarge?.copyWith(color: BBColors.white),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ClassDetailScreen extends StatelessWidget {
  final EnrolledClass classItem;

  const ClassDetailScreen({super.key, required this.classItem});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Class Details',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(color: BBColors.white),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: BBColors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 150,
              width: double.infinity,
              color: _getSubjectColor(classItem.subject),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    classItem.name,
                    style: Theme.of(
                      context,
                    ).textTheme.headlineMedium?.copyWith(color: BBColors.white),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    classItem.subject,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: BBColors.white.withOpacity(0.8),
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
                  _buildInfoSection(context, 'Class Information'),
                  _buildInfoItem(context, 'Teacher', classItem.teacher),
                  _buildInfoItem(context, 'Schedule', classItem.schedule),
                  _buildInfoItem(
                    context,
                    'Total Students',
                    classItem.totalStudents.toString(),
                  ),

                  const SizedBox(height: 24),

                  _buildInfoSection(context, 'Progress'),
                  const SizedBox(height: 12),

                  LinearProgressIndicator(
                    value:
                        classItem.totalAssignments > 0
                            ? classItem.completedAssignments /
                                classItem.totalAssignments
                            : 0,
                    backgroundColor: BBColors.borderGray,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      BBColors.successGreen,
                    ),
                    minHeight: 10,
                    borderRadius: BorderRadius.circular(5),
                  ),

                  const SizedBox(height: 12),
                  Text(
                    'You have completed ${classItem.completedAssignments} out of ${classItem.totalAssignments} assignments',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),

                  const SizedBox(height: 24),

                  _buildInfoSection(context, 'Class Actions'),
                  const SizedBox(height: 16),

                  _buildActionButton(
                    context,
                    'View Materials',
                    Icons.book,
                    BBColors.primaryBlue,
                    () {},
                  ),

                  const SizedBox(height: 12),

                  _buildActionButton(
                    context,
                    'Upcoming Assignments',
                    Icons.assignment,
                    BBColors.orangeAccent,
                    () {},
                  ),

                  const SizedBox(height: 12),

                  _buildActionButton(
                    context,
                    'Discussion Forum',
                    Icons.forum,
                    BBColors.violetAccent,
                    () {},
                  ),

                  const SizedBox(height: 12),

                  _buildActionButton(
                    context,
                    'Contact Teacher',
                    Icons.email,
                    BBColors.successGreen,
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
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 4),
        const Divider(color: BBColors.borderGray, thickness: 1),
      ],
    );
  }

  Widget _buildInfoItem(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(value, style: Theme.of(context).textTheme.bodyMedium),
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
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          color: BBColors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: BBColors.bodyText,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Color _getSubjectColor(String subject) {
    switch (subject.toLowerCase()) {
      case 'mathematics':
        return BBColors.primaryBlue;
      case 'science':
        return BBColors.successGreen;
      case 'english':
        return BBColors.violetAccent;
      case 'history':
        return BBColors.orangeAccent;
      default:
        return BBColors.secondaryColor;
    }
  }
}
