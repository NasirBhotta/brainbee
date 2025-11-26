part of 'class_bloc.dart';

abstract class ClassState extends Equatable {
  const ClassState();

  @override
  List<Object?> get props => [];
}

// Initial State
class ClassInitial extends ClassState {
  const ClassInitial();
}

// Loading States
class ClassLoading extends ClassState {
  const ClassLoading();
}

class ClassRefreshing extends ClassState {
  final List<ClassModel> previousClasses;
  final Map<String, int> submittedAssignmentCounts;

  const ClassRefreshing({
    required this.previousClasses,
    required this.submittedAssignmentCounts,
  });

  @override
  List<Object?> get props => [previousClasses, submittedAssignmentCounts];
}

// Success States
class ClassLoadSuccess extends ClassState {
  final List<ClassModel> classes;
  final Map<String, int> submittedAssignmentCounts;
  const ClassLoadSuccess({
    required this.classes,
    required this.submittedAssignmentCounts,
  });

  @override
  List<Object?> get props => [classes];
}

class ClassEmpty extends ClassState {
  const ClassEmpty();
}

// Class Detail States
class ClassDetailLoading extends ClassState {
  const ClassDetailLoading();
}

class ClassDetailLoadSuccess extends ClassState {
  final ClassModel classData;
  const ClassDetailLoadSuccess({required this.classData});

  @override
  List<Object?> get props => [classData];
}

// Error States
class ClassError extends ClassState {
  final String message;
  final bool isNetworkError;

  const ClassError({required this.message, this.isNetworkError = false});

  @override
  List<Object?> get props => [message, isNetworkError];
}

class ClassDetailError extends ClassState {
  final String message;
  final bool isNetworkError;

  const ClassDetailError({required this.message, this.isNetworkError = false});

  @override
  List<Object?> get props => [message, isNetworkError];
}
