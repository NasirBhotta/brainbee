import 'dart:convert';

import 'package:brainbee/core/utils/file_downloader.dart';
import 'package:brainbee/presentation/views/class/models/material.dart';
import 'package:brainbee/presentation/views/class/repo/material_repo.dart';
import 'package:brainbee/presentation/views/class/services/class_api_service.dart';
import 'package:flutter/material.dart';

class MaterialRepositoryImpl implements MaterialRepository {
  final ClassApiService apiService;

  MaterialRepositoryImpl({required this.apiService});

  @override
  Future<List<ClassMaterial>> getMaterials(String classId) async {
    try {
      // Updated endpoint to match your API
      final response = await apiService.get('/api/material/class/$classId');
      final data = jsonDecode(response.body);

      // Check if the response was successful
      if (data['status'] != 'success') {
        throw Exception('Failed to fetch materials: Invalid response');
      }

      final materialsList = data['data']['materials'] as List? ?? [];

      if (materialsList.isEmpty) {
        return [];
      }

      return materialsList
          .map((m) => ClassMaterial.fromJson(m as Map<String, dynamic>))
          .toList();
    } catch (e) {
      if (e.toString().contains('No internet connection')) {
        throw Exception('No internet connection');
      }
      throw Exception('Failed to load materials: $e');
    }
  }

  @override
  Future<String> downloadMaterial(
    ClassMaterial material, {
    BuildContext? context,
    Function(double)? onProgress,
  }) async {
    try {
      if (context == null) {
        throw Exception('Context is required for download');
      }

      // Use the FileDownloader utility with permission check
      final downloadPath = await FileDownloader.downloadWithPermissionCheck(
        url: material.fileUrl,
        context: context,
        fileName: material.fileName,
        onProgress: onProgress,
      );

      if (downloadPath == null) {
        throw Exception('Download cancelled or failed');
      }

      return downloadPath;
    } catch (e) {
      throw Exception('Failed to download: $e');
    }
  }
}
