// Avatales.Services.ImageService
import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import '../utils/app_utils.dart';
import 'network_service.dart';
import 'storage_service.dart';

/// Service für Bildverarbeitung, Caching und Avatar-Generierung
class ImageService {
  static ImageService? _instance;
  static ImageService get instance => _instance ??= ImageService._();
  ImageService._();

  final NetworkService _networkService = NetworkService.instance;
  final StorageService _storageService = StorageService.instance;

  // Cache für geladene Bilder
  final Map<String, Uint8List> _memoryCache = {};
  final Map<String, DateTime> _cacheTimestamps = {};
  
  // Cache-Konfiguration
  static const int _maxMemoryCacheSize = 50; // MB
  static const Duration _cacheExpiry = Duration(hours: 24);
  
  int _currentCacheSize = 0;

  /// Lädt ein Bild von einer URL
  Future<Uint8List?> loadImage(
    String url, {
    bool useCache = true,
    ImageQuality quality = ImageQuality.medium,
  }) async {
    try {
      final cacheKey = _generateCacheKey(url, quality);

      // Memory Cache prüfen
      if (useCache && _memoryCache.containsKey(cacheKey)) {
        final timestamp = _cacheTimestamps[cacheKey];
        if (timestamp != null && 
            DateTime.now().difference(timestamp) < _cacheExpiry) {
          AppUtils.debugLog('Image loaded from memory cache: $url');
          return _memoryCache[cacheKey];
        } else {
          // Abgelaufenen Cache-Eintrag entfernen
          _removeFromCache(cacheKey);
        }
      }

      // Disk Cache prüfen
      if (useCache) {
        final cachedData = await _loadFromDiskCache(cacheKey);
        if (cachedData != null) {
          await _addToMemoryCache(cacheKey, cachedData);
          AppUtils.debugLog('Image loaded from disk cache: $url');
          return cachedData;
        }
      }

      // Von Network laden
      final downloadResult = await _downloadImage(url);
      if (downloadResult != null) {
        // Bildqualität anpassen
        final processedImage = await _processImage(downloadResult, quality);
        
        if (useCache) {
          await _saveToDiskCache(cacheKey, processedImage);
          await _addToMemoryCache(cacheKey, processedImage);
        }
        
        AppUtils.debugLog('Image loaded from network: $url');
        return processedImage;
      }

      return null;
    } catch (e) {
      AppUtils.errorLog('Failed to load image: $url', error: e);
      return null;
    }
  }

  /// Lädt mehrere Bilder parallel
  Future<List<Uint8List?>> loadImages(
    List<String> urls, {
    bool useCache = true,
    ImageQuality quality = ImageQuality.medium,
    int maxConcurrent = 3,
  }) async {
    final results = <Uint8List?>[];
    
    // In Chunks aufteilen für begrenzte Parallelität
    final chunks = AppUtils.chunkList(urls, maxConcurrent);
    
    for (final chunk in chunks) {
      final futures = chunk.map((url) => loadImage(
        url,
        useCache: useCache,
        quality: quality,
      ));
      
      final chunkResults = await Future.wait(futures);
      results.addAll(chunkResults);
    }
    
    return results;
  }

  /// Generiert einen Avatar aus Widget
  Future<Uint8List?> generateAvatarImage(
    Widget avatarWidget, {
    Size size = const Size(200, 200),
    double pixelRatio = 2.0,
  }) async {
    try {
      final renderObject = RenderRepaintBoundary();
      final pipelineOwner = PipelineOwner();
      final buildOwner = BuildOwner(focusManager: FocusManager());

      // Widget in RenderObject umwandeln
      final rootWidget = RepaintBoundary(
        child: Container(
          width: size.width,
          height: size.height,
          child: avatarWidget,
        ),
      );

      final element = rootWidget.createElement();
      element.mount(null, null);
      
      // Layout und Paint
      renderObject.layout(BoxConstraints.tight(size));
      
      // Zu Bild konvertieren
      final image = await renderObject.toImage(pixelRatio: pixelRatio);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      
      if (byteData != null) {
        AppUtils.debugLog('Avatar image generated successfully');
        return byteData.buffer.asUint8List();
      }

      return null;
    } catch (e) {
      AppUtils.errorLog('Failed to generate avatar image', error: e);
      return null;
    }
  }

  /// Erstellt einen Thumbnail
  Future<Uint8List?> createThumbnail(
    Uint8List imageData, {
    int maxWidth = 150,
    int maxHeight = 150,
    ImageQuality quality = ImageQuality.medium,
  }) async {
    try {
      // Vereinfachte Thumbnail-Erstellung
      // In einer echten App würde hier eine Image-Processing Library verwendet
      
      // Simuliere Thumbnail-Generierung
      await Future.delayed(const Duration(milliseconds: 100));
      
      AppUtils.debugLog('Thumbnail created: ${maxWidth}x$maxHeight');
      return imageData; // Würde tatsächlich verkleinerte Version zurückgeben
    } catch (e) {
      AppUtils.errorLog('Failed to create thumbnail', error: e);
      return null;
    }
  }

  /// Komprimiert ein Bild
  Future<Uint8List?> compressImage(
    Uint8List imageData, {
    ImageQuality quality = ImageQuality.medium,
    int? maxWidth,
    int? maxHeight,
  }) async {
    try {
      // Vereinfachte Komprimierung
      // In einer echten App würde hier eine Image-Processing Library verwendet
      
      await Future.delayed(const Duration(milliseconds: 150));
      
      // Simuliere Komprimierung basierend auf Qualität
      final compressionRatio = _getCompressionRatio(quality);
      final compressedSize = (imageData.length * compressionRatio).round();
      
      AppUtils.debugLog('Image compressed: ${imageData.length} -> $compressedSize bytes');
      return imageData; // Würde tatsächlich komprimierte Version zurückgeben
    } catch (e) {
      AppUtils.errorLog('Failed to compress image', error: e);
      return null;
    }
  }

  /// Wandelt Widget zu Bild um
  Future<Uint8List?> widgetToImage(
    Widget widget, {
    Size? size,
    Duration timeout = const Duration(seconds: 10),
  }) async {
    try {
      final completer = Completer<Uint8List?>();
      
      // Timeout hinzufügen
      Timer(timeout, () {
        if (!completer.isCompleted) {
          completer.complete(null);
        }
      });

      // Widget-zu-Bild Konvertierung
      // In einer echten App würde hier RepaintBoundary verwendet
      final result = await generateAvatarImage(
        widget,
        size: size ?? const Size(200, 200),
      );
      
      if (!completer.isCompleted) {
        completer.complete(result);
      }
      
      return await completer.future;
    } catch (e) {
      AppUtils.errorLog('Failed to convert widget to image', error: e);
      return null;
    }
  }

  /// Speichert Bild in der Galerie (simuliert)
  Future<bool> saveToGallery(
    Uint8List imageData,
    String fileName, {
    String? albumName,
  }) async {
    try {
      // In einer echten App würde hier die Gallery-Integration stattfinden
      await Future.delayed(const Duration(milliseconds: 500));
      
      AppUtils.debugLog('Image saved to gallery: $fileName');
      return true;
    } catch (e) {
      AppUtils.errorLog('Failed to save image to gallery', error: e);
      return false;
    }
  }

  /// Lädt Bild aus der Galerie (simuliert)
  Future<Uint8List?> pickFromGallery() async {
    try {
      // In einer echten App würde hier der Image Picker verwendet
      await Future.delayed(const Duration(milliseconds: 1000));
      
      AppUtils.debugLog('Image picked from gallery');
      return null; // Würde echte Bilddaten zurückgeben
    } catch (e) {
      AppUtils.errorLog('Failed to pick image from gallery', error: e);
      return null;
    }
  }

  /// Aufnahme von der Kamera (simuliert)
  Future<Uint8List?> captureFromCamera() async {
    try {
      // In einer echten App würde hier die Kamera-Integration stattfinden
      await Future.delayed(const Duration(milliseconds: 1500));
      
      AppUtils.debugLog('Image captured from camera');
      return null; // Würde echte Bilddaten zurückgeben
    } catch (e) {
      AppUtils.errorLog('Failed to capture image from camera', error: e);
      return null;
    }
  }

  // ===== Cache Management =====

  /// Räumt den Cache auf
  Future<void> cleanCache() async {
    try {
      final now = DateTime.now();
      final expiredKeys = <String>[];

      // Abgelaufene Einträge finden
      _cacheTimestamps.forEach((key, timestamp) {
        if (now.difference(timestamp) > _cacheExpiry) {
          expiredKeys.add(key);
        }
      });

      // Memory Cache aufräumen
      for (final key in expiredKeys) {
        _removeFromCache(key);
      }

      // Disk Cache aufräumen
      await _cleanDiskCache();

      AppUtils.debugLog('Cache cleaned: ${expiredKeys.length} expired entries removed');
    } catch (e) {
      AppUtils.errorLog('Failed to clean cache', error: e);
    }
  }

  /// Löscht den gesamten Cache
  Future<void> clearCache() async {
    try {
      // Memory Cache löschen
      _memoryCache.clear();
      _cacheTimestamps.clear();
      _currentCacheSize = 0;

      // Disk Cache löschen
      await _storageService.clearCache();

      AppUtils.debugLog('Cache cleared completely');
    } catch (e) {
      AppUtils.errorLog('Failed to clear cache', error: e);
    }
  }

  /// Gibt Cache-Statistiken zurück
  Future<CacheStats> getCacheStats() async {
    try {
      final memorySizeBytes = _currentCacheSize;
      final diskSizeBytes = await _storageService.getCacheSize();
      final totalEntries = _memoryCache.length;
      
      return CacheStats(
        memorySizeBytes: memorySizeBytes,
        diskSizeBytes: diskSizeBytes,
        totalEntries: totalEntries,
        maxMemorySize: _maxMemoryCacheSize * 1024 * 1024,
      );
    } catch (e) {
      AppUtils.errorLog('Failed to get cache stats', error: e);
      return const CacheStats(
        memorySizeBytes: 0,
        diskSizeBytes: 0,
        totalEntries: 0,
        maxMemorySize: 0,
      );
    }
  }

  // ===== Private Methods =====

  Future<Uint8List?> _downloadImage(String url) async {
    try {
      final response = await _networkService.downloadFile(url);
      if (response.success && response.data != null) {
        return Uint8List.fromList(response.data!);
      }
      return null;
    } catch (e) {
      AppUtils.errorLog('Failed to download image', error: e);
      return null;
    }
  }

  Future<Uint8List> _processImage(Uint8List imageData, ImageQuality quality) async {
    // Vereinfachte Bildverarbeitung
    // In einer echten App würde hier echte Komprimierung/Resize stattfinden
    return imageData;
  }

  String _generateCacheKey(String url, ImageQuality quality) {
    return '${url.hashCode}_${quality.name}';
  }

  Future<void> _addToMemoryCache(String key, Uint8List data) async {
    final dataSize = data.length;
    
    // Cache-Größe prüfen
    while (_currentCacheSize + dataSize > _maxMemoryCacheSize * 1024 * 1024) {
      await _evictLeastRecentlyUsed();
    }

    _memoryCache[key] = data;
    _cacheTimestamps[key] = DateTime.now();
    _currentCacheSize += dataSize;
  }

  void _removeFromCache(String key) {
    final data = _memoryCache.remove(key);
    _cacheTimestamps.remove(key);
    
    if (data != null) {
      _currentCacheSize -= data.length;
    }
  }

  Future<void> _evictLeastRecentlyUsed() async {
    if (_cacheTimestamps.isEmpty) return;

    // Ältesten Eintrag finden
    String? oldestKey;
    DateTime? oldestTime;

    _cacheTimestamps.forEach((key, timestamp) {
      if (oldestTime == null || timestamp.isBefore(oldestTime!)) {
        oldestKey = key;
        oldestTime = timestamp;
      }
    });

    if (oldestKey != null) {
      _removeFromCache(oldestKey!);
    }
  }

  Future<void> _saveToDiskCache(String key, Uint8List data) async {
    try {
      await _storageService.saveFile(
        'cache_$key.img',
        data,
        location: StorageLocation.cache,
      );
    } catch (e) {
      AppUtils.errorLog('Failed to save to disk cache', error: e);
    }
  }

  Future<Uint8List?> _loadFromDiskCache(String key) async {
    try {
      return await _storageService.loadFile(
        'cache_$key.img',
        location: StorageLocation.cache,
      );
    } catch (e) {
      AppUtils.errorLog('Failed to load from disk cache', error: e);
      return null;
    }
  }

  Future<void> _cleanDiskCache() async {
    try {
      final cacheFiles = await _storageService.listFiles(
        location: StorageLocation.cache,
        extension: '.img',
      );

      for (final file in cacheFiles) {
        if (file.startsWith('cache_')) {
          await _storageService.deleteFile(
            file,
            location: StorageLocation.cache,
          );
        }
      }
    } catch (e) {
      AppUtils.errorLog('Failed to clean disk cache', error: e);
    }
  }

  double _getCompressionRatio(ImageQuality quality) {
    switch (quality) {
      case ImageQuality.low:
        return 0.3;
      case ImageQuality.medium:
        return 0.6;
      case ImageQuality.high:
        return 0.8;
      case ImageQuality.original:
        return 1.0;
    }
  }

  void dispose() {
    _memoryCache.clear();
    _cacheTimestamps.clear();
  }
}

// ===== Data Models =====

enum ImageQuality { low, medium, high, original }

class CacheStats {
  final int memorySizeBytes;
  final int diskSizeBytes;
  final int totalEntries;
  final int maxMemorySize;

  const CacheStats({
    required this.memorySizeBytes,
    required this.diskSizeBytes,
    required this.totalEntries,
    required this.maxMemorySize,
  });

  int get totalSizeBytes => memorySizeBytes + diskSizeBytes;
  
  double get memoryUsagePercentage => 
      maxMemorySize > 0 ? (memorySizeBytes / maxMemorySize) * 100 : 0;

  String get formattedMemorySize => AppUtils.formatFileSize(memorySizeBytes);
  String get formattedDiskSize => AppUtils.formatFileSize(diskSizeBytes);
  String get formattedTotalSize => AppUtils.formatFileSize(totalSizeBytes);
}

class ImageProcessingOptions {
  final ImageQuality quality;
  final int? maxWidth;
  final int? maxHeight;
  final bool maintainAspectRatio;
  final Color? backgroundColor;

  const ImageProcessingOptions({
    this.quality = ImageQuality.medium,
    this.maxWidth,
    this.maxHeight,
    this.maintainAspectRatio = true,
    this.backgroundColor,
  });
}