// lib/presentation/views/class/repo/assignment_repo.dart

import 'dart:convert';
import 'package:brainbee/core/utils/file_downloader.dart';
import 'package:brainbee/presentation/views/class/models/assignment_model.dart';
import 'package:brainbee/presentation/views/class/services/class_api_service.dart';
import 'package:flutter/material.dart'; // Corrected import path

abstract class AssignmentRepository {
  Future<List<Assignment>> getStudentAssignments({String? classId});
  Future<void> submitAssignment(String assignmentId, String filePath);
  Future<String?> downloadAttachment({
    required String fileUrl,
    required BuildContext context,
    required String fileName,
    Function(double)? onProgress,
  });

  // Helper method with default implementation
  int getSubmittedAssignmentsCount(List<Assignment> assignments) {
    return assignments
        .where(
          (assignment) =>
              assignment.status == AssignmentStatus.submitted ||
              assignment.status == AssignmentStatus.graded,
        )
        .length;
  }
}

class AssignmentRepositoryImpl implements AssignmentRepository {
  final ClassApiService apiService; // Use ClassApiService

  AssignmentRepositoryImpl({required this.apiService});

  @override
  Future<List<Assignment>> getStudentAssignments({String? classId}) async {
    try {
      // The endpoint for student assignments doesn't take a classId in the path,
      // but the backend supports it as a query parameter.
      final queryParams = classId != null ? {'classId': classId} : null;

      final response = await apiService.get(
        '/api/assignments/student/my-assignments',
        queryParams: queryParams,
      );

      final data = jsonDecode(response.body);
      if (data['status'] != 'success') {
        throw Exception(data['message'] ?? 'Failed to load assignments');
      }

      final List<dynamic> assignmentsList = data['data']['assignments'] as List;
      return assignmentsList.map((json) => Assignment.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load assignments: $e');
    }
  }

  @override
  Future<void> submitAssignment(String assignmentId, String filePath) async {
    try {
      // Use the new uploadFile method from ClassApiService
      // The backend expects the file field to be named 'file'
      await apiService.uploadFile(
        '/api/assignments/$assignmentId/submit',
        filePath,
      );
    } catch (e) {
      throw Exception('Failed to submit assignment: $e');
    }
  }

  @override
  Future<String?> downloadAttachment({
    required String fileUrl,
    required BuildContext context,
    required String fileName,
    Function(double)? onProgress,
  }) async {
    try {
      return await FileDownloader.downloadWithPermissionCheck(
        url: fileUrl,
        context: context,
        fileName: fileName,
      );
    } catch (e) {
      throw Exception('Failed to download file: $e');
    }
  }

  @override
  // Helper method with default implementation
  int getSubmittedAssignmentsCount(List<Assignment> assignments) {
    return assignments
        .where(
          (assignment) =>
              assignment.status == AssignmentStatus.submitted ||
              assignment.status == AssignmentStatus.graded,
        )
        .length;
  }
}
