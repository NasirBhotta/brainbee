class ParentGoal {
  final String id;
  final String title;
  final String description;
  final ParentInfo parentId;
  final String childId;
  final bool isCompleted;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? completedAt;

  ParentGoal({
    required this.id,
    required this.title,
    required this.description,
    required this.parentId,
    required this.childId,
    required this.isCompleted,
    required this.createdAt,
    required this.updatedAt,
    this.completedAt,
  });

  factory ParentGoal.fromJson(Map<String, dynamic> json) {
    return ParentGoal(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      parentId: ParentInfo.fromJson(json['parentId'] ?? {}),
      childId: json['childId'] ?? '',
      isCompleted: json['isCompleted'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      completedAt:
          json['completedAt'] != null
              ? DateTime.parse(json['completedAt'])
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'title': title,
      'description': description,
      'parentId': parentId.toJson(),
      'childId': childId,
      'isCompleted': isCompleted,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
    };
  }

  String getTimeAgo() {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return '$years ${years == 1 ? 'year' : 'years'} ago';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return '$months ${months == 1 ? 'month' : 'months'} ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'} ago';
    } else {
      return 'Just now';
    }
  }
}

class ParentInfo {
  final String id;
  final String firstName;
  final String lastName;
  final String role;

  ParentInfo({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.role,
  });

  factory ParentInfo.fromJson(Map<String, dynamic> json) {
    return ParentInfo(
      id: json['_id'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      role: json['role'] ?? 'parent',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'firstName': firstName,
      'lastName': lastName,
      'role': role,
    };
  }

  String get fullName => '$firstName $lastName';
}

class ParentGoalsResponse {
  final String status;
  final int results;
  final List<ParentGoal> goals;

  ParentGoalsResponse({
    required this.status,
    required this.results,
    required this.goals,
  });

  factory ParentGoalsResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    final goalsList = data['goals'] as List;

    return ParentGoalsResponse(
      status: json['status'] ?? '',
      results: json['results'] ?? 0,
      goals: goalsList.map((goal) => ParentGoal.fromJson(goal)).toList(),
    );
  }
}
