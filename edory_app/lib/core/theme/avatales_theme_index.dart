// lib/core/theme/index.dart
// 
// Avatales Theme System - Barrel Export
// Namespace: Avatales.Core.Theme
//
// Dieses File exportiert alle Theme-bezogenen Klassen und Funktionen
// für einfache Imports in der ganzen App.
//

// Core Theme Classes
export 'avatales_app_colors.dart';
export 'app_theme.dart';
export 'avatales_app_typography.dart';
export 'avatales_app_spacing.dart';
export 'avatales_app_decorations.dart';

// Legacy Support (falls die alte Datei noch benötigt wird)
// export 'modern_design_system.dart';

/// Avatales Theme System
/// 
/// Usage:
/// ```dart
/// import 'package:avatales/core/theme/index.dart';
/// 
/// // Farben verwenden
/// Container(color: AppColors.primaryBlue)
/// 
/// // Typography verwenden  
/// Text('Hello', style: AppTypography.h1)
/// 
/// // Spacing verwenden
/// Padding(padding: AppSpacing.paddingMD)
/// 
/// // Theme verwenden
/// MaterialApp(theme: AppTheme.lightTheme)
/// ```
class AvatalesTheme {
  AvatalesTheme._();
  
  /// Aktueller Theme-Name
  static const String themeName = 'Avatales Theme System';
  
  /// Theme-Version
  static const String version = '1.0.0';
  
  /// Design-System Beschreibung
  static const String description = 'iOS-inspired Design System für Avatales App';
}