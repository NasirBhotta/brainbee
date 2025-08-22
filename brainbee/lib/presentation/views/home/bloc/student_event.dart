part of 'student_bloc.dart';

sealed class StudentEvent extends Equatable {
  const StudentEvent();

  @override
  List<Object> get props => [];
}

final class StudentFetchData extends StudentEvent {
  const StudentFetchData();
}
