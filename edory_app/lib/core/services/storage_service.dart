// Avatales.Services.StorageService
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import '../utils/app_utils.dart';

/// Service für lokale Datenspeicherung (SharedPreferences + File System)
class StorageService {
  static StorageService? _instance;
  static StorageService get instance => _instance ??= StorageService._();
  StorageService._();

  // Simulierte SharedPreferences (in echter App würde das echte Package verwendet)
  final Map<String, dynamic> _preferences = {};
  
  // File System Paths
  String? _documentsPath;
  String? _tempPath;
  String? _cachePath;

  bool _isInitialized = false;

  /// Initialisiert den Storage Service
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // In einer echten App würden hier die Pfade von path_provider kommen
      _documentsPath = '/app/documents';
      _tempPath = '/app/temp';
      _cachePath = '/app/cache';

      // Verzeichnisse erstellen (simuliert)
      await _ensureDirectoriesExist();

      _isInitialized = true;
      AppUtils.debugLog('StorageService initialized');
    } catch (e) {
      AppUtils.errorLog('Failed to initialize StorageService', error: e);
      rethrow;
    }
  }

  // ===== SharedPreferences-ähnliche Methods =====

  /// Speichert einen String-Wert
  Future<bool> setString(String key, String value) async {
    try {
      _preferences[key] = value;
      await _persistPreferences();
      return true;
    } catch (e) {
      AppUtils.errorLog('Failed to set string: $key', error: e);
      return false;
    }
  }

  /// Lädt einen String-Wert
  Future<String?> getString(String key) async {
    try {
      return _preferences[key] as String?;
    } catch (e) {
      AppUtils.errorLog('Failed to get string: $key', error: e);
      return null;
    }
  }

  /// Speichert einen Integer-Wert
  Future<bool> setInt(String key, int value) async {
    try {
      _preferences[key] = value;
      await _persistPreferences();
      return true;
    } catch (e) {
      AppUtils.errorLog('Failed to set int: $key', error: e);
      return false;
    }
  }

  /// Lädt einen Integer-Wert
  Future<int?> getInt(String key) async {
    try {
      return _preferences[key] as int?;
    } catch (e) {
      AppUtils.errorLog('Failed to get int: $key', error: e);
      return null;
    }
  }

  /// Speichert einen Boolean-Wert
  Future<bool> setBool(String key, bool value) async {
    try {
      _preferences[key] = value;
      await _persistPreferences();
      return true;
    } catch (e) {
      AppUtils.errorLog('Failed to set bool: $key', error: e);
      return false;
    }
  }

  /// Lädt einen Boolean-Wert
  Future<bool?> getBool(String key) async {
    try {
      return _preferences[key] as bool?;
    } catch (e) {
      AppUtils.errorLog('Failed to get bool: $key', error: e);
      return null;
    }
  }

  /// Speichert einen Double-Wert
  Future<bool> setDouble(String key, double value) async {
    try {
      _preferences[key] = value;
      await _persistPreferences();
      return true;
    } catch (e) {
      AppUtils.errorLog('Failed to set double: $key', error: e);
      return false;
    }
  }

  /// Lädt einen Double-Wert
  Future<double?> getDouble(String key) async {
    try {
      return _preferences[key] as double?;
    } catch (e) {
      AppUtils.errorLog('Failed to get double: $key', error: e);
      return null;
    }
  }

  /// Speichert eine String-Liste
  Future<bool> setStringList(String key, List<String> value) async {
    try {
      _preferences[key] = value;
      await _persistPreferences();
      return true;
    } catch (e) {
      AppUtils.errorLog('Failed to set string list: $key', error: e);
      return false;
    }
  }

  /// Lädt eine String-Liste
  Future<List<String>?> getStringList(String key) async {
    try {
      final list = _preferences[key];
      if (list is List) {
        return List<String>.from(list);
      }
      return null;
    } catch (e) {
      AppUtils.errorLog('Failed to get string list: $key', error: e);
      return null;
    }
  }

  /// Entfernt einen Schlüssel
  Future<bool> remove(String key) async {
    try {
      _preferences.remove(key);
      await _persistPreferences();
      return true;
    } catch (e) {
      AppUtils.errorLog('Failed to remove key: $key', error: e);
      return false;
    }
  }

  /// Prüft ob ein Schlüssel existiert
  Future<bool> containsKey(String key) async {
    return _preferences.containsKey(key);
  }

  /// Löscht alle Preferences
  Future<bool> clear() async {
    try {
      _preferences.clear();
      await _persistPreferences();
      return true;
    } catch (e) {
      AppUtils.errorLog('Failed to clear preferences', error: e);
      return false;
    }
  }

  /// Gibt alle Schlüssel zurück
  Future<Set<String>> getKeys() async {
    return _preferences.keys.toSet();
  }

  // ===== File System Methods =====

  /// Speichert Daten in eine Datei
  Future<bool> saveFile(
    String fileName,
    Uint8List data, {
    StorageLocation location = StorageLocation.documents,
  }) async {
    try {
      final filePath = _getFilePath(fileName, location);
      if (filePath == null) return false;

      // Simulierte Dateispeicherung
      await Future.delayed(const Duration(milliseconds: 50));
      
      AppUtils.debugLog('File saved: $filePath (${data.length} bytes)');
      return true;
    } catch (e) {
      AppUtils.errorLog('Failed to save file: $fileName', error: e);
      return false;
    }
  }

  /// Lädt Daten aus einer Datei
  Future<Uint8List?> loadFile(
    String fileName, {
    StorageLocation location = StorageLocation.documents,
  }) async {
    try {
      final filePath = _getFilePath(fileName, location);
      if (filePath == null) return null;

      // Simulierte Dateiladung
      await Future.delayed(const Duration(milliseconds: 30));
      
      // In einer echten App würde hier File(filePath).readAsBytes() verwendet
      AppUtils.debugLog('File loaded: $filePath');
      return null; // Simuliert - würde echte Daten zurückgeben
    } catch (e) {
      AppUtils.errorLog('Failed to load file: $fileName', error: e);
      return null;
    }
  }

  /// Speichert Text in eine Datei
  Future<bool> saveTextFile(
    String fileName,
    String content, {
    StorageLocation location = StorageLocation.documents,
  }) async {
    try {
      final data = Uint8List.fromList(utf8.encode(content));
      return await saveFile(fileName, data, location: location);
    } catch (e) {
      AppUtils.errorLog('Failed to save text file: $fileName', error: e);
      return false;
    }
  }

  /// Lädt Text aus einer Datei
  Future<String?> loadTextFile(
    String fileName, {
    StorageLocation location = StorageLocation.documents,
  }) async {
    try {
      final data = await loadFile(fileName, location: location);
      if (data == null) return null;
      
      return utf8.decode(data);
    } catch (e) {
      AppUtils.errorLog('Failed to load text file: $fileName', error: e);
      return null;
    }
  }

  /// Speichert JSON-Daten in eine Datei
  Future<bool> saveJsonFile(
    String fileName,
    Map<String, dynamic> data, {
    StorageLocation location = StorageLocation.documents,
  }) async {
    try {
      final jsonString = jsonEncode(data);
      return await saveTextFile(fileName, jsonString, location: location);
    } catch (e) {
      AppUtils.errorLog('Failed to save JSON file: $fileName', error: e);
      return false;
    }
  }

  /// Lädt JSON-Daten aus einer Datei
  Future<Map<String, dynamic>?> loadJsonFile(
    String fileName, {
    StorageLocation location = StorageLocation.documents,
  }) async {
    try {
      final jsonString = await loadTextFile(fileName, location: location);
      if (jsonString == null) return null;
      
      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      AppUtils.errorLog('Failed to load JSON file: $fileName', error: e);
      return null;
    }
  }

  /// Prüft ob eine Datei existiert
  Future<bool> fileExists(
    String fileName, {
    StorageLocation location = StorageLocation.documents,
  }) async {
    try {
      final filePath = _getFilePath(fileName, location);
      if (filePath == null) return false;

      // Simulierte Existenz-Prüfung
      return _preferences.containsKey('file_$filePath');
    } catch (e) {
      AppUtils.errorLog('Failed to check file existence: $fileName', error: e);
      return false;
    }
  }

  /// Löscht eine Datei
  Future<bool> deleteFile(
    String fileName, {
    StorageLocation location = StorageLocation.documents,
  }) async {
    try {
      final filePath = _getFilePath(fileName, location);
      if (filePath == null) return false;

      // Simulierte Dateierfernung
      _preferences.remove('file_$filePath');
      
      AppUtils.debugLog('File deleted: $filePath');
      return true;
    } catch (e) {
      AppUtils.errorLog('Failed to delete file: $fileName', error: e);
      return false;
    }
  }

  /// Gibt die Dateigröße zurück
  Future<int> getFileSize(
    String fileName, {
    StorageLocation location = StorageLocation.documents,
  }) async {
    try {
      // Simulierte Dateigröße
      return 1024; // 1KB
    } catch (e) {
      AppUtils.errorLog('Failed to get file size: $fileName', error: e);
      return 0;
    }
  }

  /// Listet alle Dateien in einem Verzeichnis auf
  Future<List<String>> listFiles({
    StorageLocation location = StorageLocation.documents,
    String? extension,
  }) async {
    try {
      // Simulierte Dateiliste
      final files = <String>['avatar_1.json', 'avatar_2.json', 'settings.json'];
      
      if (extension != null) {
        return files.where((file) => file.endsWith(extension)).toList();
      }
      
      return files;
    } catch (e) {
      AppUtils.errorLog('Failed to list files', error: e);
      return [];
    }
  }

  // ===== Cache Management =====

  /// Speichert Daten im Cache
  Future<bool> cacheData(String key, Map<String, dynamic> data) async {
    try {
      final cacheEntry = CacheEntry(
        key: key,
        data: data,
        timestamp: DateTime.now(),
      );
      
      return await saveJsonFile(
        'cache_$key.json',
        cacheEntry.toJson(),
        location: StorageLocation.cache,
      );
    } catch (e) {
      AppUtils.errorLog('Failed to cache data: $key', error: e);
      return false;
    }
  }

  /// Lädt Daten aus dem Cache
  Future<Map<String, dynamic>?> getCachedData(
    String key, {
    Duration? maxAge,
  }) async {
    try {
      final cacheData = await loadJsonFile(
        'cache_$key.json',
        location: StorageLocation.cache,
      );
      
      if (cacheData == null) return null;
      
      final cacheEntry = CacheEntry.fromJson(cacheData);
      
      // Prüfe Alter der Daten
      if (maxAge != null) {
        final age = DateTime.now().difference(cacheEntry.timestamp);
        if (age > maxAge) {
          // Cache abgelaufen
          await deleteFile('cache_$key.json', location: StorageLocation.cache);
          return null;
        }
      }
      
      return cacheEntry.data;
    } catch (e) {
      AppUtils.errorLog('Failed to get cached data: $key', error: e);
      return null;
    }
  }

  /// Löscht alle Cache-Dateien
  Future<bool> clearCache() async {
    try {
      final cacheFiles = await listFiles(location: StorageLocation.cache);
      
      for (final file in cacheFiles) {
        if (file.startsWith('cache_')) {
          await deleteFile(file, location: StorageLocation.cache);
        }
      }
      
      AppUtils.debugLog('Cache cleared');
      return true;
    } catch (e) {
      AppUtils.errorLog('Failed to clear cache', error: e);
      return false;
    }
  }

  /// Gibt die Cache-Größe zurück
  Future<int> getCacheSize() async {
    try {
      final cacheFiles = await listFiles(location: StorageLocation.cache);
      int totalSize = 0;
      
      for (final file in cacheFiles) {
        totalSize += await getFileSize(file, location: StorageLocation.cache);
      }
      
      return totalSize;
    } catch (e) {
      AppUtils.errorLog('Failed to get cache size', error: e);
      return 0;
    }
  }

  // ===== Private Methods =====

  String? _getFilePath(String fileName, StorageLocation location) {
    switch (location) {
      case StorageLocation.documents:
        return _documentsPath != null ? '$_documentsPath/$fileName' : null;
      case StorageLocation.temp:
        return _tempPath != null ? '$_tempPath/$fileName' : null;
      case StorageLocation.cache:
        return _cachePath != null ? '$_cachePath/$fileName' : null;
    }
  }

  Future<void> _ensureDirectoriesExist() async {
    // Simuliert - in echter App würden hier Verzeichnisse erstellt
    AppUtils.debugLog('Storage directories initialized');
  }

  Future<void> _persistPreferences() async {
    // Simuliert - in echter App würden Preferences gespeichert
    await Future.delayed(const Duration(milliseconds: 1));
  }

  /// Exportiert alle gespeicherten Daten
  Future<Map<String, dynamic>> exportAllData() async {
    try {
      final allData = <String, dynamic>{
        'preferences': Map<String, dynamic>.from(_preferences),
        'files': <String, dynamic>{},
        'exportTimestamp': DateTime.now().toIso8601String(),
        'version': '1.0.0',
      };

      // Alle Dateien durchgehen und exportieren
      for (final location in StorageLocation.values) {
        final files = await listFiles(location: location);
        for (final file in files) {
          final content = await loadTextFile(file, location: location);
          if (content != null) {
            allData['files']['${location.name}/$file'] = content;
          }
        }
      }

      return allData;
    } catch (e) {
      AppUtils.errorLog('Failed to export data', error: e);
      return {};
    }
  }

  /// Importiert gespeicherte Daten
  Future<bool> importData(Map<String, dynamic> data) async {
    try {
      // Preferences importieren
      if (data['preferences'] is Map<String, dynamic>) {
        _preferences.clear();
        _preferences.addAll(data['preferences']);
        await _persistPreferences();
      }

      // Dateien importieren
      if (data['files'] is Map<String, dynamic>) {
        final files = data['files'] as Map<String, dynamic>;
        
        for (final entry in files.entries) {
          final pathParts = entry.key.split('/');
          if (pathParts.length >= 2) {
            final locationName = pathParts[0];
            final fileName = pathParts.sublist(1).join('/');
            final content = entry.value as String;
            
            final location = StorageLocation.values.firstWhere(
              (l) => l.name == locationName,
              orElse: () => StorageLocation.documents,
            );
            
            await saveTextFile(fileName, content, location: location);
          }
        }
      }

      AppUtils.debugLog('Data import completed');
      return true;
    } catch (e) {
      AppUtils.errorLog('Failed to import data', error: e);
      return false;
    }
  }
}

// ===== Data Models =====

enum StorageLocation {
  documents,
  temp,
  cache,
}

class CacheEntry {
  final String key;
  final Map<String, dynamic> data;
  final DateTime timestamp;

  const CacheEntry({
    required this.key,
    required this.data,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'key': key,
      'data': data,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory CacheEntry.fromJson(Map<String, dynamic> json) {
    return CacheEntry(
      key: json['key'],
      data: Map<String, dynamic>.from(json['data']),
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}