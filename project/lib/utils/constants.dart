class AppConstants {
  // API endpoints
  static const String baseUrl = 'https://api.studentapp.com/v1';
  static const String loginEndpoint = '/auth/login';
  static const String classesEndpoint = '/classes';
  static const String materialsEndpoint = '/materials';
  static const String discussionsEndpoint = '/discussions';
  static const String gradesEndpoint = '/grades';
  static const String assignmentsEndpoint = '/assignments';
  static const String quizzesEndpoint = '/quizzes';
  
  // Shared preferences keys
  static const String tokenKey = 'auth_token';
  static const String userIdKey = 'user_id';
  static const String userNameKey = 'user_name';
  static const String userEmailKey = 'user_email';
  
  // Animation durations
  static const Duration shortAnimationDuration = Duration(milliseconds: 150);
  static const Duration mediumAnimationDuration = Duration(milliseconds: 300);
  static const Duration longAnimationDuration = Duration(milliseconds: 500);
  
  // File upload limits
  static const int maxFileSize = 10 * 1024 * 1024; // 10MB
  static const List<String> allowedFileTypes = [
    'pdf', 'doc', 'docx', 'ppt', 'pptx', 'xls', 'xlsx', 'txt', 'jpg', 'jpeg', 'png'
  ];
  
  // Pagination
  static const int defaultPageSize = 20;

  // Placeholder images
  static const String placeholderProfileImage = 'https://images.pexels.com/photos/774909/pexels-photo-774909.jpeg';
  static const String placeholderClassImage = 'https://images.pexels.com/photos/256541/pexels-photo-256541.jpeg';
  static const String placeholderMaterialImage = 'https://images.pexels.com/photos/1925536/pexels-photo-1925536.jpeg';
}