// bloc/assignment_bloc.dart

import 'package:bloc/bloc.dart';
import 'package:brainbee/presentation/views/class/bloc/assignment/bloc/assignment_state.dart';
import 'package:brainbee/presentation/views/class/repo/asign_repo_impl.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

part 'assignment_event.dart';

class AssignmentBloc extends Bloc<AssignmentEvent, AssignmentState> {
  final AssignmentRepository repository;
  // Callback to notify parent when assignment is submitted
  final Function()? onAssignmentSubmitted;

  AssignmentBloc({required this.repository, this.onAssignmentSubmitted})
    : super(AssignmentInitial()) {
    on<FetchAssignmentsEvent>(_onFetchAssignments);
    on<RefreshAssignmentsEvent>(_onRefreshAssignments);
    on<SubmitAssignmentEvent>(_onSubmitAssignment);
    on<DownloadAttachmentEvent>(_onDownloadAttachment);
  }

  Future<void> _onFetchAssignments(
    FetchAssignmentsEvent event,
    Emitter<AssignmentState> emit,
  ) async {
    emit(AssignmentLoading());

    try {
      final assignments = await repository.getStudentAssignments();
      if (assignments.isEmpty) {
        emit(AssignmentEmpty());
      } else {
        emit(AssignmentLoaded(assignments: assignments));
      }
    } catch (e) {
      emit(
        AssignmentError(
          message: _getErrorMessage(e),
          isNetworkError: _isNetworkError(e),
        ),
      );
    }
  }

  Future<void> _onRefreshAssignments(
    RefreshAssignmentsEvent event,
    Emitter<AssignmentState> emit,
  ) async {
    final currentState = state;
    try {
      final assignments = await repository.getStudentAssignments();
      if (assignments.isEmpty) {
        emit(AssignmentEmpty());
      } else {
        emit(AssignmentLoaded(assignments: assignments));
      }
    } catch (e) {
      if (currentState is AssignmentLoaded) {
        emit(currentState);
      } else {
        emit(
          AssignmentError(
            message: _getErrorMessage(e),
            isNetworkError: _isNetworkError(e),
          ),
        );
      }
    }
  }

  Future<void> _onSubmitAssignment(
    SubmitAssignmentEvent event,
    Emitter<AssignmentState> emit,
  ) async {
    final currentState = state;
    if (currentState is! AssignmentLoaded) return;

    emit(
      currentState.copyWith(
        isSubmitting: true,
        submittingId: event.assignmentId,
      ),
    );

    try {
      await repository.submitAssignment(event.assignmentId, event.filePath);

      // Emit success state
      emit(
        AssignmentSubmitSuccess(
          assignmentId: event.assignmentId,
          submittedAt: DateTime.now(),
        ),
      );

      // Refresh assignments to get updated status
      final assignments = await repository.getStudentAssignments();
      emit(AssignmentLoaded(assignments: assignments));

      // Notify parent (ClassBloc) to refresh class data
      onAssignmentSubmitted?.call();
    } catch (e) {
      emit(currentState.copyWith(isSubmitting: false));
      emit(
        AssignmentSubmitError(
          assignmentId: event.assignmentId,
          message: _getErrorMessage(e),
        ),
      );
      emit(currentState.copyWith(isSubmitting: false));
    }
  }

  Future<void> _onDownloadAttachment(
    DownloadAttachmentEvent event,
    Emitter<AssignmentState> emit,
  ) async {
    final currentState = state;
    if (currentState is! AssignmentLoaded) return;

    emit(
      currentState.copyWith(
        isDownloading: true,
        downloadingFileName: event.fileName,
        downloadProgress: 0.0,
      ),
    );

    try {
      final filePath = await repository.downloadAttachment(
        fileUrl: event.fileUrl,
        context: event.context,
        fileName: event.fileName,
        onProgress: (progress) {
          emit(
            currentState.copyWith(
              isDownloading: true,
              downloadingFileName: event.fileName,
              downloadProgress: progress,
            ),
          );
        },
      );

      if (filePath != null) {
        emit(
          AttachmentDownloadSuccess(fileUrl: event.fileUrl, filePath: filePath),
        );
      } else {
        emit(
          AttachmentDownloadError(
            fileUrl: event.fileUrl,
            message: 'Failed to download file',
          ),
        );
      }

      emit(
        currentState.copyWith(
          isDownloading: false,
          downloadingFileName: null,
          downloadProgress: 0.0,
        ),
      );
    } catch (e) {
      emit(
        currentState.copyWith(
          isDownloading: false,
          downloadingFileName: null,
          downloadProgress: 0.0,
        ),
      );

      emit(
        AttachmentDownloadError(fileUrl: event.fileUrl, message: e.toString()),
      );

      emit(currentState);
    }
  }

  String _getErrorMessage(dynamic e) {
    final str = e.toString().toLowerCase();
    if (str.contains('no internet') || str.contains('network'))
      return 'No internet connection';
    if (str.contains('deadline') || str.contains('overdue'))
      return 'Submission deadline has passed';
    return 'An error occurred. Please try again.';
  }

  bool _isNetworkError(dynamic e) {
    final str = e.toString().toLowerCase();
    return str.contains('no internet') || str.contains('network');
  }
}
