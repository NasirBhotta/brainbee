import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'setting_event.dart';
part 'setting_state.dart';

class SettingBloc extends Bloc<SettingEvent, SettingState> {
  SettingBloc() : super(SettingInitial()) {
    on<SettingProfileUpdateEventButtonClicked>(
      settingProfileUpdateEventButtonClicked,
    );
    on<SettingDeleteAccountEvent>(settingDeleteAccountEvent);
  }

  FutureOr<void> settingProfileUpdateEventButtonClicked(
    SettingProfileUpdateEventButtonClicked event,
    Emitter<SettingState> emit,
  ) async {
    emit(SettingDataUpdatingState());

    try {
      await Future.delayed(const Duration(seconds: 3));

      emit(SettingDataUpdatedState());
    } catch (e) {
      emit(SettingDataUpdatedFailureState(message: e.toString()));
    }
  }

  FutureOr<void> settingDeleteAccountEvent(
    SettingDeleteAccountEvent event,
    Emitter<SettingState> emit,
  ) {}
}
