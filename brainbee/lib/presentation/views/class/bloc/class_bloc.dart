import 'package:bloc/bloc.dart';
import 'package:brainbee/presentation/views/class/models/class_models.dart';
import 'package:brainbee/presentation/views/class/repo/class_repo.dart';
import 'package:equatable/equatable.dart';

part 'class_event.dart';
part 'class_state.dart';

class ClassBloc extends Bloc<ClassEvent, ClassState> {
  final ClassRepository classRepository;

  ClassBloc({required this.classRepository}) : super(ClassInitial()) {
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
        emit(ClassLoadSuccess(classes: classes));
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
    if (state is ClassLoadSuccess) {
      final currentClasses = (state as ClassLoadSuccess).classes;
      emit(ClassRefreshing(previousClasses: currentClasses));
    } else {
      emit(const ClassLoading());
    }

    try {
      final classes = await classRepository.getMyClasses();

      if (classes.isEmpty) {
        emit(const ClassEmpty());
      } else {
        emit(ClassLoadSuccess(classes: classes));
      }
    } catch (e) {
      // If refresh fails but we had previous data, restore it
      if (state is ClassRefreshing) {
        final previousClasses = (state as ClassRefreshing).previousClasses;
        emit(ClassLoadSuccess(classes: previousClasses));
        // Optionally show a snackbar or toast for the error
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
