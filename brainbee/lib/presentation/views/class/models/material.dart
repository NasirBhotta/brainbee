import 'package:flutter/material.dart';

class ClassMaterial {
  final String id;
  final String name;
  final String type;
  final String url;
  final int size;
  final DateTime uploadedDate;
  final String uploadedBy;
  final String? description;

  ClassMaterial({
    required this.id,
    required this.name,
    required this.type,
    required this.url,
    required this.size,
    required this.uploadedDate,
    required this.uploadedBy,
    this.description,
  });

  factory ClassMaterial.fromJson(Map<String, dynamic> json) {
    return ClassMaterial(
      id: json['id'] as String,
      name: json['name'] as String,
      type: json['type'] as String,
      url: json['url'] as String,
      size: json['size'] as int,
      uploadedDate: DateTime.parse(json['uploadedDate'] as String),
      uploadedBy: json['uploadedBy'] as String,
      description: json['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'type': type,
    'url': url,
    'size': size,
    'uploadedDate': uploadedDate.toIso8601String(),
    'uploadedBy': uploadedBy,
    'description': description,
  };

  String get formattedSize {
    if (size < 1024) return '${size}B';
    if (size < 1024 * 1024) return '${(size / 1024).toStringAsFixed(1)}KB';
    if (size < 1024 * 1024 * 1024)
      return '${(size / (1024 * 1024)).toStringAsFixed(1)}MB';
    return '${(size / (1024 * 1024 * 1024)).toStringAsFixed(1)}GB';
  }

  IconData get typeIcon {
    switch (type.toLowerCase()) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'video':
      case 'mp4':
      case 'avi':
        return Icons.video_file;
      case 'image':
      case 'jpg':
      case 'png':
        return Icons.image;
      case 'ppt':
      case 'pptx':
        return Icons.slideshow;
      default:
        return Icons.insert_drive_file;
    }
  }

  Color get typeColor {
    switch (type.toLowerCase()) {
      case 'pdf':
        return Colors.red;
      case 'doc':
      case 'docx':
        return Colors.blue;
      case 'video':
      case 'mp4':
      case 'avi':
        return Colors.purple;
      case 'image':
      case 'jpg':
      case 'png':
        return Colors.green;
      case 'ppt':
      case 'pptx':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}
