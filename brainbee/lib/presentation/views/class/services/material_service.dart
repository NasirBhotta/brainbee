import 'dart:convert';
import 'package:brainbee/presentation/views/class/services/class_api_service.dart';

class MaterialService {
  final ClassApiService apiService;
  MaterialService({required this.apiService});

  Future<List<Map<String, dynamic>>> getMaterials(String classId) async {
    try {
      final response = await apiService.get('/api/classes/$classId/materials');
      final data = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(data['data']['materials'] ?? []);
    } catch (e) {
      throw Exception('Failed to load materials: $e');
    }
  }

  Future<String> getDownloadUrl(String materialId) async {
    try {
      final response = await apiService.get(
        '/api/materials/$materialId/download',
      );
      final data = jsonDecode(response.body);
      return data['data']['downloadUrl'] as String;
    } catch (e) {
      throw Exception('Failed to get download URL: $e');
    }
  }
}
