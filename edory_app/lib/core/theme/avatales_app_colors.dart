// lib/core/theme/app_colors.dart
import 'package:flutter/material.dart';

/// Avatales App Colors - Modern Premium Farbpalette
/// Namespace: Avatales.Core.Theme.AppColors
class AppColors {
  AppColors._();

  // MARK: - Primary Brand Colors
  static const Color primaryBlue = Color(0xFF007AFF);
  static const Color primaryPurple = Color(0xFF5856D6);
  static const Color primaryTeal = Color(0xFF30D5C8);
  static const Color primaryGreen = Color(0xFF34C759);
  static const Color primaryOrange = Color(0xFFFF9500);
  static const Color primaryRed = Color(0xFFFF3B30);
  static const Color primaryPink = Color(0xFFFF2D92);

  // MARK: - Pastel Accent Colors (Für Avatares/Charaktere)
  static const Color pastelRed = Color(0xFFFF6B6B);
  static const Color pastelOrange = Color(0xFFFFCC02);
  static const Color pastelYellow = Color(0xFFFFE66D);
  static const Color pastelGreen = Color(0xFF4ECDC4);
  static const Color pastelBlue = Color(0xFF74B9FF);
  static const Color pastelPurple = Color(0xFFA29BFE);
  static const Color pastelPink = Color(0xFFFF7675);
  static const Color pastelTeal = Color(0xFF00CEC9);

  // MARK: - System Colors (iOS kompatibel)
  static const Color systemBlue = Color(0xFF007AFF);
  static const Color systemGreen = Color(0xFF34C759);
  static const Color systemIndigo = Color(0xFF5856D6);
  static const Color systemOrange = Color(0xFFFF9500);
  static const Color systemPink = Color(0xFFFF2D92);
  static const Color systemPurple = Color(0xFFAF52DE);
  static const Color systemRed = Color(0xFFFF3B30);
  static const Color systemTeal = Color(0xFF30D5C8);
  static const Color systemYellow = Color(0xFFFFCC00);

  // MARK: - Background Colors
  static const Color backgroundPrimary = Color(0xFFFAFAFA);    // Main background
  static const Color backgroundSecondary = Color(0xFFFFFFFF);  // Card background
  static const Color backgroundTertiary = Color(0xFFF2F2F7);   // Secondary background
  static const Color backgroundQuaternary = Color(0xFFE5E5EA); // Disabled background

  // MARK: - Text Colors
  static const Color textPrimary = Color(0xFF000000);          // Main text
  static const Color textSecondary = Color(0xFF6D6D70);       // Secondary text
  static const Color textTertiary = Color(0xFF999999);        // Placeholder text
  static const Color textQuaternary = Color(0xFFBBBBBB);      // Disabled text
  static const Color textInverse = Color(0xFFFFFFFF);         // White text

  // MARK: - Gray Scale
  static const Color gray1 = Color(0xFF8E8E93);               // systemGray
  static const Color gray2 = Color(0xFFAEAEB2);               // systemGray2
  static const Color gray3 = Color(0xFFC7C7CC);               // systemGray3
  static const Color gray4 = Color(0xFFD1D1D6);               // systemGray4
  static const Color gray5 = Color(0xFFE5E5EA);               // systemGray5
  static const Color gray6 = Color(0xFFF2F2F7);               // systemGray6

  // MARK: - Semantic Colors
  static const Color success = systemGreen;
  static const Color warning = systemOrange;
  static const Color error = systemRed;
  static const Color info = systemBlue;

  // MARK: - Border & Separator Colors
  static const Color borderPrimary = Color(0xFFE0E0E0);
  static const Color borderSecondary = Color(0xFFF0F0F0);
  static const Color separator = Color(0xFFE5E5EA);
  static const Color divider = Color(0xFFD1D1D6);

  // MARK: - Shadow Colors
  static const Color shadowLight = Color(0x0F000000);         // 6% black
  static const Color shadowMedium = Color(0x1A000000);        // 10% black
  static const Color shadowHeavy = Color(0x33000000);         // 20% black

  // MARK: - Gradient Definitions
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryBlue, primaryTeal],
  );

  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryPurple, primaryPink],
  );

  static const LinearGradient successGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryGreen, pastelTeal],
  );

  static const LinearGradient warningGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryOrange, pastelYellow],
  );

  static const LinearGradient errorGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryRed, pastelRed],
  );

  // MARK: - Character Avatar Gradients
  static const List<LinearGradient> characterGradients = [
    LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [pastelBlue, pastelTeal],
    ),
    LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [pastelPurple, pastelPink],
    ),
    LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [pastelGreen, pastelYellow],
    ),
    LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [pastelOrange, pastelRed],
    ),
  ];

  // MARK: - Helper Methods
  
  /// Gibt einen zufälligen Character-Gradient zurück
  static LinearGradient getRandomCharacterGradient(int index) {
    return characterGradients[index % characterGradients.length];
  }

  /// Konvertiert Hex-Color zu Flutter Color
  static Color fromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  /// Erstellt eine transparente Version einer Farbe
  static Color withOpacity(Color color, double opacity) {
    return color.withOpacity(opacity);
  }

  /// Erstellt eine aufgehellte Version einer Farbe
  static Color lighten(Color color, [double amount = .1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(color);
    final hslLight = hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0));
    return hslLight.toColor();
  }

  /// Erstellt eine abgedunkelte Version einer Farbe
  static Color darken(Color color, [double amount = .1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(color);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return hslDark.toColor();
  }
}