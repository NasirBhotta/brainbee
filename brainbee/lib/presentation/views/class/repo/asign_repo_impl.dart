import 'dart:convert';
import 'package:brainbee/presentation/views/class/models/assignment_model.dart';
import 'package:brainbee/presentation/views/class/repo/assign_repo.dart';
import 'package:brainbee/presentation/views/class/services/class_api_service.dart';

class AssignmentRepositoryImpl implements AssignmentRepository {
  final ClassApiService apiService;
  AssignmentRepositoryImpl({required this.apiService});

  @override
  Future<List<Assignment>> getAssignments(String classId) async {
    try {
      final response = await apiService.get(
        '/api/classes/$classId/assignments',
      );
      final data = jsonDecode(response.body);
      final list = data['data']['assignments'] as List? ?? [];
      return list.map((a) => Assignment.fromJson(a)).toList();
    } catch (e) {
      throw Exception('Failed to load assignments: $e');
    }
  }

  @override
  Future<Assignment> getAssignmentDetail(String assignmentId) async {
    try {
      final response = await apiService.get('/api/assignments/$assignmentId');
      final data = jsonDecode(response.body);
      return Assignment.fromJson(data['data']['assignment']);
    } catch (e) {
      throw Exception('Failed to load assignment: $e');
    }
  }

  @override
  Future<void> submitAssignment(
    String assignmentId,
    List<String> filePaths,
  ) async {
    try {
      // In real impl, upload files first then submit URLs
      await apiService.post(
        '/api/assignments/$assignmentId/submit',
        data: {'files': filePaths},
      );
    } catch (e) {
      throw Exception('Failed to submit: $e');
    }
  }

  @override
  Future<String> downloadAttachment(AssignmentFile file) async {
    try {
      await Future.delayed(const Duration(seconds: 1));
      return '/downloads/${file.name}';
    } catch (e) {
      throw Exception('Failed to download: $e');
    }
  }
}
