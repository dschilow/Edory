// lib/features/characters/domain/entities/character.dart
import 'package:equatable/equatable.dart';
import 'character_traits.dart';

class Character extends Equatable {
  const Character({
    required this.id,
    required this.name,
    required this.description,
    required this.appearance,
    required this.personality,
    required this.traits,
    required this.isPublic,
    required this.createdAt,
    this.customName,
    this.adoptionCount = 0,
    this.readCount = 0,
    this.lastInteractionAt,
    this.level = 1,
    this.experienceCount = 0,
  });

  final String id;
  final String name;
  final String description;
  final String appearance;
  final String personality;
  final CharacterTraits traits;
  final bool isPublic;
  final DateTime createdAt;
  final String? customName;
  final int adoptionCount;
  final int readCount;
  final DateTime? lastInteractionAt;
  final int level;
  final int experienceCount;

  // Gibt den anzuzeigenden Namen zurück (Custom oder Original)
  String get displayName => customName ?? name;

  // Berechnet das Character-Level basierend auf Erfahrungen
  int get calculatedLevel => (experienceCount / 5).floor() + 1;

  // Prüft ob der Charakter aktiv ist (kürzlich verwendet)
  bool get isActive {
    if (lastInteractionAt == null) return false;
    final difference = DateTime.now().difference(lastInteractionAt!);
    return difference.inDays < 7; // Aktiv wenn in den letzten 7 Tagen verwendet
  }

  // Gibt den Fortschritt zum nächsten Level zurück (0.0 - 1.0)
  double get progressToNextLevel {
    final currentLevelExp = (level - 1) * 5;
    final nextLevelExp = level * 5;
    final progress = (experienceCount - currentLevelExp) / (nextLevelExp - currentLevelExp);
    return progress.clamp(0.0, 1.0);
  }

  // Erstellt eine Kopie mit geänderten Werten
  Character copyWith({
    String? id,
    String? name,
    String? description,
    String? appearance,
    String? personality,
    CharacterTraits? traits,
    bool? isPublic,
    DateTime? createdAt,
    String? customName,
    int? adoptionCount,
    int? readCount,
    DateTime? lastInteractionAt,
    int? level,
    int? experienceCount,
  }) {
    return Character(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      appearance: appearance ?? this.appearance,
      personality: personality ?? this.personality,
      traits: traits ?? this.traits,
      isPublic: isPublic ?? this.isPublic,
      createdAt: createdAt ?? this.createdAt,
      customName: customName ?? this.customName,
      adoptionCount: adoptionCount ?? this.adoptionCount,
      readCount: readCount ?? this.readCount,
      lastInteractionAt: lastInteractionAt ?? this.lastInteractionAt,
      level: level ?? this.level,
      experienceCount: experienceCount ?? this.experienceCount,
    );
  }

  @override
  List<Object?> get props => [
    id, name, description, appearance, personality, traits,
    isPublic, createdAt, customName, adoptionCount, readCount,
    lastInteractionAt, level, experienceCount,
  ];
}
