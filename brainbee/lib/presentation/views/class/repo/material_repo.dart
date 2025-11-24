import 'package:flutter/material.dart';
import 'package:brainbee/presentation/views/class/models/material.dart';

abstract class MaterialRepository {
  /// Fetch all materials for a specific class
  Future<List<ClassMaterial>> getMaterials(String classId);

  /// Download a material file
  /// Returns the local file path of the downloaded file
  Future<String> downloadMaterial(
    ClassMaterial material, {
    BuildContext? context,
    Function(double)? onProgress,
  });
}
