// lib/data/repositories/class_repository.dart

import 'package:brainbee/presentation/views/class/models/class_models.dart';

abstract class ClassRepository {
  Future<List<ClassModel>> getMyClasses();
  Future<ClassModel> getClassDetail(String classId);
}
