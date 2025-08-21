// Avatales.Widgets.AnimatedCard
import 'package:flutter/material.dart';
import 'package:edory_app/core/theme/app_theme.dart';
import 'package:edory_app/core/theme/app_colors.dart';
import 'package:flutter/services.dart';

class AnimatedCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? backgroundColor;
  final LinearGradient? gradient;
  final double? elevation;
  final BorderRadius? borderRadius;
  final bool enableHoverEffect;
  final bool enableScaleAnimation;
  final bool enableShimmerEffect;
  final Duration animationDuration;
  final Curve animationCurve;
  final double scaleValue;
  final List<BoxShadow>? customShadow;

  const AnimatedCard({
    Key? key,
    required this.child,
    this.onTap,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.gradient,
    this.elevation,
    this.borderRadius,
    this.enableHoverEffect = true,
    this.enableScaleAnimation = true,
    this.enableShimmerEffect = false,
    this.animationDuration = AppTheme.animationMedium,
    this.animationCurve = AppTheme.animationCurve,
    this.scaleValue = 0.98,
    this.customShadow,
  }) : super(key: key);

  @override
  State<AnimatedCard> createState() => _AnimatedCardState();
}

class _AnimatedCardState extends State<AnimatedCard>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _shimmerController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _shimmerAnimation;
  
  bool _isPressed = false;
  bool _isHovered = false;

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

    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: widget.scaleValue,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: widget.animationCurve,
    ));

    _shimmerAnimation = Tween<double>(
      begin: -1.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _shimmerController,
      curve: Curves.easeInOut,
    ));

    if (widget.enableShimmerEffect) {
      _shimmerController.repeat();
    }
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.enableScaleAnimation) {
      setState(() => _isPressed = true);
      _scaleController.forward();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (widget.enableScaleAnimation) {
      setState(() => _isPressed = false);
      _scaleController.reverse();
    }
  }

  void _handleTapCancel() {
    if (widget.enableScaleAnimation) {
      setState(() => _isPressed = false);
      _scaleController.reverse();
    }
  }

  void _handleTap() {
    widget.onTap?.call();
    
    // Haptic Feedback
    HapticFeedback.lightImpact();
    
    // Trigger zusätzliche Animation bei Tap
    if (widget.enableScaleAnimation) {
      _scaleController.forward().then((_) {
        _scaleController.reverse();
      });
    }
  }

  Widget _buildShimmerEffect(Widget child) {
    if (!widget.enableShimmerEffect) return child;

    return AnimatedBuilder(
      animation: _shimmerAnimation,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              colors: [
                Colors.transparent,
                AppColors.shimmerHighlight.withOpacity(0.3),
                Colors.transparent,
              ],
              stops: const [0.0, 0.5, 1.0],
              begin: Alignment(-1.0 + _shimmerAnimation.value, -1.0),
              end: Alignment(1.0 + _shimmerAnimation.value, 1.0),
            ).createShader(bounds);
          },
          blendMode: BlendMode.srcATop,
          child: child,
        );
      },
      child: child,
    );
  }

  Widget _buildCardContent() {
    return Container(
      padding: widget.padding ?? const EdgeInsets.all(AppTheme.paddingMedium),
      decoration: BoxDecoration(
        color: widget.gradient == null ? 
               (widget.backgroundColor ?? AppColors.white) : null,
        gradient: widget.gradient,
        borderRadius: widget.borderRadius ?? AppTheme.radiusMedium,
        boxShadow: widget.customShadow ?? 
                   (_isPressed ? AppTheme.softShadow : AppTheme.mediumShadow),
        border: Border.all(
          color: AppColors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: widget.child,
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget cardWidget = Container(
      margin: widget.margin ?? const EdgeInsets.all(AppTheme.paddingSmall),
      child: _buildCardContent(),
    );

    cardWidget = _buildShimmerEffect(cardWidget);

    if (widget.enableScaleAnimation) {
      cardWidget = AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          );
        },
        child: cardWidget,
      );
    }

    return GestureDetector(
      onTap: widget.onTap != null ? _handleTap : null,
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: MouseRegion(
        onEnter: (_) {
          if (widget.enableHoverEffect) {
            setState(() => _isHovered = true);
          }
        },
        onExit: (_) {
          if (widget.enableHoverEffect) {
            setState(() => _isHovered = false);
          }
        },
        child: AnimatedContainer(
          duration: widget.animationDuration,
          curve: widget.animationCurve,
          transform: Matrix4.identity()
            ..translate(0.0, _isHovered ? -2.0 : 0.0),
          child: cardWidget,
        ),
      ),
    );
  }
}

// Spezielle Card Varianten
class GlassCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  const GlassCard({
    Key? key,
    required this.child,
    this.onTap,
    this.padding,
    this.margin,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedCard(
      onTap: onTap,
      padding: padding,
      margin: margin,
      backgroundColor: AppColors.glassEffect,
      borderRadius: AppTheme.radiusMedium,
      customShadow: [
        BoxShadow(
          color: AppColors.white.withOpacity(0.25),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ],
      child: child,
    );
  }
}

class GradientCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final LinearGradient gradient;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  const GradientCard({
    Key? key,
    required this.child,
    required this.gradient,
    this.onTap,
    this.padding,
    this.margin,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedCard(
      onTap: onTap,
      padding: padding,
      margin: margin,
      gradient: gradient,
      borderRadius: AppTheme.radiusLarge,
      child: child,
    );
  }
}

class FeatureCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? icon;
  final VoidCallback? onTap;
  final Color? accentColor;

  const FeatureCard({
    Key? key,
    required this.title,
    this.subtitle,
    this.icon,
    this.onTap,
    this.accentColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = accentColor ?? AppColors.primaryBlue;

    return AnimatedCard(
      onTap: onTap,
      enableShimmerEffect: onTap != null,
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          color.withOpacity(0.1),
          color.withOpacity(0.05),
          AppColors.white,
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Container(
              padding: const EdgeInsets.all(AppTheme.paddingSmall),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: AppTheme.radiusSmall,
              ),
              child: icon,
            ),
            const SizedBox(height: AppTheme.paddingMedium),
          ],
          Text(
            title,
            style: theme.textTheme.titleLarge?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: AppTheme.paddingSmall),
            Text(
              subtitle!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.secondaryText,
              ),
            ),
          ],
        ],
      ),
    );
  }
}