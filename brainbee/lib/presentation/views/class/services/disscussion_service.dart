import 'dart:convert';

import 'package:brainbee/presentation/views/class/services/class_api_service.dart';

class DiscussionService {
  final ClassApiService apiService;
  DiscussionService({required this.apiService});

  Future<List<Map<String, dynamic>>> getTopics(String classId) async {
    try {
      final response = await apiService.get(
        '/api/classes/$classId/discussions',
      );
      final data = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(data['data']['topics'] ?? []);
    } catch (e) {
      throw Exception('Failed to load topics: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getMessages(String topicId) async {
    try {
      final response = await apiService.get(
        '/api/discussions/$topicId/messages',
      );
      final data = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(data['data']['messages'] ?? []);
    } catch (e) {
      throw Exception('Failed to load messages: $e');
    }
  }

  Future<Map<String, dynamic>> sendMessage(
    String topicId,
    String message,
  ) async {
    try {
      final response = await apiService.post(
        '/api/discussions/$topicId/messages',
        data: {'message': message},
      );
      final data = jsonDecode(response.body);
      return data['data']['message'] as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Failed to send message: $e');
    }
  }
}
