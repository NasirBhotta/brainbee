import 'package:brainbee/presentation/views/class/models/disscussion_model.dart';

abstract class DiscussionRepository {
  Future<List<DiscussionTopic>> getTopics(String classId);
  Future<List<DiscussionMessage>> getMessages(String topicId);
  Future<DiscussionMessage> sendMessage(String topicId, String message);
}
