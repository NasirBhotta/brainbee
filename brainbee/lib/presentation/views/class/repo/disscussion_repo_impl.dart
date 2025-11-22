import 'dart:convert';

import 'package:brainbee/presentation/views/class/models/disscussion_model.dart';
import 'package:brainbee/presentation/views/class/repo/disscussion_repo.dart';
import 'package:brainbee/presentation/views/class/services/class_api_service.dart';

class DiscussionRepositoryImpl implements DiscussionRepository {
  final ClassApiService apiService;
  DiscussionRepositoryImpl({required this.apiService});

  @override
  Future<List<DiscussionTopic>> getTopics(String classId) async {
    try {
      final response = await apiService.get(
        '/api/classes/$classId/discussions',
      );
      final data = jsonDecode(response.body);
      final topicsList = data['data']['topics'] as List? ?? [];
      return topicsList.map((t) => DiscussionTopic.fromJson(t)).toList();
    } catch (e) {
      throw Exception('Failed to load topics: $e');
    }
  }

  @override
  Future<List<DiscussionMessage>> getMessages(String topicId) async {
    try {
      final response = await apiService.get(
        '/api/discussions/$topicId/messages',
      );
      final data = jsonDecode(response.body);
      final msgList = data['data']['messages'] as List? ?? [];
      return msgList.map((m) => DiscussionMessage.fromJson(m)).toList();
    } catch (e) {
      throw Exception('Failed to load messages: $e');
    }
  }

  @override
  Future<DiscussionMessage> sendMessage(String topicId, String message) async {
    try {
      final response = await apiService.post(
        '/api/discussions/$topicId/messages',
        data: {'message': message},
      );
      final data = jsonDecode(response.body);
      return DiscussionMessage.fromJson(data['data']['message']);
    } catch (e) {
      throw Exception('Failed to send message: $e');
    }
  }
}
