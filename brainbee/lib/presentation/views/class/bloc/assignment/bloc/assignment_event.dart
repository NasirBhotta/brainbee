part of 'assignment_bloc.dart';

abstract class AssignmentEvent extends Equatable {
  const AssignmentEvent();
  @override
  List<Object?> get props => [];
}

class FetchAssignmentsEvent extends AssignmentEvent {
  final String classId;
  const FetchAssignmentsEvent({required this.classId});
  @override
  List<Object?> get props => [classId];
}

class RefreshAssignmentsEvent extends AssignmentEvent {
  final String classId;
  const RefreshAssignmentsEvent({required this.classId});
  @override
  List<Object?> get props => [classId];
}

class SubmitAssignmentEvent extends AssignmentEvent {
  final String assignmentId;
  final List<String> filePaths;
  const SubmitAssignmentEvent({
    required this.assignmentId,
    required this.filePaths,
  });
  @override
  List<Object?> get props => [assignmentId, filePaths];
}

class DownloadAttachmentEvent extends AssignmentEvent {
  final AssignmentFile file;
  const DownloadAttachmentEvent({required this.file});
  @override
  List<Object?> get props => [file];
}
