// lib/core/services/runware_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

/// Runware AI Image Generation Service
/// Generiert kinderfreundliche Illustrationen für Geschichten
class RunwareService {
  static const String _baseUrl = 'https://api.runware.ai';
  static const String _apiKey = 'no key yet'; // TODO: Environment variable
  
  final http.Client _client;
  
  RunwareService({http.Client? client}) : _client = client ?? http.Client();

  /// Generiert ein Bild basierend auf einer Szenen-Beschreibung
  Future<RunwareImageResult> generateSceneImage({
    required String prompt,
    required String characterName,
    required int sceneNumber,
    String? style = 'children_book_illustration',
  }) async {
    try {
      final request = RunwareImageRequest(
        prompt: _enhancePromptForChildren(prompt, characterName),
        negativePrompt: _getChildSafetyNegativePrompt(),
        width: 1024,
        height: 768,
        model: 'runware:100@1',
        style: style ?? 'children_book_illustration',
        guidanceScale: 7.5,
        steps: 25,
        numberOfImages: 1,
        outputFormat: 'PNG',
        enhancePrompt: true,
      );

      final response = await _makeRequest('/generate-image', request.toJson());
      
      if (response['status'] == 'success') {
        final imageData = response['data'][0];
        
        return RunwareImageResult(
          url: imageData['url'],
          thumbnailUrl: imageData['thumbnailUrl'],
          cost: (response['usage']['estimatedCost'] as num).toDouble(),
          sceneNumber: sceneNumber,
          prompt: request.prompt,
          generatedAt: DateTime.now(),
        );
      } else {
        throw RunwareException('Image generation failed: ${response['error']}');
      }
    } catch (e) {
      throw RunwareException('Failed to generate image: $e');
    }
  }

  /// Generiert alle Bilder für eine komplette Geschichte parallel
  Future<List<RunwareImageResult>> generateStoryImages({
    required List<StoryScene> scenes,
    required String characterName,
  }) async {
    try {
      final futures = scenes.asMap().entries.map((entry) {
        final index = entry.key;
        final scene = entry.value;
        
        return generateSceneImage(
          prompt: scene.imagePrompt,
          characterName: characterName,
          sceneNumber: index + 1,
        );
      });

      return await Future.wait(futures);
    } catch (e) {
      throw RunwareException('Failed to generate story images: $e');
    }
  }

  /// Verbessert den Prompt für kinderfreundliche Inhalte
  String _enhancePromptForChildren(String originalPrompt, String characterName) {
    final enhancedPrompt = '''
$originalPrompt

Art style: Children's book illustration, colorful, friendly, cartoon style, soft lighting, magical atmosphere, watercolor painting style
Character: $characterName (consistent appearance, friendly expression)
Mood: Happy, adventurous, magical, warm
Color palette: Bright and cheerful colors, soft pastels
Safety: Age-appropriate for 6-10 years old, no scary elements
Quality: High detail, professional illustration, storybook quality
''';
    
    return enhancedPrompt.trim();
  }

  /// Negative Prompt für Kindersicherheit
  String _getChildSafetyNegativePrompt() {
    return '''
scary, dark, violent, inappropriate for children, realistic gore, adult content, 
weapons, scary faces, nightmares, horror, blood, death, monsters, spiders, 
snakes, fire, explosions, angry expressions, sad scenes, crying, 
realistic human faces, photorealistic, nsfw, adult themes, alcohol, drugs,
ugly, deformed, blurry, low quality, watermark, text, signature
''';
  }

  /// HTTP Request Helper
  Future<Map<String, dynamic>> _makeRequest(String endpoint, Map<String, dynamic> body) async {
    final uri = Uri.parse('$_baseUrl$endpoint');
    
    final response = await _client.post(
      uri,
      headers: {
        'Authorization': 'Bearer $_apiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw HttpException('API request failed: ${response.statusCode} - ${response.body}');
    }
  }

  void dispose() {
    _client.close();
  }
}

/// Runware API Request Model
class RunwareImageRequest {
  final String prompt;
  final String negativePrompt;
  final int width;
  final int height;
  final String model;
  final String style;
  final double guidanceScale;
  final int steps;
  final int numberOfImages;
  final String outputFormat;
  final bool enhancePrompt;

  RunwareImageRequest({
    required this.prompt,
    required this.negativePrompt,
    required this.width,
    required this.height,
    required this.model,
    required this.style,
    required this.guidanceScale,
    required this.steps,
    required this.numberOfImages,
    required this.outputFormat,
    required this.enhancePrompt,
  });

  Map<String, dynamic> toJson() => {
    'prompt': prompt,
    'negativePrompt': negativePrompt,
    'width': width,
    'height': height,
    'model': model,
    'style': style,
    'guidanceScale': guidanceScale,
    'steps': steps,
    'numberOfImages': numberOfImages,
    'outputFormat': outputFormat,
    'enhancePrompt': enhancePrompt,
  };
}

/// Runware Image Generation Result
class RunwareImageResult {
  final String url;
  final String thumbnailUrl;
  final double cost;
  final int sceneNumber;
  final String prompt;
  final DateTime generatedAt;

  RunwareImageResult({
    required this.url,
    required this.thumbnailUrl,
    required this.cost,
    required this.sceneNumber,
    required this.prompt,
    required this.generatedAt,
  });

  Map<String, dynamic> toJson() => {
    'url': url,
    'thumbnailUrl': thumbnailUrl,
    'cost': cost,
    'sceneNumber': sceneNumber,
    'prompt': prompt,
    'generatedAt': generatedAt.toIso8601String(),
  };

  factory RunwareImageResult.fromJson(Map<String, dynamic> json) => RunwareImageResult(
    url: json['url'],
    thumbnailUrl: json['thumbnailUrl'],
    cost: (json['cost'] as num).toDouble(),
    sceneNumber: json['sceneNumber'],
    prompt: json['prompt'],
    generatedAt: DateTime.parse(json['generatedAt']),
  );
}

/// Story Scene für Bildgenerierung
class StoryScene {
  final int sceneNumber;
  final String title;
  final String content;
  final String imagePrompt;
  String? imageUrl;
  String? thumbnailUrl;

  StoryScene({
    required this.sceneNumber,
    required this.title,
    required this.content,
    required this.imagePrompt,
    this.imageUrl,
    this.thumbnailUrl,
  });

  Map<String, dynamic> toJson() => {
    'sceneNumber': sceneNumber,
    'title': title,
    'content': content,
    'imagePrompt': imagePrompt,
    'imageUrl': imageUrl,
    'thumbnailUrl': thumbnailUrl,
  };

  factory StoryScene.fromJson(Map<String, dynamic> json) => StoryScene(
    sceneNumber: json['sceneNumber'],
    title: json['title'],
    content: json['content'],
    imagePrompt: json['imagePrompt'],
    imageUrl: json['imageUrl'],
    thumbnailUrl: json['thumbnailUrl'],
  );
}

/// Runware Service Exceptions
class RunwareException implements Exception {
  final String message;
  RunwareException(this.message);
  
  @override
  String toString() => 'RunwareException: $message';
}