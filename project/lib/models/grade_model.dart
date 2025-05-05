class GradeModel {
  final String id;
  final String classId;
  final String title;
  final String type; // assignment, quiz, exam, etc.
  final double score;
  final double maxScore;
  final double weightPercentage;
  final DateTime gradedDate;
  final String feedback;
  final List<GradeCriterion> criteria;
  
  GradeModel({
    required this.id,
    required this.classId,
    required this.title,
    required this.type,
    required this.score,
    required this.maxScore,
    required this.weightPercentage,
    required this.gradedDate,
    required this.feedback,
    required this.criteria,
  });
  
  factory GradeModel.fromJson(Map<String, dynamic> json) {
    return GradeModel(
      id: json['id'],
      classId: json['class_id'],
      title: json['title'],
      type: json['type'],
      score: json['score'].toDouble(),
      maxScore: json['max_score'].toDouble(),
      weightPercentage: json['weight_percentage'].toDouble(),
      gradedDate: DateTime.parse(json['graded_date']),
      feedback: json['feedback'] ?? '',
      criteria: json['criteria'] != null
          ? List<GradeCriterion>.from(
              json['criteria'].map((criterion) => GradeCriterion.fromJson(criterion)))
          : [],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'class_id': classId,
      'title': title,
      'type': type,
      'score': score,
      'max_score': maxScore,
      'weight_percentage': weightPercentage,
      'graded_date': gradedDate.toIso8601String(),
      'feedback': feedback,
      'criteria': criteria.map((criterion) => criterion.toJson()).toList(),
    };
  }
  
  double get percentage => (score / maxScore) * 100;
}

class GradeCriterion {
  final String name;
  final double score;
  final double maxScore;
  final String feedback;
  
  GradeCriterion({
    required this.name,
    required this.score,
    required this.maxScore,
    required this.feedback,
  });
  
  factory GradeCriterion.fromJson(Map<String, dynamic> json) {
    return GradeCriterion(
      name: json['name'],
      score: json['score'].toDouble(),
      maxScore: json['max_score'].toDouble(),
      feedback: json['feedback'] ?? '',
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'score': score,
      'max_score': maxScore,
      'feedback': feedback,
    };
  }
  
  double get percentage => (score / maxScore) * 100;
}

// Performance trend data model
class PerformanceTrendModel {
  final String classId;
  final List<PerformanceDataPoint> dataPoints;
  
  PerformanceTrendModel({
    required this.classId,
    required this.dataPoints,
  });
  
  factory PerformanceTrendModel.fromJson(Map<String, dynamic> json) {
    return PerformanceTrendModel(
      classId: json['class_id'],
      dataPoints: List<PerformanceDataPoint>.from(
        json['data_points'].map((point) => PerformanceDataPoint.fromJson(point)),
      ),
    );
  }
}

class PerformanceDataPoint {
  final DateTime date;
  final double score;
  final String assessmentTitle;
  
  PerformanceDataPoint({
    required this.date,
    required this.score,
    required this.assessmentTitle,
  });
  
  factory PerformanceDataPoint.fromJson(Map<String, dynamic> json) {
    return PerformanceDataPoint(
      date: DateTime.parse(json['date']),
      score: json['score'].toDouble(),
      assessmentTitle: json['assessment_title'],
    );
  }
}

// Mock data for UI development
List<GradeModel> mockGrades = [
  GradeModel(
    id: '1',
    classId: '1',
    title: 'Assignment 1: Introduction to Algorithms',
    type: 'assignment',
    score: 85,
    maxScore: 100,
    weightPercentage: 10,
    gradedDate: DateTime.now().subtract(const Duration(days: 20)),
    feedback: 'Good work on the algorithm analysis. Work on code optimization for better performance.',
    criteria: [
      GradeCriterion(name: 'Algorithm Analysis', score: 25, maxScore: 30, feedback: 'Well explained big O notation'),
      GradeCriterion(name: 'Code Implementation', score: 35, maxScore: 40, feedback: 'Code works but could be optimized'),
      GradeCriterion(name: 'Documentation', score: 25, maxScore: 30, feedback: 'Comprehensive documentation'),
    ],
  ),
  GradeModel(
    id: '2',
    classId: '1',
    title: 'Quiz 1: Data Structures',
    type: 'quiz',
    score: 18,
    maxScore: 20,
    weightPercentage: 5,
    gradedDate: DateTime.now().subtract(const Duration(days: 15)),
    feedback: 'Excellent understanding of data structures concepts.',
    criteria: [
      GradeCriterion(name: 'Multiple Choice', score: 8, maxScore: 8, feedback: 'Perfect'),
      GradeCriterion(name: 'Short Answer', score: 10, maxScore: 12, feedback: 'Good explanations but missed one key point'),
    ],
  ),
  GradeModel(
    id: '3',
    classId: '1',
    title: 'Midterm Exam',
    type: 'exam',
    score: 87,
    maxScore: 100,
    weightPercentage: 25,
    gradedDate: DateTime.now().subtract(const Duration(days: 10)),
    feedback: 'Strong performance overall. Review the section on recursion for the final exam.',
    criteria: [
      GradeCriterion(name: 'Algorithm Design', score: 22, maxScore: 25, feedback: 'Well structured algorithms'),
      GradeCriterion(name: 'Data Structures', score: 23, maxScore: 25, feedback: 'Excellent understanding'),
      GradeCriterion(name: 'Recursion', score: 18, maxScore: 25, feedback: 'Review base cases and recursive step'),
      GradeCriterion(name: 'Complexity Analysis', score: 24, maxScore: 25, feedback: 'Accurate analysis'),
    ],
  ),
  GradeModel(
    id: '4',
    classId: '2',
    title: 'Assignment 1: Integration Techniques',
    type: 'assignment',
    score: 75,
    maxScore: 100,
    weightPercentage: 15,
    gradedDate: DateTime.now().subtract(const Duration(days: 18)),
    feedback: 'You need to practice more on integration by parts. Your substitution method solutions were well done.',
    criteria: [
      GradeCriterion(name: 'Substitution Method', score: 28, maxScore: 30, feedback: 'Well done'),
      GradeCriterion(name: 'Integration by Parts', score: 20, maxScore: 30, feedback: 'Review this method'),
      GradeCriterion(name: 'Partial Fractions', score: 27, maxScore: 40, feedback: 'Good work on decomposition'),
    ],
  ),
  GradeModel(
    id: '5',
    classId: '2',
    title: 'Quiz 1: Convergence Tests',
    type: 'quiz',
    score: 15,
    maxScore: 20,
    weightPercentage: 5,
    gradedDate: DateTime.now().subtract(const Duration(days: 12)),
    feedback: 'Good application of convergence tests. Review the ratio test application.',
    criteria: [
      GradeCriterion(name: 'Multiple Choice', score: 7, maxScore: 8, feedback: 'Well done'),
      GradeCriterion(name: 'Problem Solving', score: 8, maxScore: 12, feedback: 'Check your work on ratio test problems'),
    ],
  ),
];

// Mock performance trend data
PerformanceTrendModel mockPerformanceTrend = PerformanceTrendModel(
  classId: '1',
  dataPoints: [
    PerformanceDataPoint(
      date: DateTime.now().subtract(const Duration(days: 60)),
      score: 78,
      assessmentTitle: 'Quiz 0: Pre-assessment',
    ),
    PerformanceDataPoint(
      date: DateTime.now().subtract(const Duration(days: 45)),
      score: 82,
      assessmentTitle: 'Assignment 1',
    ),
    PerformanceDataPoint(
      date: DateTime.now().subtract(const Duration(days: 30)),
      score: 85,
      assessmentTitle: 'Quiz 1',
    ),
    PerformanceDataPoint(
      date: DateTime.now().subtract(const Duration(days: 15)),
      score: 87,
      assessmentTitle: 'Midterm Exam',
    ),
    PerformanceDataPoint(
      date: DateTime.now().subtract(const Duration(days: 7)),
      score: 90,
      assessmentTitle: 'Assignment 2',
    ),
  ],
);