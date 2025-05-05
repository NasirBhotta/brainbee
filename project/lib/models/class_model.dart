class ClassModel {
  final String id;
  final String name;
  final String teacherName;
  final String teacherId;
  final String description;
  final String imageUrl;
  final String schedule;
  final String location;
  final DateTime startDate;
  final DateTime endDate;
  final List<String> announcements;
  final int materialsCount;
  final int assignmentsCount;
  final int quizzesCount;
  final double overallGrade;
  
  ClassModel({
    required this.id,
    required this.name,
    required this.teacherName,
    required this.teacherId,
    required this.description,
    required this.imageUrl,
    required this.schedule,
    required this.location,
    required this.startDate,
    required this.endDate,
    required this.announcements,
    required this.materialsCount,
    required this.assignmentsCount,
    required this.quizzesCount,
    required this.overallGrade,
  });
  
  factory ClassModel.fromJson(Map<String, dynamic> json) {
    return ClassModel(
      id: json['id'],
      name: json['name'],
      teacherName: json['teacher_name'],
      teacherId: json['teacher_id'],
      description: json['description'],
      imageUrl: json['image_url'],
      schedule: json['schedule'],
      location: json['location'],
      startDate: DateTime.parse(json['start_date']),
      endDate: DateTime.parse(json['end_date']),
      announcements: List<String>.from(json['announcements'] ?? []),
      materialsCount: json['materials_count'] ?? 0,
      assignmentsCount: json['assignments_count'] ?? 0,
      quizzesCount: json['quizzes_count'] ?? 0,
      overallGrade: json['overall_grade']?.toDouble() ?? 0.0,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'teacher_name': teacherName,
      'teacher_id': teacherId,
      'description': description,
      'image_url': imageUrl,
      'schedule': schedule,
      'location': location,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'announcements': announcements,
      'materials_count': materialsCount,
      'assignments_count': assignmentsCount,
      'quizzes_count': quizzesCount,
      'overall_grade': overallGrade,
    };
  }
}

// Mock data for UI development
List<ClassModel> mockClasses = [
  ClassModel(
    id: '1',
    name: 'Introduction to Computer Science',
    teacherName: 'Dr. Jane Smith',
    teacherId: 'teacher1',
    description: 'An introductory course covering basic computer science concepts and programming fundamentals.',
    imageUrl: 'https://images.pexels.com/photos/546819/pexels-photo-546819.jpeg',
    schedule: 'Mon, Wed, Fri 10:00-11:30 AM',
    location: 'Room 301, CS Building',
    startDate: DateTime.now().subtract(const Duration(days: 30)),
    endDate: DateTime.now().add(const Duration(days: 60)),
    announcements: ['Midterm exam date announced', 'New project guidelines uploaded'],
    materialsCount: 15,
    assignmentsCount: 5,
    quizzesCount: 3,
    overallGrade: 92.5,
  ),
  ClassModel(
    id: '2',
    name: 'Calculus II',
    teacherName: 'Prof. Michael Johnson',
    teacherId: 'teacher2',
    description: 'Advanced calculus topics including integration techniques, sequences, and series.',
    imageUrl: 'https://images.pexels.com/photos/6238050/pexels-photo-6238050.jpeg',
    schedule: 'Tue, Thu 1:00-2:30 PM',
    location: 'Room 205, Math Building',
    startDate: DateTime.now().subtract(const Duration(days: 45)),
    endDate: DateTime.now().add(const Duration(days: 45)),
    announcements: ['Quiz postponed to next week', 'Office hours changed'],
    materialsCount: 12,
    assignmentsCount: 8,
    quizzesCount: 4,
    overallGrade: 85.0,
  ),
  ClassModel(
    id: '3',
    name: 'World History',
    teacherName: 'Dr. Sarah Wilson',
    teacherId: 'teacher3',
    description: 'A comprehensive overview of major historical events and movements throughout world history.',
    imageUrl: 'https://images.pexels.com/photos/1205651/pexels-photo-1205651.jpeg',
    schedule: 'Mon, Wed 3:00-4:30 PM',
    location: 'Room 102, Humanities Building',
    startDate: DateTime.now().subtract(const Duration(days: 60)),
    endDate: DateTime.now().add(const Duration(days: 30)),
    announcements: ['Research paper deadline extended', 'Museum visit next Friday'],
    materialsCount: 18,
    assignmentsCount: 4,
    quizzesCount: 2,
    overallGrade: 78.5,
  ),
  ClassModel(
    id: '4',
    name: 'Organic Chemistry',
    teacherName: 'Prof. David Brown',
    teacherId: 'teacher4',
    description: 'Study of carbon compounds and their reactions, focusing on structure and mechanisms.',
    imageUrl: 'https://images.pexels.com/photos/2280549/pexels-photo-2280549.jpeg',
    schedule: 'Tue, Thu 9:00-10:30 AM',
    location: 'Lab 3, Science Building',
    startDate: DateTime.now().subtract(const Duration(days: 15)),
    endDate: DateTime.now().add(const Duration(days: 75)),
    announcements: ['Lab safety reminder', 'Project groups assigned'],
    materialsCount: 10,
    assignmentsCount: 6,
    quizzesCount: 5,
    overallGrade: 88.0,
  ),
];