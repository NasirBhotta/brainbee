import 'dart:convert';

import 'package:brainbee/presentation/views/class/services/class_api_service.dart';

class AssignmentService {
  final ClassApiService apiService;
  AssignmentService({required this.apiService});

  Future<List<Map<String, dynamic>>> getAssignments(String classId) async {
    try {
      final response = await apiService.get(
        '/api/classes/$classId/assignments',
      );
      final data = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(data['data']['assignments'] ?? []);
    } catch (e) {
      throw Exception('Failed to load assignments: $e');
    }
  }

  Future<Map<String, dynamic>> getAssignmentDetail(String assignmentId) async {
    try {
      final response = await apiService.get('/api/assignments/$assignmentId');
      final data = jsonDecode(response.body);
      return data['data']['assignment'] as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Failed to load assignment: $e');
    }
  }

  Future<Map<String, dynamic>> submitAssignment(
    String assignmentId,
    List<String> fileUrls,
  ) async {
    try {
      final response = await apiService.post(
        '/api/assignments/$assignmentId/submit',
        data: {'files': fileUrls},
      );
      final data = jsonDecode(response.body);
      return data['data']['submission'] as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Failed to submit assignment: $e');
    }
  }
}
