import 'package:brainbee/presentation/views/class/models/assignment_model.dart';
import 'package:flutter/material.dart';

abstract class AssignmentRepository {
  Future<List<Assignment>> getStudentAssignments();
  Future<void> submitAssignment(String assignmentId, String filePath);
  Future<String> downloadAttachment(
    String fileUrl,
    BuildContext context,
    String fileName,
    Function(double)? onProgress,
  );
}
