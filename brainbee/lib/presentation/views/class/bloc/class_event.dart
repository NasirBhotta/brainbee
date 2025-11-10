part of 'class_bloc.dart';

abstract class ClassEvent extends Equatable {
  const ClassEvent();

  @override
  List<Object?> get props => [];
}

class FetchMyClassesEvent extends ClassEvent {
  const FetchMyClassesEvent();
}

class RefreshMyClassesEvent extends ClassEvent {
  const RefreshMyClassesEvent();
}

class FetchClassDetailEvent extends ClassEvent {
  final String classId;

  const FetchClassDetailEvent({required this.classId});

  @override
  List<Object?> get props => [classId];
}
