part of 'student_bloc.dart';

sealed class StudentState extends Equatable {
  const StudentState();

  @override
  List<Object> get props => [];
}

final class StudentInitial extends StudentState {}

final class StudentDataLoading extends StudentState {}

final class StudentDataLoaded extends StudentState {
  final StudentModel student;

  const StudentDataLoaded(this.student);

  @override
  List<Object> get props => [student];
}

final class StudentDataError extends StudentState {
  final String message;
  const StudentDataError(this.message);

  @override
  List<Object> get props => [message];
}
