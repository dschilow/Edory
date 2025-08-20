// lib/features/characters/data/models/character_traits_model.dart
import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/character_traits.dart';

// part 'character_traits_model.g.dart'; // TODO: Generate with build_runner

@JsonSerializable()
class CharacterTraitsModel extends CharacterTraits {
  const CharacterTraitsModel({
    required super.courage,
    required super.creativity,
    required super.helpfulness,
    required super.humor,
    required super.wisdom,
    required super.curiosity,
    required super.empathy,
    required super.persistence,
  });

  factory CharacterTraitsModel.fromJson(Map<String, dynamic> json) =>
      CharacterTraitsModel(
        courage: json['courage'] ?? 50,
        creativity: json['creativity'] ?? 50,
        helpfulness: json['helpfulness'] ?? 50,
        humor: json['humor'] ?? 50,
        wisdom: json['wisdom'] ?? 50,
        curiosity: json['curiosity'] ?? 50,
        empathy: json['empathy'] ?? 50,
        persistence: json['persistence'] ?? 50,
      );

  factory CharacterTraitsModel.fromEntity(CharacterTraits traits) =>
      CharacterTraitsModel(
        courage: traits.courage,
        creativity: traits.creativity,
        helpfulness: traits.helpfulness,
        humor: traits.humor,
        wisdom: traits.wisdom,
        curiosity: traits.curiosity,
        empathy: traits.empathy,
        persistence: traits.persistence,
      );

  Map<String, dynamic> toJson() => {
    'courage': courage,
    'creativity': creativity,
    'helpfulness': helpfulness,
    'humor': humor,
    'wisdom': wisdom,
    'curiosity': curiosity,
    'empathy': empathy,
    'persistence': persistence,
  };

  CharacterTraits toEntity() => CharacterTraits(
    courage: courage,
    creativity: creativity,
    helpfulness: helpfulness,
    humor: humor,
    wisdom: wisdom,
    curiosity: curiosity,
    empathy: empathy,
    persistence: persistence,
  );
}
