// lib/core/constants/api_constants.dart
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class ApiConstants {
  static String get baseUrl {
    if (kIsWeb) {
      return Uri.base.origin;
    }
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:5220';
    }
    return 'http://localhost:5220';
  }
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
