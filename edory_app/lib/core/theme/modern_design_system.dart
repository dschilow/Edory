// lib/core/theme/modern_design_system.dart
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'avatales_app_colors.dart' as Av;
import 'avatales_app_typography.dart' as Ty;

/// Modern Design System - Wunderschönes Premium Design
/// Inspiriert von den besten Social Media und Wellness Apps
class ModernDesignSystem {
  
  // MARK: - Wunderschöne Premium Farben
  
  /// Hauptfarben - an neues Avatales Theme angepasst
  static const Color primaryBlue = Av.AppColors.primaryBlue;
  static const Color primaryPurple = Av.AppColors.primaryPurple;      
  static const Color primaryPink = Av.AppColors.primaryPink;
  static const Color primaryGreen = Av.AppColors.primaryGreen;
  static const Color primaryOrange = Av.AppColors.primaryOrange;
  static const Color primaryRed = Av.AppColors.primaryRed;
  
  /// Background Colors (Ultra-Premium Look)
  static const Color backgroundPrimary = Av.AppColors.backgroundPrimary;
  static const Color backgroundSecondary = Av.AppColors.backgroundSecondary;
  static const Color backgroundTertiary = Av.AppColors.backgroundTertiary;
  static const Color backgroundCard = Av.AppColors.backgroundSecondary;
  
  // Legacy Support für bestehende Dateien
  static const Color cardBackground = backgroundCard;         // Card White
  static const Color borderColor = Av.AppColors.borderPrimary;
  
  /// Text Colors (Perfekte Hierarchie)
  static const Color textPrimary = Av.AppColors.textPrimary;
  static const Color textSecondary = Av.AppColors.textSecondary;
  static const Color textTertiary = Av.AppColors.textTertiary;
  static const Color textLight = Av.AppColors.textInverse;
  
  /// Accent Colors (Instagram-Style)
  static const Color accentBlue = Av.AppColors.systemBlue;          
  static const Color accentGreen = Av.AppColors.systemGreen;         
  static const Color accentOrange = Av.AppColors.systemOrange;        
  static const Color accentRed = Av.AppColors.systemRed;           
  static const Color accentPurple = Av.AppColors.systemPurple;        
  static const Color accentTeal = Av.AppColors.systemTeal;          
  static const Color accentPink = Av.AppColors.systemPink;          
  
  /// System Colors (iOS-kompatibel)
  static const Color systemGray6 = Av.AppColors.gray6;
  static const Color systemGray4 = Av.AppColors.gray4;
  static const Color systemGray = Av.AppColors.gray1;
  static const Color systemBlue = Av.AppColors.systemBlue;
  static const Color systemRed = Av.AppColors.systemRed;
  static const Color systemGreen = Av.AppColors.systemGreen;
  static const Color systemPurple = Av.AppColors.systemPurple;
  static const Color systemYellow = Av.AppColors.systemYellow;
  
  // Legacy Support
  static const Color primaryColor = accentBlue;
  static const Color successColor = accentGreen;
  static const Color warningColor = accentOrange;
  static const Color errorColor = accentRed;
  static const Color secondaryLabel = Color(0xFF8B96A5);
  static const Color tertiaryLabel = Color(0xFFADB5BD);
  static const Color label = textPrimary;
  static const Color labelColor = textPrimary;
  static const Color primaryTextColor = textPrimary;
  static const Color secondaryTextColor = textSecondary;
  static const Color whiteTextColor = Colors.white;
  static const Color separator = Color(0xFFE5E7EB);
  static const Color secondarySystemGroupedBackground = backgroundCard;
  static const Color tertiarySystemGroupedBackground = backgroundTertiary;
  
  // Pastel Colors
  static const Color pastelRed = systemRed;
  static const Color pastelGreen = systemGreen;
  static const Color pastelBlue = systemBlue;
  static const Color pastelPurple = systemPurple;
  static const Color pastelPink = Color(0xFFFF9EC7);
  
  // MARK: - Instagram-Style Gradients (PREMIUM!)
  
  static const LinearGradient primaryGradient = Av.AppColors.primaryGradient;
  
  static const LinearGradient pinkGradient = Av.AppColors.heroGradient;
  
  static const LinearGradient orangeGradient = Av.AppColors.warningGradient;
  
  static const LinearGradient greenGradient = Av.AppColors.successGradient;
  
  static const LinearGradient tealGradient = Av.AppColors.primaryGradient;
  
  static const LinearGradient purpleGradient = Av.AppColors.heroGradient;
  
  static const LinearGradient redGradient = Av.AppColors.errorGradient;
  
  static const LinearGradient blueGradient = Av.AppColors.primaryGradient;
  
  // MARK: - Premium Typography (Apple-Style)
  
  static const String fontFamily = Ty.AppTypography.primaryFontFamily;
  
  /// Display Styles (Extra Large)
  static const TextStyle displayLarge = TextStyle(
    fontSize: 48,
    fontWeight: FontWeight.w800,
    color: textPrimary,
    fontFamily: fontFamily,
    height: 1.1,
    letterSpacing: -1.0,
  );
  
  static const TextStyle displayMedium = TextStyle(
    fontSize: 36,
    fontWeight: FontWeight.w700,
    color: textPrimary,
    fontFamily: fontFamily,
    height: 1.2,
    letterSpacing: -0.8,
  );
  
  static const TextStyle displaySmall = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w600,
    color: textPrimary,
    fontFamily: fontFamily,
    height: 1.3,
    letterSpacing: -0.4,
  );
  
  /// Headlines
  static const TextStyle h1 = displayLarge;
  static const TextStyle h2 = displayMedium;
  static const TextStyle h3 = displaySmall;
  
  static const TextStyle h4 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: textPrimary,
    fontFamily: fontFamily,
    height: 1.4,
  );
  
  /// iOS-Style Text Styles
  static const TextStyle title3 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: textPrimary,
    fontFamily: fontFamily,
    height: 1.3,
  );
  
  static const TextStyle headline = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w600,
    color: textPrimary,
    fontFamily: fontFamily,
    height: 1.4,
  );
  
  static const TextStyle subheadline = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w500,
    color: textSecondary,
    fontFamily: fontFamily,
    height: 1.4,
  );
  
  /// Body Text
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w400,
    color: textPrimary,
    fontFamily: fontFamily,
    height: 1.5,
  );
  
  static const TextStyle body = bodyLarge;
  
  static const TextStyle bodyMedium = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: textSecondary,
    fontFamily: fontFamily,
    height: 1.5,
  );
  
  static const TextStyle bodySmall = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: textTertiary,
    fontFamily: fontFamily,
    height: 1.4,
  );
  
  /// Labels & Captions  
  static const TextStyle labelStyle = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: textSecondary,
    fontFamily: fontFamily,
    height: 1.3,
    letterSpacing: 0.5,
  );
  
  static const TextStyle footnote = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: textSecondary,
    fontFamily: fontFamily,
    height: 1.3,
  );
  
  static const TextStyle caption = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w400,
    color: textTertiary,
    fontFamily: fontFamily,
    height: 1.2,
    letterSpacing: 0.3,
  );
  
  static const TextStyle caption1 = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: textTertiary,
    fontFamily: fontFamily,
    height: 1.2,
  );
  
  static const TextStyle caption2 = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w400,
    color: textTertiary,
    fontFamily: fontFamily,
    height: 1.2,
  );
  
  // MARK: - Spacing System (8px Grid)
  
  static const double spacing4 = 4.0;
  static const double spacing8 = 8.0;
  static const double spacing12 = 12.0;
  static const double spacing16 = 16.0;
  static const double spacing20 = 20.0;
  static const double spacing24 = 24.0;
  static const double spacing32 = 32.0;
  static const double spacing40 = 40.0;
  static const double spacing48 = 48.0;
  static const double spacing64 = 64.0;
  static const double spacing80 = 80.0;
  
  // MARK: - Border Radius (Modern & Smooth)
  
  static const double radiusSmall = 12.0;
  static const double radiusMedium = 16.0;
  static const double radiusLarge = 24.0;
  static const double radiusXLarge = 32.0;
  static const double radiusRound = 50.0;
  
  // MARK: - Premium Shadows (iOS-Style Depth)
  
  static List<BoxShadow> shadowSmall = [
    BoxShadow(
      color: Colors.black.withOpacity(0.04),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
    BoxShadow(
      color: Colors.black.withOpacity(0.08),
      blurRadius: 1,
      offset: const Offset(0, 0),
    ),
  ];
  
  static List<BoxShadow> shadowMedium = [
    BoxShadow(
      color: Colors.black.withOpacity(0.06),
      blurRadius: 20,
      offset: const Offset(0, 8),
    ),
    BoxShadow(
      color: Colors.black.withOpacity(0.10),
      blurRadius: 2,
      offset: const Offset(0, 1),
    ),
  ];
  
  static List<BoxShadow> shadowLarge = [
    BoxShadow(
      color: Colors.black.withOpacity(0.08),
      blurRadius: 32,
      offset: const Offset(0, 16),
    ),
    BoxShadow(
      color: Colors.black.withOpacity(0.12),
      blurRadius: 4,
      offset: const Offset(0, 2),
    ),
  ];
  
  // Gradient Shadows for Cards
  static List<BoxShadow> gradientShadow(Color gradientColor) => [
    BoxShadow(
      color: gradientColor.withOpacity(0.3),
      blurRadius: 24,
      offset: const Offset(0, 12),
    ),
    BoxShadow(
      color: Colors.black.withOpacity(0.06),
      blurRadius: 8,
      offset: const Offset(0, 4),
    ),
  ];
  
  // MARK: - Animation Durations
  
  static const Duration durationFast = Duration(milliseconds: 150);
  static const Duration durationShort = Duration(milliseconds: 200);
  static const Duration durationMedium = Duration(milliseconds: 250);
  static const Duration durationSlow = Duration(milliseconds: 400);
  static const Duration durationLong = Duration(milliseconds: 500);
  static const Duration durationXSlow = Duration(milliseconds: 600);
  
  // Animation Curves
  static const Curve easeOut = Curves.easeOut;
  
  // MARK: - Premium Component Styles
  
  /// Premium Card Decoration
  static BoxDecoration cardDecoration = BoxDecoration(
    color: backgroundCard,
    borderRadius: BorderRadius.circular(radiusLarge),
    boxShadow: shadowMedium,
    border: Border.all(
      color: Colors.black.withOpacity(0.04),
      width: 1,
    ),
  );
  
  /// Elevated Card Style (Premium Look)
  static BoxDecoration elevatedCardDecoration = BoxDecoration(
    color: backgroundCard,
    borderRadius: BorderRadius.circular(radiusLarge),
    boxShadow: shadowLarge,
  );
  
  /// Gradient Card Style (Instagram-like)
  static BoxDecoration gradientCardDecoration = BoxDecoration(
    gradient: primaryGradient,
    borderRadius: BorderRadius.circular(radiusLarge),
    boxShadow: gradientShadow(primaryGradient.colors.first),
  );
  
  /// Input Field Style
  static InputDecoration inputDecoration({
    String? hintText,
    Widget? prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: bodyMedium,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: backgroundTertiary,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMedium),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMedium),
        borderSide: BorderSide(color: Colors.black.withOpacity(0.08), width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMedium),
        borderSide: BorderSide(color: accentBlue, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: spacing16,
        vertical: spacing16,
      ),
    );
  }
  
  /// Button Styles
  static ButtonStyle primaryButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: Colors.transparent,
    shadowColor: Colors.transparent,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radiusMedium),
    ),
    padding: const EdgeInsets.symmetric(
      horizontal: spacing24,
      vertical: spacing16,
    ),
    textStyle: const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      fontFamily: fontFamily,
    ),
  );
  
  static ButtonStyle secondaryButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: backgroundTertiary,
    foregroundColor: textPrimary,
    shadowColor: Colors.transparent,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radiusMedium),
      side: BorderSide(color: Colors.black.withOpacity(0.08), width: 1),
    ),
    padding: const EdgeInsets.symmetric(
      horizontal: spacing24,
      vertical: spacing16,
    ),
    textStyle: const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      fontFamily: fontFamily,
    ),
  );
}

// MARK: - Original Helper Functions (GENAU WIE URSPRÜNGLICH)

/// iOS-style Card Widget
Widget iOSCard({
  required Widget child,
  EdgeInsetsGeometry? padding,
  EdgeInsetsGeometry? margin,
  VoidCallback? onTap,
}) {
  return Container(
    margin: margin ?? const EdgeInsets.symmetric(
      horizontal: ModernDesignSystem.spacing20,
      vertical: ModernDesignSystem.spacing8,
    ),
    decoration: ModernDesignSystem.cardDecoration,
    child: Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(ModernDesignSystem.radiusLarge),
        child: Container(
          padding: padding ?? const EdgeInsets.all(ModernDesignSystem.spacing20),
          child: child,
        ),
      ),
    ),
  );
}

/// Premium Button (Gradient-Style)
Widget iOSButton({
  required String text,
  required VoidCallback? onPressed,
  bool isPrimary = true,
  bool isLoading = false,
  Widget? icon,
  LinearGradient? gradient,
}) {
  final buttonGradient = gradient ?? ModernDesignSystem.primaryGradient;
  
  return Container(
    width: double.infinity,
    height: 52,
    decoration: isPrimary ? BoxDecoration(
      gradient: buttonGradient,
      borderRadius: BorderRadius.circular(ModernDesignSystem.radiusMedium),
      boxShadow: ModernDesignSystem.gradientShadow(buttonGradient.colors.first),
    ) : BoxDecoration(
      color: ModernDesignSystem.backgroundTertiary,
      borderRadius: BorderRadius.circular(ModernDesignSystem.radiusMedium),
      border: Border.all(
        color: Colors.black.withOpacity(0.08),
        width: 1,
      ),
    ),
    child: Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isLoading ? null : onPressed,
        borderRadius: BorderRadius.circular(ModernDesignSystem.radiusMedium),
        child: Container(
          alignment: Alignment.center,
          child: isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (icon != null) ...[
                      icon,
                      const SizedBox(width: ModernDesignSystem.spacing8),
                    ],
                    Text(
                      text,
                      style: TextStyle(
                        color: isPrimary ? Colors.white : ModernDesignSystem.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        fontFamily: ModernDesignSystem.fontFamily,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    ),
  );
}

/// Modern Theme Extensions
extension ModernTheme on ThemeData {
  static ThemeData get light => ThemeData(
    useMaterial3: true,
    fontFamily: ModernDesignSystem.fontFamily,
    scaffoldBackgroundColor: ModernDesignSystem.backgroundPrimary,
    
    colorScheme: const ColorScheme.light(
      primary: ModernDesignSystem.accentBlue,
      secondary: ModernDesignSystem.accentTeal,
      tertiary: ModernDesignSystem.accentPurple,
      surface: ModernDesignSystem.backgroundCard,
      background: ModernDesignSystem.backgroundPrimary,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: ModernDesignSystem.textPrimary,
      onBackground: ModernDesignSystem.textPrimary,
      primaryContainer: ModernDesignSystem.accentBlue,
      secondaryContainer: ModernDesignSystem.accentTeal,
    ),
    
    textTheme: const TextTheme(
      displayLarge: ModernDesignSystem.displayLarge,
      displayMedium: ModernDesignSystem.displayMedium,
      displaySmall: ModernDesignSystem.displaySmall,
      headlineLarge: ModernDesignSystem.h4,
      headlineMedium: ModernDesignSystem.headline,
      headlineSmall: ModernDesignSystem.title3,
      bodyLarge: ModernDesignSystem.bodyLarge,
      bodyMedium: ModernDesignSystem.bodyMedium,
      bodySmall: ModernDesignSystem.bodySmall,
      labelLarge: ModernDesignSystem.labelStyle,
      labelMedium: ModernDesignSystem.footnote,
      labelSmall: ModernDesignSystem.caption,
    ),
    
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      iconTheme: IconThemeData(color: ModernDesignSystem.textPrimary),
      titleTextStyle: ModernDesignSystem.h3,
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ModernDesignSystem.primaryButtonStyle,
    ),
    
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: ModernDesignSystem.backgroundCard,
      selectedItemColor: ModernDesignSystem.accentBlue,
      unselectedItemColor: ModernDesignSystem.textTertiary,
      elevation: 8,
      type: BottomNavigationBarType.fixed,
    ),
    
    cardTheme: CardThemeData(
      color: ModernDesignSystem.backgroundCard,
      elevation: 0,
      shadowColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ModernDesignSystem.radiusLarge),
      ),
    ),
    
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: ModernDesignSystem.backgroundTertiary,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(ModernDesignSystem.radiusMedium),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(ModernDesignSystem.radiusMedium),
        borderSide: const BorderSide(color: ModernDesignSystem.accentBlue, width: 2),
      ),
    ),
  );
}