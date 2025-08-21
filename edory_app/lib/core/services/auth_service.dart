// Avatales.Services.AuthService
import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../utils/app_utils.dart';
import 'network_service.dart';
import 'storage_service.dart';

/// Service für Authentifizierung und Benutzerverwaltung
class AuthService {
  static AuthService? _instance;
  static AuthService get instance => _instance ??= AuthService._();
  AuthService._();

  final NetworkService _networkService = NetworkService.instance;
  final StorageService _storageService = StorageService.instance;

  // Auth State
  AuthUser? _currentUser;
  String? _accessToken;
  String? _refreshToken;
  DateTime? _tokenExpiry;
  bool _isInitialized = false;

  // Event Streams
  final StreamController<AuthState> _authStateController = 
      StreamController<AuthState>.broadcast();
  final StreamController<AuthUser?> _userController = 
      StreamController<AuthUser?>.broadcast();

  // Getters
  bool get isInitialized => _isInitialized;
  AuthUser? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null && _accessToken != null;
  bool get hasValidToken => _accessToken != null && !_isTokenExpired();
  
  Stream<AuthState> get authStateStream => _authStateController.stream;
  Stream<AuthUser?> get userStream => _userController.stream;

  /// Initialisiert den Auth Service
  Future<void> initialize() async {
    try {
      AppUtils.debugLog('Initializing AuthService...');

      // Gespeicherte Session laden
      await _loadStoredSession();
      
      // Token-Validierung starten
      _startTokenValidation();

      _isInitialized = true;
      _authStateController.add(AuthState.initialized);

      AppUtils.debugLog('AuthService initialized successfully');
    } catch (e) {
      AppUtils.errorLog('Failed to initialize AuthService', error: e);
      _authStateController.add(AuthState.error);
    }
  }

  // ===== Authentication Methods =====

  /// Registriert einen neuen Benutzer
  Future<AuthResult> register({
    required String email,
    required String password,
    required String name,
    String? username,
  }) async {
    try {
      _authStateController.add(AuthState.loading);

      // Input-Validierung
      final validationResult = _validateRegistrationInput(email, password, name);
      if (!validationResult.success) {
        _authStateController.add(AuthState.idle);
        return validationResult;
      }

      // API-Request
      final response = await _networkService.post('/auth/register', body: {
        'email': email.toLowerCase().trim(),
        'password': password,
        'name': name.trim(),
        'username': username?.toLowerCase().trim(),
        'deviceInfo': await _getDeviceInfo(),
      });

      if (response.success && response.data != null) {
        final authData = response.data as Map<String, dynamic>;
        await _handleSuccessfulAuth(authData);
        
        _authStateController.add(AuthState.authenticated);
        return AuthResult.success(message: 'Registrierung erfolgreich');
      } else {
        _authStateController.add(AuthState.idle);
        return AuthResult.failure(
          message: response.message ?? 'Registrierung fehlgeschlagen',
        );
      }
    } catch (e) {
      AppUtils.errorLog('Registration failed', error: e);
      _authStateController.add(AuthState.error);
      return AuthResult.failure(message: 'Ein Fehler ist aufgetreten');
    }
  }

  /// Meldet einen Benutzer an
  Future<AuthResult> login({
    required String email,
    required String password,
    bool rememberMe = false,
  }) async {
    try {
      _authStateController.add(AuthState.loading);

      // Input-Validierung
      if (!AppUtils.isValidEmail(email)) {
        _authStateController.add(AuthState.idle);
        return AuthResult.failure(message: 'Ungültige E-Mail-Adresse');
      }

      if (password.isEmpty) {
        _authStateController.add(AuthState.idle);
        return AuthResult.failure(message: 'Passwort darf nicht leer sein');
      }

      // API-Request
      final response = await _networkService.post('/auth/login', body: {
        'email': email.toLowerCase().trim(),
        'password': password,
        'rememberMe': rememberMe,
        'deviceInfo': await _getDeviceInfo(),
      });

      if (response.success && response.data != null) {
        final authData = response.data as Map<String, dynamic>;
        await _handleSuccessfulAuth(authData);
        
        _authStateController.add(AuthState.authenticated);
        return AuthResult.success(message: 'Anmeldung erfolgreich');
      } else {
        _authStateController.add(AuthState.idle);
        return AuthResult.failure(
          message: response.message ?? 'Anmeldung fehlgeschlagen',
        );
      }
    } catch (e) {
      AppUtils.errorLog('Login failed', error: e);
      _authStateController.add(AuthState.error);
      return AuthResult.failure(message: 'Ein Fehler ist aufgetreten');
    }
  }

  /// Meldet den aktuellen Benutzer ab
  Future<void> logout() async {
    try {
      _authStateController.add(AuthState.loading);

      // Server-seitige Abmeldung (optional)
      if (_accessToken != null) {
        try {
          await _networkService.post('/auth/logout', body: {
            'token': _accessToken,
          });
        } catch (e) {
          AppUtils.errorLog('Server logout failed', error: e);
          // Trotzdem lokale Abmeldung durchführen
        }
      }

      // Lokale Session löschen
      await _clearLocalSession();

      _authStateController.add(AuthState.unauthenticated);
      AppUtils.debugLog('User logged out successfully');
    } catch (e) {
      AppUtils.errorLog('Logout failed', error: e);
      _authStateController.add(AuthState.error);
    }
  }

  /// Sendet eine Passwort-Reset E-Mail
  Future<AuthResult> sendPasswordReset(String email) async {
    try {
      if (!AppUtils.isValidEmail(email)) {
        return AuthResult.failure(message: 'Ungültige E-Mail-Adresse');
      }

      final response = await _networkService.post('/auth/password-reset', body: {
        'email': email.toLowerCase().trim(),
      });

      if (response.success) {
        return AuthResult.success(
          message: 'Passwort-Reset E-Mail wurde gesendet',
        );
      } else {
        return AuthResult.failure(
          message: response.message ?? 'Passwort-Reset fehlgeschlagen',
        );
      }
    } catch (e) {
      AppUtils.errorLog('Password reset failed', error: e);
      return AuthResult.failure(message: 'Ein Fehler ist aufgetreten');
    }
  }

  /// Ändert das Passwort
  Future<AuthResult> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      if (!isLoggedIn) {
        return AuthResult.failure(message: 'Nicht angemeldet');
      }

      final passwordStrength = AppUtils.getPasswordStrength(newPassword);
      if (passwordStrength == PasswordStrength.weak) {
        return AuthResult.failure(
          message: 'Passwort ist zu schwach',
        );
      }

      final response = await _networkService.put('/auth/password', body: {
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      });

      if (response.success) {
        return AuthResult.success(message: 'Passwort wurde geändert');
      } else {
        return AuthResult.failure(
          message: response.message ?? 'Passwort-Änderung fehlgeschlagen',
        );
      }
    } catch (e) {
      AppUtils.errorLog('Password change failed', error: e);
      return AuthResult.failure(message: 'Ein Fehler ist aufgetreten');
    }
  }

  /// Aktualisiert das Benutzerprofil
  Future<AuthResult> updateProfile({
    String? name,
    String? username,
    String? bio,
    String? avatarUrl,
  }) async {
    try {
      if (!isLoggedIn) {
        return AuthResult.failure(message: 'Nicht angemeldet');
      }

      final updateData = <String, dynamic>{};
      if (name != null) updateData['name'] = name.trim();
      if (username != null) updateData['username'] = username.toLowerCase().trim();
      if (bio != null) updateData['bio'] = bio.trim();
      if (avatarUrl != null) updateData['avatarUrl'] = avatarUrl;

      if (updateData.isEmpty) {
        return AuthResult.failure(message: 'Keine Änderungen vorgenommen');
      }

      final response = await _networkService.put('/auth/profile', body: updateData);

      if (response.success && response.data != null) {
        final userData = response.data as Map<String, dynamic>;
        _currentUser = AuthUser.fromJson(userData);
        await _saveUserData();
        _userController.add(_currentUser);
        
        return AuthResult.success(message: 'Profil wurde aktualisiert');
      } else {
        return AuthResult.failure(
          message: response.message ?? 'Profil-Update fehlgeschlagen',
        );
      }
    } catch (e) {
      AppUtils.errorLog('Profile update failed', error: e);
      return AuthResult.failure(message: 'Ein Fehler ist aufgetreten');
    }
  }

  /// Löscht das Benutzerkonto
  Future<AuthResult> deleteAccount(String password) async {
    try {
      if (!isLoggedIn) {
        return AuthResult.failure(message: 'Nicht angemeldet');
      }

      final response = await _networkService.delete('/auth/account', body: {
        'password': password,
      });

      if (response.success) {
        await _clearLocalSession();
        _authStateController.add(AuthState.unauthenticated);
        
        return AuthResult.success(message: 'Konto wurde gelöscht');
      } else {
        return AuthResult.failure(
          message: response.message ?? 'Konto-Löschung fehlgeschlagen',
        );
      }
    } catch (e) {
      AppUtils.errorLog('Account deletion failed', error: e);
      return AuthResult.failure(message: 'Ein Fehler ist aufgetreten');
    }
  }

  // ===== Token Management =====

  /// Erneuert den Access Token
  Future<bool> refreshAccessToken() async {
    try {
      if (_refreshToken == null) {
        AppUtils.debugLog('No refresh token available');
        return false;
      }

      final response = await _networkService.post('/auth/refresh', body: {
        'refreshToken': _refreshToken,
      });

      if (response.success && response.data != null) {
        final tokenData = response.data as Map<String, dynamic>;
        await _saveTokens(
          tokenData['accessToken'],
          tokenData['refreshToken'],
          tokenData['expiresIn'],
        );
        
        AppUtils.debugLog('Access token refreshed successfully');
        return true;
      } else {
        AppUtils.debugLog('Token refresh failed: ${response.message}');
        await _clearLocalSession();
        _authStateController.add(AuthState.unauthenticated);
        return false;
      }
    } catch (e) {
      AppUtils.errorLog('Token refresh failed', error: e);
      return false;
    }
  }

  /// Prüft ob der Token abgelaufen ist
  bool _isTokenExpired() {
    if (_tokenExpiry == null) return true;
    return DateTime.now().isAfter(_tokenExpiry!);
  }

  /// Startet die Token-Validierung
  void _startTokenValidation() {
    Timer.periodic(const Duration(minutes: 5), (_) async {
      if (isLoggedIn && _isTokenExpired()) {
        AppUtils.debugLog('Token expired, attempting refresh...');
        final refreshed = await refreshAccessToken();
        if (!refreshed) {
          AppUtils.debugLog('Token refresh failed, logging out...');
          await logout();
        }
      }
    });
  }

  // ===== Private Methods =====

  /// Behandelt erfolgreiche Authentifizierung
  Future<void> _handleSuccessfulAuth(Map<String, dynamic> authData) async {
    // Benutzer-Daten
    final userData = authData['user'] as Map<String, dynamic>;
    _currentUser = AuthUser.fromJson(userData);

    // Token-Daten
    await _saveTokens(
      authData['accessToken'],
      authData['refreshToken'],
      authData['expiresIn'],
    );

    // Session speichern
    await _saveSession();
    
    _userController.add(_currentUser);
    AppUtils.debugLog('Authentication successful for user: ${_currentUser!.email}');
  }

  /// Speichert Tokens
  Future<void> _saveTokens(String accessToken, String? refreshToken, int expiresIn) async {
    _accessToken = accessToken;
    _refreshToken = refreshToken;
    _tokenExpiry = DateTime.now().add(Duration(seconds: expiresIn));
    
    // Tokens für HTTP-Requests setzen
    _networkService.setAuthToken(accessToken);
  }

  /// Speichert die Session lokal
  Future<void> _saveSession() async {
    try {
      await _saveUserData();
      await _saveTokenData();
    } catch (e) {
      AppUtils.errorLog('Failed to save session', error: e);
    }
  }

  /// Speichert Benutzer-Daten
  Future<void> _saveUserData() async {
    if (_currentUser != null) {
      await _storageService.setString('user_data', jsonEncode(_currentUser!.toJson()));
    }
  }

  /// Speichert Token-Daten
  Future<void> _saveTokenData() async {
    final tokenData = {
      'accessToken': _accessToken,
      'refreshToken': _refreshToken,
      'expiresAt': _tokenExpiry?.toIso8601String(),
    };
    await _storageService.setString('token_data', jsonEncode(tokenData));
  }

  /// Lädt gespeicherte Session
  Future<void> _loadStoredSession() async {
    try {
      // Benutzer-Daten laden
      final userDataString = await _storageService.getString('user_data');
      if (userDataString != null) {
        final userData = jsonDecode(userDataString) as Map<String, dynamic>;
        _currentUser = AuthUser.fromJson(userData);
        _userController.add(_currentUser);
      }

      // Token-Daten laden
      final tokenDataString = await _storageService.getString('token_data');
      if (tokenDataString != null) {
        final tokenData = jsonDecode(tokenDataString) as Map<String, dynamic>;
        _accessToken = tokenData['accessToken'];
        _refreshToken = tokenData['refreshToken'];
        
        if (tokenData['expiresAt'] != null) {
          _tokenExpiry = DateTime.parse(tokenData['expiresAt']);
        }

        // Token für HTTP-Requests setzen
        if (_accessToken != null && !_isTokenExpired()) {
          _networkService.setAuthToken(_accessToken!);
          _authStateController.add(AuthState.authenticated);
        } else {
          // Token abgelaufen, versuche Refresh
          final refreshed = await refreshAccessToken();
          if (refreshed) {
            _authStateController.add(AuthState.authenticated);
          } else {
            await _clearLocalSession();
            _authStateController.add(AuthState.unauthenticated);
          }
        }
      } else {
        _authStateController.add(AuthState.unauthenticated);
      }
    } catch (e) {
      AppUtils.errorLog('Failed to load stored session', error: e);
      _authStateController.add(AuthState.unauthenticated);
    }
  }

  /// Löscht lokale Session
  Future<void> _clearLocalSession() async {
    try {
      _currentUser = null;
      _accessToken = null;
      _refreshToken = null;
      _tokenExpiry = null;

      await _storageService.remove('user_data');
      await _storageService.remove('token_data');
      
      _networkService.clearAuthToken();
      _userController.add(null);
      
      AppUtils.debugLog('Local session cleared');
    } catch (e) {
      AppUtils.errorLog('Failed to clear local session', error: e);
    }
  }

  /// Validiert Registrierungsdaten
  AuthResult _validateRegistrationInput(String email, String password, String name) {
    if (!AppUtils.isValidEmail(email)) {
      return AuthResult.failure(message: 'Ungültige E-Mail-Adresse');
    }

    if (name.trim().length < 2) {
      return AuthResult.failure(message: 'Name muss mindestens 2 Zeichen lang sein');
    }

    final passwordStrength = AppUtils.getPasswordStrength(password);
    if (passwordStrength == PasswordStrength.weak) {
      return AuthResult.failure(
        message: 'Passwort ist zu schwach. Verwende mindestens 8 Zeichen.',
      );
    }

    return AuthResult.success();
  }

  /// Sammelt Geräteinformationen
  Future<Map<String, dynamic>> _getDeviceInfo() async {
    return {
      'platform': defaultTargetPlatform.name,
      'appVersion': '1.0.0',
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  void dispose() {
    _authStateController.close();
    _userController.close();
  }
}

// ===== Data Models =====

class AuthUser {
  final String id;
  final String email;
  final String name;
  final String? username;
  final String? bio;
  final String? avatarUrl;
  final bool isVerified;
  final bool isAdmin;
  final DateTime createdAt;
  final DateTime? lastLoginAt;

  const AuthUser({
    required this.id,
    required this.email,
    required this.name,
    this.username,
    this.bio,
    this.avatarUrl,
    required this.isVerified,
    required this.isAdmin,
    required this.createdAt,
    this.lastLoginAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'username': username,
      'bio': bio,
      'avatarUrl': avatarUrl,
      'isVerified': isVerified,
      'isAdmin': isAdmin,
      'createdAt': createdAt.toIso8601String(),
      'lastLoginAt': lastLoginAt?.toIso8601String(),
    };
  }

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: json['id'],
      email: json['email'],
      name: json['name'],
      username: json['username'],
      bio: json['bio'],
      avatarUrl: json['avatarUrl'],
      isVerified: json['isVerified'] ?? false,
      isAdmin: json['isAdmin'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
      lastLoginAt: json['lastLoginAt'] != null 
          ? DateTime.parse(json['lastLoginAt'])
          : null,
    );
  }
}

class AuthResult {
  final bool success;
  final String? message;
  final Map<String, dynamic>? data;

  const AuthResult({
    required this.success,
    this.message,
    this.data,
  });

  factory AuthResult.success({String? message, Map<String, dynamic>? data}) {
    return AuthResult(success: true, message: message, data: data);
  }

  factory AuthResult.failure({required String message}) {
    return AuthResult(success: false, message: message);
  }
}

enum AuthState {
  loading,
  initialized,
  authenticated,
  unauthenticated,
  error,
  idle,
}