part of 'setting_bloc.dart';

sealed class SettingState extends Equatable {
  const SettingState();

  @override
  List<Object> get props => [];
}

abstract class SettingActionState extends SettingState {}

final class SettingInitial extends SettingState {}

final class SettingDataUpdatingState extends SettingState {}

final class SettingDataUpdatedState extends SettingState {}

final class SettingDataUpdatedFailureState extends SettingState {
  final String message;

  const SettingDataUpdatedFailureState({required this.message});
}

//

final class SettingAccountDeletingState extends SettingState {}

final class SettingAccountDeletedState extends SettingState {}

final class SettingAccountDeletingFailureState extends SettingState {
  final String message;

  const SettingAccountDeletingFailureState({required this.message});
}

//

final class SettingNavigateToAuthState extends SettingActionState {}
