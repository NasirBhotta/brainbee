// models/assignment_models.dart
// screens/class_assignments_screen.dart
import 'package:flutter/material.dart';
import 'package:brainbee/core/constants/bb_colors.dart';
import 'package:file_picker/file_picker.dart';

class Assignment {
  final String id;
  final String title;
  final String description;
  final DateTime dueDate;
  final AssignmentStatus status;
  final String teacherName;
  final List<AssignmentFile> attachedFiles;
  final String? submissionType;
  final String? evaluationCriteria;
  final DateTime createdDate;
  final AssignmentSubmission? submission;

  Assignment({
    required this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.status,
    required this.teacherName,
    required this.attachedFiles,
    this.submissionType,
    this.evaluationCriteria,
    required this.createdDate,
    this.submission,
  });

  bool get isOverdue =>
      DateTime.now().isAfter(dueDate) && status != AssignmentStatus.submitted;
  bool get canSubmit => !isOverdue && status != AssignmentStatus.submitted;

  String get statusText {
    switch (status) {
      case AssignmentStatus.pending:
        return isOverdue ? 'Overdue' : 'Pending';
      case AssignmentStatus.submitted:
        return 'Submitted';
      case AssignmentStatus.graded:
        return 'Graded';
    }
  }

  Color get statusColor {
    switch (status) {
      case AssignmentStatus.pending:
        return isOverdue ? Colors.red : Colors.orange;
      case AssignmentStatus.submitted:
        return Colors.blue;
      case AssignmentStatus.graded:
        return Colors.green;
    }
  }
}

enum AssignmentStatus { pending, submitted, graded }

class AssignmentFile {
  final String id;
  final String name;
  final String type;
  final String url;
  final int size;

  AssignmentFile({
    required this.id,
    required this.name,
    required this.type,
    required this.url,
    required this.size,
  });

  String get formattedSize {
    if (size < 1024) return '${size}B';
    if (size < 1024 * 1024) return '${(size / 1024).toStringAsFixed(1)}KB';
    if (size < 1024 * 1024 * 1024) {
      return '${(size / (1024 * 1024)).toStringAsFixed(1)}MB';
    }
    return '${(size / (1024 * 1024 * 1024)).toStringAsFixed(1)}GB';
  }

  IconData get typeIcon {
    switch (type.toLowerCase()) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'image':
      case 'jpg':
      case 'png':
        return Icons.image;
      default:
        return Icons.insert_drive_file;
    }
  }
}

class AssignmentSubmission {
  final String id;
  final DateTime submittedDate;
  final List<AssignmentFile> submittedFiles;
  final String? grade;
  final String? feedback;

  AssignmentSubmission({
    required this.id,
    required this.submittedDate,
    required this.submittedFiles,
    this.grade,
    this.feedback,
  });
}

class ClassAssignmentsScreen extends StatefulWidget {
  final String classId;
  final String className;
  final String teacherName;

  const ClassAssignmentsScreen({
    super.key,
    required this.classId,
    required this.className,
    required this.teacherName,
  });

  @override
  State<ClassAssignmentsScreen> createState() => _ClassAssignmentsScreenState();
}

class _ClassAssignmentsScreenState extends State<ClassAssignmentsScreen> {
  bool _isLoading = false;
  bool _hasError = false;
  List<Assignment> _assignments = [];

  @override
  void initState() {
    super.initState();
    _loadAssignments();
  }

  Future<void> _loadAssignments() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      // Mock data
      _assignments = [
        Assignment(
          id: '1',
          title: 'Algebra Problem Set 3',
          description:
              'Complete the quadratic equations worksheet. Show all work and explain your reasoning for each problem.',
          dueDate: DateTime.now().add(const Duration(days: 3)),
          status: AssignmentStatus.pending,
          teacherName: widget.teacherName,
          attachedFiles: [
            AssignmentFile(
              id: 'f1',
              name: 'Quadratic_Worksheet.pdf',
              type: 'pdf',
              url: 'https://example.com/worksheet.pdf',
              size: 1024000,
            ),
          ],
          submissionType: 'PDF or Word Document',
          evaluationCriteria: 'Work shown (40%), Correct answers (60%)',
          createdDate: DateTime.now().subtract(const Duration(days: 2)),
        ),
        Assignment(
          id: '2',
          title: 'Chapter 4 Summary',
          description:
              'Write a 2-page summary of Chapter 4 covering linear functions and their applications.',
          dueDate: DateTime.now().subtract(const Duration(hours: 2)), // Overdue
          status: AssignmentStatus.pending,
          teacherName: widget.teacherName,
          attachedFiles: [],
          submissionType: 'Word Document or PDF',
          evaluationCriteria:
              'Content understanding (50%), Writing quality (30%), Format (20%)',
          createdDate: DateTime.now().subtract(const Duration(days: 5)),
        ),
        Assignment(
          id: '3',
          title: 'Midterm Practice Problems',
          description: 'Complete practice problems 1-20 from the study guide.',
          dueDate: DateTime.now().add(const Duration(days: 7)),
          status: AssignmentStatus.submitted,
          teacherName: widget.teacherName,
          attachedFiles: [
            AssignmentFile(
              id: 'f2',
              name: 'Practice_Problems.pdf',
              type: 'pdf',
              url: 'https://example.com/practice.pdf',
              size: 2048000,
            ),
            AssignmentFile(
              id: 'f3',
              name: 'Answer_Sheet.docx',
              type: 'docx',
              url: 'https://example.com/answers.docx',
              size: 512000,
            ),
          ],
          submissionType: 'Any format',
          createdDate: DateTime.now().subtract(const Duration(days: 1)),
          submission: AssignmentSubmission(
            id: 's1',
            submittedDate: DateTime.now().subtract(const Duration(hours: 12)),
            submittedFiles: [
              AssignmentFile(
                id: 'sf1',
                name: 'My_Solutions.pdf',
                type: 'pdf',
                url: 'local://my_solutions.pdf',
                size: 1536000,
              ),
            ],
          ),
        ),
      ];

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BBColors.lightGrayBG,
      appBar: AppBar(
        backgroundColor: BBColors.secondaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Assignments',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              widget.className,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.white70),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadAssignments,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(BBColors.primaryColor),
        ),
      );
    }

    if (_hasError) {
      return _buildErrorState();
    }

    if (_assignments.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _loadAssignments,
      color: BBColors.primaryColor,
      child: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: _assignments.length,
        itemBuilder: (context, index) {
          return _buildAssignmentCard(_assignments[index]);
        },
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: BBColors.alertRed),
          const SizedBox(height: 16),
          Text(
            'Failed to load assignments',
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
          ElevatedButton(
            onPressed: _loadAssignments,
            style: ElevatedButton.styleFrom(
              backgroundColor: BBColors.primaryColor,
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.assignment_outlined,
            size: 64,
            color: BBColors.disabledText,
          ),
          const SizedBox(height: 16),
          Text(
            'No assignments available',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: BBColors.darkHeading),
          ),
          const SizedBox(height: 8),
          Text(
            'No assignments have been posted yet.\nCheck back later for new assignments.',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: BBColors.bodyText),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _loadAssignments,
            style: ElevatedButton.styleFrom(
              backgroundColor: BBColors.primaryColor,
            ),
            child: const Text('Refresh'),
          ),
        ],
      ),
    );
  }

  Widget _buildAssignmentCard(Assignment assignment) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side:
            assignment.isOverdue &&
                    assignment.status == AssignmentStatus.pending
                ? BorderSide(
                  color: BBColors.alertRed.withOpacity(0.3),
                  width: 1,
                )
                : BorderSide.none,
      ),
      child: InkWell(
        onTap: () => _navigateToAssignmentDetails(assignment),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient:
                assignment.isOverdue &&
                        assignment.status == AssignmentStatus.pending
                    ? LinearGradient(
                      colors: [
                        BBColors.alertRed.withOpacity(0.05),
                        Colors.transparent,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                    : null,
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        assignment.title,
                        style: Theme.of(
                          context,
                        ).textTheme.titleMedium?.copyWith(
                          color: BBColors.darkHeading,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: assignment.statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        assignment.statusText,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: assignment.statusColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  assignment.description,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: BBColors.bodyText),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.schedule,
                      size: 16,
                      color:
                          assignment.isOverdue
                              ? BBColors.alertRed
                              : BBColors.bodyText,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Due: ${_formatDate(assignment.dueDate)}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color:
                            assignment.isOverdue
                                ? BBColors.alertRed
                                : BBColors.bodyText,
                        fontWeight:
                            assignment.isOverdue
                                ? FontWeight.w600
                                : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
                if (assignment.attachedFiles.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.attach_file,
                        size: 16,
                        color: BBColors.primaryColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${assignment.attachedFiles.length} file(s) attached',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: BBColors.primaryColor,
                        ),
                      ),
                    ],
                  ),
                ],
                if (assignment.submission != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.check_circle,
                        size: 16,
                        color: BBColors.successGreen,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Submitted ${_formatDate(assignment.submission!.submittedDate)}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: BBColors.successGreen,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToAssignmentDetails(Assignment assignment) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => AssignmentDetailsScreen(
              assignment: assignment,
              onAssignmentUpdated: () => _loadAssignments(),
            ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now);

    if (difference.inDays > 0) {
      return '${difference.inDays} days';
    } else if (difference.inDays == 0) {
      if (difference.inHours > 0) {
        return '${difference.inHours} hours';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes} minutes';
      } else {
        return 'Now';
      }
    } else {
      return '${difference.inDays.abs()} days ago';
    }
  }
}

// screens/assignment_details_screen.dart
class AssignmentDetailsScreen extends StatefulWidget {
  final Assignment assignment;
  final VoidCallback onAssignmentUpdated;

  const AssignmentDetailsScreen({
    super.key,
    required this.assignment,
    required this.onAssignmentUpdated,
  });

  @override
  State<AssignmentDetailsScreen> createState() =>
      _AssignmentDetailsScreenState();
}

class _AssignmentDetailsScreenState extends State<AssignmentDetailsScreen> {
  List<PlatformFile> _selectedFiles = [];
  bool _isSubmitting = false;

  Future<void> _pickFiles() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'png', 'zip'],
      );

      if (result != null) {
        setState(() {
          _selectedFiles = result.files;
        });
      }
    } catch (e) {
      _showErrorDialog('Failed to pick files. Please try again.');
    }
  }

  Future<void> _submitAssignment() async {
    if (_selectedFiles.isEmpty) {
      _showErrorDialog('Please select at least one file to submit.');
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // Simulate upload
      await Future.delayed(const Duration(seconds: 3));

      // Simulate random failure (20% chance)
      if (DateTime.now().millisecond % 5 == 0) {
        throw Exception('Upload failed');
      }

      // Success
      _showSuccessDialog();
    } catch (e) {
      _showSubmissionErrorDialog();
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            title: Row(
              children: [
                const Icon(
                  Icons.check_circle,
                  color: BBColors.successGreen,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Submission Successful',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: BBColors.darkHeading,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your assignment has been submitted successfully!',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: BBColors.bodyText),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: BBColors.successGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Submission Details:',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: BBColors.darkHeading,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Time: ${DateTime.now().toString().substring(0, 19)}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: BBColors.bodyText,
                        ),
                      ),
                      Text(
                        'Files: ${_selectedFiles.length} file(s)',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: BBColors.bodyText,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                  Navigator.pop(context); // Go back to assignments list
                  widget.onAssignmentUpdated();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: BBColors.successGreen,
                ),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  void _showSubmissionErrorDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Row(
              children: [
                const Icon(Icons.error, color: BBColors.alertRed, size: 24),
                const SizedBox(width: 8),
                Text(
                  'Submission Failed',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: BBColors.darkHeading,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            content: Text(
              'Failed to submit your assignment. Please check your connection and try again.',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: BBColors.bodyText),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: BBColors.disabledText),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _submitAssignment();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: BBColors.alertRed,
                ),
                child: const Text('Retry'),
              ),
            ],
          ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              'Error',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(color: BBColors.alertRed),
            ),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BBColors.lightGrayBG,
      appBar: AppBar(
        backgroundColor: BBColors.secondaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Assignment Details',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAssignmentHeader(),
            const SizedBox(height: 20),
            _buildAssignmentDetails(),
            const SizedBox(height: 20),
            if (widget.assignment.attachedFiles.isNotEmpty) ...[
              _buildAttachedFiles(),
              const SizedBox(height: 20),
            ],
            if (widget.assignment.submission != null)
              _buildSubmissionStatus()
            else if (widget.assignment.canSubmit)
              _buildSubmissionSection()
            else
              _buildCannotSubmitMessage(),
          ],
        ),
      ),
    );
  }

  Widget _buildAssignmentHeader() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [
              widget.assignment.statusColor.withOpacity(0.1),
              Colors.transparent,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.assignment.title,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: BBColors.darkHeading,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: widget.assignment.statusColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    widget.assignment.statusText,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: widget.assignment.statusColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.schedule,
                  size: 18,
                  color:
                      widget.assignment.isOverdue
                          ? BBColors.alertRed
                          : BBColors.bodyText,
                ),
                const SizedBox(width: 6),
                Text(
                  'Due: ${widget.assignment.dueDate.toString().substring(0, 16)}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color:
                        widget.assignment.isOverdue
                            ? BBColors.alertRed
                            : BBColors.bodyText,
                    fontWeight:
                        widget.assignment.isOverdue
                            ? FontWeight.w600
                            : FontWeight.normal,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.person, size: 18, color: BBColors.bodyText),
                const SizedBox(width: 6),
                Text(
                  'Assigned by: ${widget.assignment.teacherName}',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: BBColors.bodyText),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAssignmentDetails() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Instructions',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: BBColors.darkHeading,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.assignment.description,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: BBColors.bodyText),
            ),
            if (widget.assignment.submissionType != null) ...[
              const SizedBox(height: 16),
              Text(
                'Submission Type',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: BBColors.darkHeading,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                widget.assignment.submissionType!,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: BBColors.bodyText),
              ),
            ],
            if (widget.assignment.evaluationCriteria != null) ...[
              const SizedBox(height: 16),
              Text(
                'Evaluation Criteria',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: BBColors.darkHeading,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                widget.assignment.evaluationCriteria!,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: BBColors.bodyText),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAttachedFiles() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Attached Files',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: BBColors.darkHeading,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            ...widget.assignment.attachedFiles.map(
              (file) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: BBColors.lightGrayBG,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: BBColors.borderGray),
                ),
                child: Row(
                  children: [
                    Icon(file.typeIcon, color: BBColors.primaryColor, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            file.name,
                            style: Theme.of(
                              context,
                            ).textTheme.bodyMedium?.copyWith(
                              color: BBColors.darkHeading,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            file.formattedSize,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: BBColors.bodyText),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => _downloadFile(file),
                      icon: const Icon(
                        Icons.download,
                        color: BBColors.primaryColor,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmissionStatus() {
    final submission = widget.assignment.submission!;
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [
              BBColors.successGreen.withOpacity(0.1),
              Colors.transparent,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.check_circle,
                  color: BBColors.successGreen,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Assignment Submitted',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: BBColors.darkHeading,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(
                  Icons.access_time,
                  size: 16,
                  color: BBColors.bodyText,
                ),
                const SizedBox(width: 6),
                Text(
                  'Submitted: ${submission.submittedDate.toString().substring(0, 16)}',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: BBColors.bodyText),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Submitted Files',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: BBColors.darkHeading,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            ...submission.submittedFiles.map(
              (file) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: BBColors.successGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: BBColors.successGreen.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(file.typeIcon, color: BBColors.successGreen, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            file.name,
                            style: Theme.of(
                              context,
                            ).textTheme.bodyMedium?.copyWith(
                              color: BBColors.darkHeading,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            file.formattedSize,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: BBColors.bodyText),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.check_circle,
                      color: BBColors.successGreen,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
            if (submission.grade != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: BBColors.primaryBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Grade: ${submission.grade}',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: BBColors.primaryBlue,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (submission.feedback != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Feedback:',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: BBColors.darkHeading,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        submission.feedback!,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: BBColors.bodyText,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSubmissionSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Submit Assignment',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: BBColors.darkHeading,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            if (_selectedFiles.isEmpty) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: BBColors.lightGrayBG,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: BBColors.borderGray,
                    style: BorderStyle.solid,
                  ),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.cloud_upload_outlined,
                      size: 48,
                      color: BBColors.disabledText,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'No files selected',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: BBColors.disabledText,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tap below to select files for submission',
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: BBColors.bodyText),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ] else ...[
              Text(
                'Selected Files:',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: BBColors.darkHeading,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              ..._selectedFiles.map(
                (file) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: BBColors.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: BBColors.primaryColor.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.insert_drive_file,
                        color: BBColors.primaryColor,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              file.name,
                              style: Theme.of(
                                context,
                              ).textTheme.bodyMedium?.copyWith(
                                color: BBColors.darkHeading,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              '${(file.size / 1024).toStringAsFixed(1)} KB',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: BBColors.bodyText),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _selectedFiles.remove(file);
                          });
                        },
                        icon: const Icon(
                          Icons.close,
                          color: BBColors.alertRed,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _isSubmitting ? null : _pickFiles,
                    icon: const Icon(Icons.attach_file),
                    label: Text(
                      _selectedFiles.isEmpty
                          ? 'Select Files'
                          : 'Add More Files',
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: BBColors.primaryColor,
                      side: const BorderSide(color: BBColors.primaryColor),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed:
                        (_selectedFiles.isNotEmpty && !_isSubmitting)
                            ? _submitAssignment
                            : null,
                    icon:
                        _isSubmitting
                            ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                            : const Icon(Icons.send),
                    label: Text(_isSubmitting ? 'Submitting...' : 'Submit'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: BBColors.primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCannotSubmitMessage() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [BBColors.alertRed.withOpacity(0.1), Colors.transparent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            const Icon(Icons.block, size: 48, color: BBColors.alertRed),
            const SizedBox(height: 12),
            Text(
              'Submission Not Available',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: BBColors.darkHeading,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.assignment.isOverdue
                  ? 'This assignment is overdue. Submission is no longer allowed.'
                  : 'Submission is not available for this assignment.',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: BBColors.bodyText),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _downloadFile(AssignmentFile file) async {
    // Simulate download
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            title: const Text('Downloading...'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    BBColors.primaryColor,
                  ),
                ),
                const SizedBox(height: 16),
                Text('Downloading ${file.name}'),
              ],
            ),
          ),
    );

    // Simulate download delay
    await Future.delayed(const Duration(seconds: 2));

    Navigator.pop(context); // Close progress dialog

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${file.name} downloaded successfully'),
        backgroundColor: BBColors.successGreen,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
