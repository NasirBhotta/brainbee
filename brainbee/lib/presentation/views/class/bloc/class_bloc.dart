import 'package:bloc/bloc.dart';
import 'package:brainbee/presentation/views/class/models/class_models.dart';
import 'package:brainbee/presentation/views/class/repo/asign_repo_impl.dart';
import 'package:brainbee/presentation/views/class/repo/class_repo.dart';
import 'package:equatable/equatable.dart';

part 'class_event.dart';
part 'class_state.dart';

class ClassBloc extends Bloc<ClassEvent, ClassState> {
  final ClassRepository classRepository;
  final AssignmentRepository assignmentRepository;

  ClassBloc({required this.classRepository, required this.assignmentRepository})
    : super(ClassInitial()) {
    on<FetchMyClassesEvent>(_onFetchMyClasses);
    on<RefreshMyClassesEvent>(_onRefreshMyClasses);
    on<FetchClassDetailEvent>(_onFetchClassDetail);
  }

  Future<void> _onFetchMyClasses(
    FetchMyClassesEvent event,
    Emitter<ClassState> emit,
  ) async {
    emit(const ClassLoading());

    try {
      final classes = await classRepository.getMyClasses();

      if (classes.isEmpty) {
        emit(const ClassEmpty());
      } else {
        final allAssignments =
            await assignmentRepository.getStudentAssignments();

        // Calculate submitted assignments per class
        final submittedCounts = <String, int>{};
        for (var classItem in classes) {
          final classAssignments =
              allAssignments
                  .where(
                    (assignment) => assignment.classInfo.id == classItem.id,
                  )
                  .toList();

          // Call the method directly on assignmentRepository
          submittedCounts[classItem.id] = assignmentRepository
              .getSubmittedAssignmentsCount(classAssignments);
        }

        emit(
          ClassLoadSuccess(
            classes: classes,
            submittedAssignmentCounts: submittedCounts,
          ),
        );
      }
    } catch (e) {
      emit(
        ClassError(
          message: _getErrorMessage(e),
          isNetworkError: _isNetworkError(e),
        ),
      );
    }
  }

  Future<void> _onRefreshMyClasses(
    RefreshMyClassesEvent event,
    Emitter<ClassState> emit,
  ) async {
    // If we have previous classes, show them while refreshing
    final currentState = state;

    if (currentState is ClassLoadSuccess) {
      emit(
        ClassRefreshing(
          previousClasses: currentState.classes,
          submittedAssignmentCounts: currentState.submittedAssignmentCounts,
        ),
      );
    } else {
      emit(const ClassLoading());
    }

    try {
      // Fetch classes
      final classes = await classRepository.getMyClasses();

      if (classes.isEmpty) {
        emit(ClassEmpty());
        return;
      }

      // Fetch all assignments to calculate submitted counts
      final allAssignments = await assignmentRepository.getStudentAssignments();

      // Calculate submitted assignments per class
      final submittedCounts = <String, int>{};
      for (var classItem in classes) {
        final classAssignments =
            allAssignments
                .where((assignment) => assignment.classInfo.id == classItem.id)
                .toList();
        submittedCounts[classItem.id] = assignmentRepository
            .getSubmittedAssignmentsCount(classAssignments);
      }

      emit(
        ClassLoadSuccess(
          classes: classes,
          submittedAssignmentCounts: submittedCounts,
        ),
      );
    } catch (e) {
      if (currentState is ClassLoadSuccess) {
        emit(currentState);
      } else {
        emit(
          ClassError(
            message: _getErrorMessage(e),
            isNetworkError: _isNetworkError(e),
          ),
        );
      }
    }
  }

  Future<void> _onFetchClassDetail(
    FetchClassDetailEvent event,
    Emitter<ClassState> emit,
  ) async {
    emit(const ClassDetailLoading());

    try {
      final classData = await classRepository.getClassDetail(event.classId);
      emit(ClassDetailLoadSuccess(classData: classData));
    } catch (e) {
      emit(
        ClassDetailError(
          message: _getErrorMessage(e),
          isNetworkError: _isNetworkError(e),
        ),
      );
    }
  }

  String _getErrorMessage(dynamic error) {
    final errorString = error.toString();

    // Extract message from Exception format
    if (errorString.contains('Exception:')) {
      return errorString.split('Exception:').last.trim();
    }

    // Handle specific error patterns
    if (errorString.toLowerCase().contains('no internet') ||
        errorString.toLowerCase().contains('network')) {
      return 'No internet connection. Please check your network.';
    }

    if (errorString.toLowerCase().contains('unauthorized') ||
        errorString.toLowerCase().contains('401')) {
      return 'Unauthorized. Please login again.';
    }

    if (errorString.toLowerCase().contains('not found') ||
        errorString.toLowerCase().contains('404')) {
      return 'Class not found.';
    }

    if (errorString.toLowerCase().contains('server') ||
        errorString.toLowerCase().contains('500')) {
      return 'Server error. Please try again later.';
    }

    return 'An unexpected error occurred. Please try again.';
  }

  bool _isNetworkError(dynamic error) {
    final errorString = error.toString().toLowerCase();
    return errorString.contains('no internet') ||
        errorString.contains('network') ||
        errorString.contains('connection');
  }
}
