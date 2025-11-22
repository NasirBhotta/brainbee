part of 'assignment_bloc.dart';

abstract class AssignmentState extends Equatable {
  const AssignmentState();
  @override
  List<Object?> get props => [];
}

class AssignmentInitial extends AssignmentState {}

class AssignmentLoading extends AssignmentState {}

class AssignmentLoaded extends AssignmentState {
  final List<Assignment> assignments;
  final bool isSubmitting;
  final String? submittingId;

  const AssignmentLoaded({
    required this.assignments,
    this.isSubmitting = false,
    this.submittingId,
  });

  @override
  List<Object?> get props => [assignments, isSubmitting, submittingId];

  AssignmentLoaded copyWith({
    List<Assignment>? assignments,
    bool? isSubmitting,
    String? submittingId,
  }) {
    return AssignmentLoaded(
      assignments: assignments ?? this.assignments,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      submittingId: submittingId,
    );
  }
}

class AssignmentEmpty extends AssignmentState {}

class AssignmentError extends AssignmentState {
  final String message;
  final bool isNetworkError;
  const AssignmentError({required this.message, this.isNetworkError = false});
  @override
  List<Object?> get props => [message, isNetworkError];
}

class AssignmentSubmitSuccess extends AssignmentState {
  final String assignmentId;
  final DateTime submittedAt;
  const AssignmentSubmitSuccess({
    required this.assignmentId,
    required this.submittedAt,
  });
  @override
  List<Object?> get props => [assignmentId, submittedAt];
}

class AssignmentSubmitError extends AssignmentState {
  final String assignmentId;
  final String message;
  const AssignmentSubmitError({
    required this.assignmentId,
    required this.message,
  });
  @override
  List<Object?> get props => [assignmentId, message];
}

class AttachmentDownloadSuccess extends AssignmentState {
  final AssignmentFile file;
  final String path;
  const AttachmentDownloadSuccess({required this.file, required this.path});
  @override
  List<Object?> get props => [file, path];
}

class AttachmentDownloadError extends AssignmentState {
  final AssignmentFile file;
  final String message;
  const AttachmentDownloadError({required this.file, required this.message});
  @override
  List<Object?> get props => [file, message];
}
