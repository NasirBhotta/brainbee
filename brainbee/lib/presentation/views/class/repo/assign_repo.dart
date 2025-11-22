import 'package:brainbee/presentation/views/class/models/assignment_model.dart';

abstract class AssignmentRepository {
  Future<List<Assignment>> getAssignments(String classId);
  Future<Assignment> getAssignmentDetail(String assignmentId);
  Future<void> submitAssignment(String assignmentId, List<String> filePaths);
  Future<String> downloadAttachment(AssignmentFile file);
}
