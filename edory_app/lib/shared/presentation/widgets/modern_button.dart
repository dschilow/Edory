// lib/shared/presentation/widgets/modern_button.dart
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../../core/theme/modern_design_system.dart';

/// Modern Button - Clean, Professional Design
class ModernButton extends StatelessWidget {
  const ModernButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.type = ModernButtonType.primary,
    this.size = ModernButtonSize.medium,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = false,
  });

  final String text;
  final VoidCallback? onPressed;
  final ModernButtonType type;
  final ModernButtonSize size;
  final IconData? icon;
  final bool isLoading;
  final bool isFullWidth;

  @override
  Widget build(BuildContext context) {
    final disabled = onPressed == null || isLoading;
    
    return SizedBox(
      width: isFullWidth ? double.infinity : null,
      height: _getHeight(),
      child: ElevatedButton(
        onPressed: disabled ? null : onPressed,
        style: _getButtonStyle().copyWith(
          backgroundColor: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.disabled)) {
              return ModernDesignSystem.textDisabled;
            }
            if (states.contains(MaterialState.pressed)) {
              return _getPressedColor();
            }
            if (states.contains(MaterialState.hovered)) {
              return _getHoverColor();
            }
            return _getBackgroundColor();
          }),
          foregroundColor: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.disabled)) {
              return Colors.white;
            }
            return _getForegroundColor();
          }),
        ),
        child: isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(_getForegroundColor()),
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: _getIconSize()),
                    const SizedBox(width: ModernDesignSystem.spacing8),
                  ],
                  Text(
                    text,
                    style: _getTextStyle(),
                  ),
                ],
              ),
      ),
    );
  }

  double _getHeight() {
    switch (size) {
      case ModernButtonSize.small:
        return 36;
      case ModernButtonSize.medium:
        return 44;
      case ModernButtonSize.large:
        return 52;
    }
  }

  double _getIconSize() {
    switch (size) {
      case ModernButtonSize.small:
        return 16;
      case ModernButtonSize.medium:
        return 18;
      case ModernButtonSize.large:
        return 20;
    }
  }

  TextStyle _getTextStyle() {
    final baseStyle = TextStyle(
      fontWeight: FontWeight.w600,
      fontFamily: ModernDesignSystem.fontFamily,
    );

    switch (size) {
      case ModernButtonSize.small:
        return baseStyle.copyWith(fontSize: 14);
      case ModernButtonSize.medium:
        return baseStyle.copyWith(fontSize: 16);
      case ModernButtonSize.large:
        return baseStyle.copyWith(fontSize: 18);
    }
  }

  ButtonStyle _getButtonStyle() {
    return ElevatedButton.styleFrom(
      elevation: 0,
      shadowColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ModernDesignSystem.radiusMedium),
        side: type == ModernButtonType.secondary
            ? BorderSide(color: ModernDesignSystem.borderColor, width: 1)
            : BorderSide.none,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: _getHorizontalPadding(),
        vertical: ModernDesignSystem.spacing12,
      ),
    );
  }

  double _getHorizontalPadding() {
    switch (size) {
      case ModernButtonSize.small:
        return ModernDesignSystem.spacing16;
      case ModernButtonSize.medium:
        return ModernDesignSystem.spacing20;
      case ModernButtonSize.large:
        return ModernDesignSystem.spacing24;
    }
  }

  Color _getBackgroundColor() {
    switch (type) {
      case ModernButtonType.primary:
        return ModernDesignSystem.buttonPrimary;
      case ModernButtonType.secondary:
        return ModernDesignSystem.buttonSecondary;
      case ModernButtonType.success:
        return ModernDesignSystem.accentGreen;
      case ModernButtonType.warning:
        return ModernDesignSystem.accentOrange;
      case ModernButtonType.danger:
        return ModernDesignSystem.accentRed;
    }
  }

  Color _getForegroundColor() {
    switch (type) {
      case ModernButtonType.primary:
      case ModernButtonType.success:
      case ModernButtonType.warning:
      case ModernButtonType.danger:
        return Colors.white;
      case ModernButtonType.secondary:
        return ModernDesignSystem.textPrimary;
    }
  }

  Color _getHoverColor() {
    return _getBackgroundColor().withOpacity(0.8);
  }

  Color _getPressedColor() {
    return _getBackgroundColor().withOpacity(0.9);
  }
}

enum ModernButtonType {
  primary,
  secondary,
  success,
  warning,
  danger,
}

enum ModernButtonSize {
  small,
  medium,
  large,
}

/// Modern Icon Button
class ModernIconButton extends StatelessWidget {
  const ModernIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.backgroundColor,
    this.iconColor,
    this.size = 44,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? iconColor;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor ?? ModernDesignSystem.backgroundTertiary,
        borderRadius: BorderRadius.circular(ModernDesignSystem.radiusMedium),
        border: Border.all(
          color: ModernDesignSystem.borderColor,
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(ModernDesignSystem.radiusMedium),
          child: Center(
            child: Icon(
              icon,
              color: iconColor ?? ModernDesignSystem.textSecondary,
              size: size * 0.5,
            ),
          ),
        ),
      ),
    );
  }
}
