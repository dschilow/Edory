// Avatales.State.AppStateProvider
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:edory_app/core/services/avatar_service.dart';
import 'package:edory_app/core/services/network_service.dart';
import 'package:edory_app/core/services/storage_service.dart';
import 'package:edory_app/core/utils/app_utils.dart';

/// Haupt-State-Provider für die gesamte App
class AppStateProvider extends ChangeNotifier {
  static AppStateProvider? _instance;
  static AppStateProvider get instance => _instance ??= AppStateProvider._();
  AppStateProvider._();

  // Services
  final AvatarService _avatarService = AvatarService.instance;
  final NetworkService _networkService = NetworkService.instance;
  final StorageService _storageService = StorageService.instance;

  // App State
  bool _isInitialized = false;
  bool _isOnboardingCompleted = false;
  bool _isConnected = true;
  AppThemeMode _themeMode = AppThemeMode.system;
  String _currentLanguage = 'de';
  
  // User State
  User? _currentUser;
  bool _isLoggedIn = false;

  // Avatar State
  List<Avatar> _recentAvatars = [];
  List<String> _favoriteAvatarIds = [];
  Map<String, List<Avatar>> _categoryAvatars = {};
  List<Avatar> _searchResults = [];
  bool _isLoadingAvatars = false;

  // UI State
  int _currentNavigationIndex = 0;
  bool _showBottomNavigation = true;

  // Getters
  bool get isInitialized => _isInitialized;
  bool get isOnboardingCompleted => _isOnboardingCompleted;
  bool get isConnected => _isConnected;
  AppThemeMode get themeMode => _themeMode;
  String get currentLanguage => _currentLanguage;
  
  User? get currentUser => _currentUser;
  bool get isLoggedIn => _isLoggedIn;
  
  List<Avatar> get recentAvatars => _recentAvatars;
  List<String> get favoriteAvatarIds => _favoriteAvatarIds;
  Map<String, List<Avatar>> get categoryAvatars => _categoryAvatars;
  List<Avatar> get searchResults => _searchResults;
  bool get isLoadingAvatars => _isLoadingAvatars;
  
  int get currentNavigationIndex => _currentNavigationIndex;
  bool get showBottomNavigation => _showBottomNavigation;

  /// Initialisiert den App State
  Future<void> initialize() async {
    try {
      AppUtils.debugLog('Initializing AppStateProvider...');

      // Services initialisieren
      await _storageService.initialize();
      await _networkService.initialize();

      // Gespeicherte Einstellungen laden
      await _loadSavedSettings();
      
      // Netzwerk-Status überwachen
      _networkService.connectivityStream.listen(_onConnectivityChanged);
      
      // Avatar-Events überwachen
      _avatarService.favoritesChanged.listen(_onFavoritesChanged);

      _isInitialized = true;
      notifyListeners();

      AppUtils.debugLog('AppStateProvider initialized successfully');
    } catch (e) {
      AppUtils.errorLog('Failed to initialize AppStateProvider', error: e);
      rethrow;
    }
  }

  /// Lädt gespeicherte Einstellungen
  Future<void> _loadSavedSettings() async {
    try {
      // Onboarding Status
      _isOnboardingCompleted = await _storageService.getBool('onboarding_completed') ?? false;
      
      // Theme Einstellungen
      final themeModeString = await _storageService.getString('theme_mode');
      if (themeModeString != null) {
        _themeMode = AppThemeMode.values.firstWhere(
          (mode) => mode.name == themeModeString,
          orElse: () => AppThemeMode.system,
        );
      }
      
      // Sprache
      _currentLanguage = await _storageService.getString('language') ?? 'de';
      
      // Favoriten laden
      _favoriteAvatarIds = await _storageService.getStringList('favorites') ?? [];
      
      // Benutzer-Session prüfen
      await _checkUserSession();

      AppUtils.debugLog('Settings loaded successfully');
    } catch (e) {
      AppUtils.errorLog('Failed to load settings', error: e);
    }
  }

  /// Prüft die Benutzer-Session
  Future<void> _checkUserSession() async {
    try {
      final userData = await _storageService.getString('user_data');
      if (userData != null) {
        // In einer echten App würde hier die Session validiert werden
        _isLoggedIn = true;
        // _currentUser = User.fromJson(jsonDecode(userData));
      }
    } catch (e) {
      AppUtils.errorLog('Failed to check user session', error: e);
    }
  }

  // ===== App Settings =====

  /// Setzt den Theme-Modus
  Future<void> setThemeMode(AppThemeMode mode) async {
    if (_themeMode != mode) {
      _themeMode = mode;
      await _storageService.setString('theme_mode', mode.name);
      notifyListeners();
      AppUtils.debugLog('Theme mode changed to: ${mode.name}');
    }
  }

  /// Setzt die Sprache
  Future<void> setLanguage(String languageCode) async {
    if (_currentLanguage != languageCode) {
      _currentLanguage = languageCode;
      await _storageService.setString('language', languageCode);
      notifyListeners();
      AppUtils.debugLog('Language changed to: $languageCode');
    }
  }

  /// Markiert Onboarding als abgeschlossen
  Future<void> completeOnboarding() async {
    _isOnboardingCompleted = true;
    await _storageService.setBool('onboarding_completed', true);
    notifyListeners();
    AppUtils.debugLog('Onboarding completed');
  }

  // ===== Navigation State =====

  /// Setzt den aktuellen Navigation Index
  void setNavigationIndex(int index) {
    if (_currentNavigationIndex != index) {
      _currentNavigationIndex = index;
      notifyListeners();
    }
  }

  /// Zeigt/versteckt die Bottom Navigation
  void setBottomNavigationVisibility(bool visible) {
    if (_showBottomNavigation != visible) {
      _showBottomNavigation = visible;
      notifyListeners();
    }
  }

  // ===== Avatar Management =====

  /// Lädt aktuelle Avatare
  Future<void> loadRecentAvatars() async {
    try {
      _isLoadingAvatars = true;
      notifyListeners();

      _recentAvatars = await _avatarService.getAvatarsByCategory(
        'recent',
        limit: 10,
        sortOrder: AvatarSortOrder.newest,
      );

      _isLoadingAvatars = false;
      notifyListeners();
    } catch (e) {
      _isLoadingAvatars = false;
      notifyListeners();
      AppUtils.errorLog('Failed to load recent avatars', error: e);
    }
  }

  /// Lädt Avatare nach Kategorie
  Future<void> loadCategoryAvatars(String category) async {
    try {
      _isLoadingAvatars = true;
      notifyListeners();

      final avatars = await _avatarService.getAvatarsByCategory(category);
      _categoryAvatars[category] = avatars;

      _isLoadingAvatars = false;
      notifyListeners();
    } catch (e) {
      _isLoadingAvatars = false;
      notifyListeners();
      AppUtils.errorLog('Failed to load category avatars: $category', error: e);
    }
  }

  /// Sucht nach Avataren
  Future<void> searchAvatars(String query) async {
    try {
      _isLoadingAvatars = true;
      notifyListeners();

      _searchResults = await _avatarService.searchAvatars(query);

      _isLoadingAvatars = false;
      notifyListeners();
    } catch (e) {
      _isLoadingAvatars = false;
      notifyListeners();
      AppUtils.errorLog('Failed to search avatars: $query', error: e);
    }
  }

  /// Erstellt einen neuen Avatar
  Future<Avatar?> createAvatar(CreateAvatarRequest request) async {
    try {
      final avatar = await _avatarService.createAvatar(request);
      
      // Zu aktuellen Avataren hinzufügen
      _recentAvatars.insert(0, avatar);
      if (_recentAvatars.length > 10) {
        _recentAvatars.removeLast();
      }
      
      notifyListeners();
      return avatar;
    } catch (e) {
      AppUtils.errorLog('Failed to create avatar', error: e);
      return null;
    }
  }

  /// Fügt Avatar zu Favoriten hinzu
  Future<void> addToFavorites(String avatarId) async {
    try {
      await _avatarService.addToFavorites(avatarId);
      if (!_favoriteAvatarIds.contains(avatarId)) {
        _favoriteAvatarIds.add(avatarId);
        notifyListeners();
      }
    } catch (e) {
      AppUtils.errorLog('Failed to add to favorites: $avatarId', error: e);
    }
  }

  /// Entfernt Avatar aus Favoriten
  Future<void> removeFromFavorites(String avatarId) async {
    try {
      await _avatarService.removeFromFavorites(avatarId);
      _favoriteAvatarIds.remove(avatarId);
      notifyListeners();
    } catch (e) {
      AppUtils.errorLog('Failed to remove from favorites: $avatarId', error: e);
    }
  }

  /// Prüft ob Avatar favorisiert ist
  bool isFavorite(String avatarId) {
    return _favoriteAvatarIds.contains(avatarId);
  }

  // ===== User Management =====

  /// Meldet Benutzer an
  Future<bool> loginUser(String email, String password) async {
    try {
      // Hier würde normalerweise der AuthService verwendet werden
      await Future.delayed(const Duration(seconds: 1)); // Simuliert API-Call
      
      _currentUser = User(
        id: 'user_123',
        email: email,
        name: 'Demo User',
        avatarUrl: null,
        isVerified: false,
        createdAt: DateTime.now(),
      );
      
      _isLoggedIn = true;
      
      // Session speichern
      await _storageService.setString('user_data', _currentUser!.toJson());
      
      notifyListeners();
      AppUtils.debugLog('User logged in: $email');
      return true;
    } catch (e) {
      AppUtils.errorLog('Failed to login user', error: e);
      return false;
    }
  }

  /// Meldet Benutzer ab
  Future<void> logoutUser() async {
    try {
      _currentUser = null;
      _isLoggedIn = false;
      
      // Session löschen
      await _storageService.remove('user_data');
      
      // Cache leeren
      _recentAvatars.clear();
      _categoryAvatars.clear();
      _searchResults.clear();
      _favoriteAvatarIds.clear();
      
      notifyListeners();
      AppUtils.debugLog('User logged out');
    } catch (e) {
      AppUtils.errorLog('Failed to logout user', error: e);
    }
  }

  // ===== Event Handlers =====

  void _onConnectivityChanged(bool isConnected) {
    if (_isConnected != isConnected) {
      _isConnected = isConnected;
      notifyListeners();
      AppUtils.debugLog('Connectivity changed: $isConnected');
    }
  }

  void _onFavoritesChanged(List<String> favorites) {
    _favoriteAvatarIds = favorites;
    notifyListeners();
  }

  // ===== Cleanup =====

  @override
  void dispose() {
    super.dispose();
  }
}

/// Provider für App-Einstellungen
class SettingsProvider extends ChangeNotifier {
  final StorageService _storageService = StorageService.instance;

  // Settings
  bool _notificationsEnabled = true;
  bool _pushNotifications = true;
  bool _emailNotifications = false;
  bool _autoSaveEnabled = true;
  bool _highQualityPreview = true;
  double _animationSpeed = 1.0;
  int _maxCacheSize = 50;

  // Getters
  bool get notificationsEnabled => _notificationsEnabled;
  bool get pushNotifications => _pushNotifications;
  bool get emailNotifications => _emailNotifications;
  bool get autoSaveEnabled => _autoSaveEnabled;
  bool get highQualityPreview => _highQualityPreview;
  double get animationSpeed => _animationSpeed;
  int get maxCacheSize => _maxCacheSize;

  /// Lädt Einstellungen
  Future<void> loadSettings() async {
    try {
      _notificationsEnabled = await _storageService.getBool('notifications_enabled') ?? true;
      _pushNotifications = await _storageService.getBool('push_notifications') ?? true;
      _emailNotifications = await _storageService.getBool('email_notifications') ?? false;
      _autoSaveEnabled = await _storageService.getBool('auto_save_enabled') ?? true;
      _highQualityPreview = await _storageService.getBool('high_quality_preview') ?? true;
      _animationSpeed = await _storageService.getDouble('animation_speed') ?? 1.0;
      _maxCacheSize = await _storageService.getInt('max_cache_size') ?? 50;
      
      notifyListeners();
    } catch (e) {
      AppUtils.errorLog('Failed to load settings', error: e);
    }
  }

  /// Speichert eine Einstellung
  Future<void> _saveSetting(String key, dynamic value) async {
    try {
      if (value is bool) {
        await _storageService.setBool(key, value);
      } else if (value is int) {
        await _storageService.setInt(key, value);
      } else if (value is double) {
        await _storageService.setDouble(key, value);
      } else if (value is String) {
        await _storageService.setString(key, value);
      }
    } catch (e) {
      AppUtils.errorLog('Failed to save setting: $key', error: e);
    }
  }

  // Setter Methods
  Future<void> setNotificationsEnabled(bool enabled) async {
    _notificationsEnabled = enabled;
    await _saveSetting('notifications_enabled', enabled);
    notifyListeners();
  }

  Future<void> setPushNotifications(bool enabled) async {
    _pushNotifications = enabled;
    await _saveSetting('push_notifications', enabled);
    notifyListeners();
  }

  Future<void> setEmailNotifications(bool enabled) async {
    _emailNotifications = enabled;
    await _saveSetting('email_notifications', enabled);
    notifyListeners();
  }

  Future<void> setAutoSaveEnabled(bool enabled) async {
    _autoSaveEnabled = enabled;
    await _saveSetting('auto_save_enabled', enabled);
    notifyListeners();
  }

  Future<void> setHighQualityPreview(bool enabled) async {
    _highQualityPreview = enabled;
    await _saveSetting('high_quality_preview', enabled);
    notifyListeners();
  }

  Future<void> setAnimationSpeed(double speed) async {
    _animationSpeed = speed;
    await _saveSetting('animation_speed', speed);
    notifyListeners();
  }

  Future<void> setMaxCacheSize(int size) async {
    _maxCacheSize = size;
    await _saveSetting('max_cache_size', size);
    notifyListeners();
  }

  /// Setzt alle Einstellungen zurück
  Future<void> resetSettings() async {
    _notificationsEnabled = true;
    _pushNotifications = true;
    _emailNotifications = false;
    _autoSaveEnabled = true;
    _highQualityPreview = true;
    _animationSpeed = 1.0;
    _maxCacheSize = 50;

    // Alle Einstellungen speichern
    await Future.wait([
      _saveSetting('notifications_enabled', _notificationsEnabled),
      _saveSetting('push_notifications', _pushNotifications),
      _saveSetting('email_notifications', _emailNotifications),
      _saveSetting('auto_save_enabled', _autoSaveEnabled),
      _saveSetting('high_quality_preview', _highQualityPreview),
      _saveSetting('animation_speed', _animationSpeed),
      _saveSetting('max_cache_size', _maxCacheSize),
    ]);

    notifyListeners();
  }
}

// ===== Data Models =====

enum AppThemeMode { light, dark, system }

class User {
  final String id;
  final String email;
  final String name;
  final String? avatarUrl;
  final bool isVerified;
  final DateTime createdAt;

  const User({
    required this.id,
    required this.email,
    required this.name,
    this.avatarUrl,
    required this.isVerified,
    required this.createdAt,
  });

  String toJson() {
    // Vereinfacht - in echter App würde JSON verwendet
    return '$id|$email|$name|${avatarUrl ?? ''}|$isVerified|${createdAt.toIso8601String()}';
  }

  factory User.fromJson(String json) {
    final parts = json.split('|');
    return User(
      id: parts[0],
      email: parts[1],
      name: parts[2],
      avatarUrl: parts[3].isEmpty ? null : parts[3],
      isVerified: parts[4] == 'true',
      createdAt: DateTime.parse(parts[5]),
    );
  }
}