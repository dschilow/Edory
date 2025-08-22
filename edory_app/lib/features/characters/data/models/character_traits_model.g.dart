// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'character_traits_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CharacterTraitsModel _$CharacterTraitsModelFromJson(
        Map<String, dynamic> json) =>
    CharacterTraitsModel(
      courage: (json['courage'] as num).toInt(),
      creativity: (json['creativity'] as num).toInt(),
      helpfulness: (json['helpfulness'] as num).toInt(),
      humor: (json['humor'] as num).toInt(),
      wisdom: (json['wisdom'] as num).toInt(),
      curiosity: (json['curiosity'] as num).toInt(),
      empathy: (json['empathy'] as num).toInt(),
      persistence: (json['persistence'] as num).toInt(),
      intelligence: (json['intelligence'] as num).toInt(),
      kindness: (json['kindness'] as num).toInt(),
    );

Map<String, dynamic> _$CharacterTraitsModelToJson(
        CharacterTraitsModel instance) =>
    <String, dynamic>{
      'courage': instance.courage,
      'creativity': instance.creativity,
      'helpfulness': instance.helpfulness,
      'humor': instance.humor,
      'wisdom': instance.wisdom,
      'curiosity': instance.curiosity,
      'empathy': instance.empathy,
      'persistence': instance.persistence,
      'intelligence': instance.intelligence,
      'kindness': instance.kindness,
    };
