// lib/blocs/badge/badge_event.dart
import 'package:equatable/equatable.dart';

abstract class BadgeEvent extends Equatable {
  const BadgeEvent();

  @override
  List<Object?> get props => [];
}

class LoadBadges extends BadgeEvent {
  final String studentId;

  const LoadBadges({required this.studentId});

  @override
  List<Object?> get props => [studentId];
}

class RefreshBadges extends BadgeEvent {
  final String studentId;

  const RefreshBadges({required this.studentId});

  @override
  List<Object?> get props => [studentId];
}

class RetryLoadBadges extends BadgeEvent {
  final String studentId;

  const RetryLoadBadges({required this.studentId});

  @override
  List<Object?> get props => [studentId];
}
