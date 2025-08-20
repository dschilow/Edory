// lib/core/constants/api_constants.dart
class ApiConstants {
  static const String baseUrl = 'http://localhost:5220';
  static const String apiVersion = '/api';
  
  // Character endpoints
  static const String charactersEndpoint = '$apiVersion/characters';
  static const String publicCharactersEndpoint = '$charactersEndpoint/public';
  
  // Story endpoints
  static const String storiesEndpoint = '$apiVersion/stories';
  static const String generateStoryEndpoint = '$storiesEndpoint/generate';
  
  // Learning endpoints
  static const String learningEndpoint = '$apiVersion/learning';
  static const String objectivesEndpoint = '$learningEndpoint/objectives';
  
  // Request timeouts
  static const int connectionTimeout = 30000; // 30 seconds
  static const int receiveTimeout = 30000; // 30 seconds
  
  // API Headers
  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
}
