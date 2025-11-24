import 'package:brainbee/presentation/views/class/models/assignment_model.dart';
import 'package:equatable/equatable.dart';

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
  final bool isDownloading;
  final String? downloadingFileName;
  final double downloadProgress;

  const AssignmentLoaded({
    required this.assignments,
    this.isSubmitting = false,
    this.submittingId,
    this.isDownloading = false,
    this.downloadingFileName,
    this.downloadProgress = 0.0,
  });

  @override
  List<Object?> get props => [
    assignments,
    isSubmitting,
    submittingId,
    isDownloading,
    downloadingFileName,
    downloadProgress,
  ];

  AssignmentLoaded copyWith({
    List<Assignment>? assignments,
    bool? isSubmitting,
    String? submittingId,
    bool? isDownloading,
    String? downloadingFileName,
    double? downloadProgress,
  }) {
    return AssignmentLoaded(
      assignments: assignments ?? this.assignments,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      submittingId: submittingId,
      isDownloading: isDownloading ?? this.isDownloading,
      downloadingFileName: downloadingFileName,
      downloadProgress: downloadProgress ?? this.downloadProgress,
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
  final String fileUrl;
  final String filePath;

  const AttachmentDownloadSuccess({
    required this.fileUrl,
    required this.filePath,
  });

  @override
  List<Object?> get props => [fileUrl, filePath];
}

class AttachmentDownloadError extends AssignmentState {
  final String fileUrl;
  final String message;

  const AttachmentDownloadError({required this.fileUrl, required this.message});

  @override
  List<Object?> get props => [fileUrl, message];
}
