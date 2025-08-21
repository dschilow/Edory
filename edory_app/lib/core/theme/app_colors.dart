// Avatales.Theme.AppColors
import 'package:flutter/material.dart';

class AppColors {
  // Primary Pastell Palette - Inspiriert von den Referenzen
  static const Color primaryBlue = Color(0xFF6BB6FF);
  static const Color primaryPink = Color(0xFFFF8FB1);
  static const Color primaryPurple = Color(0xFFB794F6);
  static const Color primaryMint = Color(0xFF68D8F0);
  static const Color primaryPeach = Color(0xFFFFB088);
  static const Color primaryLavender = Color(0xFFDDD6FE);

  // Secondary Pastell Töne
  static const Color softBlue = Color(0xFFE3F2FD);
  static const Color softPink = Color(0xFFFCE4EC);
  static const Color softPurple = Color(0xFFF3E5F5);
  static const Color softMint = Color(0xFFE0F2F1);
  static const Color softPeach = Color(0xFFFFF3E0);
  static const Color softLavender = Color(0xFFF8F7FF);

  // Gradient Kombinationen
  static const LinearGradient skyGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF87CEEB),
      Color(0xFFE0F6FF),
      Color(0xFFF0F8FF),
    ],
  );

  static const LinearGradient sunsetGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFFFFE4E1),
      Color(0xFFFFB6C1),
      Color(0xFFFFA07A),
    ],
  );

  static const LinearGradient cloudGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFF8F9FA),
      Color(0xFFE9ECEF),
      Color(0xFFDEE2E6),
    ],
  );

  static const LinearGradient dreamGradient = LinearGradient(
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
    colors: [
      Color(0xFFE8D5FF),
      Color(0xFFB794F6),
      Color(0xFF9F7AEA),
    ],
  );

  // Neutral Töne
  static const Color white = Color(0xFFFFFFFF);
  static const Color offWhite = Color(0xFFFAFAFA);
  static const Color lightGray = Color(0xFFF5F5F5);
  static const Color mediumGray = Color(0xFFE0E0E0);
  static const Color darkGray = Color(0xFF757575);
  static const Color charcoal = Color(0xFF424242);

  // Text Farben
  static const Color primaryText = Color(0xFF2C3E50);
  static const Color secondaryText = Color(0xFF7F8C8D);
  static const Color accentText = Color(0xFF6BB6FF);

  // Status Farben - Pastell Varianten
  static const Color success = Color(0xFF90EE90);
  static const Color warning = Color(0xFFFFE135);
  static const Color error = Color(0xFFFFB3BA);
  static const Color info = Color(0xFFB3E5FC);

  // Schatten Farben
  static const Color shadowLight = Color(0x1A000000);
  static const Color shadowMedium = Color(0x33000000);
  static const Color shadowDark = Color(0x4D000000);

  // Spezielle Effekte
  static const Color glassEffect = Color(0x40FFFFFF);
  static const Color shimmerBase = Color(0xFFF0F0F0);
  static const Color shimmerHighlight = Color(0xFFFFFFFF);

  // Card Farben für verschiedene Kategorien
  static const Color cardBlue = Color(0xFFE3F2FD);
  static const Color cardPink = Color(0xFFFCE4EC);
  static const Color cardGreen = Color(0xFFE8F5E8);
  static const Color cardYellow = Color(0xFFFFFDE7);
  static const Color cardPurple = Color(0xFFF3E5F5);
  static const Color cardOrange = Color(0xFFFFF3E0);

  // Utility Methods
  static Color withOpacity(Color color, double opacity) {
    return color.withOpacity(opacity);
  }

  static LinearGradient createCustomGradient({
    required Color startColor,
    required Color endColor,
    Alignment begin = Alignment.topLeft,
    Alignment end = Alignment.bottomRight,
  }) {
    return LinearGradient(
      begin: begin,
      end: end,
      colors: [startColor, endColor],
    );
  }

  // Dynamische Farb-Generierung basierend auf Kontext
  static Color getCardColor(int index) {
    final colors = [
      cardBlue,
      cardPink,
      cardGreen,
      cardYellow,
      cardPurple,
      cardOrange,
    ];
    return colors[index % colors.length];
  }

  static LinearGradient getGradient(String type) {
    switch (type) {
      case 'sky':
        return skyGradient;
      case 'sunset':
        return sunsetGradient;
      case 'cloud':
        return cloudGradient;
      case 'dream':
        return dreamGradient;
      default:
        return skyGradient;
    }
  }
}