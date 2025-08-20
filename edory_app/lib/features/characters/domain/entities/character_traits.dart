// lib/features/characters/domain/entities/character_traits.dart
import 'package:equatable/equatable.dart';

class CharacterTraits extends Equatable {
  const CharacterTraits({
    required this.courage,
    required this.creativity,
    required this.helpfulness,
    required this.humor,
    required this.wisdom,
    required this.curiosity,
    required this.empathy,
    required this.persistence,
  });

  final int courage;      // Mut (0-100)
  final int creativity;   // Kreativität (0-100)  
  final int helpfulness;  // Hilfsbereitschaft (0-100)
  final int humor;        // Humor (0-100)
  final int wisdom;       // Weisheit (0-100)
  final int curiosity;    // Neugier (0-100)
  final int empathy;      // Empathie (0-100)
  final int persistence;  // Ausdauer (0-100)

  // Factory constructor für neutrale Traits
  factory CharacterTraits.neutral() => const CharacterTraits(
    courage: 50,
    creativity: 50,
    helpfulness: 50,
    humor: 50,
    wisdom: 50,
    curiosity: 50,
    empathy: 50,
    persistence: 50,
  );

  // Berechnet den Durchschnittswert aller Eigenschaften
  double get averageValue {
    return (courage + creativity + helpfulness + humor + 
            wisdom + curiosity + empathy + persistence) / 8.0;
  }

  // Gibt die stärkste Eigenschaft zurück
  String get dominantTrait {
    final traits = {
      'Mut': courage,
      'Kreativität': creativity,
      'Hilfsbereitschaft': helpfulness,
      'Humor': humor,
      'Weisheit': wisdom,
      'Neugier': curiosity,
      'Empathie': empathy,
      'Ausdauer': persistence,
    };
    
    return traits.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }

  // Erstellt eine Kopie mit geänderten Werten
  CharacterTraits copyWith({
    int? courage,
    int? creativity,
    int? helpfulness,
    int? humor,
    int? wisdom,
    int? curiosity,
    int? empathy,
    int? persistence,
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
    );
  }

  @override
  List<Object?> get props => [
    courage, creativity, helpfulness, humor,
    wisdom, curiosity, empathy, persistence,
  ];
}
