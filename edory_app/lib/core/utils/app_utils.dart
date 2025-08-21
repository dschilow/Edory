// Avatales.Utils.AppUtils
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';

/// Utility-Klasse mit verschiedenen Helper-Funktionen für die gesamte App
class AppUtils {
  AppUtils._(); // Private Constructor für Utility-Klasse

  // ===== Format Utilities =====
  
  /// Formatiert große Zahlen in lesbares Format (1.2k, 1.5M, etc.)
  static String formatNumber(int number) {
    if (number < 1000) {
      return number.toString();
    } else if (number < 1000000) {
      double value = number / 1000.0;
      return value % 1 == 0 
          ? '${value.toInt()}k' 
          : '${value.toStringAsFixed(1)}k';
    } else {
      double value = number / 1000000.0;
      return value % 1 == 0 
          ? '${value.toInt()}M' 
          : '${value.toStringAsFixed(1)}M';
    }
  }

  /// Formatiert Dateigröße in MB, GB, etc.
  static String formatFileSize(int bytes) {
    if (bytes < 1024) return '${bytes}B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)}KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)}GB';
  }

  /// Formatiert Zeitdauer in lesbares Format
  static String formatDuration(Duration duration) {
    if (duration.inDays > 0) {
      return '${duration.inDays}d ${duration.inHours % 24}h';
    } else if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes % 60}m';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes}m';
    } else {
      return '${duration.inSeconds}s';
    }
  }

  /// Formatiert DateTime in deutsches Format
  static String formatDate(DateTime date, {bool includeTime = false}) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateToCheck = DateTime(date.year, date.month, date.day);

    String dateStr;
    if (dateToCheck == today) {
      dateStr = 'Heute';
    } else if (dateToCheck == yesterday) {
      dateStr = 'Gestern';
    } else {
      dateStr = '${date.day}.${date.month}.${date.year}';
    }

    if (includeTime) {
      final timeStr = '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
      return '$dateStr, $timeStr';
    }

    return dateStr;
  }

  /// Formatiert relative Zeit (vor X Minuten, vor X Stunden, etc.)
  static String formatRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Gerade eben';
    } else if (difference.inMinutes < 60) {
      return 'vor ${difference.inMinutes} Min.';
    } else if (difference.inHours < 24) {
      return 'vor ${difference.inHours} Std.';
    } else if (difference.inDays < 7) {
      return 'vor ${difference.inDays} Tagen';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return 'vor $weeks Woche${weeks > 1 ? 'n' : ''}';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return 'vor $months Monat${months > 1 ? 'en' : ''}';
    } else {
      final years = (difference.inDays / 365).floor();
      return 'vor $years Jahr${years > 1 ? 'en' : ''}';
    }
  }

  // ===== Validation Utilities =====
  
  /// Validiert E-Mail-Adresse
  static bool isValidEmail(String email) {
    return RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
        .hasMatch(email);
  }

  /// Validiert Passwort-Stärke
  static PasswordStrength getPasswordStrength(String password) {
    if (password.isEmpty) return PasswordStrength.empty;
    if (password.length < 6) return PasswordStrength.weak;
    
    bool hasUppercase = RegExp(r'[A-Z]').hasMatch(password);
    bool hasLowercase = RegExp(r'[a-z]').hasMatch(password);
    bool hasDigits = RegExp(r'[0-9]').hasMatch(password);
    bool hasSpecialCharacters = RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password);
    
    int criteriaCount = 0;
    if (hasUppercase) criteriaCount++;
    if (hasLowercase) criteriaCount++;
    if (hasDigits) criteriaCount++;
    if (hasSpecialCharacters) criteriaCount++;
    
    if (password.length >= 12 && criteriaCount >= 3) {
      return PasswordStrength.strong;
    } else if (password.length >= 8 && criteriaCount >= 2) {
      return PasswordStrength.medium;
    } else {
      return PasswordStrength.weak;
    }
  }

  /// Validiert Username
  static bool isValidUsername(String username) {
    return RegExp(r'^[a-zA-Z0-9_]{3,20}$').hasMatch(username);
  }

  // ===== Device & Platform Utilities =====
  
  /// Gibt die Bildschirmgröße-Kategorie zurück
  static ScreenSize getScreenSize(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 600) return ScreenSize.small;
    if (width < 900) return ScreenSize.medium;
    return ScreenSize.large;
  }

  /// Überprüft ob es sich um ein Tablet handelt
  static bool isTablet(BuildContext context) {
    final shortestSide = MediaQuery.of(context).size.shortestSide;
    return shortestSide >= 600;
  }

  /// Gibt die sichere Bereichshöhe zurück
  static double getSafeAreaHeight(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    return mediaQuery.size.height - 
           mediaQuery.padding.top - 
           mediaQuery.padding.bottom;
  }

  // ===== Color Utilities =====
  
  /// Generiert eine zufällige Farbe aus der App-Palette
  static Color getRandomAppColor() {
    final colors = [
      AppColors.primaryBlue,
      AppColors.primaryPink,
      AppColors.primaryMint,
      AppColors.primaryPurple,
      AppColors.primaryPeach,
      AppColors.primaryLavender,
    ];
    return colors[(DateTime.now().millisecondsSinceEpoch % colors.length)];
  }

  /// Bestimmt ob eine Farbe hell oder dunkel ist
  static bool isLightColor(Color color) {
    final luminance = color.computeLuminance();
    return luminance > 0.5;
  }

  /// Gibt die optimale Textfarbe für einen Hintergrund zurück
  static Color getOptimalTextColor(Color backgroundColor) {
    return isLightColor(backgroundColor) 
        ? AppColors.primaryText 
        : AppColors.white;
  }

  // ===== Animation Utilities =====
  
  /// Erstellt eine sanfte Slide-Transition
  static Widget slideTransition({
    required Widget child,
    required Animation<double> animation,
    SlideDirection direction = SlideDirection.fromRight,
  }) {
    Offset begin;
    switch (direction) {
      case SlideDirection.fromLeft:
        begin = const Offset(-1.0, 0.0);
        break;
      case SlideDirection.fromRight:
        begin = const Offset(1.0, 0.0);
        break;
      case SlideDirection.fromTop:
        begin = const Offset(0.0, -1.0);
        break;
      case SlideDirection.fromBottom:
        begin = const Offset(0.0, 1.0);
        break;
    }

    return SlideTransition(
      position: Tween<Offset>(
        begin: begin,
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
      )),
      child: child,
    );
  }

  /// Erstellt eine Fade-Transition mit Scale
  static Widget fadeScaleTransition({
    required Widget child,
    required Animation<double> animation,
  }) {
    return FadeTransition(
      opacity: animation,
      child: ScaleTransition(
        scale: Tween<double>(
          begin: 0.8,
          end: 1.0,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutBack,
        )),
        child: child,
      ),
    );
  }

  // ===== Haptic & Sound Utilities =====
  
  /// Führt leichtes Haptic Feedback aus
  static void lightHaptic() {
    HapticFeedback.lightImpact();
  }

  /// Führt mittleres Haptic Feedback aus
  static void mediumHaptic() {
    HapticFeedback.mediumImpact();
  }

  /// Führt starkes Haptic Feedback aus
  static void heavyHaptic() {
    HapticFeedback.heavyImpact();
  }

  /// Führt Auswahl Haptic Feedback aus
  static void selectionHaptic() {
    HapticFeedback.selectionClick();
  }

  // ===== String Utilities =====
  
  /// Kürzt Text ab und fügt Ellipsis hinzu
  static String truncateText(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  /// Entfernt alle Leerzeichen und Sonderzeichen
  static String sanitizeString(String input) {
    return input.replaceAll(RegExp(r'[^\w\s]'), '').trim();
  }

  /// Konvertiert String zu Title Case
  static String toTitleCase(String input) {
    return input.split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  /// Generiert einen zufälligen String
  static String generateRandomString(int length) {
    const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = DateTime.now().millisecondsSinceEpoch;
    return String.fromCharCodes(Iterable.generate(
      length, (_) => chars.codeUnitAt(random % chars.length),
    ));
  }

  // ===== URL & Deep Link Utilities =====
  
  /// Extrahiert Domain aus URL
  static String? extractDomain(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.host;
    } catch (e) {
      return null;
    }
  }

  /// Validiert URL
  static bool isValidUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https');
    } catch (e) {
      return false;
    }
  }

  // ===== Debug & Development Utilities =====
  
  /// Loggt Debug-Informationen (nur im Debug-Modus)
  static void debugLog(String message, {String? tag}) {
    assert(() {
      final timestamp = DateTime.now().toIso8601String();
      final tagStr = tag != null ? '[$tag] ' : '';
      print('🐛 $timestamp $tagStr$message');
      return true;
    }());
  }

  /// Loggt Fehler-Informationen
  static void errorLog(String message, {Object? error, StackTrace? stackTrace}) {
    assert(() {
      final timestamp = DateTime.now().toIso8601String();
      print('❌ $timestamp ERROR: $message');
      if (error != null) print('   Error Object: $error');
      if (stackTrace != null) print('   Stack Trace: $stackTrace');
      return true;
    }());
  }

  /// Misst Performance einer Funktion
  static Future<T> measurePerformance<T>(
    String operation,
    Future<T> Function() function,
  ) async {
    final stopwatch = Stopwatch()..start();
    try {
      final result = await function();
      stopwatch.stop();
      debugLog('⏱️ $operation took ${stopwatch.elapsedMilliseconds}ms');
      return result;
    } catch (e) {
      stopwatch.stop();
      errorLog('$operation failed after ${stopwatch.elapsedMilliseconds}ms', error: e);
      rethrow;
    }
  }

  // ===== List & Collection Utilities =====
  
  /// Entfernt Duplikate aus einer Liste
  static List<T> removeDuplicates<T>(List<T> list) {
    return list.toSet().toList();
  }

  /// Mischt eine Liste zufällig
  static List<T> shuffleList<T>(List<T> list) {
    final shuffled = List<T>.from(list);
    final random = DateTime.now().millisecondsSinceEpoch;
    for (int i = shuffled.length - 1; i > 0; i--) {
      final j = (random + i) % (i + 1);
      final temp = shuffled[i];
      shuffled[i] = shuffled[j];
      shuffled[j] = temp;
    }
    return shuffled;
  }

  /// Teilt eine Liste in Chunks auf
  static List<List<T>> chunkList<T>(List<T> list, int chunkSize) {
    final chunks = <List<T>>[];
    for (int i = 0; i < list.length; i += chunkSize) {
      chunks.add(list.sublist(
        i, 
        i + chunkSize > list.length ? list.length : i + chunkSize,
      ));
    }
    return chunks;
  }
}

// ===== Enums =====

enum PasswordStrength { empty, weak, medium, strong }

enum ScreenSize { small, medium, large }

enum SlideDirection { fromLeft, fromRight, fromTop, fromBottom }

// ===== Extensions =====

extension PasswordStrengthExtension on PasswordStrength {
  String get description {
    switch (this) {
      case PasswordStrength.empty:
        return 'Passwort eingeben';
      case PasswordStrength.weak:
        return 'Schwach';
      case PasswordStrength.medium:
        return 'Mittel';
      case PasswordStrength.strong:
        return 'Stark';
    }
  }

  Color get color {
    switch (this) {
      case PasswordStrength.empty:
        return AppColors.mediumGray;
      case PasswordStrength.weak:
        return AppColors.error;
      case PasswordStrength.medium:
        return AppColors.warning;
      case PasswordStrength.strong:
        return AppColors.success;
    }
  }

  double get progress {
    switch (this) {
      case PasswordStrength.empty:
        return 0.0;
      case PasswordStrength.weak:
        return 0.25;
      case PasswordStrength.medium:
        return 0.65;
      case PasswordStrength.strong:
        return 1.0;
    }
  }
}

extension ScreenSizeExtension on ScreenSize {
  int get columns {
    switch (this) {
      case ScreenSize.small:
        return 2;
      case ScreenSize.medium:
        return 3;
      case ScreenSize.large:
        return 4;
    }
  }

  double get padding {
    switch (this) {
      case ScreenSize.small:
        return 16.0;
      case ScreenSize.medium:
        return 24.0;
      case ScreenSize.large:
        return 32.0;
    }
  }
}