import 'package:brainbee/presentation/views/class/models/material.dart';

abstract class MaterialRepository {
  Future<List<ClassMaterial>> getMaterials(String classId);
  Future<String> downloadMaterial(ClassMaterial material);
}
