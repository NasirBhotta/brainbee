// bloc/assignment_event.dart

part of 'assignment_bloc.dart';

abstract class AssignmentEvent extends Equatable {
  const AssignmentEvent();

  @override
  List<Object> get props => [];
}

class FetchAssignmentsEvent extends AssignmentEvent {
  const FetchAssignmentsEvent();
}

class RefreshAssignmentsEvent extends AssignmentEvent {
  const RefreshAssignmentsEvent();
}

class SubmitAssignmentEvent extends AssignmentEvent {
  final String assignmentId;
  final String filePath;

  const SubmitAssignmentEvent({
    required this.assignmentId,
    required this.filePath,
  });

  @override
  List<Object> get props => [assignmentId, filePath];
}

class DownloadAttachmentEvent extends AssignmentEvent {
  final String fileUrl;
  final String fileName;
  final BuildContext context;

  const DownloadAttachmentEvent({
    required this.fileUrl,
    required this.fileName,
    required this.context,
  });

  @override
  List<Object> get props => [fileUrl, fileName];
}
