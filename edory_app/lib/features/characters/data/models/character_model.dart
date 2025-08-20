// lib/features/characters/data/models/character_model.dart
import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/character.dart';
import 'character_traits_model.dart';

// part 'character_model.g.dart'; // TODO: Generate with build_runner

@JsonSerializable()
class CharacterModel extends Character {
  const CharacterModel({
    required super.id,
    required super.name,
    required super.description,
    required super.appearance,
    required super.personality,
    required super.traits,
    required super.isPublic,
    required super.createdAt,
    super.customName,
    super.adoptionCount = 0,
    super.readCount = 0,
    super.lastInteractionAt,
    super.level = 1,
    super.experienceCount = 0,
  });

  factory CharacterModel.fromJson(Map<String, dynamic> json) =>
      CharacterModel(
        id: json['id'] ?? '',
        name: json['name'] ?? '',
        description: json['description'] ?? '',
        appearance: json['appearance'] ?? '',
        personality: json['personality'] ?? '',
        traits: CharacterTraitsModel.fromJson(json['traits'] ?? {}),
        isPublic: json['isPublic'] ?? false,
        createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
        customName: json['customName'],
        adoptionCount: json['adoptionCount'] ?? 0,
        readCount: json['readCount'] ?? 0,
        lastInteractionAt: json['lastInteractionAt'] != null 
            ? DateTime.tryParse(json['lastInteractionAt']) 
            : null,
        level: json['level'] ?? 1,
        experienceCount: json['experienceCount'] ?? 0,
      );

  factory CharacterModel.fromEntity(Character character) => CharacterModel(
    id: character.id,
    name: character.name,
    description: character.description,
    appearance: character.appearance,
    personality: character.personality,
    traits: character.traits,
    isPublic: character.isPublic,
    createdAt: character.createdAt,
    customName: character.customName,
    adoptionCount: character.adoptionCount,
    readCount: character.readCount,
    lastInteractionAt: character.lastInteractionAt,
    level: character.level,
    experienceCount: character.experienceCount,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'appearance': appearance,
    'personality': personality,
    'traits': (traits as CharacterTraitsModel).toJson(),
    'isPublic': isPublic,
    'createdAt': createdAt.toIso8601String(),
    'customName': customName,
    'adoptionCount': adoptionCount,
    'readCount': readCount,
    'lastInteractionAt': lastInteractionAt?.toIso8601String(),
    'level': level,
    'experienceCount': experienceCount,
  };

  Character toEntity() => Character(
    id: id,
    name: name,
    description: description,
    appearance: appearance,
    personality: personality,
    traits: traits,
    isPublic: isPublic,
    createdAt: createdAt,
    customName: customName,
    adoptionCount: adoptionCount,
    readCount: readCount,
    lastInteractionAt: lastInteractionAt,
    level: level,
    experienceCount: experienceCount,
  );
}
