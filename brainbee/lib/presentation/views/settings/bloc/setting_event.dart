part of 'setting_bloc.dart';

sealed class SettingEvent extends Equatable {
  const SettingEvent();

  @override
  List<Object> get props => [];
}

// Existing events
class SettingsLoadGradeFromLocal extends SettingEvent {}

class SettingsSaveGradeLocal extends SettingEvent {
  final int grade;
  const SettingsSaveGradeLocal(this.grade);
  @override
  List<Object> get props => [grade];
}

class SettingsUpdateGradeAndSubjects extends SettingEvent {
  final int grade;
  final List<String> subjects;
  const SettingsUpdateGradeAndSubjects({
    required this.grade,
    required this.subjects,
  });
  @override
  List<Object> get props => [grade, subjects];
}

class SettingsClearLocalGrade extends SettingEvent {}

class SettingsSaveStudentLocal extends SettingEvent {
  final int grade;

  const SettingsSaveStudentLocal({required this.grade});

  @override
  List<Object> get props => [grade];
}

class SettingsLoadStudentFromLocal extends SettingEvent {}

class SettingsClearLocalStudent extends SettingEvent {}
