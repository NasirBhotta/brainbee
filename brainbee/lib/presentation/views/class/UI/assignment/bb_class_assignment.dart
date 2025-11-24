// screens/assignment_list_screen.dart

import 'package:brainbee/core/constants/bb_colors.dart';
import 'package:brainbee/presentation/views/class/bloc/assignment/bloc/assignment_bloc.dart';
import 'package:brainbee/presentation/views/class/bloc/assignment/bloc/assignment_state.dart';
import 'package:brainbee/presentation/views/class/models/assignment_model.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BbClassAssignment extends StatefulWidget {
  final VoidCallback? onAssignmentSubmitted;
  const BbClassAssignment({super.key, this.onAssignmentSubmitted});

  @override
  State<BbClassAssignment> createState() => _BbClassAssignmentState();
}

class _BbClassAssignmentState extends State<BbClassAssignment> {
  @override
  void initState() {
    super.initState();
    context.read<AssignmentBloc>().add(FetchAssignmentsEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BBColors.background,
      appBar: AppBar(
        title: Text('My Assignments'),
        backgroundColor: BBColors.primary,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.white),
            onPressed:
                () => context.read<AssignmentBloc>().add(
                  RefreshAssignmentsEvent(),
                ),
          ),
        ],
      ),
      body: BlocBuilder<AssignmentBloc, AssignmentState>(
        builder: (context, state) {
          if (state is AssignmentLoading) {
            return Center(
              child: CircularProgressIndicator(color: BBColors.primary),
            );
          }

          if (state is AssignmentError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    state.isNetworkError ? Icons.wifi_off : Icons.error_outline,
                    size: 64,
                    color: BBColors.error,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Failed to load assignments',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  SizedBox(height: 8),
                  Text(
                    state.message,
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 24),
                  ElevatedButton(
                    onPressed:
                        () => context.read<AssignmentBloc>().add(
                          FetchAssignmentsEvent(),
                        ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: BBColors.primary,
                    ),
                    child: Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is AssignmentEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.assignment_outlined,
                    size: 64,
                    color: BBColors.textSecondary,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No assignments available',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Check back later for new assignments.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            );
          }

          if (state is AssignmentLoaded) {
            return RefreshIndicator(
              onRefresh: () async {
                context.read<AssignmentBloc>().add(RefreshAssignmentsEvent());
                await context.read<AssignmentBloc>().stream.firstWhere(
                  (s) => s is! AssignmentLoading,
                );
              },
              child: ListView.builder(
                padding: EdgeInsets.all(16),
                itemCount: state.assignments.length,
                itemBuilder:
                    (context, index) =>
                        _buildAssignmentCard(context, state.assignments[index]),
              ),
            );
          }

          return SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildAssignmentCard(BuildContext context, Assignment assignment) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side:
            assignment.isOverdue &&
                    assignment.status == AssignmentStatus.pending
                ? BorderSide(color: BBColors.error.withOpacity(0.3), width: 1)
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
                        BBColors.error.withOpacity(0.05),
                        Colors.transparent,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                    : null,
          ),
          child: Padding(
            padding: EdgeInsets.all(16),
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
                          color: BBColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                SizedBox(height: 8),
                Text(
                  assignment.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: BBColors.textSecondary,
                  ),
                ),
                SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.schedule,
                      size: 16,
                      color:
                          assignment.isOverdue
                              ? BBColors.error
                              : BBColors.textSecondary,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Due: ${_formatDate(assignment.dueDate)}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color:
                            assignment.isOverdue
                                ? BBColors.error
                                : BBColors.textSecondary,
                        fontWeight:
                            assignment.isOverdue
                                ? FontWeight.w600
                                : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.class_, size: 16, color: BBColors.textSecondary),
                    SizedBox(width: 4),
                    Text(
                      '${assignment.classInfo.name} (${assignment.classInfo.subject})',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: BBColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                if (assignment.attachedFile != null) ...[
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.attach_file,
                        size: 16,
                        color: BBColors.primary,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Attachment available',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: BBColors.primary,
                        ),
                      ),
                    ],
                  ),
                ],
                if (assignment.submission != null) ...[
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        size: 16,
                        color: BBColors.success,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Submitted ${_formatDate(assignment.submission!.submittedAt)}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: BBColors.success,
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
            (context) => BlocProvider.value(
              value: context.read<AssignmentBloc>(),
              child: AssignmentDetailScreen(
                assignment: assignment,
                onAssignmentSubmitted: widget.onAssignmentSubmitted,
              ),
            ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final diff = dt.difference(now);

    if (diff.isNegative) {
      // Date is in the past
      final pastDiff = now.difference(dt);
      if (pastDiff.inDays > 0) return '${pastDiff.inDays} days ago';
      if (pastDiff.inHours > 0) return '${pastDiff.inHours} hours ago';
      if (pastDiff.inMinutes > 0) return '${pastDiff.inMinutes} minutes ago';
      return 'Just now';
    } else {
      // Date is in the future
      if (diff.inDays > 0) return '${diff.inDays} days';
      if (diff.inHours > 0) return '${diff.inHours} hours';
      if (diff.inMinutes > 0) return '${diff.inMinutes} minutes';
      return 'Soon';
    }
  }
}

class AssignmentDetailScreen extends StatefulWidget {
  final VoidCallback? onAssignmentSubmitted;
  final Assignment assignment;

  const AssignmentDetailScreen({
    super.key,
    required this.assignment,
    this.onAssignmentSubmitted,
  });

  @override
  State<AssignmentDetailScreen> createState() => _AssignmentDetailScreenState();
}

class _AssignmentDetailScreenState extends State<AssignmentDetailScreen> {
  String? _selectedFilePath;

  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: false,
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'png', 'zip'],
      );

      if (result != null && result.files.isNotEmpty) {
        setState(() {
          _selectedFilePath =
              result.files.first.path ?? result.files.first.name;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to pick file'),
          backgroundColor: BBColors.error,
        ),
      );
    }
  }

  void _submitAssignment() {
    if (_selectedFilePath == null || _selectedFilePath!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select a file to submit'),
          backgroundColor: BBColors.error,
        ),
      );
      return;
    }

    context.read<AssignmentBloc>().add(
      SubmitAssignmentEvent(
        assignmentId: widget.assignment.id,
        filePath: _selectedFilePath!,
      ),
    );
  }

  void _downloadAttachment(String fileUrl) async {
    // Extract a filename from the URL
    final uri = Uri.parse(fileUrl);
    final fileName = uri.pathSegments.last;

    // Call the repository method
    context.read<AssignmentBloc>().add(
      DownloadAttachmentEvent(
        context: context,
        fileUrl: fileUrl,
        fileName: fileName,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BBColors.background,
      appBar: AppBar(
        backgroundColor: BBColors.primary,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Assignment Details',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: MultiBlocListener(
        listeners: [
          BlocListener<AssignmentBloc, AssignmentState>(
            listenWhen: (prev, curr) => curr is AssignmentSubmitSuccess,
            listener: (context, state) {
              if (state is AssignmentSubmitSuccess) {
                if (widget.onAssignmentSubmitted != null) {
                  widget.onAssignmentSubmitted!();
                }
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Assignment submitted successfully!'),
                    backgroundColor: BBColors.success,
                  ),
                );
                Navigator.pop(context);
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
                    backgroundColor: BBColors.error,
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
                    content: Text('File downloaded successfully'),
                    backgroundColor: BBColors.success,
                  ),
                );
              }
            },
          ),
          BlocListener<AssignmentBloc, AssignmentState>(
            listenWhen: (prev, curr) => curr is AttachmentDownloadError,
            listener: (context, state) {
              if (state is AttachmentDownloadError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: BBColors.error,
                  ),
                );
              }
            },
          ),
        ],
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              SizedBox(height: 20),
              _buildDetails(),
              SizedBox(height: 20),
              if (widget.assignment.attachedFile != null) _buildAttachment(),
              if (widget.assignment.submission != null) ...[
                SizedBox(height: 20),
                _buildSubmissionStatus(),
              ] else if (widget.assignment.canSubmit) ...[
                SizedBox(height: 20),
                _buildSubmissionSection(),
              ] else ...[
                SizedBox(height: 20),
                _buildCannotSubmit(),
              ],
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
        padding: EdgeInsets.all(16),
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
                      color: BBColors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
            SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.schedule,
                  size: 18,
                  color:
                      widget.assignment.isOverdue
                          ? BBColors.error
                          : BBColors.textSecondary,
                ),
                SizedBox(width: 6),
                Text(
                  'Due: ${_formatDate(widget.assignment.dueDate)}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color:
                        widget.assignment.isOverdue
                            ? BBColors.error
                            : BBColors.textSecondary,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.person, size: 18, color: BBColors.textSecondary),
                SizedBox(width: 6),
                Text(
                  'Assigned by: ${widget.assignment.teacherInfo.email}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: BBColors.textSecondary,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.class_, size: 18, color: BBColors.textSecondary),
                SizedBox(width: 6),
                Text(
                  '${widget.assignment.classInfo.name} (${widget.assignment.classInfo.subject})',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: BBColors.textSecondary,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.grade, size: 18, color: BBColors.textSecondary),
                SizedBox(width: 6),
                Text(
                  'Total Points: ${widget.assignment.totalPoints}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: BBColors.textSecondary,
                  ),
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
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Description',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: BBColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 8),
            Text(
              widget.assignment.description,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: BBColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttachment() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Attachment',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: BBColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 12),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: BBColors.background,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: BBColors.border),
              ),
              child: Row(
                children: [
                  Icon(
                    widget.assignment.attachedFile!.typeIcon,
                    color: BBColors.primary,
                    size: 20,
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Attachment file',
                          style: Theme.of(
                            context,
                          ).textTheme.bodyMedium?.copyWith(
                            color: BBColors.textPrimary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          widget.assignment.attachedFile!.type,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: BBColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed:
                        () => _downloadAttachment(
                          widget.assignment.attachedFile!.url,
                        ),
                    icon: Icon(
                      Icons.download,
                      color: BBColors.primary,
                      size: 20,
                    ),
                  ),
                ],
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
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [BBColors.success.withOpacity(0.1), Colors.transparent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.check_circle, color: BBColors.success, size: 24),
                SizedBox(width: 8),
                Text(
                  'Assignment Submitted',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
            SizedBox(height: 12),
            Text(
              'Submitted: ${_formatDate(submission.submittedAt)}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            if (submission.grade != null) ...[
              SizedBox(height: 8),
              Text(
                'Grade: ${submission.grade}',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: BBColors.primary,
                ),
              ),
            ],
            if (submission.feedback != null) ...[
              SizedBox(height: 8),
              Text(
                'Feedback: ${submission.feedback}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
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
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Submit Assignment',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: BBColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 12),
                if (_selectedFilePath == null || _selectedFilePath!.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: BBColors.background,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: BBColors.border),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.cloud_upload_outlined,
                          size: 48,
                          color: BBColors.textSecondary,
                        ),
                        SizedBox(height: 12),
                        Text('No file selected'),
                      ],
                    ),
                  )
                else
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: BBColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.insert_drive_file,
                          color: BBColors.primary,
                          size: 20,
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _selectedFilePath!.split('/').last,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                        IconButton(
                          onPressed:
                              () => setState(() => _selectedFilePath = null),
                          icon: Icon(
                            Icons.close,
                            color: BBColors.error,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                  ),
                SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: isSubmitting ? null : _pickFile,
                        icon: Icon(Icons.attach_file),
                        label: Text(
                          _selectedFilePath == null
                              ? 'Select File'
                              : 'Change File',
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: BBColors.primary,
                          side: BorderSide(color: BBColors.primary),
                          padding: EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed:
                            (_selectedFilePath != null && !isSubmitting)
                                ? _submitAssignment
                                : null,
                        icon:
                            isSubmitting
                                ? SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                                : Icon(Icons.send),
                        label: Text(isSubmitting ? 'Submitting...' : 'Submit'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: BBColors.primary,
                          padding: EdgeInsets.symmetric(vertical: 12),
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
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [BBColors.error.withOpacity(0.1), Colors.transparent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            Icon(Icons.block, size: 48, color: BBColors.error),
            SizedBox(height: 12),
            Text(
              'Submission Not Available',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 8),
            Text(
              widget.assignment.isOverdue
                  ? 'This assignment is overdue. Submission is no longer allowed.'
                  : 'Submission is not available for this assignment.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}
