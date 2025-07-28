// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quest_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Quest _$QuestFromJson(Map<String, dynamic> json) => Quest(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      coinReward: (json['coinReward'] as num).toInt(),
      type: $enumDecode(_$QuestTypeEnumMap, json['type']),
      status: $enumDecode(_$QuestStatusEnumMap, json['status']),
      iconPath: json['iconPath'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      completedAt: json['completedAt'] == null
          ? null
          : DateTime.parse(json['completedAt'] as String),
      claimedAt: json['claimedAt'] == null
          ? null
          : DateTime.parse(json['claimedAt'] as String),
      lastResetAt: json['lastResetAt'] == null
          ? null
          : DateTime.parse(json['lastResetAt'] as String),
    );

Map<String, dynamic> _$QuestToJson(Quest instance) => <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'coinReward': instance.coinReward,
      'type': _$QuestTypeEnumMap[instance.type]!,
      'status': _$QuestStatusEnumMap[instance.status]!,
      'iconPath': instance.iconPath,
      'createdAt': instance.createdAt.toIso8601String(),
      'completedAt': instance.completedAt?.toIso8601String(),
      'claimedAt': instance.claimedAt?.toIso8601String(),
      'lastResetAt': instance.lastResetAt?.toIso8601String(),
    };

const _$QuestTypeEnumMap = {
  QuestType.daily: 'daily',
  QuestType.weekly: 'weekly',
  QuestType.oneTime: 'one_time',
};

const _$QuestStatusEnumMap = {
  QuestStatus.incomplete: 'incomplete',
  QuestStatus.complete: 'complete',
  QuestStatus.claimed: 'claimed',
};

T $enumDecode<T>(
  Map<T, Object> enumValues,
  Object? source, {
  T? unknownValue,
}) {
  if (source == null) {
    throw ArgumentError(
      'A value must be provided. Supported values: '
      '${enumValues.values.join(', ')}',
    );
  }

  return enumValues.entries.singleWhere(
    (e) => e.value == source,
    orElse: () {
      if (unknownValue == null) {
        throw ArgumentError(
          '`$source` is not one of the supported values: '
          '${enumValues.values.join(', ')}',
        );
      }
      return MapEntry(unknownValue, enumValues.values.first);
    },
  ).key;
}