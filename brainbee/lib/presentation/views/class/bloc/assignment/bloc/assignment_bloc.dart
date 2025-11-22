import 'package:bloc/bloc.dart';
import 'package:brainbee/presentation/views/class/UI/assignment/bb_class_assignment.dart';
import 'package:brainbee/presentation/views/class/models/assignment_model.dart';
import 'package:brainbee/presentation/views/class/repo/assign_repo.dart';
import 'package:equatable/equatable.dart';

part 'assignment_event.dart';
part 'assignment_state.dart';

class AssignmentBloc extends Bloc<AssignmentEvent, AssignmentState> {
  final AssignmentRepository repository;
  String? _currentClassId;

  AssignmentBloc({required this.repository}) : super(AssignmentInitial()) {
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
    _currentClassId = event.classId;

    try {
      final assignments = await repository.getAssignments(event.classId);
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
      final assignments = await repository.getAssignments(event.classId);
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
      await repository.submitAssignment(event.assignmentId, event.filePaths);
      emit(
        AssignmentSubmitSuccess(
          assignmentId: event.assignmentId,
          submittedAt: DateTime.now(),
        ),
      );

      // Refresh assignments to get updated status
      if (_currentClassId != null) {
        final assignments = await repository.getAssignments(_currentClassId!);
        emit(AssignmentLoaded(assignments: assignments));
      }
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
    try {
      final path = await repository.downloadAttachment(event.file);
      emit(AttachmentDownloadSuccess(file: event.file, path: path));
      if (currentState is AssignmentLoaded) emit(currentState);
    } catch (e) {
      emit(
        AttachmentDownloadError(file: event.file, message: _getErrorMessage(e)),
      );
      if (currentState is AssignmentLoaded) emit(currentState);
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
