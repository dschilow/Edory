// lib/core/services/story_generation_service.dart
import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import '../../features/characters/domain/entities/character.dart';
import '../../features/characters/domain/entities/character_traits.dart';
import '../../features/stories/domain/entities/story.dart';
import '../constants/api_constants.dart';

/// Professioneller Story Generation Service für Avatales
/// Integriert OpenAI API und lokale Fallback-Stories
class StoryGenerationService {
  static final StoryGenerationService _instance = StoryGenerationService._internal();
  factory StoryGenerationService() => _instance;
  StoryGenerationService._internal();

  final Dio _dio = Dio();
  static const String _openAiApiKey = String.fromEnvironment(
    'OPENAI_API_KEY',
    defaultValue: '', // Wird durch Mock ersetzt wenn leer
  );

  /// Haupt-Methode für Story Generation
  Future<Story> generateStory({
    required Character character,
    required StoryGenerationRequest request,
  }) async {
    try {
      // Versuche zuerst AI Generation
      if (_openAiApiKey.isNotEmpty) {
        final aiStory = await _generateWithAI(character, request);
        if (aiStory != null) {
          return aiStory;
        }
      }
      
      // Fallback auf lokale Story Generation
      return await _generateMockStory(character, request);
    } catch (e) {
      debugPrint('Story Generation Error: $e');
      // Fallback auf Mock Story
      return await _generateMockStory(character, request);
    }
  }

  /// OpenAI API Integration
  Future<Story?> _generateWithAI(Character character, StoryGenerationRequest request) async {
    try {
      final prompt = _buildPrompt(character, request);
      
      final response = await _dio.post(
        'https://api.openai.com/v1/chat/completions',
        options: Options(
          headers: {
            'Authorization': 'Bearer $_openAiApiKey',
            'Content-Type': 'application/json',
          },
        ),
        data: {
          'model': 'gpt-4o-mini',
          'messages': [
            {
              'role': 'system',
              'content': _getSystemPrompt(),
            },
            {
              'role': 'user',
              'content': prompt,
            }
          ],
          'max_tokens': _getMaxTokens(request.length),
          'temperature': 0.8,
          'presence_penalty': 0.2,
          'frequency_penalty': 0.1,
        },
      );

      final content = response.data['choices'][0]['message']['content'];
      final storyData = _parseAIResponse(content);
      
      return Story(
        id: _generateId(),
        title: storyData['title'] ?? _generateTitle(character, request),
        content: storyData['content'] ?? content,
        characterId: character.id,
        characterName: character.displayName,
        genre: request.genre,
        targetAge: request.targetAge,
        length: request.length,
        createdAt: DateTime.now(),
        isAiGenerated: true,
        learningObjectives: request.learningObjectives,
        mood: request.mood,
        setting: request.setting,
        tokensUsed: response.data['usage']['total_tokens'],
        estimatedReadingTime: _calculateReadingTime(content),
      );
    } catch (e) {
      debugPrint('AI Generation Error: $e');
      return null;
    }
  }

  /// Lokale Mock Story Generation
  Future<Story> _generateMockStory(Character character, StoryGenerationRequest request) async {
    // Simuliere API Delay
    await Future.delayed(Duration(milliseconds: 1500 + Random().nextInt(1500)));
    
    final templates = _getStoryTemplates(request.genre);
    final template = templates[Random().nextInt(templates.length)];
    
    final personalizedContent = _personalizeStory(
      template: template,
      character: character,
      request: request,
    );

    return Story(
      id: _generateId(),
      title: _generateTitle(character, request),
      content: personalizedContent,
      characterId: character.id,
      characterName: character.displayName,
      genre: request.genre,
      targetAge: request.targetAge,
      length: request.length,
      createdAt: DateTime.now(),
      isAiGenerated: false,
      learningObjectives: request.learningObjectives,
      mood: request.mood,
      setting: request.setting,
      tokensUsed: 0,
      estimatedReadingTime: _calculateReadingTime(personalizedContent),
    );
  }

  /// System Prompt für OpenAI
  String _getSystemPrompt() {
    return '''Du bist ein kreativer Geschichtenerzähler für Kinder. 
Erstelle magische, lehrreiche und altersgerechte Geschichten.

REGELN:
- Verwende einfache, verständliche Sprache
- Integriere positive Werte und Lektionen
- Beschreibe Charaktere lebendig und sympathisch
- Baue Spannung auf, aber ohne Angst zu machen
- Verwende viel wörtliche Rede
- Gestalte ein zufriedenstellendes Ende
- Integriere die Charaktereigenschaften natürlich

FORMAT:
{
  "title": "Kreativer Titel",
  "content": "Die vollständige Geschichte in Kapiteln..."
}

Schreibe auf Deutsch und altersgerecht.''';
  }

  /// Prompt für spezifische Story
  String _buildPrompt(Character character, StoryGenerationRequest request) {
    final traitsDescription = _describeTraits(character.traits);
    
    return '''
Erstelle eine ${request.length.displayName.toLowerCase()} Geschichte für ein ${request.targetAge}-jähriges Kind.

CHARAKTER:
- Name: ${character.displayName}
- Beschreibung: ${character.description}
- Eigenschaften: $traitsDescription

STORY-DETAILS:
- Genre: ${request.genre}
- Stimmung: ${request.mood ?? 'abenteuerlich'}
- Schauplatz: ${request.setting ?? 'magische Welt'}
- Prompt: ${request.prompt}

LERNZIELE:
${request.learningObjectives.map((goal) => '- $goal').join('\n')}

Integriere die Charaktereigenschaften natürlich in die Handlung.
${_getLengthGuideline(request.length)}
    ''';
  }

  /// Mock Story Templates basierend auf Genre
  List<String> _getStoryTemplates(String genre) {
    switch (genre.toLowerCase()) {
      case 'abenteuer':
        return [
          '''[CHARAKTER] entdeckte einen geheimnisvollen Pfad im verzauberten Wald. Mit [TRAIT_PRIMARY] im Herzen folgte [PRONOUN] dem glitzernden Weg, der zu einem versteckten Tal führte.

Dort wartete ein kleiner [MAGICAL_CREATURE], der [POSSESSIVE] Hilfe brauchte. "[CHARACTER], kannst du mir helfen, meine Familie zu finden?", fragte [CREATURE_PRONOUN] mit großen, hoffnungsvollen Augen.

[CHARAKTER] zeigte [TRAIT_SECONDARY] und sagte: "Natürlich helfe ich dir! Zusammen schaffen wir das."

Sie machten sich auf eine aufregende Reise durch magische Landschaften. [CHARAKTER] nutzte [POSSESSIVE] [TRAIT_TERTIARY], um kluge Lösungen für jedes Hindernis zu finden.

Am Ende fanden sie nicht nur die Familie des kleinen Wesens, sondern [CHARAKTER] hatte auch gelernt, dass [LEARNING_OBJECTIVE].

"Danke, [CHARACTER]!", rief die ganze [CREATURE_FAMILY]. "Du bist ein wahrer Freund!"

Mit einem warmen Gefühl im Herzen kehrte [CHARAKTER] nach Hause zurück, bereit für das nächste Abenteuer.''',
          
          '''Es war ein besonderer Tag für [CHARAKTER]. [PRONOUN] hatte von einem magischen [MAGICAL_OBJECT] gehört, das in der [MYSTICAL_LOCATION] versteckt war.

Mit [TRAIT_PRIMARY] und [TRAIT_SECONDARY] ausgerüstet, begann [CHARAKTER] die aufregende Suche. Der Weg war voller Überraschungen und freundlicher Kreaturen.

Ein weiser [GUIDE_CHARACTER] gab [CHARAKTER] einen wichtigen Rat: "[ADVICE_TEXT]"

[CHARAKTER] folgte dem Rat und entdeckte dabei [POSSESSIVE] eigene [TRAIT_TERTIARY]. Jede Herausforderung wurde zu einer Chance, zu wachsen und zu lernen.

Schließlich fand [CHARAKTER] das [MAGICAL_OBJECT], aber das wahre Geschenk war die Erkenntnis: [LEARNING_OBJECTIVE].

Mit neuer Weisheit und [TRAIT_PRIMARY] kehrte [CHARAKTER] heim, voller Geschichten und wertvoller Lektionen.'''
        ];
        
      case 'freundschaft':
        return [
          '''[CHARAKTER] war neu in der magischen Schule und fühlte sich etwas einsam. [PRONOUN] wünschte sich sehnlichst einen guten Freund.

In der Pause sah [CHARAKTER] [FRIEND_CHARACTER], der/die ganz alleine saß. Mit [TRAIT_PRIMARY] ging [CHARAKTER] hinüber und sagte: "Hallo! Ich bin [CHARACTER]. Möchtest du mit mir spielen?"

[FRIEND_CHARACTER] lächelte schüchtern. "Ich bin [FRIEND_NAME]. Ich würde gerne, aber ich bin nicht sehr gut in Spielen."

"Das macht nichts!", antwortete [CHARAKTER] mit [TRAIT_SECONDARY]. "Wir können zusammen lernen und uns gegenseitig helfen!"

Sie verbrachten den Tag damit, sich kennenzulernen und verschiedene Spiele auszuprobieren. [CHARAKTER] zeigte [POSSESSIVE] [TRAIT_TERTIARY], indem [PRONOUN] [FRIEND_CHARACTER] ermutigte.

Bald merkten sie, dass sie viele gemeinsame Interessen hatten. [CHARAKTER] lernte, dass [LEARNING_OBJECTIVE].

Von diesem Tag an waren sie die besten Freunde und erlebten viele wunderbare Abenteuer zusammen.''',
        ];
        
      case 'lernen':
        return [
          '''[CHARAKTER] stand vor einem großen Rätsel in der Bibliothek der Weisheit. Die alten Bücher sprachen in Rätseln, und [PRONOUN] musste [POSSESSIVE] [TRAIT_PRIMARY] nutzen, um sie zu verstehen.

"Wie kann ich nur diese schwierigen Aufgaben lösen?", fragte sich [CHARAKTER]. Doch dann erinnerte [PRONOUN] sich an [POSSESSIVE] [TRAIT_SECONDARY].

[CHARAKTER] begann systematisch zu arbeiten. [PRONOUN] las sorgfältig, stellte Fragen und probierte verschiedene Ansätze aus. Mit [TRAIT_TERTIARY] gab [PRONOUN] nicht auf, auch wenn es schwierig wurde.

Plötzlich öffnete sich eine geheime Tür! [CHARAKTER] hatte das Rätsel gelöst. Dahinter wartete der weise [MENTOR_CHARACTER] mit einem besonderen Geschenk.

"Du hast bewiesen, dass [LEARNING_OBJECTIVE]", sagte [MENTOR_CHARACTER] stolz. "Das ist die wahre Magie des Lernens!"

[CHARAKTER] strahlte vor Freude. [PRONOUN] hatte nicht nur das Rätsel gelöst, sondern auch etwas Wichtiges über sich selbst gelernt.''',
        ];
        
      default:
        return [
          '''[CHARAKTER] erlebte einen magischen Tag voller Überraschungen. Mit [TRAIT_PRIMARY] und [TRAIT_SECONDARY] meisterte [PRONOUN] jede Herausforderung.

Dabei lernte [CHARAKTER], dass [LEARNING_OBJECTIVE]. 

Am Ende des Tages war [CHARAKTER] glücklich und stolz auf das, was [PRONOUN] erreicht hatte.'''
        ];
    }
  }

  /// Personalisiert Story Template
  String _personalizeStory({
    required String template,
    required Character character,
    required StoryGenerationRequest request,
  }) {
    final traits = character.traits;
    final dominantTrait = traits.dominantTrait;
    final secondaryTrait = _getSecondaryTrait(traits);
    final tertiaryTrait = _getTertiaryTrait(traits);
    
    var story = template
        .replaceAll('[CHARAKTER]', character.displayName)
        .replaceAll('[CHARACTER]', character.displayName)
        .replaceAll('[PRONOUN]', _getPronoun(character))
        .replaceAll('[POSSESSIVE]', _getPossessive(character))
        .replaceAll('[TRAIT_PRIMARY]', dominantTrait.toLowerCase())
        .replaceAll('[TRAIT_SECONDARY]', secondaryTrait.toLowerCase())
        .replaceAll('[TRAIT_TERTIARY]', tertiaryTrait.toLowerCase());

    // Genre-spezifische Ersetzungen
    story = _replaceGenreSpecific(story, request.genre);
    
    // Lernziele einbauen
    if (request.learningObjectives.isNotEmpty) {
      final learningGoal = request.learningObjectives.first;
      story = story.replaceAll('[LEARNING_OBJECTIVE]', learningGoal.toLowerCase());
    }
    
    return story;
  }

  /// Genre-spezifische Ersetzungen
  String _replaceGenreSpecific(String story, String genre) {
    final replacements = {
      '[MAGICAL_CREATURE]': _getRandomElement(['Einhorn', 'Drache', 'Fee', 'Kobold', 'Phönix']),
      '[CREATURE_PRONOUN]': _getRandomElement(['es', 'sie', 'er']),
      '[CREATURE_FAMILY]': _getRandomElement(['Drachenfamilie', 'Feenschar', 'Koboldsippe']),
      '[MAGICAL_OBJECT]': _getRandomElement(['Kristall der Weisheit', 'Zauberstab des Mutes', 'Amulett der Freundschaft']),
      '[MYSTICAL_LOCATION]': _getRandomElement(['Kristallhöhle', 'Wolkenschloss', 'Zeitgarten']),
      '[GUIDE_CHARACTER]': _getRandomElement(['Eule', 'alter Zauberer', 'sprechender Baum']),
      '[ADVICE_TEXT]': _getRandomElement([
        'Glaube an dich selbst, dann ist alles möglich',
        'Die größte Magie liegt in der Freundlichkeit',
        'Mut bedeutet nicht, keine Angst zu haben, sondern trotz Angst das Richtige zu tun'
      ]),
      '[FRIEND_CHARACTER]': _getRandomElement(['ein kleines Mädchen', 'ein schüchterner Junge', 'ein magisches Wesen']),
      '[FRIEND_NAME]': _getRandomElement(['Mila', 'Tim', 'Luna', 'Ben', 'Zara']),
      '[MENTOR_CHARACTER]': _getRandomElement(['Bibliotheksgeist', 'weise Schildkröte', 'alte Hexe']),
    };

    replacements.forEach((placeholder, replacement) {
      story = story.replaceAll(placeholder, replacement);
    });

    return story;
  }

  /// Hilfsmethoden für Charaktereigenschaften
  String _describeTraits(CharacterTraits traits) {
    final descriptions = <String>[];
    
    if (traits.courage >= 70) descriptions.add('sehr mutig');
    if (traits.creativity >= 70) descriptions.add('äußerst kreativ');
    if (traits.helpfulness >= 70) descriptions.add('sehr hilfsbereit');
    if (traits.empathy >= 70) descriptions.add('einfühlsam');
    if (traits.wisdom >= 70) descriptions.add('weise');
    if (traits.curiosity >= 70) descriptions.add('neugierig');
    if (traits.humor >= 70) descriptions.add('fröhlich');
    if (traits.persistence >= 70) descriptions.add('ausdauernd');
    if (traits.intelligence >= 70) descriptions.add('intelligent');
    if (traits.kindness >= 70) descriptions.add('freundlich');
    
    if (descriptions.isEmpty) descriptions.add('ausgewogen');
    
    return descriptions.take(3).join(', ');
  }

  String _getSecondaryTrait(CharacterTraits traits) {
    final traitsMap = {
      'Mut': traits.courage,
      'Kreativität': traits.creativity,
      'Hilfsbereitschaft': traits.helpfulness,
      'Humor': traits.humor,
      'Weisheit': traits.wisdom,
      'Neugier': traits.curiosity,
      'Empathie': traits.empathy,
      'Ausdauer': traits.persistence,
      'Intelligenz': traits.intelligence,
      'Freundlichkeit': traits.kindness,
    };
    
    final sorted = traitsMap.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    return sorted.length > 1 ? sorted[1].key : sorted[0].key;
  }

  String _getTertiaryTrait(CharacterTraits traits) {
    final traitsMap = {
      'Mut': traits.courage,
      'Kreativität': traits.creativity,
      'Hilfsbereitschaft': traits.helpfulness,
      'Humor': traits.humor,
      'Weisheit': traits.wisdom,
      'Neugier': traits.curiosity,
      'Empathie': traits.empathy,
      'Ausdauer': traits.persistence,
      'Intelligenz': traits.intelligence,
      'Freundlichkeit': traits.kindness,
    };
    
    final sorted = traitsMap.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    return sorted.length > 2 ? sorted[2].key : sorted[0].key;
  }

  /// Utility Methods
  String _generateId() => DateTime.now().millisecondsSinceEpoch.toString();
  
  String _generateTitle(Character character, StoryGenerationRequest request) {
    final titles = {
      'abenteuer': [
        '${character.displayName}s großes Abenteuer',
        'Die magische Reise von ${character.displayName}',
        '${character.displayName} und das Geheimnis des verzauberten Waldes',
      ],
      'freundschaft': [
        '${character.displayName} findet einen Freund',
        'Die wunderbare Freundschaft von ${character.displayName}',
        '${character.displayName} und die Kraft der Freundschaft',
      ],
      'lernen': [
        '${character.displayName} und das Rätsel der Weisheit',
        'Wie ${character.displayName} das Unmögliche lernte',
        '${character.displayName}s Entdeckungsreise',
      ],
    };
    
    final genreTitles = titles[request.genre.toLowerCase()] ?? titles['abenteuer']!;
    return genreTitles[Random().nextInt(genreTitles.length)];
  }

  int _calculateReadingTime(String content) {
    const wordsPerMinute = 150; // Durchschnittliche Lesegeschwindigkeit für Kinder
    final wordCount = content.split(' ').length;
    return (wordCount / wordsPerMinute).ceil();
  }

  Map<String, dynamic> _parseAIResponse(String content) {
    try {
      return json.decode(content);
    } catch (e) {
      return {'content': content};
    }
  }

  int _getMaxTokens(StoryLength length) {
    switch (length) {
      case StoryLength.short:
        return 800;
      case StoryLength.medium:
        return 1500;
      case StoryLength.long:
        return 2500;
    }
  }

  String _getLengthGuideline(StoryLength length) {
    switch (length) {
      case StoryLength.short:
        return 'Schreibe eine kurze Geschichte (400-600 Wörter).';
      case StoryLength.medium:
        return 'Schreibe eine mittellange Geschichte (800-1200 Wörter).';
      case StoryLength.long:
        return 'Schreibe eine längere Geschichte (1500-2000 Wörter).';
    }
  }

  String _getPronoun(Character character) => 'sie'; // Vereinfacht für Demo
  String _getPossessive(Character character) => 'ihre'; // Vereinfacht für Demo
  
  String _getRandomElement(List<String> elements) {
    return elements[Random().nextInt(elements.length)];
  }
}

/// Story Generation Request Model
class StoryGenerationRequest {
  const StoryGenerationRequest({
    required this.prompt,
    required this.genre,
    required this.length,
    required this.targetAge,
    this.mood,
    this.setting,
    this.learningObjectives = const [],
  });

  final String prompt;
  final String genre;
  final StoryLength length;
  final int targetAge;
  final String? mood;
  final String? setting;
  final List<String> learningObjectives;
}

