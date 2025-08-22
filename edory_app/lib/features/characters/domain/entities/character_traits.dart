// lib/features/characters/domain/entities/character_traits.dart
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'character_traits.g.dart';

/// Charaktereigenschaften für Avatales
/// Umfasst alle wichtigen Eigenschaften für die Charakterentwicklung
@JsonSerializable()
class CharacterTraits extends Equatable {
  const CharacterTraits({
    required this.courage,      // Mut
    required this.creativity,   // Kreativität
    required this.helpfulness,  // Hilfsbereitschaft
    required this.humor,        // Humor
    required this.wisdom,       // Weisheit
    required this.curiosity,    // Neugier
    required this.empathy,      // Empathie
    required this.persistence,  // Ausdauer (ersetzt "strength")
    required this.intelligence, // Intelligenz
    required this.kindness,     // Freundlichkeit
  });

  /// Standardwerte für ausgeglichene Charaktere
  factory CharacterTraits.neutral() => const CharacterTraits(
    courage: 50,
    creativity: 50,
    helpfulness: 50,
    humor: 50,
    wisdom: 50,
    curiosity: 50,
    empathy: 50,
    persistence: 50,
    intelligence: 50,
    kindness: 50,
  );

  /// Erstellt heroische Charaktereigenschaften
  factory CharacterTraits.heroic() => const CharacterTraits(
    courage: 85,
    creativity: 70,
    helpfulness: 90,
    humor: 60,
    wisdom: 75,
    curiosity: 80,
    empathy: 85,
    persistence: 90,
    intelligence: 80,
    kindness: 95,
  );

  /// Erstellt kreative Charaktereigenschaften
  factory CharacterTraits.creative() => const CharacterTraits(
    courage: 60,
    creativity: 95,
    helpfulness: 65,
    humor: 80,
    wisdom: 70,
    curiosity: 90,
    empathy: 75,
    persistence: 70,
    intelligence: 85,
    kindness: 70,
  );

  /// Alle Eigenschaften (0-100)
  final int courage;      // Mut - für Abenteuer und Herausforderungen
  final int creativity;   // Kreativität - für künstlerische und innovative Lösungen
  final int helpfulness;  // Hilfsbereitschaft - für soziale Interaktionen
  final int humor;        // Humor - für Spaß und positive Stimmung
  final int wisdom;       // Weisheit - für kluge Entscheidungen
  final int curiosity;    // Neugier - für Lernen und Entdeckungen
  final int empathy;      // Empathie - für emotionale Verbindungen
  final int persistence;  // Ausdauer - für Durchhaltevermögen
  final int intelligence; // Intelligenz - für Problemlösung
  final int kindness;     // Freundlichkeit - für zwischenmenschliche Beziehungen

  /// Berechnet den Durchschnittswert aller Eigenschaften
  double get averageValue {
    return (courage + creativity + helpfulness + humor + wisdom + 
            curiosity + empathy + persistence + intelligence + kindness) / 10.0;
  }

  /// Gibt die höchste Eigenschaft zurück
  String get dominantTrait {
    final Map<String, int> traits = {
      'Mut': courage,
      'Kreativität': creativity,
      'Hilfsbereitschaft': helpfulness,
      'Humor': humor,
      'Weisheit': wisdom,
      'Neugier': curiosity,
      'Empathie': empathy,
      'Ausdauer': persistence,
      'Intelligenz': intelligence,
      'Freundlichkeit': kindness,
    };
    
    return traits.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }

  /// Gibt die Charakterstärke basierend auf dem Durchschnitt zurück
  CharacterStrength get overallStrength {
    final avg = averageValue;
    if (avg >= 80) return CharacterStrength.legendary;
    if (avg >= 65) return CharacterStrength.strong;
    if (avg >= 50) return CharacterStrength.balanced;
    if (avg >= 35) return CharacterStrength.developing;
    return CharacterStrength.weak;
  }

  /// Erstellt eine Kopie mit geänderten Werten
  CharacterTraits copyWith({
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
    return CharacterTraits(
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

  /// Balanciert alle Eigenschaften automatisch
  CharacterTraits balance() {
    const target = 65; // Zielwert für ausbalancierte Charaktere
    return CharacterTraits(
      courage: target,
      creativity: target,
      helpfulness: target,
      humor: target,
      wisdom: target,
      curiosity: target,
      empathy: target,
      persistence: target,
      intelligence: target,
      kindness: target,
    );
  }

  /// Validiert alle Eigenschaften (0-100)
  bool get isValid {
    return [courage, creativity, helpfulness, humor, wisdom, 
            curiosity, empathy, persistence, intelligence, kindness]
        .every((trait) => trait >= 0 && trait <= 100);
  }

  /// Konvertiert zu Map für JSON Serialization
  Map<String, dynamic> toMap() {
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
    };
  }

  /// Erstellt aus Map (JSON Deserialization)
  factory CharacterTraits.fromMap(Map<String, dynamic> map) {
    return CharacterTraits(
      courage: (map['courage'] ?? 50).clamp(0, 100),
      creativity: (map['creativity'] ?? 50).clamp(0, 100),
      helpfulness: (map['helpfulness'] ?? 50).clamp(0, 100),
      humor: (map['humor'] ?? 50).clamp(0, 100),
      wisdom: (map['wisdom'] ?? 50).clamp(0, 100),
      curiosity: (map['curiosity'] ?? 50).clamp(0, 100),
      empathy: (map['empathy'] ?? 50).clamp(0, 100),
      persistence: (map['persistence'] ?? map['strength'] ?? 50).clamp(0, 100), // Backward compatibility
      intelligence: (map['intelligence'] ?? 50).clamp(0, 100),
      kindness: (map['kindness'] ?? 50).clamp(0, 100),
    );
  }

  /// JSON Serialization
  factory CharacterTraits.fromJson(Map<String, dynamic> json) => _$CharacterTraitsFromJson(json);
  Map<String, dynamic> toJson() => _$CharacterTraitsToJson(this);

  @override
  List<Object?> get props => [
    courage, creativity, helpfulness, humor, wisdom,
    curiosity, empathy, persistence, intelligence, kindness,
  ];

  @override
  String toString() {
    return 'CharacterTraits(courage: $courage, creativity: $creativity, '
           'helpfulness: $helpfulness, humor: $humor, wisdom: $wisdom, '
           'curiosity: $curiosity, empathy: $empathy, persistence: $persistence, '
           'intelligence: $intelligence, kindness: $kindness)';
  }
}

/// Charakterstärke Enum
enum CharacterStrength {
  weak('Schwach', '😴'),
  developing('Entwickelnd', '🌱'),
  balanced('Ausgewogen', '⚖️'),
  strong('Stark', '💪'),
  legendary('Legendär', '🌟');

  const CharacterStrength(this.displayName, this.emoji);
  
  final String displayName;
  final String emoji;
}

/// Trait-Daten für UI-Darstellung
class TraitData {
  const TraitData(this.name, this.value, this.emoji, this.gradient);
  
  final String name;
  final int value;
  final String emoji;
  final dynamic gradient; // LinearGradient
}