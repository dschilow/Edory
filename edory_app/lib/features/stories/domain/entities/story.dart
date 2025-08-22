// lib/features/stories/domain/entities/story.dart
import 'package:equatable/equatable.dart';

/// Story Entity für Avatales
/// Represents a generated story with all its metadata and content
class Story extends Equatable {
  const Story({
    required this.id,
    required this.title,
    required this.content,
    required this.characterId,
    required this.characterName,
    required this.genre,
    required this.targetAge,
    required this.length,
    required this.createdAt,
    required this.isAiGenerated,
    this.mood,
    this.setting,
    this.learningObjectives = const [],
    this.keywords = const [],
    this.tokensUsed = 0,
    this.estimatedReadingTime = 0,
    this.chapters = const [],
    this.illustrations = const [],
    this.isFavorite = false,
    this.readCount = 0,
    this.lastReadAt,
    this.rating,
    this.feedback,
    this.sharedCount = 0,
    this.isPublic = false,
  });

  // Core Story Data
  final String id;
  final String title;
  final String content;
  final String characterId;
  final String characterName;
  
  // Story Configuration
  final String genre;
  final int targetAge;
  final StoryLength length;
  final String? mood;
  final String? setting;
  final List<String> learningObjectives;
  final List<String> keywords;
  
  // Generation Metadata
  final DateTime createdAt;
  final bool isAiGenerated;
  final int tokensUsed;
  final int estimatedReadingTime;
  
  // Content Structure
  final List<StoryChapter> chapters;
  final List<StoryIllustration> illustrations;
  
  // User Interaction
  final bool isFavorite;
  final int readCount;
  final DateTime? lastReadAt;
  final double? rating;
  final String? feedback;
  
  // Social Features
  final int sharedCount;
  final bool isPublic;

  /// Creates a copy with modified values
  Story copyWith({
    String? id,
    String? title,
    String? content,
    String? characterId,
    String? characterName,
    String? genre,
    int? targetAge,
    StoryLength? length,
    String? mood,
    String? setting,
    List<String>? learningObjectives,
    List<String>? keywords,
    DateTime? createdAt,
    bool? isAiGenerated,
    int? tokensUsed,
    int? estimatedReadingTime,
    List<StoryChapter>? chapters,
    List<StoryIllustration>? illustrations,
    bool? isFavorite,
    int? readCount,
    DateTime? lastReadAt,
    double? rating,
    String? feedback,
    int? sharedCount,
    bool? isPublic,
  }) {
    return Story(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      characterId: characterId ?? this.characterId,
      characterName: characterName ?? this.characterName,
      genre: genre ?? this.genre,
      targetAge: targetAge ?? this.targetAge,
      length: length ?? this.length,
      mood: mood ?? this.mood,
      setting: setting ?? this.setting,
      learningObjectives: learningObjectives ?? this.learningObjectives,
      keywords: keywords ?? this.keywords,
      createdAt: createdAt ?? this.createdAt,
      isAiGenerated: isAiGenerated ?? this.isAiGenerated,
      tokensUsed: tokensUsed ?? this.tokensUsed,
      estimatedReadingTime: estimatedReadingTime ?? this.estimatedReadingTime,
      chapters: chapters ?? this.chapters,
      illustrations: illustrations ?? this.illustrations,
      isFavorite: isFavorite ?? this.isFavorite,
      readCount: readCount ?? this.readCount,
      lastReadAt: lastReadAt ?? this.lastReadAt,
      rating: rating ?? this.rating,
      feedback: feedback ?? this.feedback,
      sharedCount: sharedCount ?? this.sharedCount,
      isPublic: isPublic ?? this.isPublic,
    );
  }

  /// Factory for creating mock stories for testing
  factory Story.mock({
    String? id,
    String? title,
    String? characterName,
    String? genre,
    StoryLength? length,
  }) {
    return Story(
      id: id ?? 'mock_story_${DateTime.now().millisecondsSinceEpoch}',
      title: title ?? 'Die magische Reise von Luna',
      content: '''Es war einmal eine mutige kleine Entdeckerin namens Luna, die in einem verzauberten Dorf lebte. Jeden Tag träumte sie davon, die Geheimnisse des mystischen Waldes zu erkunden, der ihr Zuhause umgab.

Eines strahlenden Morgens entschied Luna, dass heute der Tag für ihr großes Abenteuer war. Sie packte ihren kleinen Rucksack mit allem, was sie brauchte: ein Butterbrot, eine Wasserflasche und ihr magisches Kompass, das ihr Großvater ihr geschenkt hatte.

Als sie den Waldrand erreichte, begann der Kompass zu leuchten. "Das ist ein gutes Zeichen!", dachte Luna und folgte dem glitzernden Pfad, der sich vor ihr öffnete.

Tief im Wald traf sie einen sprechenden Fuchs namens Felix. "Hallo, kleine Entdeckerin", sagte Felix mit einem freundlichen Lächeln. "Ich habe gehört, dass du nach dem Kristall der Weisheit suchst."

Luna staunte. "Woher wusstest du das?"

"Der Wald spricht zu denen, die ein reines Herz haben", antwortete Felix. "Ich kann dir helfen, aber du musst drei Aufgaben lösen."

Und so begann Lunas wundervolles Abenteuer, das ihr nicht nur den Kristall bringen würde, sondern auch wichtige Lektionen über Mut, Freundschaft und Vertrauen.''',
      characterId: 'mock_character_id',
      characterName: characterName ?? 'Luna die Entdeckerin',
      genre: genre ?? 'Abenteuer',
      targetAge: 8,
      length: length ?? StoryLength.medium,
      createdAt: DateTime.now(),
      isAiGenerated: false,
      estimatedReadingTime: 5,
      learningObjectives: ['Mut entwickeln', 'Freundschaften schließen'],
      mood: 'Abenteuerlich',
      setting: 'Verzauberter Wald',
    );
  }

  /// Factory for short story
  factory Story.shortExample(String characterName) {
    return Story(
      id: 'short_${DateTime.now().millisecondsSinceEpoch}',
      title: '$characterName und der magische Garten',
      content: '''$characterName entdeckte eines Tages einen geheimen Garten hinter ihrem Haus. Die Blumen dort konnten sprechen und erzählten wundervolle Geschichten. 

"Willkommen im Garten der Träume", flüsterte eine Rose. "$characterName, du hast ein besonderes Geschenk - du kannst uns verstehen!"

$characterName lernte an diesem Tag, dass die Natur voller Wunder steckt und dass jeder, der genau hinhört, ihre Geheimnisse entdecken kann.''',
      characterId: 'example_character',
      characterName: characterName,
      genre: 'Fantasy',
      targetAge: 6,
      length: StoryLength.short,
      createdAt: DateTime.now(),
      isAiGenerated: false,
      estimatedReadingTime: 2,
      learningObjectives: ['Naturverbundenheit fördern'],
    );
  }

  /// Splits content into chapters automatically
  List<StoryChapter> get autoChapters {
    if (chapters.isNotEmpty) return chapters;
    
    final paragraphs = content
        .split('\n\n')
        .where((p) => p.trim().isNotEmpty)
        .toList();
    
    return paragraphs.asMap().entries.map((entry) {
      return StoryChapter(
        id: '${id}_chapter_${entry.key}',
        title: 'Kapitel ${entry.key + 1}',
        content: entry.value.trim(),
        order: entry.key,
      );
    }).toList();
  }

  /// Word count estimation
  int get wordCount {
    return content.split(RegExp(r'\s+')).length;
  }

  /// Reading time based on age-appropriate reading speed
  int get calculatedReadingTime {
    if (estimatedReadingTime > 0) return estimatedReadingTime;
    
    // Age-appropriate reading speeds (words per minute)
    final wordsPerMinute = switch (targetAge) {
      <= 6 => 50,   // Young children (read to)
      <= 8 => 80,   // Early readers
      <= 10 => 120, // Developing readers
      <= 12 => 160, // Fluent readers
      _ => 200,     // Advanced readers
    };
    
    return (wordCount / wordsPerMinute).ceil();
  }

  /// Story complexity level
  StoryComplexity get complexity {
    final sentences = content.split(RegExp(r'[.!?]+'));
    final avgWordsPerSentence = wordCount / sentences.length;
    
    if (avgWordsPerSentence < 8) return StoryComplexity.simple;
    if (avgWordsPerSentence < 15) return StoryComplexity.medium;
    return StoryComplexity.complex;
  }

  /// Story quality score (0-100)
  int get qualityScore {
    int score = 50; // Base score
    
    // Length appropriateness
    if (length == StoryLength.medium) score += 10;
    
    // Learning objectives
    score += (learningObjectives.length * 5).clamp(0, 20);
    
    // Content quality indicators
    if (content.contains('"')) score += 10; // Has dialogue
    if (content.contains('!')) score += 5;  // Has excitement
    if (content.length > 500) score += 10;  // Substantial content
    
    // AI vs Human bonus
    if (!isAiGenerated) score += 5;
    
    return score.clamp(0, 100);
  }

  /// Age appropriateness check
  bool get isAgeAppropriate {
    // Simple content analysis for age appropriateness
    final forbiddenWords = ['gewalt', 'angst', 'tod', 'horror'];
    final contentLower = content.toLowerCase();
    
    return !forbiddenWords.any((word) => contentLower.contains(word));
  }

  /// JSON serialization
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'characterId': characterId,
      'characterName': characterName,
      'genre': genre,
      'targetAge': targetAge,
      'length': length.name,
      'mood': mood,
      'setting': setting,
      'learningObjectives': learningObjectives,
      'keywords': keywords,
      'createdAt': createdAt.toIso8601String(),
      'isAiGenerated': isAiGenerated,
      'tokensUsed': tokensUsed,
      'estimatedReadingTime': estimatedReadingTime,
      'chapters': chapters.map((c) => c.toJson()).toList(),
      'illustrations': illustrations.map((i) => i.toJson()).toList(),
      'isFavorite': isFavorite,
      'readCount': readCount,
      'lastReadAt': lastReadAt?.toIso8601String(),
      'rating': rating,
      'feedback': feedback,
      'sharedCount': sharedCount,
      'isPublic': isPublic,
    };
  }

  /// JSON deserialization
  factory Story.fromJson(Map<String, dynamic> json) {
    return Story(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      characterId: json['characterId'] ?? '',
      characterName: json['characterName'] ?? '',
      genre: json['genre'] ?? '',
      targetAge: json['targetAge'] ?? 8,
      length: StoryLength.values.firstWhere(
        (e) => e.name == json['length'],
        orElse: () => StoryLength.medium,
      ),
      mood: json['mood'],
      setting: json['setting'],
      learningObjectives: List<String>.from(json['learningObjectives'] ?? []),
      keywords: List<String>.from(json['keywords'] ?? []),
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      isAiGenerated: json['isAiGenerated'] ?? false,
      tokensUsed: json['tokensUsed'] ?? 0,
      estimatedReadingTime: json['estimatedReadingTime'] ?? 0,
      chapters: (json['chapters'] as List<dynamic>?)
          ?.map((c) => StoryChapter.fromJson(c))
          .toList() ?? [],
      illustrations: (json['illustrations'] as List<dynamic>?)
          ?.map((i) => StoryIllustration.fromJson(i))
          .toList() ?? [],
      isFavorite: json['isFavorite'] ?? false,
      readCount: json['readCount'] ?? 0,
      lastReadAt: json['lastReadAt'] != null 
          ? DateTime.tryParse(json['lastReadAt'])
          : null,
      rating: json['rating']?.toDouble(),
      feedback: json['feedback'],
      sharedCount: json['sharedCount'] ?? 0,
      isPublic: json['isPublic'] ?? false,
    );
  }

  @override
  List<Object?> get props => [
    id, title, content, characterId, characterName, genre, targetAge,
    length, mood, setting, learningObjectives, keywords, createdAt,
    isAiGenerated, tokensUsed, estimatedReadingTime, chapters,
    illustrations, isFavorite, readCount, lastReadAt, rating,
    feedback, sharedCount, isPublic,
  ];

  @override
  String toString() {
    return 'Story(id: $id, title: $title, characterName: $characterName, '
           'genre: $genre, targetAge: $targetAge, length: $length)';
  }
}

/// Story Length Enum
enum StoryLength {
  short('Kurz', 1, 2),
  medium('Mittel', 3, 7),
  long('Lang', 8, 15);

  const StoryLength(this.displayName, this.minMinutes, this.maxMinutes);
  
  final String displayName;
  final int minMinutes;
  final int maxMinutes;
}

/// Story Complexity Enum
enum StoryComplexity {
  simple('Einfach', '👶'),
  medium('Mittel', '🧒'),
  complex('Komplex', '🧑');

  const StoryComplexity(this.displayName, this.emoji);
  
  final String displayName;
  final String emoji;
}

/// Story Chapter Entity
class StoryChapter extends Equatable {
  const StoryChapter({
    required this.id,
    required this.title,
    required this.content,
    required this.order,
    this.illustrationUrl,
  });

  final String id;
  final String title;
  final String content;
  final int order;
  final String? illustrationUrl;

  StoryChapter copyWith({
    String? id,
    String? title,
    String? content,
    int? order,
    String? illustrationUrl,
  }) {
    return StoryChapter(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      order: order ?? this.order,
      illustrationUrl: illustrationUrl ?? this.illustrationUrl,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'order': order,
      'illustrationUrl': illustrationUrl,
    };
  }

  factory StoryChapter.fromJson(Map<String, dynamic> json) {
    return StoryChapter(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      order: json['order'] ?? 0,
      illustrationUrl: json['illustrationUrl'],
    );
  }

  @override
  List<Object?> get props => [id, title, content, order, illustrationUrl];
}

/// Story Illustration Entity
class StoryIllustration extends Equatable {
  const StoryIllustration({
    required this.id,
    required this.url,
    required this.description,
    this.chapterId,
    this.order = 0,
  });

  final String id;
  final String url;
  final String description;
  final String? chapterId;
  final int order;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'url': url,
      'description': description,
      'chapterId': chapterId,
      'order': order,
    };
  }

  factory StoryIllustration.fromJson(Map<String, dynamic> json) {
    return StoryIllustration(
      id: json['id'] ?? '',
      url: json['url'] ?? '',
      description: json['description'] ?? '',
      chapterId: json['chapterId'],
      order: json['order'] ?? 0,
    );
  }

  @override
  List<Object?> get props => [id, url, description, chapterId, order];
}