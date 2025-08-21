// lib/core/theme/app_spacing.dart
import 'package:flutter/material.dart';

/// Avatales Spacing & Layout System - Consistent Spacing
/// Namespace: Avatales.Core.Theme.AppSpacing
class AppSpacing {
  AppSpacing._();

  // MARK: - Base Unit
  
  /// Base spacing unit (8px) - All spacing is based on this
  static const double _baseUnit = 8.0;

  // MARK: - Spacing Values
  
  /// Extra Small - 4px
  static const double xs = _baseUnit * 0.5;
  
  /// Small - 8px
  static const double sm = _baseUnit * 1;
  
  /// Medium - 16px
  static const double md = _baseUnit * 2;
  
  /// Large - 24px
  static const double lg = _baseUnit * 3;
  
  /// Extra Large - 32px
  static const double xl = _baseUnit * 4;
  
  /// Extra Extra Large - 40px
  static const double xxl = _baseUnit * 5;
  
  /// Extra Extra Extra Large - 48px
  static const double xxxl = _baseUnit * 6;

  // MARK: - Named Spacing (iOS-Style)
  
  /// Spacing 4px
  static const double spacing4 = 4.0;
  
  /// Spacing 8px
  static const double spacing8 = 8.0;
  
  /// Spacing 12px
  static const double spacing12 = 12.0;
  
  /// Spacing 16px
  static const double spacing16 = 16.0;
  
  /// Spacing 20px
  static const double spacing20 = 20.0;
  
  /// Spacing 24px
  static const double spacing24 = 24.0;
  
  /// Spacing 32px
  static const double spacing32 = 32.0;
  
  /// Spacing 40px
  static const double spacing40 = 40.0;
  
  /// Spacing 48px
  static const double spacing48 = 48.0;
  
  /// Spacing 56px
  static const double spacing56 = 56.0;
  
  /// Spacing 64px
  static const double spacing64 = 64.0;

  // MARK: - Border Radius
  
  /// Small radius - 8px
  static const double radiusSmall = 8.0;
  
  /// Medium radius - 12px
  static const double radiusMedium = 12.0;
  
  /// Large radius - 16px
  static const double radiusLarge = 16.0;
  
  /// Extra Large radius - 20px
  static const double radiusXLarge = 20.0;
  
  /// Extra Extra Large radius - 24px
  static const double radiusXXLarge = 24.0;
  
  /// Circle radius - 999px (for pill shapes)
  static const double radiusCircle = 999.0;

  // MARK: - iOS-Style Border Radius
  
  /// iOS Small radius - 6px
  static const double radiusIOS6 = 6.0;
  
  /// iOS Medium radius - 10px
  static const double radiusIOS10 = 10.0;
  
  /// iOS Large radius - 14px
  static const double radiusIOS14 = 14.0;
  
  /// iOS Extra Large radius - 18px
  static const double radiusIOS18 = 18.0;

  // MARK: - EdgeInsets Shortcuts
  
  /// All sides - 4px
  static const EdgeInsets paddingXS = EdgeInsets.all(xs);
  
  /// All sides - 8px
  static const EdgeInsets paddingSM = EdgeInsets.all(sm);
  
  /// All sides - 16px
  static const EdgeInsets paddingMD = EdgeInsets.all(md);
  
  /// All sides - 24px
  static const EdgeInsets paddingLG = EdgeInsets.all(lg);
  
  /// All sides - 32px
  static const EdgeInsets paddingXL = EdgeInsets.all(xl);

  // MARK: - Horizontal Padding
  
  /// Horizontal - 8px
  static const EdgeInsets horizontalSM = EdgeInsets.symmetric(horizontal: sm);
  
  /// Horizontal - 16px
  static const EdgeInsets horizontalMD = EdgeInsets.symmetric(horizontal: md);
  
  /// Horizontal - 24px
  static const EdgeInsets horizontalLG = EdgeInsets.symmetric(horizontal: lg);
  
  /// Horizontal - 32px
  static const EdgeInsets horizontalXL = EdgeInsets.symmetric(horizontal: xl);

  // MARK: - Vertical Padding
  
  /// Vertical - 8px
  static const EdgeInsets verticalSM = EdgeInsets.symmetric(vertical: sm);
  
  /// Vertical - 16px
  static const EdgeInsets verticalMD = EdgeInsets.symmetric(vertical: md);
  
  /// Vertical - 24px
  static const EdgeInsets verticalLG = EdgeInsets.symmetric(vertical: lg);
  
  /// Vertical - 32px
  static const EdgeInsets verticalXL = EdgeInsets.symmetric(vertical: xl);

  // MARK: - Custom Padding Combinations
  
  /// Top & Bottom 8px, Left & Right 16px
  static const EdgeInsets cardPadding = EdgeInsets.symmetric(
    vertical: sm,
    horizontal: md,
  );
  
  /// Top & Bottom 16px, Left & Right 20px
  static const EdgeInsets pagePadding = EdgeInsets.symmetric(
    vertical: md,
    horizontal: spacing20,
  );
  
  /// Top & Bottom 12px, Left & Right 16px
  static const EdgeInsets buttonPadding = EdgeInsets.symmetric(
    vertical: spacing12,
    horizontal: md,
  );
  
  /// Top & Bottom 16px, Left & Right 24px
  static const EdgeInsets sectionPadding = EdgeInsets.symmetric(
    vertical: md,
    horizontal: lg,
  );

  // MARK: - Safe Area Padding
  
  /// Screen padding with safe area - 20px horizontal
  static const EdgeInsets screenPadding = EdgeInsets.symmetric(
    horizontal: spacing20,
  );
  
  /// Screen padding with top safe area - 20px horizontal, 16px top
  static const EdgeInsets screenPaddingWithTop = EdgeInsets.fromLTRB(
    spacing20,
    md,
    spacing20,
    0,
  );
  
  /// Screen padding with bottom safe area - 20px horizontal, 24px bottom
  static const EdgeInsets screenPaddingWithBottom = EdgeInsets.fromLTRB(
    spacing20,
    0,
    spacing20,
    lg,
  );

  // MARK: - Component-Specific Padding
  
  /// AppBar padding
  static const EdgeInsets appBarPadding = EdgeInsets.symmetric(
    horizontal: spacing20,
  );
  
  /// Card content padding
  static const EdgeInsets cardContentPadding = EdgeInsets.all(spacing20);
  
  /// List item padding
  static const EdgeInsets listItemPadding = EdgeInsets.symmetric(
    vertical: spacing12,
    horizontal: spacing20,
  );
  
  /// Dialog padding
  static const EdgeInsets dialogPadding = EdgeInsets.all(lg);
  
  /// Bottom sheet padding
  static const EdgeInsets bottomSheetPadding = EdgeInsets.fromLTRB(
    spacing20,
    spacing20,
    spacing20,
    spacing40,
  );

  // MARK: - SizedBox Shortcuts
  
  /// Vertical spacing - 4px
  static const SizedBox verticalSpaceXS = SizedBox(height: xs);
  
  /// Vertical spacing - 8px
  static const SizedBox verticalSpaceSM = SizedBox(height: sm);
  
  /// Vertical spacing - 16px
  static const SizedBox verticalSpaceMD = SizedBox(height: md);
  
  /// Vertical spacing - 24px
  static const SizedBox verticalSpaceLG = SizedBox(height: lg);
  
  /// Vertical spacing - 32px
  static const SizedBox verticalSpaceXL = SizedBox(height: xl);

  /// Horizontal spacing - 4px
  static const SizedBox horizontalSpaceXS = SizedBox(width: xs);
  
  /// Horizontal spacing - 8px
  static const SizedBox horizontalSpaceSM = SizedBox(width: sm);
  
  /// Horizontal spacing - 16px
  static const SizedBox horizontalSpaceMD = SizedBox(width: md);
  
  /// Horizontal spacing - 24px
  static const SizedBox horizontalSpaceLG = SizedBox(width: lg);
  
  /// Horizontal spacing - 32px
  static const SizedBox horizontalSpaceXL = SizedBox(width: xl);

  // MARK: - BorderRadius Shortcuts
  
  /// Small border radius
  static BorderRadius get borderRadiusSmall => BorderRadius.circular(radiusSmall);
  
  /// Medium border radius
  static BorderRadius get borderRadiusMedium => BorderRadius.circular(radiusMedium);
  
  /// Large border radius
  static BorderRadius get borderRadiusLarge => BorderRadius.circular(radiusLarge);
  
  /// Extra large border radius
  static BorderRadius get borderRadiusXLarge => BorderRadius.circular(radiusXLarge);
  
  /// Circle border radius
  static BorderRadius get borderRadiusCircle => BorderRadius.circular(radiusCircle);

  // MARK: - iOS-Style BorderRadius
  
  /// iOS card border radius
  static BorderRadius get borderRadiusCard => BorderRadius.circular(radiusIOS14);
  
  /// iOS button border radius
  static BorderRadius get borderRadiusButton => BorderRadius.circular(radiusIOS10);
  
  /// iOS input border radius
  static BorderRadius get borderRadiusInput => BorderRadius.circular(radiusIOS10);

  // MARK: - Helper Methods
  
  /// Custom spacing based on base unit
  static double spacing(double multiplier) => _baseUnit * multiplier;
  
  /// Custom EdgeInsets
  static EdgeInsets custom({
    double top = 0,
    double bottom = 0,
    double left = 0,
    double right = 0,
  }) {
    return EdgeInsets.fromLTRB(left, top, right, bottom);
  }
  
  /// Custom symmetric EdgeInsets
  static EdgeInsets symmetric({
    double vertical = 0,
    double horizontal = 0,
  }) {
    return EdgeInsets.symmetric(
      vertical: vertical,
      horizontal: horizontal,
    );
  }
  
  /// Custom border radius
  static BorderRadius customRadius(double radius) {
    return BorderRadius.circular(radius);
  }
  
  /// Custom border radius with different values
  static BorderRadius customRadiusDirectional({
    double topLeft = 0,
    double topRight = 0,
    double bottomLeft = 0,
    double bottomRight = 0,
  }) {
    return BorderRadius.only(
      topLeft: Radius.circular(topLeft),
      topRight: Radius.circular(topRight),
      bottomLeft: Radius.circular(bottomLeft),
      bottomRight: Radius.circular(bottomRight),
    );
  }
}