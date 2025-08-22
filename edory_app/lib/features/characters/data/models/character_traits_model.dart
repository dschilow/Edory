// lib/features/characters/data/models/character_traits_model.dart
import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/character_traits.dart';

part 'character_traits_model.g.dart';

/// Data Model für CharacterTraits mit JSON Serialization
/// Vollständig kompatibel mit der aktualisierten CharacterTraits Entity
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
    required super.intelligence,
    required super.kindness,
  });

  /// Erstellt Model aus JSON - Mit Backward Compatibility
  factory CharacterTraitsModel.fromJson(Map<String, dynamic> json) {
    // Backward compatibility für altes "strength" field
    final persistence = json['persistence'] ?? json['strength'] ?? 50;
    
    return CharacterTraitsModel(
      courage: (json['courage'] ?? 50).clamp(0, 100),
      creativity: (json['creativity'] ?? 50).clamp(0, 100),
      helpfulness: (json['helpfulness'] ?? 50).clamp(0, 100),
      humor: (json['humor'] ?? 50).clamp(0, 100),
      wisdom: (json['wisdom'] ?? 50).clamp(0, 100),
      curiosity: (json['curiosity'] ?? 50).clamp(0, 100),
      empathy: (json['empathy'] ?? 50).clamp(0, 100),
      persistence: persistence.clamp(0, 100),
      intelligence: (json['intelligence'] ?? 50).clamp(0, 100),
      kindness: (json['kindness'] ?? 50).clamp(0, 100),
    );
  }

  /// Erstellt Model aus Entity
  factory CharacterTraitsModel.fromEntity(CharacterTraits traits) {
    return CharacterTraitsModel(
      courage: traits.courage,
      creativity: traits.creativity,
      helpfulness: traits.helpfulness,
      humor: traits.humor,
      wisdom: traits.wisdom,
      curiosity: traits.curiosity,
      empathy: traits.empathy,
      persistence: traits.persistence,
      intelligence: traits.intelligence,
      kindness: traits.kindness,
    );
  }

  /// Erstellt Model mit Mock-Daten für Tests
  factory CharacterTraitsModel.mock({
    int? courage,
    int? creativity,
    int? helpfulness,
    int? humor,
    int? wisdom,
    int? curiosity,
    int? empathy,
    int? persistence,
    int? intelligence,
    int? kindness,
  }) {
    return CharacterTraitsModel(
      courage: courage ?? 75,
      creativity: creativity ?? 80,
      helpfulness: helpfulness ?? 70,
      humor: humor ?? 65,
      wisdom: wisdom ?? 60,
      curiosity: curiosity ?? 85,
      empathy: empathy ?? 90,
      persistence: persistence ?? 75,
      intelligence: intelligence ?? 80,
      kindness: kindness ?? 85,
    );
  }

  /// Erstellt verschiedene Charakter-Archetypen
  factory CharacterTraitsModel.hero() {
    return CharacterTraitsModel.fromEntity(CharacterTraits.heroic());
  }

  factory CharacterTraitsModel.artist() {
    return CharacterTraitsModel.fromEntity(CharacterTraits.creative());
  }

  factory CharacterTraitsModel.balanced() {
    return CharacterTraitsModel.fromEntity(CharacterTraits.neutral());
  }

  /// Konvertiert zu JSON
  Map<String, dynamic> toJson() => {
    'courage': courage,
    'creativity': creativity,
    'helpfulness': helpfulness,
    'humor': humor,
    'wisdom': wisdom,
    'curiosity': curiosity,
    'empathy': empathy,
    'persistence': persistence,
    'intelligence': intelligence,
    'kindness': kindness,
  };

  /// Konvertiert zu Entity
  CharacterTraits toEntity() {
    return CharacterTraits(
      courage: courage,
      creativity: creativity,
      helpfulness: helpfulness,
      humor: humor,
      wisdom: wisdom,
      curiosity: curiosity,
      empathy: empathy,
      persistence: persistence,
      intelligence: intelligence,
      kindness: kindness,
    );
  }

  /// Erstellt API-kompatible Map für Backend
  Map<String, dynamic> toApiJson() {
    return {
      'courage': courage,
      'creativity': creativity,
      'helpfulness': helpfulness,
      'humor': humor,
      'wisdom': wisdom,
      'curiosity': curiosity,
      'empathy': empathy,
      'persistence': persistence,
      'intelligence': intelligence,
      'kindness': kindness,
      // Zusätzliche Felder für API
      'averageValue': averageValue,
      'dominantTrait': dominantTrait,
      'overallStrength': overallStrength.name,
    };
  }

  /// Erstellt Model aus API Response
  factory CharacterTraitsModel.fromApiJson(Map<String, dynamic> json) {
    return CharacterTraitsModel.fromJson(json);
  }

  /// Validiert alle Werte
  bool validate() {
    return isValid;
  }

  /// Erstellt eine zufällige Variante basierend auf aktuellen Werten
  CharacterTraitsModel createVariant({int variance = 10}) {
    return CharacterTraitsModel(
      courage: _varyValue(courage, variance),
      creativity: _varyValue(creativity, variance),
      helpfulness: _varyValue(helpfulness, variance),
      humor: _varyValue(humor, variance),
      wisdom: _varyValue(wisdom, variance),
      curiosity: _varyValue(curiosity, variance),
      empathy: _varyValue(empathy, variance),
      persistence: _varyValue(persistence, variance),
      intelligence: _varyValue(intelligence, variance),
      kindness: _varyValue(kindness, variance),
    );
  }

  /// Hilfsmethode für Variationen
  int _varyValue(int base, int variance) {
    final random = DateTime.now().microsecond % (variance * 2 + 1) - variance;
    return (base + random).clamp(0, 100);
  }

  /// Erstellt optimierte Traits für bestimmte Story-Genres
  CharacterTraitsModel optimizeForGenre(String genre) {
    switch (genre.toLowerCase()) {
      case 'abenteuer':
        return copyWithModel(
          courage: (courage + 20).clamp(0, 100),
          curiosity: (curiosity + 15).clamp(0, 100),
          persistence: (persistence + 10).clamp(0, 100),
        );
      case 'freundschaft':
        return copyWithModel(
          empathy: (empathy + 20).clamp(0, 100),
          kindness: (kindness + 15).clamp(0, 100),
          helpfulness: (helpfulness + 10).clamp(0, 100),
        );
      case 'lernen':
        return copyWithModel(
          intelligence: (intelligence + 20).clamp(0, 100),
          curiosity: (curiosity + 15).clamp(0, 100),
          wisdom: (wisdom + 10).clamp(0, 100),
        );
      case 'fantasy':
        return copyWithModel(
          creativity: (creativity + 20).clamp(0, 100),
          wisdom: (wisdom + 15).clamp(0, 100),
          courage: (courage + 10).clamp(0, 100),
        );
      default:
        return this;
    }
  }

  /// Model-spezifisches copyWith
  CharacterTraitsModel copyWithModel({
    int? courage,
    int? creativity,
    int? helpfulness,
    int? humor,
    int? wisdom,
    int? curiosity,
    int? empathy,
    int? persistence,
    int? intelligence,
    int? kindness,
  }) {
    return CharacterTraitsModel(
      courage: courage ?? this.courage,
      creativity: creativity ?? this.creativity,
      helpfulness: helpfulness ?? this.helpfulness,
      humor: humor ?? this.humor,
      wisdom: wisdom ?? this.wisdom,
      curiosity: curiosity ?? this.curiosity,
      empathy: empathy ?? this.empathy,
      persistence: persistence ?? this.persistence,
      intelligence: intelligence ?? this.intelligence,
      kindness: kindness ?? this.kindness,
    );
  }

  @override
  String toString() {
    return 'CharacterTraitsModel(${super.toString()})';
  }
}