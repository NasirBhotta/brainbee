part of 'setting_bloc.dart';

sealed class SettingsState extends Equatable {
  const SettingsState();

  @override
  List<Object?> get props => [];
}

class SettingsInitial extends SettingsState {}

class SettingsLoading extends SettingsState {}

class SettingsGradeLoadedLocally extends SettingsState {
  final int? grade;

  const SettingsGradeLoadedLocally(this.grade);

  @override
  List<Object?> get props => [grade];
}

class SettingsGradeSavedLocal extends SettingsState {
  final int grade;

  const SettingsGradeSavedLocal(this.grade);

  @override
  List<Object> get props => [grade];
}

class SettingsUpdateSuccess extends SettingsState {
  final StudentModel student;

  const SettingsUpdateSuccess(this.student);

  @override
  List<Object> get props => [student];
}

class SettingsUpdateFailure extends SettingsState {
  final String error;

  const SettingsUpdateFailure(this.error);

  @override
  List<Object> get props => [error];
}

class SettingsStudentSavedLocal extends SettingsState {
  final int grade;
  const SettingsStudentSavedLocal(this.grade);

  @override
  List<Object?> get props => [grade];
}

class SettingsStudentLoaded extends SettingsState {
  final int? grade;
  const SettingsStudentLoaded(this.grade);

  @override
  List<Object?> get props => [grade];
}

class SettingsStudentCleared extends SettingsState {}

class SettingsPasswordUpdateSuccess extends SettingsState {}

class SettingsPasswordUpdateFailure extends SettingsState {
  final String error;

  const SettingsPasswordUpdateFailure(this.error);

  @override
  List<Object> get props => [error];
}

class SettingsPasswordUpdating extends SettingsState {}
