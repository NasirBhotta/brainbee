import 'package:bloc/bloc.dart';
import 'package:brainbee/presentation/views/class/models/material.dart';
import 'package:brainbee/presentation/views/class/repo/material_repo.dart';
import 'package:equatable/equatable.dart';

part 'classMaterial_event.dart';
part 'classMaterial_state.dart';

class ClassMaterialBloc extends Bloc<ClassMaterialEvent, ClassMaterialState> {
  final MaterialRepository repository;

  ClassMaterialBloc({required this.repository}) : super(MaterialInitial()) {
    on<FetchMaterialsEvent>(_onFetchMaterials);
    on<RefreshMaterialsEvent>(_onRefreshMaterials);
    on<DownloadMaterialEvent>(_onDownloadMaterial);
  }

  Future<void> _onFetchMaterials(
    FetchMaterialsEvent event,
    Emitter<ClassMaterialState> emit,
  ) async {
    emit(MaterialLoading());
    try {
      final materials = await repository.getMaterials(event.classId);
      if (materials.isEmpty) {
        emit(MaterialEmpty());
      } else {
        emit(MaterialLoaded(materials: materials));
      }
    } catch (e) {
      emit(
        MaterialError(
          message: _getErrorMessage(e),
          isNetworkError: _isNetworkError(e),
        ),
      );
    }
  }

  Future<void> _onRefreshMaterials(
    RefreshMaterialsEvent event,
    Emitter<ClassMaterialState> emit,
  ) async {
    final currentState = state;
    try {
      final materials = await repository.getMaterials(event.classId);
      if (materials.isEmpty) {
        emit(MaterialEmpty());
      } else {
        emit(MaterialLoaded(materials: materials));
      }
    } catch (e) {
      if (currentState is MaterialLoaded) {
        emit(currentState); // Keep previous data on refresh failure
      } else {
        emit(
          MaterialError(
            message: _getErrorMessage(e),
            isNetworkError: _isNetworkError(e),
          ),
        );
      }
    }
  }

  Future<void> _onDownloadMaterial(
    DownloadMaterialEvent event,
    Emitter<ClassMaterialState> emit,
  ) async {
    final currentState = state;
    if (currentState is! MaterialLoaded) return;

    final newDownloading = Set<String>.from(currentState.downloadingIds)
      ..add(event.material.id);
    final newProgress = Map<String, double>.from(currentState.downloadProgress);
    newProgress[event.material.id] = 0.0;

    emit(
      currentState.copyWith(
        downloadingIds: newDownloading,
        downloadProgress: newProgress,
      ),
    );

    try {
      // Simulate download progress
      for (int i = 0; i <= 100; i += 10) {
        await Future.delayed(const Duration(milliseconds: 150));
        newProgress[event.material.id] = i / 100.0;
        emit(
          currentState.copyWith(
            downloadProgress: Map.from(newProgress),
            downloadingIds: newDownloading,
          ),
        );
      }

      final downloadPath = await repository.downloadMaterial(event.material);

      final finalDownloading = Set<String>.from(newDownloading)
        ..remove(event.material.id);
      final finalProgress = Map<String, double>.from(newProgress)
        ..remove(event.material.id);

      emit(
        currentState.copyWith(
          downloadingIds: finalDownloading,
          downloadProgress: finalProgress,
        ),
      );
      emit(
        MaterialDownloadSuccess(
          material: event.material,
          downloadPath: downloadPath,
        ),
      );
      emit(
        currentState.copyWith(
          downloadingIds: finalDownloading,
          downloadProgress: finalProgress,
        ),
      );
    } catch (e) {
      final finalDownloading = Set<String>.from(newDownloading)
        ..remove(event.material.id);
      final finalProgress = Map<String, double>.from(newProgress)
        ..remove(event.material.id);

      emit(
        currentState.copyWith(
          downloadingIds: finalDownloading,
          downloadProgress: finalProgress,
        ),
      );
      emit(
        MaterialDownloadError(
          material: event.material,
          message: _getErrorMessage(e),
        ),
      );
      emit(
        currentState.copyWith(
          downloadingIds: finalDownloading,
          downloadProgress: finalProgress,
        ),
      );
    }
  }

  String _getErrorMessage(dynamic e) {
    final str = e.toString().toLowerCase();
    if (str.contains('no internet') || str.contains('network'))
      return 'No internet connection';
    if (str.contains('unauthorized') || str.contains('401'))
      return 'Please login again';
    return 'An error occurred. Please try again.';
  }

  bool _isNetworkError(dynamic e) {
    final str = e.toString().toLowerCase();
    return str.contains('no internet') ||
        str.contains('network') ||
        str.contains('connection');
  }
}
