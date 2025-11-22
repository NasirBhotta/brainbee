part of 'classMaterial_bloc.dart';

abstract class ClassMaterialState extends Equatable {
  const ClassMaterialState();
  @override
  List<Object?> get props => [];
}

class MaterialInitial extends ClassMaterialState {}

class MaterialLoading extends ClassMaterialState {}

class MaterialLoaded extends ClassMaterialState {
  final List<ClassMaterial> materials;
  final Map<String, double> downloadProgress;
  final Set<String> downloadingIds;

  const MaterialLoaded({
    required this.materials,
    this.downloadProgress = const {},
    this.downloadingIds = const {},
  });

  @override
  List<Object?> get props => [materials, downloadProgress, downloadingIds];

  MaterialLoaded copyWith({
    List<ClassMaterial>? materials,
    Map<String, double>? downloadProgress,
    Set<String>? downloadingIds,
  }) {
    return MaterialLoaded(
      materials: materials ?? this.materials,
      downloadProgress: downloadProgress ?? this.downloadProgress,
      downloadingIds: downloadingIds ?? this.downloadingIds,
    );
  }
}

class MaterialEmpty extends ClassMaterialState {}

class MaterialError extends ClassMaterialState {
  final String message;
  final bool isNetworkError;
  const MaterialError({required this.message, this.isNetworkError = false});
  @override
  List<Object?> get props => [message, isNetworkError];
}

class MaterialDownloadSuccess extends ClassMaterialState {
  final ClassMaterial material;
  final String downloadPath;
  const MaterialDownloadSuccess({
    required this.material,
    required this.downloadPath,
  });
  @override
  List<Object?> get props => [material, downloadPath];
}

class MaterialDownloadError extends ClassMaterialState {
  final ClassMaterial material;
  final String message;
  const MaterialDownloadError({required this.material, required this.message});
  @override
  List<Object?> get props => [material, message];
}
