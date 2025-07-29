enum RewardStatus { available, redeemed, insufficientCoins }

enum RewardType { oneTime, recurring }

class RewardModel {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final int coinPrice;
  final RewardStatus status;
  final RewardType type;
  final String redemptionInstructions;
  final String termsAndConditions;
  final bool requiresUserInput;
  final String? inputLabel; // e.g., "PUBG ID", "Email Address"
  final String? inputPlaceholder;
  final DateTime? redeemedAt;
  final String? submittedInfo; // The info user submitted during redemption

  const RewardModel({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.coinPrice,
    required this.status,
    this.type = RewardType.oneTime,
    required this.redemptionInstructions,
    required this.termsAndConditions,
    this.requiresUserInput = false,
    this.inputLabel,
    this.inputPlaceholder,
    this.redeemedAt,
    this.submittedInfo,
  });

  RewardModel copyWith({
    String? id,
    String? title,
    String? description,
    String? imageUrl,
    int? coinPrice,
    RewardStatus? status,
    RewardType? type,
    String? redemptionInstructions,
    String? termsAndConditions,
    bool? requiresUserInput,
    String? inputLabel,
    String? inputPlaceholder,
    DateTime? redeemedAt,
    String? submittedInfo,
  }) {
    return RewardModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      coinPrice: coinPrice ?? this.coinPrice,
      status: status ?? this.status,
      type: type ?? this.type,
      redemptionInstructions:
          redemptionInstructions ?? this.redemptionInstructions,
      termsAndConditions: termsAndConditions ?? this.termsAndConditions,
      requiresUserInput: requiresUserInput ?? this.requiresUserInput,
      inputLabel: inputLabel ?? this.inputLabel,
      inputPlaceholder: inputPlaceholder ?? this.inputPlaceholder,
      redeemedAt: redeemedAt ?? this.redeemedAt,
      submittedInfo: submittedInfo ?? this.submittedInfo,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'coinPrice': coinPrice,
      'status': status.name,
      'type': type.name,
      'redemptionInstructions': redemptionInstructions,
      'termsAndConditions': termsAndConditions,
      'requiresUserInput': requiresUserInput,
      'inputLabel': inputLabel,
      'inputPlaceholder': inputPlaceholder,
      'redeemedAt': redeemedAt?.toIso8601String(),
      'submittedInfo': submittedInfo,
    };
  }

  factory RewardModel.fromJson(Map<String, dynamic> json) {
    return RewardModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      imageUrl: json['imageUrl'],
      coinPrice: json['coinPrice'],
      status: RewardStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => RewardStatus.available,
      ),
      type: RewardType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => RewardType.oneTime,
      ),
      redemptionInstructions: json['redemptionInstructions'],
      termsAndConditions: json['termsAndConditions'],
      requiresUserInput: json['requiresUserInput'] ?? false,
      inputLabel: json['inputLabel'],
      inputPlaceholder: json['inputPlaceholder'],
      redeemedAt:
          json['redeemedAt'] != null
              ? DateTime.parse(json['redeemedAt'])
              : null,
      submittedInfo: json['submittedInfo'],
    );
  }
}
