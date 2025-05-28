part of 'setting_bloc.dart';

sealed class SettingEvent extends Equatable {
  const SettingEvent();

  @override
  List<Object> get props => [];
}

class SettingProfileUpdateEventButtonClicked extends SettingEvent {
  final String fullName;
  final String? email;
  final String mobile;
  final String dateOfBirth;
  final String imageURL;
  final String? address;
  final int? postCode;
  final String? state;
  final String? city;
  final String schoolName;

  const SettingProfileUpdateEventButtonClicked({
    required this.fullName,
    this.email,
    required this.mobile,
    required this.dateOfBirth,
    required this.imageURL,
    this.address,
    this.postCode,
    this.state,
    this.city,
    required this.schoolName,
  });
}

final class SettingDeleteAccountEvent extends SettingEvent {}
