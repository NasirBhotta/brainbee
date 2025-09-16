part of 'student_bloc.dart';

sealed class StudentEvent extends Equatable {
  const StudentEvent();

  @override
  List<Object> get props => [];
}

final class StudentFetchData extends StudentEvent {
  const StudentFetchData();
}

final class StudentUpdateGoals extends StudentEvent {
  final Goal goal;

  const StudentUpdateGoals({required this.goal});
}

final class StudentUpdateProfile extends StudentEvent {
  final String firstName;
  final String lastName;
  final String address;
  final String phoneNumber;
  final File image;

  const StudentUpdateProfile({
    required this.image,
    required this.firstName,
    required this.lastName,
    required this.address,
    required this.phoneNumber,
  });
}
