part of 'classMaterial_bloc.dart';

abstract class ClassMaterialEvent extends Equatable {
  const ClassMaterialEvent();

  @override
  List<Object?> get props => [];
}

class FetchMaterialsEvent extends ClassMaterialEvent {
  final String classId;

  const FetchMaterialsEvent({required this.classId});

  @override
  List<Object> get props => [classId];
}

class RefreshMaterialsEvent extends ClassMaterialEvent {
  final String classId;

  const RefreshMaterialsEvent({required this.classId});

  @override
  List<Object> get props => [classId];
}

class DownloadMaterialEvent extends ClassMaterialEvent {
  final ClassMaterial material;
  final BuildContext context;

  const DownloadMaterialEvent({required this.material, required this.context});

  @override
  List<Object> get props => [material, context];
}
