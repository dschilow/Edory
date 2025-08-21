// lib/core/theme/app_decorations.dart
import 'package:flutter/material.dart';
import 'avatales_app_colors.dart';
import 'avatales_app_spacing.dart';

/// Avatales Decorations - Shadows, Borders, and Visual Effects
/// Namespace: Avatales.Core.Theme.AppDecorations
class AppDecorations {
  AppDecorations._();

  // MARK: - Shadow Definitions
  
  /// Light shadow - subtle elevation
  static const List<BoxShadow> shadowLight = [
    BoxShadow(
      color: AppColors.shadowLight,
      offset: Offset(0, 1),
      blurRadius: 3,
      spreadRadius: 0,
    ),
  ];

  /// Medium shadow - standard elevation
  static const List<BoxShadow> shadowMedium = [
    BoxShadow(
      color: AppColors.shadowMedium,
      offset: Offset(0, 2),
      blurRadius: 8,
      spreadRadius: 0,
    ),
    BoxShadow(
      color: Color(0x05000000),
      offset: Offset(0, 1),
      blurRadius: 2,
      spreadRadius: 0,
    ),
  ];

  /// Heavy shadow - prominent elevation
  static const List<BoxShadow> shadowHeavy = [
    BoxShadow(
      color: AppColors.shadowHeavy,
      offset: Offset(0, 4),
      blurRadius: 16,
      spreadRadius: 0,
    ),
    BoxShadow(
      color: Color(0x08000000),
      offset: Offset(0, 2),
      blurRadius: 4,
      spreadRadius: 0,
    ),
  ];

  /// iOS-style Card Shadow
  static const List<BoxShadow> shadowCard = [
    BoxShadow(
      color: Color(0x08000000),
      offset: Offset(0, 1),
      blurRadius: 2,
      spreadRadius: 0,
    ),
    BoxShadow(
      color: Color(0x06000000),
      offset: Offset(0, 2),
      blurRadius: 8,
      spreadRadius: 0,
    ),
  ];

  /// Floating Action Button Shadow
  static const List<BoxShadow> shadowFAB = [
    BoxShadow(
      color: Color(0x33000000),
      offset: Offset(0, 6),
      blurRadius: 12,
      spreadRadius: 0,
    ),
  ];

  /// Bottom Navigation Shadow
  static const List<BoxShadow> shadowBottomNav = [
    BoxShadow(
      color: Color(0x0A000000),
      offset: Offset(0, -1),
      blurRadius: 4,
      spreadRadius: 0,
    ),
  ];

  // MARK: - Card Decorations
  
  /// Standard card decoration
  static BoxDecoration get cardDecoration => BoxDecoration(
    color: AppColors.backgroundSecondary,
    borderRadius: AppSpacing.borderRadiusLarge,
    border: Border.all(
      color: AppColors.borderSecondary,
      width: 0.5,
    ),
    boxShadow: shadowCard,
  );

  /// Elevated card decoration
  static BoxDecoration get elevatedCardDecoration => BoxDecoration(
    color: AppColors.backgroundSecondary,
    borderRadius: AppSpacing.borderRadiusLarge,
    boxShadow: shadowMedium,
  );

  /// Character card decoration with gradient
  static BoxDecoration characterCardDecoration(LinearGradient gradient) => BoxDecoration(
    gradient: gradient,
    borderRadius: AppSpacing.borderRadiusLarge,
    boxShadow: shadowMedium,
  );

  /// Hero card decoration
  static BoxDecoration get heroCardDecoration => BoxDecoration(
    gradient: AppColors.heroGradient,
    borderRadius: AppSpacing.borderRadiusXLarge,
    boxShadow: shadowHeavy,
  );

  // MARK: - Button Decorations
  
  /// Primary button decoration
  static BoxDecoration get primaryButtonDecoration => BoxDecoration(
    gradient: AppColors.primaryGradient,
    borderRadius: AppSpacing.borderRadiusLarge,
    boxShadow: shadowLight,
  );

  /// Secondary button decoration
  static BoxDecoration get secondaryButtonDecoration => BoxDecoration(
    color: AppColors.backgroundSecondary,
    borderRadius: AppSpacing.borderRadiusLarge,
    border: Border.all(
      color: AppColors.borderPrimary,
      width: 1.5,
    ),
  );

  /// Ghost button decoration
  static BoxDecoration get ghostButtonDecoration => BoxDecoration(
    color: Colors.transparent,
    borderRadius: AppSpacing.borderRadiusLarge,
    border: Border.all(
      color: AppColors.primaryBlue,
      width: 1.5,
    ),
  );

  /// Floating Action Button decoration
  static BoxDecoration get fabDecoration => BoxDecoration(
    gradient: AppColors.primaryGradient,
    borderRadius: BorderRadius.circular(AppSpacing.radiusCircle),
    boxShadow: shadowFAB,
  );

  // MARK: - Input Decorations
  
  /// Standard input decoration
  static BoxDecoration get inputDecoration => BoxDecoration(
    color: AppColors.backgroundTertiary,
    borderRadius: AppSpacing.borderRadiusMedium,
    border: Border.all(
      color: AppColors.borderSecondary,
      width: 1,
    ),
  );

  /// Focused input decoration
  static BoxDecoration get focusedInputDecoration => BoxDecoration(
    color: AppColors.backgroundSecondary,
    borderRadius: AppSpacing.borderRadiusMedium,
    border: Border.all(
      color: AppColors.primaryBlue,
      width: 2,
    ),
    boxShadow: [
      BoxShadow(
        color: AppColors.primaryBlue.withOpacity(0.1),
        offset: const Offset(0, 0),
        blurRadius: 4,
        spreadRadius: 0,
      ),
    ],
  );

  /// Error input decoration
  static BoxDecoration get errorInputDecoration => BoxDecoration(
    color: AppColors.backgroundSecondary,
    borderRadius: AppSpacing.borderRadiusMedium,
    border: Border.all(
      color: AppColors.error,
      width: 2,
    ),
  );

  // MARK: - Navigation Decorations
  
  /// Bottom navigation decoration
  static BoxDecoration get bottomNavigationDecoration => BoxDecoration(
    color: AppColors.backgroundSecondary,
    borderRadius: const BorderRadius.only(
      topLeft: Radius.circular(AppSpacing.radiusXLarge),
      topRight: Radius.circular(AppSpacing.radiusXLarge),
    ),
    border: const Border(
      top: BorderSide(
        color: AppColors.borderSecondary,
        width: 0.5,
      ),
    ),
    boxShadow: shadowBottomNav,
  );

  /// Tab bar decoration
  static BoxDecoration get tabBarDecoration => BoxDecoration(
    color: AppColors.backgroundSecondary,
    borderRadius: AppSpacing.borderRadiusLarge,
    border: Border.all(
      color: AppColors.borderSecondary,
      width: 0.5,
    ),
    boxShadow: shadowLight,
  );

  // MARK: - Container Decorations
  
  /// Section container decoration
  static BoxDecoration get sectionDecoration => BoxDecoration(
    color: AppColors.backgroundSecondary,
    borderRadius: AppSpacing.borderRadiusLarge,
    border: Border.all(
      color: AppColors.borderSecondary,
      width: 0.5,
    ),
  );

  /// Highlighted section decoration
  static BoxDecoration get highlightedSectionDecoration => BoxDecoration(
    color: AppColors.backgroundSecondary,
    borderRadius: AppSpacing.borderRadiusLarge,
    border: Border.all(
      color: AppColors.primaryBlue.withOpacity(0.3),
      width: 1,
    ),
    boxShadow: [
      BoxShadow(
        color: AppColors.primaryBlue.withOpacity(0.05),
        offset: const Offset(0, 2),
        blurRadius: 8,
        spreadRadius: 0,
      ),
    ],
  );

  /// Dialog decoration
  static BoxDecoration get dialogDecoration => BoxDecoration(
    color: AppColors.backgroundSecondary,
    borderRadius: AppSpacing.borderRadiusXLarge,
    boxShadow: shadowHeavy,
  );

  /// Bottom sheet decoration
  static BoxDecoration get bottomSheetDecoration => BoxDecoration(
    color: AppColors.backgroundSecondary,
    borderRadius: const BorderRadius.only(
      topLeft: Radius.circular(AppSpacing.radiusXLarge),
      topRight: Radius.circular(AppSpacing.radiusXLarge),
    ),
    boxShadow: shadowHeavy,
  );

  // MARK: - Status Decorations
  
  /// Success decoration
  static BoxDecoration get successDecoration => BoxDecoration(
    gradient: AppColors.successGradient,
    borderRadius: AppSpacing.borderRadiusLarge,
    boxShadow: shadowLight,
  );

  /// Warning decoration
  static BoxDecoration get warningDecoration => BoxDecoration(
    gradient: AppColors.warningGradient,
    borderRadius: AppSpacing.borderRadiusLarge,
    boxShadow: shadowLight,
  );

  /// Error decoration
  static BoxDecoration get errorDecoration => BoxDecoration(
    gradient: AppColors.errorGradient,
    borderRadius: AppSpacing.borderRadiusLarge,
    boxShadow: shadowLight,
  );

  // MARK: - Special Effect Decorations
  
  /// Glassmorphism decoration
  static BoxDecoration get glassMorphismDecoration => BoxDecoration(
    color: Colors.white.withOpacity(0.1),
    borderRadius: AppSpacing.borderRadiusLarge,
    border: Border.all(
      color: Colors.white.withOpacity(0.2),
      width: 1,
    ),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.1),
        offset: const Offset(0, 8),
        blurRadius: 32,
        spreadRadius: 0,
      ),
    ],
  );

  /// Neumorphism decoration (light)
  static BoxDecoration get neumorphismLightDecoration => BoxDecoration(
    color: AppColors.backgroundPrimary,
    borderRadius: AppSpacing.borderRadiusLarge,
    boxShadow: [
      BoxShadow(
        color: Colors.white.withOpacity(0.7),
        offset: const Offset(-4, -4),
        blurRadius: 8,
        spreadRadius: 0,
      ),
      BoxShadow(
        color: Colors.black.withOpacity(0.1),
        offset: const Offset(4, 4),
        blurRadius: 8,
        spreadRadius: 0,
      ),
    ],
  );

  // MARK: - Border Decorations
  
  /// Top border decoration
  static BoxDecoration topBorderDecoration({
    Color color = AppColors.borderPrimary,
    double width = 1,
  }) => BoxDecoration(
    border: Border(
      top: BorderSide(color: color, width: width),
    ),
  );

  /// Bottom border decoration
  static BoxDecoration bottomBorderDecoration({
    Color color = AppColors.borderPrimary,
    double width = 1,
  }) => BoxDecoration(
    border: Border(
      bottom: BorderSide(color: color, width: width),
    ),
  );

  /// Left border decoration
  static BoxDecoration leftBorderDecoration({
    Color color = AppColors.borderPrimary,
    double width = 1,
  }) => BoxDecoration(
    border: Border(
      left: BorderSide(color: color, width: width),
    ),
  );

  /// All borders decoration
  static BoxDecoration allBordersDecoration({
    Color color = AppColors.borderPrimary,
    double width = 1,
    BorderRadius? borderRadius,
  }) => BoxDecoration(
    border: Border.all(color: color, width: width),
    borderRadius: borderRadius ?? AppSpacing.borderRadiusMedium,
  );

  // MARK: - Helper Methods
  
  /// Custom shadow with color and blur
  static List<BoxShadow> customShadow({
    required Color color,
    required Offset offset,
    required double blurRadius,
    double spreadRadius = 0,
  }) => [
    BoxShadow(
      color: color,
      offset: offset,
      blurRadius: blurRadius,
      spreadRadius: spreadRadius,
    ),
  ];

  /// Custom gradient decoration
  static BoxDecoration customGradientDecoration({
    required LinearGradient gradient,
    BorderRadius? borderRadius,
    List<BoxShadow>? boxShadow,
    Border? border,
  }) => BoxDecoration(
    gradient: gradient,
    borderRadius: borderRadius ?? AppSpacing.borderRadiusLarge,
    boxShadow: boxShadow,
    border: border,
  );

  /// Custom solid color decoration
  static BoxDecoration customColorDecoration({
    required Color color,
    BorderRadius? borderRadius,
    List<BoxShadow>? boxShadow,
    Border? border,
  }) => BoxDecoration(
    color: color,
    borderRadius: borderRadius ?? AppSpacing.borderRadiusLarge,
    boxShadow: boxShadow,
    border: border,
  );
}