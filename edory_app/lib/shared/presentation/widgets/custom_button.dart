// Avatales.Widgets.CustomButton
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:edory_app/core/theme/app_theme.dart';
import 'package:edory_app/core/theme/app_colors.dart';

enum ButtonType {
  primary,
  secondary,
  outline,
  ghost,
  gradient,
  floating,
}

enum ButtonSize {
  small,
  medium,
  large,
  extraLarge,
}

class CustomButton extends StatefulWidget {
  final String? text;
  final Widget? child;
  final VoidCallback? onPressed;
  final ButtonType type;
  final ButtonSize size;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final LinearGradient? gradient;
  final IconData? leadingIcon;
  final IconData? trailingIcon;
  final bool isLoading;
  final bool isExpanded;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;
  final List<BoxShadow>? customShadow;
  final Duration animationDuration;
  final bool enableHaptic;
  final bool enableSoundEffect;

  const CustomButton({
    Key? key,
    this.text,
    this.child,
    this.onPressed,
    this.type = ButtonType.primary,
    this.size = ButtonSize.medium,
    this.backgroundColor,
    this.foregroundColor,
    this.gradient,
    this.leadingIcon,
    this.trailingIcon,
    this.isLoading = false,
    this.isExpanded = false,
    this.padding,
    this.borderRadius,
    this.customShadow,
    this.animationDuration = AppTheme.animationMedium,
    this.enableHaptic = true,
    this.enableSoundEffect = false,
  }) : super(key: key);

  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _rippleController;
  late AnimationController _loadingController;
  
  late Animation<double> _scaleAnimation;
  late Animation<double> _rippleAnimation;
  late Animation<double> _loadingAnimation;
  
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _scaleController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _rippleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _loadingController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: AppTheme.animationCurve,
    ));

    _rippleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _rippleController,
      curve: Curves.elasticOut,
    ));

    _loadingAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _loadingController,
      curve: Curves.easeInOut,
    ));

    if (widget.isLoading) {
      _loadingController.repeat();
    }
  }

  @override
  void didUpdateWidget(CustomButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isLoading != oldWidget.isLoading) {
      if (widget.isLoading) {
        _loadingController.repeat();
      } else {
        _loadingController.stop();
      }
    }
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _rippleController.dispose();
    _loadingController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    _scaleController.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _scaleController.reverse();
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
    _scaleController.reverse();
  }

  void _handleTap() {
    if (widget.isLoading || widget.onPressed == null) return;

    // Haptic Feedback
    if (widget.enableHaptic) {
      HapticFeedback.lightImpact();
    }

    // Ripple Animation
    _rippleController.forward().then((_) {
      _rippleController.reset();
    });

    // Sound Effect (kann erweitert werden)
    if (widget.enableSoundEffect) {
      SystemSound.play(SystemSoundType.click);
    }

    widget.onPressed?.call();
  }

  EdgeInsetsGeometry _getPadding() {
    if (widget.padding != null) return widget.padding!;

    switch (widget.size) {
      case ButtonSize.small:
        return const EdgeInsets.symmetric(
          horizontal: AppTheme.paddingSmall * 2,
          vertical: AppTheme.paddingSmall,
        );
      case ButtonSize.medium:
        return const EdgeInsets.symmetric(
          horizontal: AppTheme.paddingMedium * 1.5,
          vertical: AppTheme.paddingMedium,
        );
      case ButtonSize.large:
        return const EdgeInsets.symmetric(
          horizontal: AppTheme.paddingLarge,
          vertical: AppTheme.paddingMedium * 1.25,
        );
      case ButtonSize.extraLarge:
        return const EdgeInsets.symmetric(
          horizontal: AppTheme.paddingXLarge,
          vertical: AppTheme.paddingLarge,
        );
    }
  }

  double _getFontSize() {
    switch (widget.size) {
      case ButtonSize.small:
        return 12;
      case ButtonSize.medium:
        return 14;
      case ButtonSize.large:
        return 16;
      case ButtonSize.extraLarge:
        return 18;
    }
  }

  BorderRadius _getBorderRadius() {
    if (widget.borderRadius != null) return widget.borderRadius!;

    switch (widget.size) {
      case ButtonSize.small:
        return AppTheme.radiusSmall;
      case ButtonSize.medium:
        return AppTheme.radiusMedium;
      case ButtonSize.large:
        return AppTheme.radiusMedium;
      case ButtonSize.extraLarge:
        return AppTheme.radiusLarge;
    }
  }

  ButtonStyle _getButtonStyle() {
    final isEnabled = widget.onPressed != null && !widget.isLoading;
    final borderRadius = _getBorderRadius();
    final padding = _getPadding();

    switch (widget.type) {
      case ButtonType.primary:
        return ElevatedButton.styleFrom(
          backgroundColor: widget.backgroundColor ?? AppColors.primaryBlue,
          foregroundColor: widget.foregroundColor ?? AppColors.white,
          padding: padding,
          shape: RoundedRectangleBorder(borderRadius: borderRadius),
          elevation: _isPressed ? AppTheme.elevationLow : AppTheme.elevationMedium,
          shadowColor: AppColors.shadowMedium,
          disabledBackgroundColor: AppColors.mediumGray,
          disabledForegroundColor: AppColors.secondaryText,
        );

      case ButtonType.secondary:
        return ElevatedButton.styleFrom(
          backgroundColor: widget.backgroundColor ?? AppColors.lightGray,
          foregroundColor: widget.foregroundColor ?? AppColors.primaryText,
          padding: padding,
          shape: RoundedRectangleBorder(borderRadius: borderRadius),
          elevation: _isPressed ? 1 : AppTheme.elevationLow,
          shadowColor: AppColors.shadowLight,
        );

      case ButtonType.outline:
        return OutlinedButton.styleFrom(
          foregroundColor: widget.foregroundColor ?? AppColors.primaryBlue,
          padding: padding,
          shape: RoundedRectangleBorder(borderRadius: borderRadius),
          side: BorderSide(
            color: widget.backgroundColor ?? AppColors.primaryBlue,
            width: 2,
          ),
        );

      case ButtonType.ghost:
        return TextButton.styleFrom(
          foregroundColor: widget.foregroundColor ?? AppColors.primaryBlue,
          padding: padding,
          shape: RoundedRectangleBorder(borderRadius: borderRadius),
        );

      case ButtonType.gradient:
      case ButtonType.floating:
        return ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: padding,
          shape: RoundedRectangleBorder(borderRadius: borderRadius),
          elevation: 0,
        );
    }
  }

  Widget _buildButtonContent() {
    final theme = Theme.of(context);
    final fontSize = _getFontSize();
    final textStyle = theme.textTheme.labelLarge?.copyWith(
      fontSize: fontSize,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.5,
    );

    List<Widget> children = [];

    // Leading Icon
    if (widget.leadingIcon != null && !widget.isLoading) {
      children.add(Icon(
        widget.leadingIcon,
        size: fontSize * 1.2,
      ));
      if (widget.text != null || widget.child != null) {
        children.add(const SizedBox(width: AppTheme.paddingSmall));
      }
    }

    // Loading Indicator
    if (widget.isLoading) {
      children.add(
        AnimatedBuilder(
          animation: _loadingAnimation,
          builder: (context, child) {
            return Transform.rotate(
              angle: _loadingAnimation.value * 2 * 3.14159,
              child: SizedBox(
                width: fontSize * 1.2,
                height: fontSize * 1.2,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    widget.foregroundColor ?? 
                    (widget.type == ButtonType.primary ? AppColors.white : AppColors.primaryBlue),
                  ),
                ),
              ),
            );
          },
        ),
      );
      if (widget.text != null || widget.child != null) {
        children.add(const SizedBox(width: AppTheme.paddingSmall));
      }
    }

    // Text/Child Content
    if (widget.child != null) {
      children.add(widget.child!);
    } else if (widget.text != null) {
      children.add(
        Text(
          widget.text!,
          style: textStyle,
        ),
      );
    }

    // Trailing Icon
    if (widget.trailingIcon != null && !widget.isLoading) {
      if (widget.text != null || widget.child != null) {
        children.add(const SizedBox(width: AppTheme.paddingSmall));
      }
      children.add(Icon(
        widget.trailingIcon,
        size: fontSize * 1.2,
      ));
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: children,
    );
  }

  Widget _buildGradientButton() {
    final gradient = widget.gradient ?? AppColors.createCustomGradient(
      startColor: AppColors.primaryBlue,
      endColor: AppColors.primaryPink,
    );

    return Container(
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: _getBorderRadius(),
        boxShadow: widget.customShadow ?? AppTheme.mediumShadow,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _handleTap,
          onTapDown: _handleTapDown,
          onTapUp: _handleTapUp,
          onTapCancel: _handleTapCancel,
          borderRadius: _getBorderRadius(),
          child: Container(
            padding: _getPadding(),
            child: DefaultTextStyle(
              style: TextStyle(
                color: widget.foregroundColor ?? AppColors.white,
                fontSize: _getFontSize(),
                fontWeight: FontWeight.w600,
              ),
              child: _buildButtonContent(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingButton() {
    return Container(
      decoration: BoxDecoration(
        gradient: widget.gradient ?? AppColors.skyGradient,
        borderRadius: _getBorderRadius(),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _handleTap,
          onTapDown: _handleTapDown,
          onTapUp: _handleTapUp,
          onTapCancel: _handleTapCancel,
          borderRadius: _getBorderRadius(),
          child: Container(
            padding: _getPadding(),
            child: DefaultTextStyle(
              style: TextStyle(
                color: widget.foregroundColor ?? AppColors.primaryText,
                fontSize: _getFontSize(),
                fontWeight: FontWeight.w600,
              ),
              child: _buildButtonContent(),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget button;

    if (widget.type == ButtonType.gradient) {
      button = _buildGradientButton();
    } else if (widget.type == ButtonType.floating) {
      button = _buildFloatingButton();
    } else {
      // Standard Material Buttons
      switch (widget.type) {
        case ButtonType.primary:
        case ButtonType.secondary:
          button = ElevatedButton(
            onPressed: widget.isLoading ? null : widget.onPressed,
            style: _getButtonStyle(),
            child: _buildButtonContent(),
          );
          break;
        case ButtonType.outline:
          button = OutlinedButton(
            onPressed: widget.isLoading ? null : widget.onPressed,
            style: _getButtonStyle(),
            child: _buildButtonContent(),
          );
          break;
        case ButtonType.ghost:
          button = TextButton(
            onPressed: widget.isLoading ? null : widget.onPressed,
            style: _getButtonStyle(),
            child: _buildButtonContent(),
          );
          break;
        default:
          button = ElevatedButton(
            onPressed: widget.isLoading ? null : widget.onPressed,
            style: _getButtonStyle(),
            child: _buildButtonContent(),
          );
      }
    }

    // Wrap with animation if needed
    if (widget.type == ButtonType.gradient || widget.type == ButtonType.floating) {
      button = AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          );
        },
        child: button,
      );
    }

    // Ripple effect overlay
    button = Stack(
      children: [
        button,
        Positioned.fill(
          child: AnimatedBuilder(
            animation: _rippleAnimation,
            builder: (context, child) {
              if (_rippleAnimation.value == 0) return const SizedBox.shrink();
              
              return Container(
                decoration: BoxDecoration(
                  borderRadius: _getBorderRadius(),
                  border: Border.all(
                    color: AppColors.primaryBlue.withOpacity(
                      0.6 * (1.0 - _rippleAnimation.value),
                    ),
                    width: 2,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );

    if (widget.isExpanded) {
      button = SizedBox(
        width: double.infinity,
        child: button,
      );
    }

    return button;
  }
}

// Vordefinierte Button-Komponenten für häufige Anwendungsfälle
class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonSize size;
  final bool isLoading;
  final bool isExpanded;
  final IconData? icon;

  const PrimaryButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.size = ButtonSize.medium,
    this.isLoading = false,
    this.isExpanded = false,
    this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomButton(
      text: text,
      onPressed: onPressed,
      type: ButtonType.primary,
      size: size,
      isLoading: isLoading,
      isExpanded: isExpanded,
      leadingIcon: icon,
    );
  }
}

class GradientButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final LinearGradient? gradient;
  final ButtonSize size;
  final bool isLoading;
  final bool isExpanded;

  const GradientButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.gradient,
    this.size = ButtonSize.medium,
    this.isLoading = false,
    this.isExpanded = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomButton(
      text: text,
      onPressed: onPressed,
      type: ButtonType.gradient,
      gradient: gradient,
      size: size,
      isLoading: isLoading,
      isExpanded: isExpanded,
    );
  }
}

class FloatingActionButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final IconData icon;
  final String? tooltip;
  final ButtonSize size;

  const FloatingActionButton({
    Key? key,
    this.onPressed,
    required this.icon,
    this.tooltip,
    this.size = ButtonSize.large,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip ?? '',
      child: CustomButton(
        onPressed: onPressed,
        type: ButtonType.floating,
        size: size,
        child: Icon(icon),
        borderRadius: BorderRadius.circular(28),
      ),
    );
  }
}