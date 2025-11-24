// models/assignment_model.dart

import 'package:flutter/material.dart';

enum AssignmentStatus { pending, submitted, graded }

class AssignmentFile {
  final String id;
  final String url;
  final String name = 'attachment';
  final String type;

  AssignmentFile({required this.id, required this.url, required this.type});

  factory AssignmentFile.fromJson(Map<String, dynamic> json) {
    return AssignmentFile(
      id: json['_id'] as String? ?? '',
      url: json['fileUrl'] as String? ?? '',
      type: json['fileType'] as String? ?? '',
    );
  }

  IconData get typeIcon {
    switch (type.toLowerCase()) {
      case 'application/pdf':
        return Icons.picture_as_pdf;
      case 'application/msword':
      case 'application/vnd.openxmlformats-officedocument.wordprocessingml.document':
        return Icons.description;
      case 'image/jpeg':
      case 'image/png':
        return Icons.image;
      default:
        return Icons.insert_drive_file;
    }
  }
}

class AssignmentSubmission {
  final String id;
  final DateTime submittedAt;
  final String fileUrl;
  final String fileType;
  final String? grade;
  final String? feedback;

  AssignmentSubmission({
    required this.id,
    required this.submittedAt,
    required this.fileUrl,
    required this.fileType,
    this.grade,
    this.feedback,
  });

  factory AssignmentSubmission.fromJson(Map<String, dynamic> json) {
    return AssignmentSubmission(
      id: json['_id'] as String? ?? '',
      submittedAt: DateTime.parse(json['submittedAt'] as String),
      fileUrl: json['fileUrl'] as String? ?? '',
      fileType: json['fileType'] as String? ?? '',
      grade: json['grade'] as String?,
      feedback: json['feedback'] as String?,
    );
  }
}

class ClassInfo {
  final String id;
  final String name;
  final int grade;
  final String subject;

  ClassInfo({
    required this.id,
    required this.name,
    required this.grade,
    required this.subject,
  });

  factory ClassInfo.fromJson(Map<String, dynamic> json) {
    return ClassInfo(
      id: json['_id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      grade: json['grade'] as int? ?? 0,
      subject: json['subject'] as String? ?? '',
    );
  }
}

class TeacherInfo {
  final String id;
  final String email;
  final String role;

  TeacherInfo({required this.id, required this.email, required this.role});

  factory TeacherInfo.fromJson(Map<String, dynamic> json) {
    return TeacherInfo(
      id: json['_id'] as String? ?? '',
      email: json['email'] as String? ?? '',
      role: json['role'] as String? ?? '',
    );
  }
}

class Assignment {
  final String id;
  final String title;
  final String description;
  final DateTime dueDate;
  final int totalPoints;
  final AssignmentStatus status;
  final ClassInfo classInfo;
  final TeacherInfo teacherInfo;
  final DateTime createdAt;
  final DateTime updatedAt;
  final AssignmentFile? attachedFile;
  final AssignmentSubmission? submission;

  Assignment({
    required this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.totalPoints,
    required this.status,
    required this.classInfo,
    required this.teacherInfo,
    required this.createdAt,
    required this.updatedAt,
    this.attachedFile,
    this.submission,
  });

  factory Assignment.fromJson(Map<String, dynamic> json) {
    // Determine status from submissionStatus field
    AssignmentStatus status;
    final submissionStatus = json['submissionStatus'] as String?;
    if (submissionStatus == 'submitted') {
      status = AssignmentStatus.submitted;
    } else if (submissionStatus == 'graded') {
      status = AssignmentStatus.graded;
    } else {
      status = AssignmentStatus.pending;
    }

    // Parse submission if exists
    AssignmentSubmission? submission;
    if (json['submission'] != null) {
      submission = AssignmentSubmission.fromJson(json['submission']);
    }

    // Parse attached file if exists
    AssignmentFile? attachedFile;
    if (json['fileUrl'] != null) {
      attachedFile = AssignmentFile(
        id: json['_id'] as String,
        url: json['fileUrl'] as String,
        type: json['fileType'] as String,
      );
    }

    return Assignment(
      id: json['_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      dueDate: DateTime.parse(json['dueDate'] as String),
      totalPoints: json['totalPoints'] as int? ?? 0,
      status: status,
      classInfo: ClassInfo.fromJson(json['classId'] as Map<String, dynamic>),
      teacherInfo: TeacherInfo.fromJson(
        json['createdBy'] as Map<String, dynamic>,
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      attachedFile: attachedFile,
      submission: submission,
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
