// lib/features/characters/domain/entities/character.dart
import 'package:equatable/equatable.dart';
import 'character_traits.dart';

/// Character Entity für Avatales
/// Represents a user's digital avatar character with traits, appearance, and metadata
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
    this.avatarUrl,
    this.adoptionCount = 0,
    this.readCount = 0,
    this.lastInteractionAt,
    this.level = 1,
    this.experienceCount = 0,
    this.favoriteGenres = const [],
    this.achievements = const [],
    this.backstory,
    this.voiceSettings,
    this.preferences,
  });

  // Core Identity
  final String id;
  final String name;                // Base character name
  final String? customName;         // User's custom name for the character
  final String description;
  final String appearance;          // Physical description
  final String personality;         // Personality description
  final String? backstory;          // Character's background story
  final String? avatarUrl;          // Generated avatar image URL

  // Character Traits & Stats
  final CharacterTraits traits;
  final int level;
  final int experienceCount;
  final List<String> achievements;

  // User Interaction Data
  final bool isPublic;              // Can be shared/adopted by others
  final int adoptionCount;          // How many times adopted by other users
  final int readCount;              // How many stories read with this character
  final DateTime createdAt;
  final DateTime? lastInteractionAt;

  // Preferences & Settings
  final List<String> favoriteGenres;
  final CharacterVoiceSettings? voiceSettings;
  final CharacterPreferences? preferences;

  /// Display name prioritizes custom name over base name
  String get displayName => customName?.isNotEmpty == true ? customName! : name;

  /// Experience needed for next level
  int get experienceToNextLevel {
    return _calculateExperienceForLevel(level + 1) - experienceCount;
  }

  /// Progress to next level (0.0 - 1.0)
  double get levelProgress {
    final currentLevelExp = _calculateExperienceForLevel(level);
    final nextLevelExp = _calculateExperienceForLevel(level + 1);
    final progressExp = experienceCount - currentLevelExp;
    final totalExpNeeded = nextLevelExp - currentLevelExp;
    
    return (progressExp / totalExpNeeded).clamp(0.0, 1.0);
  }

  /// Character rarity based on traits and level
  CharacterRarity get rarity {
    final avgTraits = traits.averageValue;
    final totalScore = (avgTraits * 0.7) + (level * 0.3);
    
    if (totalScore >= 90) return CharacterRarity.legendary;
    if (totalScore >= 80) return CharacterRarity.epic;
    if (totalScore >= 70) return CharacterRarity.rare;
    if (totalScore >= 60) return CharacterRarity.uncommon;
    return CharacterRarity.common;
  }

  /// Character category based on dominant traits
  CharacterCategory get category {
    final dominantTrait = traits.dominantTrait.toLowerCase();
    
    if (dominantTrait.contains('mut') || dominantTrait.contains('ausdauer')) {
      return CharacterCategory.hero;
    }
    if (dominantTrait.contains('kreativ') || dominantTrait.contains('neugier')) {
      return CharacterCategory.explorer;
    }
    if (dominantTrait.contains('empathie') || dominantTrait.contains('freundlich')) {
      return CharacterCategory.helper;
    }
    if (dominantTrait.contains('humor') || dominantTrait.contains('freundlich')) {
      return CharacterCategory.entertainer;
    }
    if (dominantTrait.contains('weisheit') || dominantTrait.contains('intelligent')) {
      return CharacterCategory.sage;
    }
    
    return CharacterCategory.balanced;
  }

  /// Creates a copy with modified values
  Character copyWith({
    String? id,
    String? name,
    String? customName,
    String? description,
    String? appearance,
    String? personality,
    String? backstory,
    String? avatarUrl,
    CharacterTraits? traits,
    int? level,
    int? experienceCount,
    List<String>? achievements,
    bool? isPublic,
    int? adoptionCount,
    int? readCount,
    DateTime? createdAt,
    DateTime? lastInteractionAt,
    List<String>? favoriteGenres,
    CharacterVoiceSettings? voiceSettings,
    CharacterPreferences? preferences,
  }) {
    return Character(
      id: id ?? this.id,
      name: name ?? this.name,
      customName: customName ?? this.customName,
      description: description ?? this.description,
      appearance: appearance ?? this.appearance,
      personality: personality ?? this.personality,
      backstory: backstory ?? this.backstory,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      traits: traits ?? this.traits,
      level: level ?? this.level,
      experienceCount: experienceCount ?? this.experienceCount,
      achievements: achievements ?? this.achievements,
      isPublic: isPublic ?? this.isPublic,
      adoptionCount: adoptionCount ?? this.adoptionCount,
      readCount: readCount ?? this.readCount,
      createdAt: createdAt ?? this.createdAt,
      lastInteractionAt: lastInteractionAt ?? this.lastInteractionAt,
      favoriteGenres: favoriteGenres ?? this.favoriteGenres,
      voiceSettings: voiceSettings ?? this.voiceSettings,
      preferences: preferences ?? this.preferences,
    );
  }

  /// Adds experience and potentially levels up
  Character addExperience(int experience) {
    final newExperienceCount = experienceCount + experience;
    final newLevel = _calculateLevelForExperience(newExperienceCount);
    
    return copyWith(
      experienceCount: newExperienceCount,
      level: newLevel,
      lastInteractionAt: DateTime.now(),
    );
  }

  /// Adds read count and experience
  Character addReadSession() {
    const readExperience = 25; // XP per story read
    return copyWith(
      readCount: readCount + 1,
      experienceCount: experienceCount + readExperience,
      lastInteractionAt: DateTime.now(),
    );
  }

  /// Adds achievement
  Character addAchievement(String achievement) {
    if (achievements.contains(achievement)) return this;
    
    return copyWith(
      achievements: [...achievements, achievement],
      experienceCount: experienceCount + 50, // Achievement bonus
    );
  }

  /// Factory for creating mock characters
  factory Character.mock({
    String? id,
    String? name,
    String? customName,
    int? level,
    CharacterTraits? traits,
  }) {
    return Character(
      id: id ?? 'mock_${DateTime.now().millisecondsSinceEpoch}',
      name: name ?? 'Adrian',
      customName: customName,
      description: 'Ein mutiger und freundlicher Abenteurer, der gerne neue Welten erkundet und anderen hilft.',
      appearance: 'Mittelgroß mit braunen Haaren und freundlichen Augen. Trägt oft ein Lächeln und bunte Kleidung.',
      personality: 'Optimistisch, hilfsbereit und neugierig. Liebt es, neue Freunde zu finden und spannende Geschichten zu erleben.',
      traits: traits ?? CharacterTraits.heroic(),
      isPublic: false,
      createdAt: DateTime.now().subtract(Duration(days: level ?? 1)),
      level: level ?? 1,
      experienceCount: _calculateExperienceForLevel(level ?? 1),
      favoriteGenres: ['Abenteuer', 'Freundschaft'],
      achievements: ['Erste Geschichte', 'Freundschafts-Champion'],
    );
  }

  /// Factory for creating hero archetype
  factory Character.hero({
    required String name,
    String? customName,
  }) {
    return Character(
      id: 'hero_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      customName: customName,
      description: 'Ein mutiger Held, der immer bereit ist, anderen zu helfen und das Richtige zu tun.',
      appearance: 'Stark und selbstbewusst, mit strahlenden Augen voller Entschlossenheit.',
      personality: 'Mutig, gerecht und selbstlos. Setzt sich für die Schwächeren ein.',
      traits: CharacterTraits.heroic(),
      isPublic: false,
      createdAt: DateTime.now(),
      level: 1,
      experienceCount: 0,
      favoriteGenres: ['Abenteuer', 'Action'],
    );
  }

  /// Factory for creating creative archetype
  factory Character.artist({
    required String name,
    String? customName,
  }) {
    return Character(
      id: 'artist_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      customName: customName,
      description: 'Ein kreativer Geist mit unendlicher Fantasie und künstlerischem Talent.',
      appearance: 'Expressiv und farbenfroh, oft mit kreativen Accessoires geschmückt.',
      personality: 'Imaginativ, ausdrucksstark und inspirierend. Sieht Schönheit überall.',
      traits: CharacterTraits.creative(),
      isPublic: false,
      createdAt: DateTime.now(),
      level: 1,
      experienceCount: 0,
      favoriteGenres: ['Fantasy', 'Kunst', 'Musik'],
    );
  }

  /// JSON serialization
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'customName': customName,
      'description': description,
      'appearance': appearance,
      'personality': personality,
      'backstory': backstory,
      'avatarUrl': avatarUrl,
      'traits': traits.toMap(),
      'level': level,
      'experienceCount': experienceCount,
      'achievements': achievements,
      'isPublic': isPublic,
      'adoptionCount': adoptionCount,
      'readCount': readCount,
      'createdAt': createdAt.toIso8601String(),
      'lastInteractionAt': lastInteractionAt?.toIso8601String(),
      'favoriteGenres': favoriteGenres,
      'voiceSettings': voiceSettings?.toJson(),
      'preferences': preferences?.toJson(),
    };
  }

  /// JSON deserialization
  factory Character.fromJson(Map<String, dynamic> json) {
    return Character(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      customName: json['customName'],
      description: json['description'] ?? '',
      appearance: json['appearance'] ?? '',
      personality: json['personality'] ?? '',
      backstory: json['backstory'],
      avatarUrl: json['avatarUrl'],
      traits: CharacterTraits.fromMap(json['traits'] ?? {}),
      level: json['level'] ?? 1,
      experienceCount: json['experienceCount'] ?? 0,
      achievements: List<String>.from(json['achievements'] ?? []),
      isPublic: json['isPublic'] ?? false,
      adoptionCount: json['adoptionCount'] ?? 0,
      readCount: json['readCount'] ?? 0,
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      lastInteractionAt: json['lastInteractionAt'] != null
          ? DateTime.tryParse(json['lastInteractionAt'])
          : null,
      favoriteGenres: List<String>.from(json['favoriteGenres'] ?? []),
      voiceSettings: json['voiceSettings'] != null
          ? CharacterVoiceSettings.fromJson(json['voiceSettings'])
          : null,
      preferences: json['preferences'] != null
          ? CharacterPreferences.fromJson(json['preferences'])
          : null,
    );
  }

  // Private helper methods
  static int _calculateExperienceForLevel(int level) {
    // Progressive XP requirements: Level 1: 0, Level 2: 100, Level 3: 250, etc.
    if (level <= 1) return 0;
    return ((level - 1) * 100) + ((level - 2) * 50);
  }

  static int _calculateLevelForExperience(int experience) {
    int level = 1;
    while (_calculateExperienceForLevel(level + 1) <= experience) {
      level++;
    }
    return level;
  }

  @override
  List<Object?> get props => [
    id, name, customName, description, appearance, personality, backstory,
    avatarUrl, traits, level, experienceCount, achievements, isPublic,
    adoptionCount, readCount, createdAt, lastInteractionAt, favoriteGenres,
    voiceSettings, preferences,
  ];

  @override
  String toString() {
    return 'Character(id: $id, displayName: $displayName, level: $level, '
           'rarity: ${rarity.name}, category: ${category.name})';
  }
}

/// Character Rarity Enum
enum CharacterRarity {
  common('Gewöhnlich', '⚪', 0),
  uncommon('Ungewöhnlich', '🟢', 1),
  rare('Selten', '🔵', 2),
  epic('Episch', '🟣', 3),
  legendary('Legendär', '🟡', 4);

  const CharacterRarity(this.displayName, this.emoji, this.tier);
  
  final String displayName;
  final String emoji;
  final int tier;
}

/// Character Category Enum
enum CharacterCategory {
  hero('Held', '🦸', 'Mutig und selbstlos'),
  explorer('Entdecker', '🧭', 'Neugierig und abenteuerlustig'),
  helper('Helfer', '🤝', 'Empathisch und hilfsbereit'),
  entertainer('Entertainer', '🎭', 'Lustig und charismatisch'),
  sage('Weise', '🦉', 'Klug und bedacht'),
  balanced('Ausgewogen', '⚖️', 'Harmonisch und vielseitig');

  const CharacterCategory(this.displayName, this.emoji, this.description);
  
  final String displayName;
  final String emoji;
  final String description;
}

/// Character Voice Settings
class CharacterVoiceSettings extends Equatable {
  const CharacterVoiceSettings({
    required this.voiceId,
    required this.speed,
    required this.pitch,
    this.accent,
  });

  final String voiceId;
  final double speed;    // 0.5 - 2.0
  final double pitch;    // 0.5 - 2.0
  final String? accent;

  Map<String, dynamic> toJson() {
    return {
      'voiceId': voiceId,
      'speed': speed,
      'pitch': pitch,
      'accent': accent,
    };
  }

  factory CharacterVoiceSettings.fromJson(Map<String, dynamic> json) {
    return CharacterVoiceSettings(
      voiceId: json['voiceId'] ?? 'default',
      speed: (json['speed'] ?? 1.0).toDouble(),
      pitch: (json['pitch'] ?? 1.0).toDouble(),
      accent: json['accent'],
    );
  }

  @override
  List<Object?> get props => [voiceId, speed, pitch, accent];
}

/// Character Preferences
class CharacterPreferences extends Equatable {
  const CharacterPreferences({
    this.preferredStoryLength,
    this.favoriteThemes = const [],
    this.avoidedTopics = const [],
    this.difficultyLevel,
  });

  final String? preferredStoryLength;
  final List<String> favoriteThemes;
  final List<String> avoidedTopics;
  final String? difficultyLevel;

  Map<String, dynamic> toJson() {
    return {
      'preferredStoryLength': preferredStoryLength,
      'favoriteThemes': favoriteThemes,
      'avoidedTopics': avoidedTopics,
      'difficultyLevel': difficultyLevel,
    };
  }

  factory CharacterPreferences.fromJson(Map<String, dynamic> json) {
    return CharacterPreferences(
      preferredStoryLength: json['preferredStoryLength'],
      favoriteThemes: List<String>.from(json['favoriteThemes'] ?? []),
      avoidedTopics: List<String>.from(json['avoidedTopics'] ?? []),
      difficultyLevel: json['difficultyLevel'],
    );
  }

  @override
  List<Object?> get props => [
    preferredStoryLength, favoriteThemes, avoidedTopics, difficultyLevel,
  ];
}