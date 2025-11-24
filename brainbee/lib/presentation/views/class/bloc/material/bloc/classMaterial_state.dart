part of 'classMaterial_bloc.dart';

abstract class ClassMaterialState extends Equatable {
  const ClassMaterialState();

  @override
  List<Object?> get props => [];
}

class MaterialInitial extends ClassMaterialState {}

class MaterialLoading extends ClassMaterialState {}

class MaterialEmpty extends ClassMaterialState {}

class MaterialLoaded extends ClassMaterialState {
  final List<ClassMaterial> materials;
  final Set<String> downloadingIds;
  final Map<String, double> downloadProgress;

  const MaterialLoaded({
    required this.materials,
    this.downloadingIds = const {},
    this.downloadProgress = const {},
  });

  MaterialLoaded copyWith({
    List<ClassMaterial>? materials,
    Set<String>? downloadingIds,
    Map<String, double>? downloadProgress,
  }) {
    return MaterialLoaded(
      materials: materials ?? this.materials,
      downloadingIds: downloadingIds ?? this.downloadingIds,
      downloadProgress: downloadProgress ?? this.downloadProgress,
    );
  }

  @override
  List<Object> get props => [materials, downloadingIds, downloadProgress];
}

class MaterialError extends ClassMaterialState {
  final String message;
  final bool isNetworkError;

  const MaterialError({required this.message, this.isNetworkError = false});

  @override
  List<Object> get props => [message, isNetworkError];
}

class MaterialDownloadSuccess extends ClassMaterialState {
  final ClassMaterial material;
  final String downloadPath;

  const MaterialDownloadSuccess({
    required this.material,
    required this.downloadPath,
  });

  @override
  List<Object> get props => [material, downloadPath];
}

class MaterialDownloadError extends ClassMaterialState {
  final ClassMaterial material;
  final String message;

  const MaterialDownloadError({required this.material, required this.message});

  @override
  List<Object> get props => [material, message];
}
