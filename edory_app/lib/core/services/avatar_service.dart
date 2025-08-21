// Avatales.Services.AvatarService
import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../utils/app_utils.dart';
import 'network_service.dart';
import 'storage_service.dart';

/// Service für Avatar-Management und -Operations
class AvatarService {
  static AvatarService? _instance;
  static AvatarService get instance => _instance ??= AvatarService._();
  AvatarService._();

  final NetworkService _networkService = NetworkService.instance;
  final StorageService _storageService = StorageService.instance;

  // Cache für Avatare
  final Map<String, Avatar> _avatarCache = {};
  final Map<String, List<Avatar>> _categoryCache = {};
  
  // Event Streams
  final _avatarUpdatedController = StreamController<Avatar>.broadcast();
  final _avatarDeletedController = StreamController<String>.broadcast();
  final _favoritesChangedController = StreamController<List<String>>.broadcast();

  Stream<Avatar> get avatarUpdated => _avatarUpdatedController.stream;
  Stream<String> get avatarDeleted => _avatarDeletedController.stream;
  Stream<List<String>> get favoritesChanged => _favoritesChangedController.stream;

  // ===== Avatar CRUD Operations =====

  /// Erstellt einen neuen Avatar
  Future<Avatar> createAvatar(CreateAvatarRequest request) async {
    try {
      AppUtils.debugLog('Creating avatar: ${request.name}');

      // Validierung
      if (request.name.trim().isEmpty) {
        throw AvatarException('Avatar name cannot be empty');
      }

      // Avatar ID generieren
      final avatarId = _generateAvatarId();

      // Avatar-Daten erstellen
      final avatar = Avatar(
        id: avatarId,
        name: request.name.trim(),
        description: request.description?.trim() ?? '',
        category: request.category,
        style: request.style,
        colors: request.colors,
        accessories: request.accessories,
        tags: request.tags,
        isPublic: request.isPublic,
        isPremium: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        authorId: 'current_user', // TODO: Get from AuthService
        authorName: 'Current User',
        stats: const AvatarStats(
          likes: 0,
          downloads: 0,
          views: 0,
          comments: 0,
        ),
      );

      // Lokal speichern
      await _saveAvatarLocally(avatar);

      // Zu Server senden (wenn online)
      if (await _networkService.isConnected()) {
        try {
          final serverAvatar = await _uploadAvatarToServer(avatar);
          // Server-Version verwenden (hat möglicherweise zusätzliche Daten)
          _avatarCache[serverAvatar.id] = serverAvatar;
          _avatarUpdatedController.add(serverAvatar);
          return serverAvatar;
        } catch (e) {
          AppUtils.errorLog('Failed to upload avatar to server', error: e);
          // Fallback auf lokale Version
        }
      }

      // Cache aktualisieren
      _avatarCache[avatar.id] = avatar;
      _avatarUpdatedController.add(avatar);

      AppUtils.debugLog('Avatar created successfully: ${avatar.id}');
      return avatar;
    } catch (e) {
      AppUtils.errorLog('Failed to create avatar', error: e);
      rethrow;
    }
  }

  /// Lädt einen Avatar nach ID
  Future<Avatar?> getAvatar(String avatarId) async {
    try {
      // Zuerst im Cache suchen
      if (_avatarCache.containsKey(avatarId)) {
        return _avatarCache[avatarId];
      }

      // Lokal suchen
      final localAvatar = await _loadAvatarLocally(avatarId);
      if (localAvatar != null) {
        _avatarCache[avatarId] = localAvatar;
        return localAvatar;
      }

      // Vom Server laden
      if (await _networkService.isConnected()) {
        final serverAvatar = await _fetchAvatarFromServer(avatarId);
        if (serverAvatar != null) {
          _avatarCache[avatarId] = serverAvatar;
          await _saveAvatarLocally(serverAvatar);
          return serverAvatar;
        }
      }

      return null;
    } catch (e) {
      AppUtils.errorLog('Failed to get avatar: $avatarId', error: e);
      return null;
    }
  }

  /// Lädt Avatare nach Kategorie
  Future<List<Avatar>> getAvatarsByCategory(
    String category, {
    int page = 0,
    int limit = 20,
    AvatarSortOrder sortOrder = AvatarSortOrder.newest,
  }) async {
    try {
      final cacheKey = '${category}_${sortOrder.name}_${page}_$limit';
      
      // Cache prüfen
      if (_categoryCache.containsKey(cacheKey)) {
        return _categoryCache[cacheKey]!;
      }

      List<Avatar> avatars = [];

      // Vom Server laden (bevorzugt)
      if (await _networkService.isConnected()) {
        try {
          avatars = await _fetchAvatarsByCategoryFromServer(
            category,
            page: page,
            limit: limit,
            sortOrder: sortOrder,
          );
          // Lokal cachen
          for (final avatar in avatars) {
            await _saveAvatarLocally(avatar);
            _avatarCache[avatar.id] = avatar;
          }
        } catch (e) {
          AppUtils.errorLog('Failed to fetch avatars from server', error: e);
        }
      }

      // Fallback auf lokale Daten
      if (avatars.isEmpty) {
        avatars = await _loadAvatarsLocallyByCategory(category, sortOrder);
      }

      // Cache aktualisieren
      _categoryCache[cacheKey] = avatars;

      return avatars;
    } catch (e) {
      AppUtils.errorLog('Failed to get avatars by category: $category', error: e);
      return [];
    }
  }

  /// Sucht nach Avataren
  Future<List<Avatar>> searchAvatars(
    String query, {
    List<String>? categories,
    List<String>? tags,
    int page = 0,
    int limit = 20,
  }) async {
    try {
      if (query.trim().isEmpty) return [];

      List<Avatar> results = [];

      // Server-Suche (bevorzugt)
      if (await _networkService.isConnected()) {
        try {
          results = await _searchAvatarsOnServer(
            query,
            categories: categories,
            tags: tags,
            page: page,
            limit: limit,
          );
        } catch (e) {
          AppUtils.errorLog('Server search failed', error: e);
        }
      }

      // Lokale Suche als Fallback
      if (results.isEmpty) {
        results = await _searchAvatarsLocally(query, categories, tags);
      }

      return results;
    } catch (e) {
      AppUtils.errorLog('Failed to search avatars', error: e);
      return [];
    }
  }

  /// Aktualisiert einen Avatar
  Future<Avatar> updateAvatar(String avatarId, UpdateAvatarRequest request) async {
    try {
      final existingAvatar = await getAvatar(avatarId);
      if (existingAvatar == null) {
        throw AvatarException('Avatar not found: $avatarId');
      }

      // Aktualisierte Version erstellen
      final updatedAvatar = existingAvatar.copyWith(
        name: request.name?.trim(),
        description: request.description?.trim(),
        category: request.category,
        style: request.style,
        colors: request.colors,
        accessories: request.accessories,
        tags: request.tags,
        isPublic: request.isPublic,
        updatedAt: DateTime.now(),
      );

      // Lokal speichern
      await _saveAvatarLocally(updatedAvatar);

      // Server aktualisieren
      if (await _networkService.isConnected()) {
        try {
          await _updateAvatarOnServer(updatedAvatar);
        } catch (e) {
          AppUtils.errorLog('Failed to update avatar on server', error: e);
        }
      }

      // Cache aktualisieren
      _avatarCache[avatarId] = updatedAvatar;
      _avatarUpdatedController.add(updatedAvatar);

      return updatedAvatar;
    } catch (e) {
      AppUtils.errorLog('Failed to update avatar: $avatarId', error: e);
      rethrow;
    }
  }

  /// Löscht einen Avatar
  Future<void> deleteAvatar(String avatarId) async {
    try {
      // Vom Server löschen
      if (await _networkService.isConnected()) {
        try {
          await _deleteAvatarFromServer(avatarId);
        } catch (e) {
          AppUtils.errorLog('Failed to delete avatar from server', error: e);
        }
      }

      // Lokal löschen
      await _deleteAvatarLocally(avatarId);

      // Cache aktualisieren
      _avatarCache.remove(avatarId);
      _categoryCache.clear(); // Cache invalidieren
      _avatarDeletedController.add(avatarId);

      AppUtils.debugLog('Avatar deleted: $avatarId');
    } catch (e) {
      AppUtils.errorLog('Failed to delete avatar: $avatarId', error: e);
      rethrow;
    }
  }

  // ===== Favoriten-Management =====

  /// Fügt Avatar zu Favoriten hinzu
  Future<void> addToFavorites(String avatarId) async {
    try {
      final favorites = await getFavorites();
      if (!favorites.contains(avatarId)) {
        favorites.add(avatarId);
        await _saveFavorites(favorites);
        _favoritesChangedController.add(favorites);
      }
    } catch (e) {
      AppUtils.errorLog('Failed to add to favorites: $avatarId', error: e);
      rethrow;
    }
  }

  /// Entfernt Avatar aus Favoriten
  Future<void> removeFromFavorites(String avatarId) async {
    try {
      final favorites = await getFavorites();
      if (favorites.remove(avatarId)) {
        await _saveFavorites(favorites);
        _favoritesChangedController.add(favorites);
      }
    } catch (e) {
      AppUtils.errorLog('Failed to remove from favorites: $avatarId', error: e);
      rethrow;
    }
  }

  /// Prüft ob Avatar in Favoriten ist
  Future<bool> isFavorite(String avatarId) async {
    try {
      final favorites = await getFavorites();
      return favorites.contains(avatarId);
    } catch (e) {
      AppUtils.errorLog('Failed to check favorite status: $avatarId', error: e);
      return false;
    }
  }

  /// Lädt alle Favoriten-IDs
  Future<List<String>> getFavorites() async {
    try {
      return await _storageService.getStringList('favorites') ?? [];
    } catch (e) {
      AppUtils.errorLog('Failed to get favorites', error: e);
      return [];
    }
  }

  /// Lädt alle Favoriten-Avatare
  Future<List<Avatar>> getFavoriteAvatars() async {
    try {
      final favoriteIds = await getFavorites();
      final avatars = <Avatar>[];

      for (final id in favoriteIds) {
        final avatar = await getAvatar(id);
        if (avatar != null) {
          avatars.add(avatar);
        }
      }

      return avatars;
    } catch (e) {
      AppUtils.errorLog('Failed to get favorite avatars', error: e);
      return [];
    }
  }

  // ===== Private Methods =====

  String _generateAvatarId() {
    return 'avatar_${DateTime.now().millisecondsSinceEpoch}_${AppUtils.generateRandomString(8)}';
  }

  Future<void> _saveFavorites(List<String> favorites) async {
    await _storageService.setStringList('favorites', favorites);
  }

  Future<void> _saveAvatarLocally(Avatar avatar) async {
    final key = 'avatar_${avatar.id}';
    final data = avatar.toJson();
    await _storageService.setString(key, jsonEncode(data));
  }

  Future<Avatar?> _loadAvatarLocally(String avatarId) async {
    try {
      final key = 'avatar_$avatarId';
      final data = await _storageService.getString(key);
      if (data != null) {
        final json = jsonDecode(data) as Map<String, dynamic>;
        return Avatar.fromJson(json);
      }
      return null;
    } catch (e) {
      AppUtils.errorLog('Failed to load avatar locally: $avatarId', error: e);
      return null;
    }
  }

  Future<void> _deleteAvatarLocally(String avatarId) async {
    final key = 'avatar_$avatarId';
    await _storageService.remove(key);
  }

  Future<List<Avatar>> _loadAvatarsLocallyByCategory(
    String category,
    AvatarSortOrder sortOrder,
  ) async {
    // Implementierung für lokale Kategorie-Suche
    // Vereinfacht: Alle lokalen Avatare laden und filtern
    return [];
  }

  Future<List<Avatar>> _searchAvatarsLocally(
    String query,
    List<String>? categories,
    List<String>? tags,
  ) async {
    // Implementierung für lokale Suche
    // Vereinfacht: Alle lokalen Avatare laden und filtern
    return [];
  }

  // Server-Methods (würden echte API-Calls machen)
  Future<Avatar> _uploadAvatarToServer(Avatar avatar) async {
    // Simulierte Server-Interaktion
    await Future.delayed(const Duration(milliseconds: 500));
    return avatar.copyWith(
      stats: const AvatarStats(likes: 1, downloads: 0, views: 5, comments: 0),
    );
  }

  Future<Avatar?> _fetchAvatarFromServer(String avatarId) async {
    // Simulierte Server-Interaktion
    await Future.delayed(const Duration(milliseconds: 200));
    return null; // Würde echten API-Call machen
  }

  Future<List<Avatar>> _fetchAvatarsByCategoryFromServer(
    String category, {
    required int page,
    required int limit,
    required AvatarSortOrder sortOrder,
  }) async {
    // Simulierte Server-Interaktion
    await Future.delayed(const Duration(milliseconds: 300));
    return []; // Würde echten API-Call machen
  }

  Future<List<Avatar>> _searchAvatarsOnServer(
    String query, {
    List<String>? categories,
    List<String>? tags,
    required int page,
    required int limit,
  }) async {
    // Simulierte Server-Interaktion
    await Future.delayed(const Duration(milliseconds: 400));
    return []; // Würde echten API-Call machen
  }

  Future<void> _updateAvatarOnServer(Avatar avatar) async {
    // Simulierte Server-Interaktion
    await Future.delayed(const Duration(milliseconds: 300));
  }

  Future<void> _deleteAvatarFromServer(String avatarId) async {
    // Simulierte Server-Interaktion
    await Future.delayed(const Duration(milliseconds: 200));
  }

  void dispose() {
    _avatarUpdatedController.close();
    _avatarDeletedController.close();
    _favoritesChangedController.close();
  }
}

// ===== Data Models =====

class Avatar {
  final String id;
  final String name;
  final String description;
  final String category;
  final String style;
  final List<Color> colors;
  final List<String> accessories;
  final List<String> tags;
  final bool isPublic;
  final bool isPremium;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String authorId;
  final String authorName;
  final AvatarStats stats;
  final String? imageUrl;
  final Uint8List? imageData;

  const Avatar({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.style,
    required this.colors,
    required this.accessories,
    required this.tags,
    required this.isPublic,
    required this.isPremium,
    required this.createdAt,
    required this.updatedAt,
    required this.authorId,
    required this.authorName,
    required this.stats,
    this.imageUrl,
    this.imageData,
  });

  Avatar copyWith({
    String? name,
    String? description,
    String? category,
    String? style,
    List<Color>? colors,
    List<String>? accessories,
    List<String>? tags,
    bool? isPublic,
    bool? isPremium,
    DateTime? updatedAt,
    AvatarStats? stats,
    String? imageUrl,
    Uint8List? imageData,
  }) {
    return Avatar(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      style: style ?? this.style,
      colors: colors ?? this.colors,
      accessories: accessories ?? this.accessories,
      tags: tags ?? this.tags,
      isPublic: isPublic ?? this.isPublic,
      isPremium: isPremium ?? this.isPremium,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      authorId: authorId,
      authorName: authorName,
      stats: stats ?? this.stats,
      imageUrl: imageUrl ?? this.imageUrl,
      imageData: imageData ?? this.imageData,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category,
      'style': style,
      'colors': colors.map((c) => c.value).toList(),
      'accessories': accessories,
      'tags': tags,
      'isPublic': isPublic,
      'isPremium': isPremium,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'authorId': authorId,
      'authorName': authorName,
      'stats': stats.toJson(),
      'imageUrl': imageUrl,
      'imageData': imageData?.toList(),
    };
  }

  factory Avatar.fromJson(Map<String, dynamic> json) {
    return Avatar(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      category: json['category'],
      style: json['style'],
      colors: (json['colors'] as List<dynamic>)
          .map((c) => Color(c as int))
          .toList(),
      accessories: List<String>.from(json['accessories']),
      tags: List<String>.from(json['tags']),
      isPublic: json['isPublic'],
      isPremium: json['isPremium'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      authorId: json['authorId'],
      authorName: json['authorName'],
      stats: AvatarStats.fromJson(json['stats']),
      imageUrl: json['imageUrl'],
      imageData: json['imageData'] != null 
          ? Uint8List.fromList(List<int>.from(json['imageData']))
          : null,
    );
  }
}

class AvatarStats {
  final int likes;
  final int downloads;
  final int views;
  final int comments;

  const AvatarStats({
    required this.likes,
    required this.downloads,
    required this.views,
    required this.comments,
  });

  Map<String, dynamic> toJson() {
    return {
      'likes': likes,
      'downloads': downloads,
      'views': views,
      'comments': comments,
    };
  }

  factory AvatarStats.fromJson(Map<String, dynamic> json) {
    return AvatarStats(
      likes: json['likes'],
      downloads: json['downloads'],
      views: json['views'],
      comments: json['comments'],
    );
  }
}

class CreateAvatarRequest {
  final String name;
  final String? description;
  final String category;
  final String style;
  final List<Color> colors;
  final List<String> accessories;
  final List<String> tags;
  final bool isPublic;

  const CreateAvatarRequest({
    required this.name,
    this.description,
    required this.category,
    required this.style,
    required this.colors,
    required this.accessories,
    required this.tags,
    this.isPublic = true,
  });
}

class UpdateAvatarRequest {
  final String? name;
  final String? description;
  final String? category;
  final String? style;
  final List<Color>? colors;
  final List<String>? accessories;
  final List<String>? tags;
  final bool? isPublic;

  const UpdateAvatarRequest({
    this.name,
    this.description,
    this.category,
    this.style,
    this.colors,
    this.accessories,
    this.tags,
    this.isPublic,
  });
}

enum AvatarSortOrder {
  newest,
  oldest,
  mostLiked,
  mostDownloaded,
  alphabetical,
}

class AvatarException implements Exception {
  final String message;
  const AvatarException(this.message);

  @override
  String toString() => 'AvatarException: $message';
}