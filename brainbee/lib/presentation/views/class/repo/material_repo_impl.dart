import 'dart:convert';

import 'package:brainbee/presentation/views/class/models/material.dart';
import 'package:brainbee/presentation/views/class/repo/material_repo.dart';
import 'package:brainbee/presentation/views/class/services/class_api_service.dart';

class MaterialRepositoryImpl implements MaterialRepository {
  final ClassApiService apiService;
  MaterialRepositoryImpl({required this.apiService});

  @override
  Future<List<ClassMaterial>> getMaterials(String classId) async {
    try {
      final response = await apiService.get('/api/classes/$classId/materials');
      final data = jsonDecode(response.body);
      final materialsList = data['data']['materials'] as List? ?? [];
      return materialsList.map((m) => ClassMaterial.fromJson(m)).toList();
    } catch (e) {
      throw Exception('Failed to load materials: $e');
    }
  }

  @override
  Future<String> downloadMaterial(ClassMaterial material) async {
    try {
      // In real implementation, use dio or http to download file
      // For now, simulate download and return mock path
      await Future.delayed(const Duration(seconds: 1));
      return '/downloads/${material.name}';
    } catch (e) {
      throw Exception('Failed to download: $e');
    }
  }
}
