import 'package:brainbee/presentation/views/extras/achievements/Certificates/models/bb_certificates_class.dart';
import 'package:brainbee/presentation/views/extras/achievements/badges/models/badge_model.dart';

class Achievements {
  final List<BbBadge> badges; // <-- use BbBadge here
  final List<Certificate> certificates;

  Achievements({required this.badges, required this.certificates});

  factory Achievements.fromJson(Map<String, dynamic> json) {
    return Achievements(
      badges:
          (json['badges'] as List? ?? [])
              .map((b) => BbBadge.fromJson(b)) // <-- use BbBadge.fromJson
              .toList(),
      certificates:
          (json['certificates'] as List? ?? [])
              .map((c) => Certificate.fromJson(c))
              .toList(),
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'badges': badges.map((b) => b.toJson()).toList(),
      'certificates': certificates.map((c) => c.toJson()).toList(),
    };
  }
}
