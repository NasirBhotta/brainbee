import 'package:flutter/material.dart';

class ClassMaterial {
  final String id;
  final String title;
  final String fileType;
  final String fileUrl;
  final String? description;
  final DateTime uploadedAt;
  final Teacher teacher;

  ClassMaterial({
    required this.id,
    required this.title,
    required this.fileType,
    required this.fileUrl,
    required this.uploadedAt,
    required this.teacher,
    this.description,
  });

  factory ClassMaterial.fromJson(Map<String, dynamic> json) {
    return ClassMaterial(
      id: json['_id'] as String,
      title: json['title'] as String,
      fileType: json['fileType'] as String,
      fileUrl: json['fileUrl'] as String,
      uploadedAt: DateTime.parse(json['uploadedAt'] as String),
      teacher: Teacher.fromJson(json['teacher'] as Map<String, dynamic>),
      description: json['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    '_id': id,
    'title': title,
    'fileType': fileType,
    'fileUrl': fileUrl,
    'uploadedAt': uploadedAt.toIso8601String(),
    'teacher': teacher.toJson(),
    'description': description,
  };

  // Get file name with extension
  String get fileName => '$title.$fileType';

  // Format size (you might want to get actual size from server)
  String get formattedSize => 'Unknown'; // TODO: Add size field from backend

  // Get icon based on file type
  IconData get typeIcon {
    switch (fileType.toLowerCase()) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'mp4':
      case 'avi':
      case 'mov':
      case 'mkv':
        return Icons.video_file;
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
      case 'bmp':
        return Icons.image;
      case 'ppt':
      case 'pptx':
        return Icons.slideshow;
      case 'xls':
      case 'xlsx':
        return Icons.table_chart;
      case 'zip':
      case 'rar':
      case '7z':
        return Icons.folder_zip;
      case 'txt':
        return Icons.text_snippet;
      default:
        return Icons.insert_drive_file;
    }
  }

  // Get color based on file type
  Color get typeColor {
    switch (fileType.toLowerCase()) {
      case 'pdf':
        return Colors.red;
      case 'doc':
      case 'docx':
        return Colors.blue;
      case 'mp4':
      case 'avi':
      case 'mov':
      case 'mkv':
        return Colors.purple;
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
      case 'bmp':
        return Colors.green;
      case 'ppt':
      case 'pptx':
        return Colors.orange;
      case 'xls':
      case 'xlsx':
        return Colors.teal;
      case 'zip':
      case 'rar':
      case '7z':
        return Colors.amber;
      case 'txt':
        return Colors.blueGrey;
      default:
        return Colors.grey;
    }
  }

  // Get type display name
  String get type {
    switch (fileType.toLowerCase()) {
      case 'pdf':
        return 'PDF';
      case 'doc':
      case 'docx':
        return 'DOC';
      case 'mp4':
      case 'avi':
      case 'mov':
      case 'mkv':
        return 'VIDEO';
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
      case 'bmp':
        return 'IMAGE';
      case 'ppt':
      case 'pptx':
        return 'PPT';
      case 'xls':
      case 'xlsx':
        return 'XLS';
      case 'zip':
      case 'rar':
      case '7z':
        return 'ARCHIVE';
      case 'txt':
        return 'TEXT';
      default:
        return fileType.toUpperCase();
    }
  }

  // Get uploaded by name
  String get uploadedBy => '${teacher.firstName} ${teacher.lastName}';
}

class Teacher {
  final String id;
  final String firstName;
  final String lastName;
  final String role;

  Teacher({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.role,
  });

  factory Teacher.fromJson(Map<String, dynamic> json) {
    return Teacher(
      id: json['_id'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      role: json['role'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    '_id': id,
    'firstName': firstName,
    'lastName': lastName,
    'role': role,
  };
}
