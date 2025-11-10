// lib/data/repositories/class_repository_impl.dart
import 'dart:convert';

import 'package:brainbee/presentation/views/class/models/class_models.dart';
import 'package:brainbee/presentation/views/class/repo/class_repo.dart';
import 'package:brainbee/presentation/views/class/services/class_api_service.dart';

class ClassRepositoryImpl implements ClassRepository {
  final ClassApiService apiService;

  ClassRepositoryImpl({required this.apiService});

  @override
  Future<List<ClassModel>> getMyClasses() async {
    try {
      final response = await apiService.get('/api/classes/student/my-classes');

      var data = jsonDecode(response.body);
      final classesResponse = MyClassesResponse.fromJson(data);

      return classesResponse.classes;
    } catch (e) {
      throw Exception('Failed to load classes: $e');
    }
  }

  @override
  Future<ClassModel> getClassDetail(String classId) async {
    try {
      final response = await apiService.get(
        '/api/classes/$classId/student-view',
      );

      final Map<String, dynamic> data = jsonDecode(response.body);
      final classDetailResponse = ClassDetailResponse.fromJson(data);

      return classDetailResponse.classData;
    } catch (e) {
      throw Exception('Failed to load class details: $e');
    }
  }
}
