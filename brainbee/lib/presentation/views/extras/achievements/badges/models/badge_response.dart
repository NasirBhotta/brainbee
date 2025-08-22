// lib/models/badge_response.dart
import 'package:brainbee/presentation/views/extras/achievements/badges/models/badge_model.dart';
import 'package:equatable/equatable.dart';

class BadgeResponse extends Equatable {
  final List<BbBadge> badges;
  final bool success;
  final String? message;

  const BadgeResponse({
    required this.badges,
    required this.success,
    this.message,
  });

  factory BadgeResponse.fromJson(Map<String, dynamic> json) {
    return BadgeResponse(
      badges:
          (json['badges'] as List<dynamic>?)
              ?.map(
                (badgeJson) =>
                    BbBadge.fromJson(badgeJson as Map<String, dynamic>),
              )
              .toList() ??
          [],
      success: json['success'] as bool? ?? false,
      message: json['message'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'badges': badges.map((badge) => badge.toJson()).toList(),
      'success': success,
      'message': message,
    };
  }

  @override
  List<Object?> get props => [badges, success, message];
}
