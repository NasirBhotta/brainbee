class DiscussionModel {
  final String id;
  final String classId;
  final String topicTitle;
  final String content;
  final String authorId;
  final String authorName;
  final String authorAvatar;
  final DateTime createdAt;
  final int repliesCount;
  final int viewsCount;
  final int likesCount;
  final bool isLiked;
  final bool isPinned;
  final List<DiscussionReply> replies;
  
  DiscussionModel({
    required this.id,
    required this.classId,
    required this.topicTitle,
    required this.content,
    required this.authorId,
    required this.authorName,
    required this.authorAvatar,
    required this.createdAt,
    required this.repliesCount,
    required this.viewsCount,
    required this.likesCount,
    required this.isLiked,
    required this.isPinned,
    required this.replies,
  });
  
  factory DiscussionModel.fromJson(Map<String, dynamic> json) {
    return DiscussionModel(
      id: json['id'],
      classId: json['class_id'],
      topicTitle: json['topic_title'],
      content: json['content'],
      authorId: json['author_id'],
      authorName: json['author_name'],
      authorAvatar: json['author_avatar'],
      createdAt: DateTime.parse(json['created_at']),
      repliesCount: json['replies_count'] ?? 0,
      viewsCount: json['views_count'] ?? 0,
      likesCount: json['likes_count'] ?? 0,
      isLiked: json['is_liked'] ?? false,
      isPinned: json['is_pinned'] ?? false,
      replies: json['replies'] != null
          ? List<DiscussionReply>.from(
              json['replies'].map((reply) => DiscussionReply.fromJson(reply)))
          : [],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'class_id': classId,
      'topic_title': topicTitle,
      'content': content,
      'author_id': authorId,
      'author_name': authorName,
      'author_avatar': authorAvatar,
      'created_at': createdAt.toIso8601String(),
      'replies_count': repliesCount,
      'views_count': viewsCount,
      'likes_count': likesCount,
      'is_liked': isLiked,
      'is_pinned': isPinned,
      'replies': replies.map((reply) => reply.toJson()).toList(),
    };
  }
}

class DiscussionReply {
  final String id;
  final String discussionId;
  final String content;
  final String authorId;
  final String authorName;
  final String authorAvatar;
  final DateTime createdAt;
  final int likesCount;
  final bool isLiked;
  
  DiscussionReply({
    required this.id,
    required this.discussionId,
    required this.content,
    required this.authorId,
    required this.authorName,
    required this.authorAvatar,
    required this.createdAt,
    required this.likesCount,
    required this.isLiked,
  });
  
  factory DiscussionReply.fromJson(Map<String, dynamic> json) {
    return DiscussionReply(
      id: json['id'],
      discussionId: json['discussion_id'],
      content: json['content'],
      authorId: json['author_id'],
      authorName: json['author_name'],
      authorAvatar: json['author_avatar'],
      createdAt: DateTime.parse(json['created_at']),
      likesCount: json['likes_count'] ?? 0,
      isLiked: json['is_liked'] ?? false,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'discussion_id': discussionId,
      'content': content,
      'author_id': authorId,
      'author_name': authorName,
      'author_avatar': authorAvatar,
      'created_at': createdAt.toIso8601String(),
      'likes_count': likesCount,
      'is_liked': isLiked,
    };
  }
}

// Mock data for UI development
List<DiscussionModel> mockDiscussions = [
  DiscussionModel(
    id: '1',
    classId: '1',
    topicTitle: 'Help with recursion assignment',
    content: 'I\'m having trouble understanding how to implement the recursive function for problem 3. Can someone explain the base case and recursive step?',
    authorId: 'student1',
    authorName: 'Alex Johnson',
    authorAvatar: 'https://images.pexels.com/photos/220453/pexels-photo-220453.jpeg',
    createdAt: DateTime.now().subtract(const Duration(days: 3, hours: 5)),
    repliesCount: 4,
    viewsCount: 25,
    likesCount: 7,
    isLiked: true,
    isPinned: false,
    replies: [
      DiscussionReply(
        id: 'reply1',
        discussionId: '1',
        content: 'For recursion, you always need to have a base case that stops the recursion. In this problem, think about what the smallest input would be that gives a direct answer without further recursion.',
        authorId: 'student2',
        authorName: 'Emily Chen',
        authorAvatar: 'https://images.pexels.com/photos/1239291/pexels-photo-1239291.jpeg',
        createdAt: DateTime.now().subtract(const Duration(days: 3, hours: 4)),
        likesCount: 3,
        isLiked: false,
      ),
      DiscussionReply(
        id: 'reply2',
        discussionId: '1',
        content: 'To add to what Emily said, for problem 3 specifically, your base case should be when n=0 or n=1. Then the recursive step would call the function with n-1 and n-2.',
        authorId: 'teacher1',
        authorName: 'Dr. Jane Smith',
        authorAvatar: 'https://images.pexels.com/photos/733872/pexels-photo-733872.jpeg',
        createdAt: DateTime.now().subtract(const Duration(days: 3, hours: 2)),
        likesCount: 5,
        isLiked: true,
      ),
    ],
  ),
  DiscussionModel(
    id: '2',
    classId: '1',
    topicTitle: 'Project deadline question',
    content: 'Is the final project still due on Friday, or has the deadline been extended? I\'m working on the extra credit portion and could use a few more days.',
    authorId: 'student3',
    authorName: 'Mike Taylor',
    authorAvatar: 'https://images.pexels.com/photos/91227/pexels-photo-91227.jpeg',
    createdAt: DateTime.now().subtract(const Duration(days: 2, hours: 10)),
    repliesCount: 2,
    viewsCount: 42,
    likesCount: 3,
    isLiked: false,
    isPinned: true,
    replies: [
      DiscussionReply(
        id: 'reply3',
        discussionId: '2',
        content: 'The deadline has been extended to next Monday. I announced this in class yesterday, but I\'ll also send an email to everyone.',
        authorId: 'teacher1',
        authorName: 'Dr. Jane Smith',
        authorAvatar: 'https://images.pexels.com/photos/733872/pexels-photo-733872.jpeg',
        createdAt: DateTime.now().subtract(const Duration(days: 2, hours: 8)),
        likesCount: 8,
        isLiked: true,
      ),
    ],
  ),
  DiscussionModel(
    id: '3',
    classId: '2',
    topicTitle: 'Study group for midterm',
    content: 'Would anyone be interested in forming a study group for the upcoming midterm? I was thinking we could meet at the library this weekend.',
    authorId: 'student4',
    authorName: 'Sarah Williams',
    authorAvatar: 'https://images.pexels.com/photos/774909/pexels-photo-774909.jpeg',
    createdAt: DateTime.now().subtract(const Duration(days: 4, hours: 15)),
    repliesCount: 8,
    viewsCount: 55,
    likesCount: 12,
    isLiked: true,
    isPinned: false,
    replies: [],
  ),
];