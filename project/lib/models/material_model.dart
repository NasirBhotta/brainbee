class MaterialModel {
  final String id;
  final String classId;
  final String title;
  final String description;
  final String fileUrl;
  final String fileType;
  final int fileSize;
  final DateTime uploadDate;
  final bool isDownloaded;
  final String uploadedBy;
  final List<String> tags;
  
  MaterialModel({
    required this.id,
    required this.classId,
    required this.title,
    required this.description,
    required this.fileUrl,
    required this.fileType,
    required this.fileSize,
    required this.uploadDate,
    required this.isDownloaded,
    required this.uploadedBy,
    required this.tags,
  });
  
  factory MaterialModel.fromJson(Map<String, dynamic> json) {
    return MaterialModel(
      id: json['id'],
      classId: json['class_id'],
      title: json['title'],
      description: json['description'],
      fileUrl: json['file_url'],
      fileType: json['file_type'],
      fileSize: json['file_size'],
      uploadDate: DateTime.parse(json['upload_date']),
      isDownloaded: json['is_downloaded'] ?? false,
      uploadedBy: json['uploaded_by'],
      tags: List<String>.from(json['tags'] ?? []),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'class_id': classId,
      'title': title,
      'description': description,
      'file_url': fileUrl,
      'file_type': fileType,
      'file_size': fileSize,
      'upload_date': uploadDate.toIso8601String(),
      'is_downloaded': isDownloaded,
      'uploaded_by': uploadedBy,
      'tags': tags,
    };
  }
}

// Mock data for UI development
List<MaterialModel> mockMaterials = [
  MaterialModel(
    id: '1',
    classId: '1',
    title: 'Introduction to Programming - Lecture Slides',
    description: 'Slides covering basic programming concepts and syntax.',
    fileUrl: 'https://example.com/files/lecture1.pdf',
    fileType: 'pdf',
    fileSize: 2500000, // 2.5MB
    uploadDate: DateTime.now().subtract(const Duration(days: 25)),
    isDownloaded: true,
    uploadedBy: 'Dr. Jane Smith',
    tags: ['lecture', 'programming', 'introduction'],
  ),
  MaterialModel(
    id: '2',
    classId: '1',
    title: 'Algorithm Design - Worksheet',
    description: 'Practice problems on algorithm design and complexity analysis.',
    fileUrl: 'https://example.com/files/worksheet1.pdf',
    fileType: 'pdf',
    fileSize: 1200000, // 1.2MB
    uploadDate: DateTime.now().subtract(const Duration(days: 18)),
    isDownloaded: false,
    uploadedBy: 'Dr. Jane Smith',
    tags: ['worksheet', 'algorithms', 'practice'],
  ),
  MaterialModel(
    id: '3',
    classId: '1',
    title: 'Python Setup Guide',
    description: 'Step-by-step instructions for setting up Python and required libraries.',
    fileUrl: 'https://example.com/files/python_setup.docx',
    fileType: 'docx',
    fileSize: 850000, // 850KB
    uploadDate: DateTime.now().subtract(const Duration(days: 23)),
    isDownloaded: false,
    uploadedBy: 'Dr. Jane Smith',
    tags: ['guide', 'python', 'setup'],
  ),
  MaterialModel(
    id: '4',
    classId: '2',
    title: 'Integration Techniques - Summary',
    description: 'Comprehensive summary of various integration techniques and formulas.',
    fileUrl: 'https://example.com/files/integration.pdf',
    fileType: 'pdf',
    fileSize: 3100000, // 3.1MB
    uploadDate: DateTime.now().subtract(const Duration(days: 15)),
    isDownloaded: true,
    uploadedBy: 'Prof. Michael Johnson',
    tags: ['calculus', 'integration', 'summary'],
  ),
  MaterialModel(
    id: '5',
    classId: '2',
    title: 'Infinite Series - Practice Problems',
    description: 'Collection of problems on convergence tests and series calculations.',
    fileUrl: 'https://example.com/files/series_problems.pdf',
    fileType: 'pdf',
    fileSize: 1800000, // 1.8MB
    uploadDate: DateTime.now().subtract(const Duration(days: 10)),
    isDownloaded: false,
    uploadedBy: 'Prof. Michael Johnson',
    tags: ['practice', 'series', 'calculus'],
  ),
];