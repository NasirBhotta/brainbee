import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:brainbee/presentation/views/home/models/bb_student_model.dart';
import 'package:brainbee/presentation/views/settings/model/book_model.dart';
import 'package:brainbee/presentation/views/settings/repository/settings_repo.dart';
import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'setting_event.dart';
part 'setting_state.dart';

class SettingsBloc extends Bloc<SettingEvent, SettingsState> {
  final SettingsRepository repository;
  static const String _gradeKey = 'selected_grade';

  SettingsBloc({required this.repository}) : super(SettingsInitial()) {
    on<SettingsLoadGradeFromLocal>(_onLoadGradeFromLocal);
    on<SettingsSaveGradeLocal>(_onSaveGradeLocal);
    on<SettingsLoadAvailableBooks>(_onLoadAvailableBooks);
    on<SettingsUpdateGradeAndBooks>(_onUpdateGradeAndBooks);
    on<SettingsUpdateGradeAndSubjects>(_onUpdateGradeAndSubjects);
    on<SettingsClearLocalGrade>(_onClearLocalGrade);
    on<SettingsUpdatePassword>(_onUpdatePassword);
  }

  FutureOr<void> _onLoadGradeFromLocal(
    SettingsLoadGradeFromLocal event,
    Emitter<SettingsState> emit,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final grade = prefs.getInt(_gradeKey);

      emit(SettingsGradeLoadedLocally(grade));
    } catch (e) {
      emit(SettingsUpdateFailure('Failed to load grade: ${e.toString()}'));
    }
  }

  FutureOr<void> _onSaveGradeLocal(
    SettingsSaveGradeLocal event,
    Emitter<SettingsState> emit,
  ) async {
    emit(SettingsLoading());
    try {
      await Future.delayed(const Duration(seconds: 2));
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_gradeKey, event.grade);

      emit(SettingsGradeSavedLocal(event.grade));
    } catch (e) {
      emit(SettingsUpdateFailure('Failed to save grade: ${e.toString()}'));
    }
  }

  /// NEW: Load available books for a grade
  FutureOr<void> _onLoadAvailableBooks(
    SettingsLoadAvailableBooks event,
    Emitter<SettingsState> emit,
  ) async {
    emit(SettingsLoading());
    try {
      final booksResponse = await repository.fetchAvailableBooksForGrade(
        event.grade,
      );
      emit(SettingsAvailableBooksLoaded(booksResponse));
    } catch (e) {
      emit(SettingsUpdateFailure('Failed to load books: ${e.toString()}'));
    }
  }

  /// NEW PREFERRED: Update grade and books using book IDs
  FutureOr<void> _onUpdateGradeAndBooks(
    SettingsUpdateGradeAndBooks event,
    Emitter<SettingsState> emit,
  ) async {
    emit(SettingsLoading());

    try {
      final studentData = await repository.updateGradeAndBooks(
        grade: event.grade,
        bookIds: event.bookIds,
      );

      emit(SettingsUpdateSuccess(studentData));
    } catch (e) {
      emit(SettingsUpdateFailure(e.toString()));
    }
  }

  /// LEGACY: Update grade and subjects (for backward compatibility)
  FutureOr<void> _onUpdateGradeAndSubjects(
    SettingsUpdateGradeAndSubjects event,
    Emitter<SettingsState> emit,
  ) async {
    emit(SettingsLoading());

    try {
      final studentData = await repository.updateGradeAndSubjects(
        grade: event.grade,
        subjects: event.subjects,
      );

      emit(SettingsUpdateSuccess(studentData));
    } catch (e) {
      emit(SettingsUpdateFailure(e.toString()));
    }
  }

  FutureOr<void> _onClearLocalGrade(
    SettingsClearLocalGrade event,
    Emitter<SettingsState> emit,
  ) async {
    try {
      await _clearLocalGrade();
      emit(SettingsGradeLoadedLocally(null));
    } catch (e) {
      emit(SettingsUpdateFailure('Failed to clear grade: ${e.toString()}'));
    }
  }

  Future<void> _clearLocalGrade() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_gradeKey);
  }

  FutureOr<void> _onUpdatePassword(
    SettingsUpdatePassword event,
    Emitter<SettingsState> emit,
  ) async {
    emit(SettingsPasswordUpdating());

    try {
      await repository.updatePassword(
        currentPassword: event.currentPassword,
        newPassword: event.newPassword,
        confirmPassword: event.confirmPassword,
      );

      emit(SettingsPasswordUpdateSuccess());
    } catch (e) {
      emit(SettingsPasswordUpdateFailure(e.toString()));
    }
  }
}
