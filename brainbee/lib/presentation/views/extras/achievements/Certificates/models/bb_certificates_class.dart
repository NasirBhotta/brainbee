class Certificate {
  final String certificateId;
  final String name;
  final String? description;
  final String? imageUrl;
  final DateTime earnedAt;

  Certificate({
    required this.certificateId,
    required this.name,
    this.description,
    this.imageUrl,
    required this.earnedAt,
  });

  factory Certificate.fromJson(Map<String, dynamic> json) {
    return Certificate(
      certificateId: json['certificateId'],
      name: json['name'],
      description: json['description'],
      imageUrl: json['imageUrl'],
      earnedAt: DateTime.parse(json['earnedAt']),
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'certificateId': certificateId,
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'earnedAt': earnedAt.toIso8601String(),
    };
  }
}
