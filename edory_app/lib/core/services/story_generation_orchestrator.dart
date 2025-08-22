// lib/core/services/story_generation_orchestrator.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'runware_service.dart';

/// Orchestriert komplette KI-gestützte Geschichtenerstellung
/// ChatGPT für Text + Runware für Bilder + Memory-Updates
class StoryGenerationOrchestrator {
  final OpenAIService _openAIService;
  final RunwareService _runwareService;
  final CharacterMemoryService _memoryService;

  StoryGenerationOrchestrator({
    required OpenAIService openAIService,
    required RunwareService runwareService,
    required CharacterMemoryService memoryService,
  }) : _openAIService = openAIService,
       _runwareService = runwareService,
       _memoryService = memoryService;

  /// Kompletter Workflow: Story → Bilder → Memory
  Future<CompleteStoryResult> generateCompleteStory(
    StoryGenerationRequest request,
  ) async {
    try {
      // SCHRITT 1: ChatGPT - Geschichte mit Szenen generieren
      final storyResponse = await _generateStoryWithScenes(request);
      
      // SCHRITT 2: Runware - Bilder parallel generieren
      final imageResults = await _runwareService.generateStoryImages(
        scenes: storyResponse.scenes,
        characterName: request.characterName,
      );
      
      // SCHRITT 3: Bilder zu Szenen zuordnen
      for (int i = 0; i < storyResponse.scenes.length && i < imageResults.length; i++) {
        storyResponse.scenes[i].imageUrl = imageResults[i].url;
        storyResponse.scenes[i].thumbnailUrl = imageResults[i].thumbnailUrl;
      }

      // SCHRITT 4: Character Memory aktualisieren
      await _updateCharacterMemory(
        request.characterId,
        storyResponse.characterDevelopment,
      );

      // SCHRITT 5: Komplettes Ergebnis
      return CompleteStoryResult(
        storyId: DateTime.now().millisecondsSinceEpoch.toString(),
        title: storyResponse.title,
        scenes: storyResponse.scenes,
        characterDevelopment: storyResponse.characterDevelopment,
        learningOutcomes: storyResponse.learningOutcomes,
        totalWordCount: storyResponse.totalWordCount,
        generatedAt: DateTime.now(),
        costBreakdown: CostBreakdown(
          openAITokens: storyResponse.tokensUsed,
          openAICost: _calculateOpenAICost(storyResponse.tokensUsed),
          runwareImages: imageResults.length,
          runwareCost: imageResults.fold(0.0, (sum, img) => sum + img.cost),
        ),
      );
    } catch (e) {
      throw StoryGenerationException('Complete story generation failed: $e');
    }
  }

  /// SCHRITT 1: ChatGPT Story-Generierung
  Future<ChatGPTStoryResponse> _generateStoryWithScenes(
    StoryGenerationRequest request,
  ) async {
    // Character Context aus Memory
    final characterContext = await _memoryService.getCharacterContext(request.characterId);
    
    // ChatGPT Prompt erstellen
    final prompt = _buildChatGPTPrompt(request, characterContext);
    
    final openAIRequest = OpenAIRequest(
      model: 'gpt-4',
      messages: [
        OpenAIMessage(role: 'system', content: _getSystemPrompt()),
        OpenAIMessage(role: 'user', content: prompt),
      ],
      maxTokens: 2000,
      temperature: 0.8,
    );

    final response = await _openAIService.generateCompletion(openAIRequest);
    
    // JSON Response parsen
    final storyData = ChatGPTStoryResponse.fromJson(jsonDecode(response.content));
    storyData.tokensUsed = response.usage.totalTokens;
    
    return storyData;
  }

  /// SCHRITT 4: Character Memory Update
  Future<void> _updateCharacterMemory(
    String characterId,
    CharacterDevelopment development,
  ) async {
    // Trait-Änderungen anwenden
    for (final traitChange in development.traitChanges.entries) {
      await _memoryService.updateCharacterTrait(
        characterId,
        traitChange.key,
        traitChange.value,
      );
    }

    // Neue Memories hinzufügen
    for (final memory in development.newMemories) {
      await _memoryService.addMemory(
        characterId,
        CharacterMemory(
          title: memory.title,
          description: memory.description,
          importance: memory.importance,
          emotionalImpact: memory.emotionalImpact,
          learningValue: memory.learningValue,
          createdAt: DateTime.now(),
          type: MemoryType.storyExperience,
        ),
      );
    }
  }

  /// ChatGPT Prompt Builder
  String _buildChatGPTPrompt(StoryGenerationRequest request, CharacterContext context) {
    return '''
Erstelle eine Geschichte für den Charakter:

**CHARAKTER-PROFIL:**
- Name: ${request.characterName}
- Beschreibung: ${request.characterDescription}
- Eigenschaften: ${context.traits.map((t) => '${t.name}: ${t.value}/10').join(', ')}
- Alter: ${request.characterAge}
- Bisherige Erfahrungen: ${context.recentMemories.map((m) => m.title).join('; ')}

**STORY-PARAMETER:**
- Prompt: ${request.userPrompt}
- Zielgruppe: ${request.targetAge} Jahre
- Genre: ${request.genre}
- Lernziele: ${request.learningObjectives.join(', ')}
- Länge: ~500 Wörter

**ANFORDERUNGEN:**
1. Teile in genau 5 Abschnitte (~100 Wörter je Abschnitt)
2. Jeder Abschnitt braucht detaillierte Bildbeschreibung für KI-Generierung
3. Charakterentwicklung durch Geschichte
4. Lernziele natürlich integrieren
5. Memory-Updates basierend auf Erlebnissen

Antworte in JSON-Format (siehe System-Prompt).
''';
  }

  String _getSystemPrompt() {
    return '''
Du bist Kindergeschichten-Autor. Erstelle personalisierte, altersgerechte Geschichten.

JSON-FORMAT:
{
  "story": {
    "title": "Titel",
    "totalWordCount": 500,
    "scenes": [
      {
        "sceneNumber": 1,
        "title": "Szenen-Titel",
        "content": "Text (~100 Wörter)",
        "imagePrompt": "Detaillierte Beschreibung für Runware Bildgenerierung: Szene, Charaktere, Umgebung, Stimmung",
        "wordCount": 95
      }
    ]
  },
  "characterDevelopment": {
    "traitChanges": {
      "courage": "+0.2",
      "creativity": "+0.1"
    },
    "newMemories": [
      {
        "title": "Erinnerung",
        "description": "Was passierte",
        "importance": 8,
        "emotionalImpact": "positive",
        "learningValue": "Was gelernt"
      }
    ]
  },
  "learningOutcomes": [
    {
      "objective": "Mut entwickeln",
      "achieved": true,
      "evidence": "Beweis"
    }
  ],
  "metadata": {
    "genre": "Fantasy",
    "ageGroup": "6-10",
    "tokensUsed": 450
  }
}
''';
  }

  double _calculateOpenAICost(int tokens) {
    const inputCost = 0.03 / 1000;   // $0.03 per 1K input
    const outputCost = 0.06 / 1000;  // $0.06 per 1K output
    return (tokens / 2 * inputCost) + (tokens / 2 * outputCost);
  }
}

// DTOs
class StoryGenerationRequest {
  final String characterId;
  final String characterName;
  final String characterDescription;
  final int characterAge;
  final String userPrompt;
  final int targetAge;
  final String genre;
  final List<String> learningObjectives;

  StoryGenerationRequest({
    required this.characterId,
    required this.characterName,
    required this.characterDescription,
    required this.characterAge,
    required this.userPrompt,
    required this.targetAge,
    required this.genre,
    required this.learningObjectives,
  });
}

class CompleteStoryResult {
  final String storyId;
  final String title;
  final List<StoryScene> scenes;
  final CharacterDevelopment characterDevelopment;
  final List<LearningOutcome> learningOutcomes;
  final int totalWordCount;
  final DateTime generatedAt;
  final CostBreakdown costBreakdown;

  CompleteStoryResult({
    required this.storyId,
    required this.title,
    required this.scenes,
    required this.characterDevelopment,
    required this.learningOutcomes,
    required this.totalWordCount,
    required this.generatedAt,
    required this.costBreakdown,
  });
}

class ChatGPTStoryResponse {
  final String title;
  final List<StoryScene> scenes;
  final CharacterDevelopment characterDevelopment;
  final List<LearningOutcome> learningOutcomes;
  final int totalWordCount;
  int tokensUsed = 0;

  ChatGPTStoryResponse({
    required this.title,
    required this.scenes,
    required this.characterDevelopment,
    required this.learningOutcomes,
    required this.totalWordCount,
  });

  factory ChatGPTStoryResponse.fromJson(Map<String, dynamic> json) {
    final story = json['story'];
    final scenes = (story['scenes'] as List)
        .map((scene) => StoryScene.fromJson(scene))
        .toList();
    
    final development = CharacterDevelopment.fromJson(json['characterDevelopment']);
    final outcomes = (json['learningOutcomes'] as List)
        .map((outcome) => LearningOutcome.fromJson(outcome))
        .toList();

    return ChatGPTStoryResponse(
      title: story['title'],
      scenes: scenes,
      characterDevelopment: development,
      learningOutcomes: outcomes,
      totalWordCount: story['totalWordCount'],
    );
  }
}

class CharacterDevelopment {
  final Map<String, String> traitChanges;
  final List<NewMemory> newMemories;

  CharacterDevelopment({
    required this.traitChanges,
    required this.newMemories,
  });

  factory CharacterDevelopment.fromJson(Map<String, dynamic> json) {
    return CharacterDevelopment(
      traitChanges: Map<String, String>.from(json['traitChanges']),
      newMemories: (json['newMemories'] as List)
          .map((memory) => NewMemory.fromJson(memory))
          .toList(),
    );
  }
}

class NewMemory {
  final String title;
  final String description;
  final int importance;
  final String emotionalImpact;
  final String learningValue;

  NewMemory({
    required this.title,
    required this.description,
    required this.importance,
    required this.emotionalImpact,
    required this.learningValue,
  });

  factory NewMemory.fromJson(Map<String, dynamic> json) {
    return NewMemory(
      title: json['title'],
      description: json['description'],
      importance: json['importance'],
      emotionalImpact: json['emotionalImpact'],
      learningValue: json['learningValue'],
    );
  }
}

class LearningOutcome {
  final String objective;
  final bool achieved;
  final String evidence;

  LearningOutcome({
    required this.objective,
    required this.achieved,
    required this.evidence,
  });

  factory LearningOutcome.fromJson(Map<String, dynamic> json) {
    return LearningOutcome(
      objective: json['objective'],
      achieved: json['achieved'],
      evidence: json['evidence'],
    );
  }
}

class CostBreakdown {
  final int openAITokens;
  final double openAICost;
  final int runwareImages;
  final double runwareCost;
  double get totalCost => openAICost + runwareCost;

  CostBreakdown({
    required this.openAITokens,
    required this.openAICost,
    required this.runwareImages,
    required this.runwareCost,
  });
}

// Mock Services (zu implementieren)
abstract class OpenAIService {
  Future<OpenAIResponse> generateCompletion(OpenAIRequest request);
}

abstract class CharacterMemoryService {
  Future<CharacterContext> getCharacterContext(String characterId);
  Future<void> updateCharacterTrait(String characterId, String trait, String value);
  Future<void> addMemory(String characterId, CharacterMemory memory);
}

// Mock Models
class OpenAIRequest {
  final String model;
  final List<OpenAIMessage> messages;
  final int maxTokens;
  final double temperature;

  OpenAIRequest({
    required this.model,
    required this.messages,
    required this.maxTokens,
    required this.temperature,
  });
}

class OpenAIMessage {
  final String role;
  final String content;

  OpenAIMessage({required this.role, required this.content});
}

class OpenAIResponse {
  final String content;
  final TokenUsage usage;

  OpenAIResponse({required this.content, required this.usage});
}

class TokenUsage {
  final int totalTokens;
  TokenUsage({required this.totalTokens});
}

class CharacterContext {
  final List<CharacterTrait> traits;
  final List<CharacterMemory> recentMemories;

  CharacterContext({required this.traits, required this.recentMemories});
}

class CharacterTrait {
  final String name;
  final int value;

  CharacterTrait({required this.name, required this.value});
}

class CharacterMemory {
  final String title;
  final String description;
  final int importance;
  final String emotionalImpact;
  final String learningValue;
  final DateTime createdAt;
  final MemoryType type;

  CharacterMemory({
    required this.title,
    required this.description,
    required this.importance,
    required this.emotionalImpact,
    required this.learningValue,
    required this.createdAt,
    required this.type,
  });
}

enum MemoryType { storyExperience, userInteraction, systemEvent }

class StoryGenerationException implements Exception {
  final String message;
  StoryGenerationException(this.message);
  
  @override
  String toString() => 'StoryGenerationException: $message';
}