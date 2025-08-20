import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Professional OpenAI Service - KORREKT FUNKTIONIEREND
/// Generiert ECHTE Geschichten mit GPT-4o-mini
class OpenAIService {
  static const String _baseUrl = 'https://api.openai.com/v1';
  
  // WICHTIG: Ihr echter API Key hier einfügen!
  static const String _apiKey = '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';
  
  final Dio _dio;
  bool _isApiKeyValid = false;

  OpenAIService() : _dio = Dio() {
    _dio.options = BaseOptions(
      baseUrl: _baseUrl,
      headers: {
        'Authorization': 'Bearer $_apiKey',
        'Content-Type': 'application/json',
        'User-Agent': 'Edory-StoryWeaver/1.0',
      },
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(minutes: 2),
      sendTimeout: const Duration(seconds: 30),
    );
    
    // Logging für Debugging
    if (kDebugMode) {
      _dio.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
        error: true,
      ));
    }
    
    _validateApiKey();
  }

  /// Validiert den API Key beim Start
  Future<void> _validateApiKey() async {
    try {
      final response = await _dio.get('/models');
      _isApiKeyValid = response.statusCode == 200;
      if (kDebugMode) {
        print('✅ OpenAI API Key ist gültig!');
      }
    } catch (e) {
      _isApiKeyValid = false;
      if (kDebugMode) {
        print('❌ OpenAI API Key ungültig: $e');
      }
    }
  }

  /// Generiert ECHTE KI-Geschichten mit korrekter OpenAI API
  Future<StoryGenerationResult> generateStory({
    required String characterName,
    required String characterDescription,
    required String characterPersonality,
    required String prompt,
    required int targetAge,
    required String genre,
    required StoryLength length,
    required StoryComplexity complexity,
    required List<String> learningObjectives,
    List<String> characterMemories = const [],
    String? mood,
    String? setting,
    bool includeEducationalElements = true,
    bool includeMoralLesson = true,
  }) async {
    if (!_isApiKeyValid || _apiKey.isEmpty || _apiKey == 'YOUR_API_KEY_HERE') {
      return _generateFallbackStory(
        characterName: characterName,
        prompt: prompt,
        genre: genre,
        length: length,
      );
    }

    try {
      final systemPrompt = _buildAdvancedSystemPrompt(
        targetAge: targetAge,
        genre: genre,
        length: length,
        complexity: complexity,
        learningObjectives: learningObjectives,
        includeEducationalElements: includeEducationalElements,
        includeMoralLesson: includeMoralLesson,
      );
      
      final userPrompt = _buildAdvancedUserPrompt(
        characterName: characterName,
        characterDescription: characterDescription,
        characterPersonality: characterPersonality,
        prompt: prompt,
        characterMemories: characterMemories,
        mood: mood,
        setting: setting,
      );

      if (kDebugMode) {
        print('🤖 Sende Request an OpenAI /chat/completions...');
        print('Model: gpt-4o-mini');
        print('Max Tokens: ${_getMaxTokensForLength(length)}');
        print('System Prompt: ${systemPrompt.substring(0, 100)}...');
        print('User Prompt: ${userPrompt.substring(0, 100)}...');
      }

      // ✅ KORREKTER OpenAI API Aufruf
      final response = await _dio.post(
        '/chat/completions',  // ✅ Richtiger Endpoint
        data: {
          'model': 'gpt-4o-mini',  // ✅ Existierendes Model
          'messages': [  // ✅ Korrekte Struktur
            {
              'role': 'system',
              'content': systemPrompt,
            },
            {
              'role': 'user', 
              'content': userPrompt,
            }
          ],
          'max_tokens': _getMaxTokensForLength(length),
          'temperature': _getTemperatureForComplexity(complexity),
          'top_p': 0.9,
          'frequency_penalty': 0.1,
          'presence_penalty': 0.1,
        },
      );

      // ✅ Korrekte Response-Behandlung für Chat Completions
      final responseData = response.data;
      String content = '';
      int tokensUsed = 0;

      if (kDebugMode) {
        print('📝 Response Status: ${response.statusCode}');
        print('📄 Response Keys: ${responseData.keys}');
      }

      // Standard OpenAI Chat Completions Response Structure
      if (responseData['choices'] != null && 
          responseData['choices'].isNotEmpty &&
          responseData['choices'][0]['message'] != null &&
          responseData['choices'][0]['message']['content'] != null) {
        
        content = responseData['choices'][0]['message']['content'] as String;
        
        // Token-Verbrauch extrahieren
        if (responseData['usage'] != null && responseData['usage']['total_tokens'] != null) {
          tokensUsed = responseData['usage']['total_tokens'] as int;
        }
        
        if (kDebugMode) {
          print('✅ Geschichte erfolgreich generiert!');
          print('Tokens verwendet: $tokensUsed');
          print('Geschichtenlänge: ${content.length} Zeichen');
          print('Content Preview: ${content.substring(0, 200)}...');
        }

        return StoryGenerationResult(
          content: content.trim(),
          isAiGenerated: true,
          tokensUsed: tokensUsed,
          model: 'gpt-4o-mini',
          generatedAt: DateTime.now(),
          settings: StorySettings(
            characterName: characterName,
            genre: genre,
            length: length,
            complexity: complexity,
            targetAge: targetAge,
            learningObjectives: learningObjectives,
          ),
        );
      } else {
        throw Exception('Unerwartete Response-Struktur von OpenAI API: ${responseData.keys}');
      }

    } on DioException catch (e) {
      if (kDebugMode) {
        print('❌ OpenAI API Fehler: ${e.message}');
        print('Response Status: ${e.response?.statusCode}');
        print('Response Data: ${e.response?.data}');
        print('Request Data: ${e.requestOptions.data}');
      }
      
      // Spezielle Fehlerbehandlung
      if (e.response?.statusCode == 400) {
        if (kDebugMode) {
          print('🔍 400 Bad Request - Prüfe Request-Format');
        }
        return _generateFallbackStory(
          characterName: characterName,
          prompt: prompt,
          genre: genre,
          length: length,
          error: 'API Request-Fehler (400): Ungültiges Request-Format',
        );
      }
      
      if (e.response?.statusCode == 401) {
        if (kDebugMode) {
          print('🔑 401 Unauthorized - API Key ungültig');
        }
        return _generateFallbackStory(
          characterName: characterName,
          prompt: prompt,
          genre: genre,
          length: length,
          error: 'API Key ungültig (401): Bitte korrekten OpenAI API Key eintragen',
        );
      }
      
      if (e.response?.statusCode == 429) {
        if (kDebugMode) {
          print('⚠️ 429 Rate Limit erreicht - verwende erweiterte Fallback-Story');
        }
        return _generateEnhancedFallbackStory(
          characterName: characterName,
          characterDescription: characterDescription,
          characterPersonality: characterPersonality,
          prompt: prompt,
          genre: genre,
          length: length,
          targetAge: targetAge,
          learningObjectives: learningObjectives,
          mood: mood,
          setting: setting,
        );
      }
      
      // Bei anderen API-Fehlern: Standard-Fallback
      return _generateFallbackStory(
        characterName: characterName,
        prompt: prompt,
        genre: genre,
        length: length,
        error: 'API Fehler (${e.response?.statusCode}): ${e.message}',
      );
    } catch (e) {
      if (kDebugMode) {
        print('❌ Unbekannter Fehler: $e');
      }
      
      return _generateFallbackStory(
        characterName: characterName,
        prompt: prompt,
        genre: genre,
        length: length,
        error: 'Unbekannter Fehler: $e',
      );
    }
  }

  /// Erweiterte System-Prompt für bessere Geschichten
  String _buildAdvancedSystemPrompt({
    required int targetAge,
    required String genre,
    required StoryLength length,
    required StoryComplexity complexity,
    required List<String> learningObjectives,
    required bool includeEducationalElements,
    required bool includeMoralLesson,
  }) {
    final lengthInstruction = _getLengthInstruction(length);
    final complexityInstruction = _getComplexityInstruction(complexity, targetAge);
    final learningInstruction = learningObjectives.isNotEmpty 
        ? 'Integriere folgende Lernziele natürlich in die Geschichte: ${learningObjectives.join(", ")}'
        : '';
    
    return '''Du bist ein professioneller Kinderbuchautor und Pädagoge. Schreibe eine fesselnde, altersgerechte Geschichte auf Deutsch.

ZIELGRUPPE: Kinder im Alter von $targetAge Jahren
GENRE: $genre
LÄNGE: $lengthInstruction
KOMPLEXITÄT: $complexityInstruction

ANFORDERUNGEN:
- Verwende altersgerechte Sprache und Konzepte
- Erschaffe lebendige, interessante Charaktere
- Baue Spannung und emotionale Momente ein
- Verwende beschreibende Sprache für Atmosphäre
- ${includeEducationalElements ? 'Integriere pädagogische Elemente natürlich' : 'Fokussiere auf Unterhaltung'}
- ${includeMoralLesson ? 'Vermittle eine positive Lektion oder Werte' : 'Keine explizite Moral nötig'}
- $learningInstruction

STIL:
- Lebendige Beschreibungen von Orten und Charakteren
- Direkte Rede für Dialoge
- Emotionale Tiefe angemessen für das Alter
- Spannungsaufbau mit befriedigender Auflösung
- Positive, hoffnungsvolle Grundstimmung

Die Geschichte soll vollständig, in sich geschlossen und komplett auf Deutsch sein.''';
  }

  /// Erweiterte User-Prompt mit Charakter-Memory
  String _buildAdvancedUserPrompt({
    required String characterName,
    required String characterDescription,
    required String characterPersonality,
    required String prompt,
    required List<String> characterMemories,
    String? mood,
    String? setting,
  }) {
    String memoryContext = '';
    if (characterMemories.isNotEmpty) {
      memoryContext = '''
CHARAKTER-ERINNERUNGEN:
${characterMemories.take(3).map((memory) => '- $memory').join('\n')}
(Beziehe dich subtil auf diese vergangenen Erlebnisse)
''';
    }

    String contextualInfo = '';
    if (mood != null || setting != null) {
      contextualInfo = '''
ZUSÄTZLICHER KONTEXT:
${mood != null ? '- Stimmung: $mood' : ''}
${setting != null ? '- Schauplatz: $setting' : ''}
''';
    }

    return '''HAUPTCHARAKTER:
Name: $characterName
Beschreibung: $characterDescription
Persönlichkeit: $characterPersonality

$memoryContext

$contextualInfo

STORY-PROMPT:
$prompt

Schreibe eine vollständige Geschichte mit diesem Charakter als Protagonist. Die Geschichte sollte den Prompt als Ausgangspunkt nutzen und die Persönlichkeit des Charakters zum Leben erwecken.''';
  }

  /// Erweiterte Fallback-Story bei Rate Limiting (realistische Geschichten)
  StoryGenerationResult _generateEnhancedFallbackStory({
    required String characterName,
    required String characterDescription,
    required String characterPersonality,
    required String prompt,
    required String genre,
    required StoryLength length,
    required int targetAge,
    required List<String> learningObjectives,
    String? mood,
    String? setting,
  }) {
    final storyContent = _buildEnhancedStory(
      characterName: characterName,
      characterDescription: characterDescription,
      characterPersonality: characterPersonality,
      prompt: prompt,
      genre: genre,
      length: length,
      targetAge: targetAge,
      learningObjectives: learningObjectives,
      mood: mood,
      setting: setting,
    );

    return StoryGenerationResult(
      content: storyContent,
      isAiGenerated: false,
      tokensUsed: 0,
      model: 'Enhanced-Fallback',
      generatedAt: DateTime.now(),
      settings: StorySettings(
        characterName: characterName,
        genre: genre,
        length: length,
        complexity: StoryComplexity.medium,
        targetAge: targetAge,
        learningObjectives: learningObjectives,
      ),
    );
  }

  /// Fallback-Story Generator (wenn API nicht funktioniert)
  StoryGenerationResult _generateFallbackStory({
    required String characterName,
    required String prompt,
    required String genre,
    required StoryLength length,
    String? error,
  }) {
    final storyLength = _getFallbackStoryLength(length);
    
    final story = '''🌟 Das Abenteuer von $characterName

$characterName war schon immer ein besonderer Charakter. An diesem besonderen Tag sollte ein aufregendes Abenteuer beginnen.

$prompt

Als $characterName sich auf den Weg machte, spürte er eine Mischung aus Aufregung und Nervosität. Die Welt um ihn herum war voller Möglichkeiten und Geheimnisse, die darauf warteten, entdeckt zu werden.

${_generateFallbackContent(genre, storyLength, characterName)}

Am Ende des Tages hatte $characterName nicht nur ein großartiges Abenteuer erlebt, sondern auch wichtige Lektionen über Mut, Freundschaft und das Vertrauen in die eigenen Fähigkeiten gelernt.

Die Sterne funkelten hell am Himmel, als $characterName zufrieden nach Hause zurückkehrte, bereits gespannt auf das nächste Abenteuer.

---
${error != null ? '⚠️ HINWEIS: $error' : '⚠️ HINWEIS: Diese Geschichte wurde mit Fallback-Daten erstellt.'}
🔧 Für echte KI-Geschichten: OpenAI API Key konfigurieren
🎯 Genre: $genre | Länge: ${length.name}''';

    return StoryGenerationResult(
      content: story,
      isAiGenerated: false,
      tokensUsed: 0,
      model: 'Fallback',
      generatedAt: DateTime.now(),
      settings: StorySettings(
        characterName: characterName,
        genre: genre,
        length: length,
        complexity: StoryComplexity.medium,
        targetAge: 8,
        learningObjectives: [],
      ),
    );
  }

  String _generateFallbackContent(String genre, int targetLength, String characterName) {
    final contentMap = {
      'Abenteuer': 'Mutig erkundete $characterName unbekannte Gebiete, überwand Hindernisse und entdeckte verborgene Schätze.',
      'Fantasy': 'In einer magischen Welt voller Wunder und mystischer Kreaturen erlebte $characterName außergewöhnliche Ereignisse.',
      'Märchen': 'Wie in den schönsten Märchen begegnete $characterName sprechenden Tieren und erlebte zauberhafte Momente.',
      'Freundschaft': 'Durch Zusammenarbeit und gegenseitiges Vertrauen entstanden wunderbare Freundschaften.',
      'Familie': 'Die Kraft der Familie und Zusammengehörigkeit spielte eine wichtige Rolle in diesem besonderen Erlebnis.',
    };
    
    String baseContent = contentMap[genre] ?? 'Es war ein aufregendes Erlebnis voller Überraschungen und wertvoller Lektionen.';
    
    // Erweitere den Inhalt basierend auf gewünschter Länge
    if (targetLength > 300) {
      baseContent += '\n\nAuf dem Weg traf $characterName interessante Charaktere, die ihm halfen und ihn herausforderten. Jede Begegnung brachte neue Erkenntnisse und stärkte seinen Charakter.';
    }
    
    if (targetLength > 600) {
      baseContent += '\n\nDie Herausforderungen wurden größer, aber auch die Belohnungen. $characterName lernte, dass wahre Stärke von innen kommt und dass Mut nicht bedeutet, keine Angst zu haben, sondern trotz der Angst das Richtige zu tun.';
    }
    
    return baseContent;
  }

  /// Erstellt eine erweiterte, realistische Story mit allen Details
  String _buildEnhancedStory({
    required String characterName,
    required String characterDescription,
    required String characterPersonality,
    required String prompt,
    required String genre,
    required StoryLength length,
    required int targetAge,
    required List<String> learningObjectives,
    String? mood,
    String? setting,
  }) {
    final settingText = setting ?? _getGenreDefaultSetting(genre);
    final moodText = mood ?? 'aufregend';
    final ageAppropriate = _getAgeAppropriateElements(targetAge);
    final learningText = learningObjectives.isNotEmpty 
        ? learningObjectives.take(2).join(' und ')
        : 'Mut und Freundschaft';

    final storyParts = [
      '# $characterName: $prompt',
      '',
      _buildStoryOpening(characterName, characterDescription, settingText, moodText),
      '',
      _buildStoryMiddle(characterName, characterPersonality, genre, prompt, learningText, ageAppropriate),
      '',
      _buildStoryEnding(characterName, learningObjectives, targetAge),
      '',
      '---',
      '📚 **Lernziele erreicht:** $learningText',
      '🎯 **Genre:** $genre | **Altersgruppe:** $targetAge Jahre',
      '⚡ **Hinweis:** Offline-Story wegen API-Limit. Für KI-Geschichten: Später erneut versuchen.',
    ];

    return storyParts.join('\n');
  }

  String _buildStoryOpening(String characterName, String description, String setting, String mood) {
    return '''$characterName, $description, befand sich an diesem $mood Tag in $setting. 

Die Luft war erfüllt von Spannung und Möglichkeiten. $characterName spürte, dass heute etwas Besonderes geschehen würde - ein Abenteuer, das alles verändern könnte.''';
  }

  String _buildStoryMiddle(String characterName, String personality, String genre, String prompt, String learningText, String ageElements) {
    final genreAction = _getGenreAction(genre, characterName);
    return '''Plötzlich geschah genau das, was der Ausgangspunkt der Geschichte war: $prompt

Mit ${personality.toLowerCase()} ging $characterName der Sache auf den Grund. $genreAction 

Dabei lernte $characterName wichtige Lektionen über $learningText. $ageElements

Durch Mut, Kreativität und die Hilfe neuer Freunde gelang es $characterName, alle Herausforderungen zu meistern.''';
  }

  String _buildStoryEnding(String characterName, List<String> learningObjectives, int targetAge) {
    return '''Als die Sonne unterging, blickte $characterName zufrieden auf das Erlebte zurück. 

Nicht nur hatte sich ein großartiges Abenteuer ereignet, sondern $characterName war auch persönlich gewachsen und hatte wertvolle Erfahrungen gesammelt.

Mit einem Lächeln und voller Vorfreude auf kommende Abenteuer kehrte $characterName nach Hause zurück, bereit für das nächste große Erlebnis.''';
  }

  String _getGenreDefaultSetting(String genre) {
    final settings = {
      'Abenteuer': 'einem wilden, unbekannten Wald',
      'Fantasy': 'einem magischen Königreich voller Wunder',
      'Märchen': 'einem verzauberten Schloss',
      'Freundschaft': 'einer lebendigen, bunten Nachbarschaft',
      'Familie': 'dem warmen, gemütlichen Zuhause',
      'Tiere': 'einer wunderschönen Tierwelt',
      'Weltraum': 'einer fernen Galaxie voller Sterne',
      'Unterwasser': 'den geheimnisvollen Tiefen des Ozeans',
    };
    return settings[genre] ?? 'einer wunderschönen, fantastischen Welt';
  }

  String _getGenreAction(String genre, String characterName) {
    final actions = {
      'Abenteuer': 'Mutig erforschte $characterName verborgene Pfade und überwand gefährliche Hindernisse.',
      'Fantasy': 'Mit Hilfe magischer Kräfte und alter Weisheiten meisterte $characterName die Herausforderung.',
      'Märchen': 'Wie in den besten Märchen half $characterName anderen und wurde dafür belohnt.',
      'Freundschaft': 'Gemeinsam mit treuen Freunden löste $characterName das Problem durch Zusammenarbeit.',
      'Familie': 'Mit der Unterstützung der liebevollen Familie fand $characterName einen Weg.',
    };
    return actions[genre] ?? 'Mit Entschlossenheit und klugen Entscheidungen bewältigte $characterName die Situation.';
  }

  String _getAgeAppropriateElements(int age) {
    if (age <= 6) {
      return 'Dabei gab es viele bunte Farben zu sehen und lustige Geräusche zu hören.';
    } else if (age <= 10) {
      return 'Unterwegs gab es knifflige Rätsel zu lösen und spannende Entdeckungen zu machen.';
    } else {
      return 'Die Herausforderungen erforderten strategisches Denken und emotionale Reife.';
    }
  }

  // Hilfsmethoden
  int _getMaxTokensForLength(StoryLength length) {
    switch (length) {
      case StoryLength.short:
        return 500;
      case StoryLength.medium:
        return 1000;
      case StoryLength.long:
        return 1500;
      case StoryLength.extraLong:
        return 2000;
    }
  }

  double _getTemperatureForComplexity(StoryComplexity complexity) {
    switch (complexity) {
      case StoryComplexity.simple:
        return 0.7;
      case StoryComplexity.medium:
        return 0.8;
      case StoryComplexity.complex:
        return 0.9;
    }
  }

  String _getLengthInstruction(StoryLength length) {
    switch (length) {
      case StoryLength.short:
        return 'Kurze Geschichte (300-500 Wörter)';
      case StoryLength.medium:
        return 'Mittlere Geschichte (600-900 Wörter)';
      case StoryLength.long:
        return 'Lange Geschichte (1000-1300 Wörter)';
      case StoryLength.extraLong:
        return 'Sehr lange Geschichte (1400+ Wörter)';
    }
  }

  String _getComplexityInstruction(StoryComplexity complexity, int age) {
    switch (complexity) {
      case StoryComplexity.simple:
        return 'Einfache Sprache, direkte Handlung, wenige Charaktere';
      case StoryComplexity.medium:
        return 'Ausgewogene Komplexität mit Unterplots und Charakterentwicklung';
      case StoryComplexity.complex:
        return 'Vielschichtige Handlung mit mehreren Handlungssträngen und tieferer Charakterentwicklung';
    }
  }

  int _getFallbackStoryLength(StoryLength length) {
    switch (length) {
      case StoryLength.short:
        return 300;
      case StoryLength.medium:
        return 600;
      case StoryLength.long:
        return 900;
      case StoryLength.extraLong:
        return 1200;
    }
  }
}

/// Story Length Enum - Detaillierte Längenoptionen
enum StoryLength {
  short('Kurz'),
  medium('Mittel'),
  long('Lang'),
  extraLong('Sehr Lang');

  const StoryLength(this.displayName);
  final String displayName;
}

/// Story Complexity Enum - Komplexitätsstufen
enum StoryComplexity {
  simple('Einfach'),
  medium('Mittel'),
  complex('Komplex');

  const StoryComplexity(this.displayName);
  final String displayName;
}

/// Story Generation Result - Detaillierte Ergebnisse
class StoryGenerationResult {
  final String content;
  final bool isAiGenerated;
  final int tokensUsed;
  final String model;
  final DateTime generatedAt;
  final StorySettings settings;

  StoryGenerationResult({
    required this.content,
    required this.isAiGenerated,
    required this.tokensUsed,
    required this.model,
    required this.generatedAt,
    required this.settings,
  });
}

/// Story Settings - Einstellungen für Geschichtenerstellung
class StorySettings {
  final String characterName;
  final String genre;
  final StoryLength length;
  final StoryComplexity complexity;
  final int targetAge;
  final List<String> learningObjectives;

  StorySettings({
    required this.characterName,
    required this.genre,
    required this.length,
    required this.complexity,
    required this.targetAge,
    required this.learningObjectives,
  });
}