// lib/data/models/class_models.dart

class Teacher {
  final String id;
  final String firstName;
  final String lastName;
  final String fullName;
  final String email;

  Teacher({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.fullName,
    required this.email,
  });

  factory Teacher.fromJson(Map<String, dynamic> json) {
    return Teacher(
      id: json['id'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      fullName: json['fullName'] as String,
      email: json['email'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'fullName': fullName,
      'email': email,
    };
  }
}

class ClassModel {
  final String id;
  final String name;
  final String subject;
  final int grade;
  final String description;
  final Teacher teacher;
  final String schedule;
  final int totalStudents;
  final int totalAssignments;
  final int completedAssignments;
  final String? imageUrl;

  ClassModel({
    required this.id,
    required this.name,
    required this.subject,
    required this.grade,
    required this.description,
    required this.teacher,
    required this.schedule,
    required this.totalStudents,
    required this.totalAssignments,
    required this.completedAssignments,
    this.imageUrl,
  });

  factory ClassModel.fromJson(Map<String, dynamic> json) {
    return ClassModel(
      id: json['id'] as String,
      name: json['name'] as String,
      subject: json['subject'] as String,
      grade: json['grade'] as int,
      description: json['description'] as String,
      teacher: Teacher.fromJson(json['teacher'] as Map<String, dynamic>),
      schedule: json['schedule'] as String,
      totalStudents: json['totalStudents'] as int,
      totalAssignments: json['totalAssignments'] as int,
      completedAssignments: json['completedAssignments'] as int,
      imageUrl: json['imageUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'subject': subject,
      'grade': grade,
      'description': description,
      'teacher': teacher.toJson(),
      'schedule': schedule,
      'totalStudents': totalStudents,
      'totalAssignments': totalAssignments,
      'completedAssignments': completedAssignments,
      'imageUrl': imageUrl,
    };
  }

  // Helper method to convert to EnrolledClass for UI compatibility
  EnrolledClass toEnrolledClass() {
    return EnrolledClass(
      id: int.tryParse(id) ?? 0,
      name: name,
      subject: subject,
      teacher: teacher.fullName,
      imageUrl: imageUrl ?? _getDefaultImageForSubject(subject),
      schedule: schedule,
      totalStudents: totalStudents,
      totalAssignments: totalAssignments,
      completedAssignments: completedAssignments,
    );
  }

  String _getDefaultImageForSubject(String subject) {
    switch (subject.toLowerCase()) {
      case 'mathematics':
      case 'math':
        return 'assets/images/math.png';
      case 'science':
      case 'physics':
      case 'chemistry':
      case 'biology':
      case 'bio':
        return 'assets/images/science.png';
      case 'english':
        return 'assets/images/english.png';
      case 'history':
        return 'assets/images/history.png';
      default:
        return 'assets/images/default_class.png';
    }
  }
}

class MyClassesResponse {
  final String status;
  final int results;
  final List<ClassModel> classes;

  MyClassesResponse({
    required this.status,
    required this.results,
    required this.classes,
  });

  factory MyClassesResponse.fromJson(Map<String, dynamic> json) {
    return MyClassesResponse(
      status: json['status'] as String,
      results: json['results'] as int,
      classes:
          (json['data']['classes'] as List)
              .map((classJson) => ClassModel.fromJson(classJson))
              .toList(),
    );
  }
}

class ClassDetailResponse {
  final String status;
  final ClassModel classData;

  ClassDetailResponse({required this.status, required this.classData});

  factory ClassDetailResponse.fromJson(Map<String, dynamic> json) {
    return ClassDetailResponse(
      status: json['status'] as String,
      classData: ClassModel.fromJson(
        json['data']['class'] as Map<String, dynamic>,
      ),
    );
  }
}

// Keep the existing EnrolledClass for backward compatibility
class EnrolledClass {
  final int id;
  final String name;
  final String subject;
  final String teacher;
  final String imageUrl;
  final String schedule;
  final int totalStudents;
  final int completedAssignments;
  final int totalAssignments;

  EnrolledClass({
    required this.id,
    required this.name,
    required this.subject,
    required this.teacher,
    required this.imageUrl,
    required this.schedule,
    required this.totalStudents,
    required this.totalAssignments,
    required this.completedAssignments,
  });
}
