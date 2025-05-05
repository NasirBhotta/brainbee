import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/discussion_model.dart';
import '../services/discussion_service.dart';
import '../utils/helpers.dart';

class ClassDiscussionsTab extends StatelessWidget {
  final String classId;

  const ClassDiscussionsTab({super.key, required this.classId});

  @override
  Widget build(BuildContext context) {
    return Consumer<DiscussionService>(
      builder: (context, discussionService, child) {
        final discussions = mockDiscussions.where((d) => d.classId == classId).toList();

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: discussions.length,
          itemBuilder: (context, index) {
            final discussion = discussions[index];
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundImage: NetworkImage(discussion.authorAvatar),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                discussion.authorName,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              Text(
                                Helpers.formatDateTime(discussion.createdAt),
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                        if (discussion.isPinned)
                          const Icon(Icons.push_pin, color: Colors.blue),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      discussion.topicTitle,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(discussion.content),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        _buildStat(Icons.comment, '${discussion.repliesCount}'),
                        const SizedBox(width: 16),
                        _buildStat(Icons.remove_red_eye, '${discussion.viewsCount}'),
                        const SizedBox(width: 16),
                        _buildStat(
                          discussion.isLiked ? Icons.favorite : Icons.favorite_border,
                          '${discussion.likesCount}',
                          color: discussion.isLiked ? Colors.red : null,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildStat(IconData icon, String text, {Color? color}) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 4),
        Text(text),
      ],
    );
  }
}