import 'package:brainbee/presentation/views/class/bloc/assignment/bloc/assignment_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'package:brainbee/core/constants/bb_colors.dart';
import 'package:brainbee/presentation/views/class/models/assignment_model.dart';

class ClassAssignmentsScreen extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return _AssignmentsView(
      classId: classId,
      className: className,
      teacherName: teacherName,
    );
  }
}

class _AssignmentsView extends StatefulWidget {
  final String classId;
  final String className;
  final String teacherName;

  const _AssignmentsView({
    required this.classId,
    required this.className,
    required this.teacherName,
  });

  @override
  State<_AssignmentsView> createState() => _AssignmentsViewState();
}

class _AssignmentsViewState extends State<_AssignmentsView> {
  @override
  void initState() {
    super.initState();

    context.read<AssignmentBloc>().add(
      FetchAssignmentsEvent(classId: widget.classId),
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
            onPressed:
                () => context.read<AssignmentBloc>().add(
                  RefreshAssignmentsEvent(classId: widget.classId),
                ),
          ),
        ],
      ),
      body: MultiBlocListener(
        listeners: [
          BlocListener<AssignmentBloc, AssignmentState>(
            listenWhen: (prev, curr) => curr is AssignmentSubmitSuccess,
            listener: (context, state) {
              if (state is AssignmentSubmitSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Assignment submitted successfully!'),
                    backgroundColor: BBColors.successGreen,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
          ),
          BlocListener<AssignmentBloc, AssignmentState>(
            listenWhen: (prev, curr) => curr is AssignmentSubmitError,
            listener: (context, state) {
              if (state is AssignmentSubmitError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: BBColors.alertRed,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
          ),
          BlocListener<AssignmentBloc, AssignmentState>(
            listenWhen: (prev, curr) => curr is AttachmentDownloadSuccess,
            listener: (context, state) {
              if (state is AttachmentDownloadSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${state.file.name} downloaded'),
                    backgroundColor: BBColors.successGreen,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
          ),
        ],
        child: BlocBuilder<AssignmentBloc, AssignmentState>(
          buildWhen:
              (prev, curr) =>
                  curr is AssignmentLoading ||
                  curr is AssignmentLoaded ||
                  curr is AssignmentEmpty ||
                  curr is AssignmentError,
          builder: (context, state) {
            if (state is AssignmentLoading) return _buildLoading();
            if (state is AssignmentError) return _buildError(context, state);
            if (state is AssignmentEmpty) return _buildEmpty(context);
            if (state is AssignmentLoaded) return _buildList(context, state);
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildLoading() {
    return const Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(BBColors.primaryColor),
      ),
    );
  }

  Widget _buildError(BuildContext context, AssignmentError state) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            state.isNetworkError ? Icons.wifi_off : Icons.error_outline,
            size: 64,
            color: BBColors.alertRed,
          ),
          const SizedBox(height: 16),
          Text(
            'Failed to load assignments',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            state.message,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: BBColors.bodyText),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed:
                () => context.read<AssignmentBloc>().add(
                  FetchAssignmentsEvent(classId: widget.classId),
                ),
            style: ElevatedButton.styleFrom(
              backgroundColor: BBColors.primaryColor,
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty(BuildContext context) {
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
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Check back later for new assignments.',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: BBColors.bodyText),
          ),
        ],
      ),
    );
  }

  Widget _buildList(BuildContext context, AssignmentLoaded state) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<AssignmentBloc>().add(
          RefreshAssignmentsEvent(classId: widget.classId),
        );
        await context.read<AssignmentBloc>().stream.firstWhere(
          (s) => s is! AssignmentLoading,
        );
      },
      color: BBColors.primaryColor,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: state.assignments.length,
        itemBuilder:
            (context, index) =>
                _buildAssignmentCard(context, state.assignments[index]),
      ),
    );
  }

  Widget _buildAssignmentCard(BuildContext context, Assignment assignment) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
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
        onTap: () => _navigateToDetails(context, assignment),
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
            padding: const EdgeInsets.all(16),
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
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: BBColors.bodyText),
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

  void _navigateToDetails(BuildContext context, Assignment assignment) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (navContext) => BlocProvider.value(
              value: context.read<AssignmentBloc>(),
              child: AssignmentDetailsScreen(
                assignment: assignment,
                classId: widget.classId,
              ),
            ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final diff = dt.difference(DateTime.now());
    if (diff.inDays > 0) return '${diff.inDays} days';
    if (diff.inDays == 0) {
      if (diff.inHours > 0) return '${diff.inHours} hours';
      if (diff.inMinutes > 0) return '${diff.inMinutes} minutes';
      return 'Now';
    }
    return '${diff.inDays.abs()} days ago';
  }
}

// ============================================
// Assignment Details Screen
// ============================================
class AssignmentDetailsScreen extends StatefulWidget {
  final Assignment assignment;
  final String classId;

  const AssignmentDetailsScreen({
    super.key,
    required this.assignment,
    required this.classId,
  });

  @override
  State<AssignmentDetailsScreen> createState() =>
      _AssignmentDetailsScreenState();
}

class _AssignmentDetailsScreenState extends State<AssignmentDetailsScreen> {
  List<PlatformFile> _selectedFiles = [];

  Future<void> _pickFiles() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'png', 'zip'],
      );
      if (result != null) setState(() => _selectedFiles = result.files);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to pick files'),
          backgroundColor: BBColors.alertRed,
        ),
      );
    }
  }

  void _submitAssignment() {
    if (_selectedFiles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one file'),
          backgroundColor: BBColors.alertRed,
        ),
      );
      return;
    }
    final filePaths = _selectedFiles.map((f) => f.path ?? f.name).toList();
    context.read<AssignmentBloc>().add(
      SubmitAssignmentEvent(
        assignmentId: widget.assignment.id,
        filePaths: filePaths,
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
      body: BlocListener<AssignmentBloc, AssignmentState>(
        listener: (context, state) {
          if (state is AssignmentSubmitSuccess &&
              state.assignmentId == widget.assignment.id) {
            Navigator.pop(context);
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 20),
              _buildDetails(),
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
                _buildCannotSubmit(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: const EdgeInsets.all(16),
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

  Widget _buildDetails() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
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
              Text(widget.assignment.submissionType!),
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
              Text(widget.assignment.evaluationCriteria!),
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
        padding: const EdgeInsets.all(16),
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
                      onPressed:
                          () => context.read<AssignmentBloc>().add(
                            DownloadAttachmentEvent(file: file),
                          ),
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
        padding: const EdgeInsets.all(16),
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
            const Row(
              children: [
                Icon(
                  Icons.check_circle,
                  color: BBColors.successGreen,
                  size: 24,
                ),
                SizedBox(width: 8),
                Text(
                  'Assignment Submitted',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Submitted: ${submission.submittedDate.toString().substring(0, 16)}',
            ),
            if (submission.grade != null) ...[
              const SizedBox(height: 8),
              Text(
                'Grade: ${submission.grade}',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: BBColors.primaryBlue,
                ),
              ),
            ],
            if (submission.feedback != null) ...[
              const SizedBox(height: 8),
              Text('Feedback: ${submission.feedback}'),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSubmissionSection() {
    return BlocBuilder<AssignmentBloc, AssignmentState>(
      builder: (context, state) {
        final isSubmitting =
            state is AssignmentLoaded &&
            state.isSubmitting &&
            state.submittingId == widget.assignment.id;
        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
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
                if (_selectedFiles.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: BBColors.lightGrayBG,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: BBColors.borderGray),
                    ),
                    child: const Column(
                      children: [
                        Icon(
                          Icons.cloud_upload_outlined,
                          size: 48,
                          color: BBColors.disabledText,
                        ),
                        SizedBox(height: 12),
                        Text('No files selected'),
                      ],
                    ),
                  )
                else
                  ..._selectedFiles.map(
                    (file) => Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: BBColors.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.insert_drive_file,
                            color: BBColors.primaryColor,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(child: Text(file.name)),
                          IconButton(
                            onPressed:
                                () =>
                                    setState(() => _selectedFiles.remove(file)),
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
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: isSubmitting ? null : _pickFiles,
                        icon: const Icon(Icons.attach_file),
                        label: Text(
                          _selectedFiles.isEmpty ? 'Select Files' : 'Add More',
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
                            (_selectedFiles.isNotEmpty && !isSubmitting)
                                ? _submitAssignment
                                : null,
                        icon:
                            isSubmitting
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
                        label: Text(isSubmitting ? 'Submitting...' : 'Submit'),
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
      },
    );
  }

  Widget _buildCannotSubmit() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: const EdgeInsets.all(16),
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
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              widget.assignment.isOverdue
                  ? 'This assignment is overdue. Submission is no longer allowed.'
                  : 'Submission is not available for this assignment.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
