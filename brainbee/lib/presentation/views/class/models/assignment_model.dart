import 'package:flutter/material.dart';

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

  factory AssignmentFile.fromJson(Map<String, dynamic> json) {
    return AssignmentFile(
      id: json['id'] as String,
      name: json['name'] as String,
      type: json['type'] as String,
      url: json['url'] as String,
      size: json['size'] as int,
    );
  }

  String get formattedSize {
    if (size < 1024) return '${size}B';
    if (size < 1024 * 1024) return '${(size / 1024).toStringAsFixed(1)}KB';
    return '${(size / (1024 * 1024)).toStringAsFixed(1)}MB';
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

  factory AssignmentSubmission.fromJson(Map<String, dynamic> json) {
    return AssignmentSubmission(
      id: json['id'] as String,
      submittedDate: DateTime.parse(json['submittedDate'] as String),
      submittedFiles:
          (json['submittedFiles'] as List?)
              ?.map((f) => AssignmentFile.fromJson(f))
              .toList() ??
          [],
      grade: json['grade'] as String?,
      feedback: json['feedback'] as String?,
    );
  }
}

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

  factory Assignment.fromJson(Map<String, dynamic> json) {
    return Assignment(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      dueDate: DateTime.parse(json['dueDate'] as String),
      status: AssignmentStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => AssignmentStatus.pending,
      ),
      teacherName: json['teacherName'] as String,
      attachedFiles:
          (json['attachedFiles'] as List?)
              ?.map((f) => AssignmentFile.fromJson(f))
              .toList() ??
          [],
      submissionType: json['submissionType'] as String?,
      evaluationCriteria: json['evaluationCriteria'] as String?,
      createdDate: DateTime.parse(json['createdDate'] as String),
      submission:
          json['submission'] != null
              ? AssignmentSubmission.fromJson(json['submission'])
              : null,
    );
  }

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
