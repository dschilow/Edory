// lib/core/theme/app_typography.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'avatales_app_colors.dart';

/// Avatales Typography System - iOS-inspired Typography
/// Namespace: Avatales.Core.Theme.AppTypography
class AppTypography {
  AppTypography._();

  // MARK: - Font Configuration
  
  /// Primary font family - Apple San Francisco Pro Display
  static const String primaryFontFamily = 'SF Pro Display';
  
  /// Secondary font family - Google Fonts Inter (Fallback)
  static String get secondaryFontFamily => GoogleFonts.inter().fontFamily!;
  
  /// Aktuelle Font Family (mit Fallback-Support)
  static String get fontFamily => primaryFontFamily;

  // MARK: - Text Theme
  
  static TextTheme get textTheme => TextTheme(
    // Display Styles (Large Headlines)
    displayLarge: displayLarge,
    displayMedium: displayMedium,
    displaySmall: displaySmall,
    
    // Headline Styles
    headlineLarge: h1,
    headlineMedium: h2,
    headlineSmall: h3,
    
    // Title Styles
    titleLarge: title1,
    titleMedium: title2,
    titleSmall: title3,
    
    // Body Styles
    bodyLarge: bodyLarge,
    bodyMedium: bodyMedium,
    bodySmall: bodySmall,
    
    // Label Styles
    labelLarge: labelLarge,
    labelMedium: labelMedium,
    labelSmall: labelSmall,
  );

  // MARK: - Display Styles (Hero Text)
  
  static const TextStyle displayLarge = TextStyle(
    fontSize: 57,
    fontWeight: FontWeight.w900,
    height: 1.12,
    letterSpacing: -0.25,
    fontFamily: primaryFontFamily,
    color: AppColors.textPrimary,
  );

  static const TextStyle displayMedium = TextStyle(
    fontSize: 45,
    fontWeight: FontWeight.w800,
    height: 1.16,
    letterSpacing: 0,
    fontFamily: primaryFontFamily,
    color: AppColors.textPrimary,
  );

  static const TextStyle displaySmall = TextStyle(
    fontSize: 36,
    fontWeight: FontWeight.w700,
    height: 1.22,
    letterSpacing: 0,
    fontFamily: primaryFontFamily,
    color: AppColors.textPrimary,
  );

  // MARK: - Headline Styles (Main Headings)
  
  static const TextStyle h1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    height: 1.25,
    letterSpacing: 0,
    fontFamily: primaryFontFamily,
    color: AppColors.textPrimary,
  );

  static const TextStyle h2 = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w600,
    height: 1.29,
    letterSpacing: 0,
    fontFamily: primaryFontFamily,
    color: AppColors.textPrimary,
  );

  static const TextStyle h3 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    height: 1.33,
    letterSpacing: 0,
    fontFamily: primaryFontFamily,
    color: AppColors.textPrimary,
  );

  static const TextStyle h4 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.4,
    letterSpacing: 0.15,
    fontFamily: primaryFontFamily,
    color: AppColors.textPrimary,
  );

  // MARK: - Title Styles (Subtitles)
  
  static const TextStyle title1 = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    height: 1.27,
    letterSpacing: 0,
    fontFamily: primaryFontFamily,
    color: AppColors.textPrimary,
  );

  static const TextStyle title2 = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w600,
    height: 1.41,
    letterSpacing: -0.41,
    fontFamily: primaryFontFamily,
    color: AppColors.textPrimary,
  );

  static const TextStyle title3 = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    height: 1.33,
    letterSpacing: -0.24,
    fontFamily: primaryFontFamily,
    color: AppColors.textPrimary,
  );

  // MARK: - Body Styles (Regular Text)
  
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w400,
    height: 1.41,
    letterSpacing: -0.41,
    fontFamily: primaryFontFamily,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    height: 1.33,
    letterSpacing: -0.24,
    fontFamily: primaryFontFamily,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 1.38,
    letterSpacing: -0.08,
    fontFamily: primaryFontFamily,
    color: AppColors.textSecondary,
  );

  // MARK: - Label Styles (Small Text)
  
  static const TextStyle labelLarge = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w500,
    height: 1.33,
    letterSpacing: -0.24,
    fontFamily: primaryFontFamily,
    color: AppColors.textPrimary,
  );

  static const TextStyle labelMedium = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    height: 1.38,
    letterSpacing: -0.08,
    fontFamily: primaryFontFamily,
    color: AppColors.textPrimary,
  );

  static const TextStyle labelSmall = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    height: 1.36,
    letterSpacing: 0.07,
    fontFamily: primaryFontFamily,
    color: AppColors.textSecondary,
  );

  // MARK: - iOS System Styles (Zusätzliche iOS-spezifische Stile)
  
  static const TextStyle largeTitle = TextStyle(
    fontSize: 34,
    fontWeight: FontWeight.w700,
    height: 1.21,
    letterSpacing: 0.37,
    fontFamily: primaryFontFamily,
    color: AppColors.textPrimary,
  );

  static const TextStyle callout = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.31,
    letterSpacing: -0.32,
    fontFamily: primaryFontFamily,
    color: AppColors.textPrimary,
  );

  static const TextStyle subheadline = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    height: 1.33,
    letterSpacing: -0.24,
    fontFamily: primaryFontFamily,
    color: AppColors.textSecondary,
  );

  static const TextStyle footnote = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 1.38,
    letterSpacing: -0.08,
    fontFamily: primaryFontFamily,
    color: AppColors.textSecondary,
  );

  static const TextStyle caption1 = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.33,
    letterSpacing: 0,
    fontFamily: primaryFontFamily,
    color: AppColors.textTertiary,
  );

  static const TextStyle caption2 = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w400,
    height: 1.36,
    letterSpacing: 0.07,
    fontFamily: primaryFontFamily,
    color: AppColors.textTertiary,
  );

  // MARK: - Button Text Styles
  
  static const TextStyle buttonLarge = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w600,
    height: 1.41,
    letterSpacing: -0.41,
    fontFamily: primaryFontFamily,
    color: AppColors.textInverse,
  );

  static const TextStyle buttonMedium = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    height: 1.33,
    letterSpacing: -0.24,
    fontFamily: primaryFontFamily,
    color: AppColors.textInverse,
  );

  static const TextStyle buttonSmall = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    height: 1.38,
    letterSpacing: -0.08,
    fontFamily: primaryFontFamily,
    color: AppColors.textInverse,
  );

  // MARK: - Special Text Styles
  
  static const TextStyle heroTitle = TextStyle(
    fontSize: 40,
    fontWeight: FontWeight.w800,
    height: 1.1,
    letterSpacing: -0.8,
    fontFamily: primaryFontFamily,
    color: AppColors.textPrimary,
  );

  static const TextStyle cardTitle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.33,
    letterSpacing: -0.45,
    fontFamily: primaryFontFamily,
    color: AppColors.textPrimary,
  );

  static const TextStyle cardSubtitle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.43,
    letterSpacing: -0.15,
    fontFamily: primaryFontFamily,
    color: AppColors.textSecondary,
  );

  static const TextStyle navigationTitle = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w600,
    height: 1.41,
    letterSpacing: -0.41,
    fontFamily: primaryFontFamily,
    color: AppColors.textPrimary,
  );

  static const TextStyle tabBarLabel = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    height: 1.3,
    letterSpacing: 0.12,
    fontFamily: primaryFontFamily,
    color: AppColors.textSecondary,
  );

  // MARK: - Helper Methods
  
  /// Erstellt eine semibold Version eines TextStyles
  static TextStyle semibold(TextStyle style) {
    return style.copyWith(fontWeight: FontWeight.w600);
  }

  /// Erstellt eine bold Version eines TextStyles
  static TextStyle bold(TextStyle style) {
    return style.copyWith(fontWeight: FontWeight.w700);
  }

  /// Erstellt eine medium Version eines TextStyles
  static TextStyle medium(TextStyle style) {
    return style.copyWith(fontWeight: FontWeight.w500);
  }

  /// Erstellt eine Version mit angepasster Farbe
  static TextStyle withColor(TextStyle style, Color color) {
    return style.copyWith(color: color);
  }

  /// Erstellt eine Version mit angepasster Größe
  static TextStyle withSize(TextStyle style, double size) {
    return style.copyWith(fontSize: size);
  }

  /// Erstellt eine Version mit angepasster Line Height
  static TextStyle withHeight(TextStyle style, double height) {
    return style.copyWith(height: height);
  }

  // MARK: - Google Fonts Fallback
  
  /// Lädt Google Fonts als Fallback
  static TextTheme getGoogleFontsTextTheme() {
    return GoogleFonts.interTextTheme().copyWith(
      displayLarge: GoogleFonts.inter(textStyle: displayLarge),
      displayMedium: GoogleFonts.inter(textStyle: displayMedium),
      displaySmall: GoogleFonts.inter(textStyle: displaySmall),
      headlineLarge: GoogleFonts.inter(textStyle: h1),
      headlineMedium: GoogleFonts.inter(textStyle: h2),
      headlineSmall: GoogleFonts.inter(textStyle: h3),
      titleLarge: GoogleFonts.inter(textStyle: title1),
      titleMedium: GoogleFonts.inter(textStyle: title2),
      titleSmall: GoogleFonts.inter(textStyle: title3),
      bodyLarge: GoogleFonts.inter(textStyle: bodyLarge),
      bodyMedium: GoogleFonts.inter(textStyle: bodyMedium),
      bodySmall: GoogleFonts.inter(textStyle: bodySmall),
      labelLarge: GoogleFonts.inter(textStyle: labelLarge),
      labelMedium: GoogleFonts.inter(textStyle: labelMedium),
      labelSmall: GoogleFonts.inter(textStyle: labelSmall),
    );
  }
}