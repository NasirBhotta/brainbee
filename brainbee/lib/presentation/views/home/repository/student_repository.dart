import 'dart:convert';
import 'dart:io';
import 'package:brainbee/core/models/token_user.dart';
import 'package:brainbee/presentation/views/auth/models/user_model.dart';
import 'package:brainbee/presentation/views/home/models/bb_student_model.dart';
import 'package:brainbee/presentation/views/home/services/student_api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StudentRepository {
  final AuthApiService _apiService = AuthApiService();

  // Mock response data (keeping the same structure from your BLoC)
  final Map<String, dynamic> _mockResponse = {
    "status": "success",
    "accessToken": "dummy-token-123",
    "user": {
      "id": "S001",
      "email": "student@example.com",
      "firstName": "Ali",
      "lastName": "Khan",
      "grade": 8,
      "subjects": ["Math", "Science"],
      "parentId": "P001",
      "coins": 120,
      "streakScore": 5,
      "lastStreakDate": "2025-08-10T00:00:00.000Z",
      "dailyLives": 5,
      "livesResetTime": "2025-08-23T00:00:00.000Z",
      "friends": ["S002", "S003"],
      "achievements": {"badges": [], "trophies": []},
      "leaderboardStats": {"rank": 15, "points": 1200},
      "battleStats": {"wins": 10, "losses": 3, "totalBattles": 13},
      "enrolledClasses": ["Math101", "Sci101"],
      "chapter_levels": {"math_ch1": "completed", "sci_ch1": "in-progress"},
      "score": 25,
      "topic_performance": {
        "fractions": {"attempts": 10, "correct": 7},
        "algebra": {"attempts": 5, "correct": 4},
      },
      "goal": {
        "title": "Casual",
        "description": "2 Quizzes & Estimate 7 minutes daily",
        "dueDate": "2025-08-30T00:00:00.000Z",
        "reminder": [],
        "value": 2,
        "status": true,
        "noOfAttempts": 2,
      },
    },
  };

  Future<TokenUserData> getTokenAndUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      final userData = prefs.getString('user_data');

      UserModel? user;
      if (userData != null && userData.isNotEmpty) {
        try {
          final userMap = jsonDecode(userData);
          user = UserModel.fromJson(userMap);
        } catch (e) {
          await removeTokenAndUser();
        }
      }

      return TokenUserData(token: token, user: user);
    } catch (e) {
      return TokenUserData(token: null, user: null);
    }
  }

  Future<void> removeTokenAndUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
      await prefs.remove('user_data');
    } catch (e) {
      throw Exception("Error removing token and user: $e");
    }
  }

  Future<StudentModel> fetchStudentData() async {
    final tokenUserData = await getTokenAndUser();
    final token = tokenUserData.token;

    print("tokem is $token");
    if (token == null || token.isEmpty) {
      throw Exception("Authentication token not found");
    }

    try {
      final response = await _apiService.getProfile(token);

      if (response.statusCode != 200) {
        throw Exception('Failed to fetch profile data: ${response.body}');
      }

      final responseData = jsonDecode(response.body);

      if (responseData['status'] != 'success') {
        throw Exception(
          'API Error: ${responseData['message'] ?? 'Unknown error'}',
        );
      }

      // Transform API response to match StudentModel structure
      final userData = responseData['data']['user'];
      final transformedResponse = _transformUserDataToStudentModel(
        userData,
        token,
      );

      return StudentModel.fromJson(transformedResponse);
    } catch (e) {
      if (e.toString().contains('Connection refused')) {
        throw Exception(
          "Cannot connect to server. Please check your connection.",
        );
      } else if (e.toString().contains('TimeoutException')) {
        throw Exception(
          "Request timed out. Please check your internet connection.",
        );
      }
      rethrow;
    }
  }

  Map<String, dynamic> _transformUserDataToStudentModel(
    Map<String, dynamic> userData,
    String token,
  ) {
    return {
      "status": "success",
      "accessToken": token,
      "user": {
        "profileImage": userData['profileImage'],
        "id": userData['_id'],
        "email": userData['email'],
        "firstName": userData['firstName'],
        "lastName": userData['lastName'],
        "grade": userData['grade'] ?? 8,
        "subjects": userData['subjects'] ?? [],
        "parentId": userData['parentId'],
        "coins": userData['coins'] ?? 0,
        "streakScore": userData['streakScore'] ?? 0,
        "lastStreakDate": userData['lastStreakDate'],
        "dailyLives": userData['dailyLives'] ?? 5,
        "livesResetTime": userData['livesResetTime'],
        "friends": userData['friends'] ?? [],
        "achievements":
            userData['achievements'] ?? {"badges": [], "certificates": []},
        "leaderboardStats": _transformLeaderboardStats(
          userData['leaderboardStats'],
        ),
        "battleStats":
            userData['battleStats'] ??
            {"wins": 0, "losses": 0, "totalBattles": 0},
        "enrolledClasses": userData['enrolledClasses'] ?? [],
        "chapter_levels": userData['chapter_levels'] ?? {},
        "score": userData['score'] ?? 0,
        "topic_performance": userData['topic_performance'] ?? {},
        "goal": userData['goal'] ?? _getDefaultGoal(),
      },
    };
  }

  Map<String, dynamic> _transformLeaderboardStats(Map<String, dynamic>? stats) {
    if (stats == null) return {"rank": 0, "points": 0};

    // Transform API leaderboard format to expected format
    final totalPoints =
        (stats['weeklyScore'] ?? 0) +
        (stats['monthlyScore'] ?? 0) +
        (stats['yearlyScore'] ?? 0) +
        (stats['overallScore'] ?? 0);

    return {"rank": stats['rank'] ?? 0, "points": totalPoints};
  }

  Map<String, dynamic> _getDefaultGoal() {
    return {
      "title": "Casual",
      "description": "2 Quizzes & Estimate 7 minutes daily",
      "dueDate": DateTime.now().add(Duration(days: 7)).toIso8601String(),
      "reminder": [],
      "value": 2,
      "status": true,
      "noOfAttempts": 0,
    };
  }

  Future<StudentModel> updateProfile({
    required File image,
    required String firstName,
    required String lastName,
    required String address,
    required String phoneNumber,
  }) async {
    final tokenUserData = await getTokenAndUser();
    final token = tokenUserData.token;
    final user = tokenUserData.user;

    if (token == null || token.isEmpty) {
      throw Exception("Authentication token not found");
    }

    try {
      // Update profile image
      final imageResponse = await _apiService.updateProfileImage(image, token);
      if (imageResponse.statusCode != 200) {
        throw Exception(
          'Failed to update profile image: ${imageResponse.body}',
        );
      }

      // Update other profile data
      final profileResponse = await _apiService.updateProfileData(
        firstName: firstName,
        lastName: lastName,
        address: address,
        phoneNumber: phoneNumber,
        token: token,
      );

      if (profileResponse.statusCode != 200) {
        throw Exception(
          'Failed to update profile data: ${profileResponse.body}',
        );
      }

      // Update local mock response data
      final studentData = await fetchStudentData();

      return studentData;
    } catch (e) {
      if (e.toString().contains('Connection refused')) {
        throw Exception(
          "Cannot connect to server. Please check your connection.",
        );
      } else if (e.toString().contains('TimeoutException')) {
        throw Exception(
          "Request timed out. Please check your internet connection.",
        );
      }
      rethrow;
    }
  }

  Future<StudentModel> updateGoals({
    required String title,
    required String description,
    required DateTime dueDate,
    required List<DateTime> reminders,
    required int value,
    required bool status,
  }) async {
    await Future.delayed(const Duration(seconds: 2)); // Simulate API delay

    final int noOfAttempts = _mockResponse['user']['goal']['noOfAttempts'];

    // Update goal data in mock response
    _mockResponse['user']['goal'] = {
      "title": title,
      "description": description,
      "dueDate": dueDate.toIso8601String(),
      "reminder": reminders.map((date) => date.toIso8601String()).toList(),
      "value": value,
      "status": status,
      "noOfAttempts": noOfAttempts,
    };

    return StudentModel.fromJson(_mockResponse);
  }
}
