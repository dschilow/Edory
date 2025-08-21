// Avatales.Widgets.LoadingWidgets
import 'package:flutter/material.dart';
import 'package:edory_app/core/theme/app_theme.dart';
import 'package:edory_app/core/theme/app_colors.dart';

/// Animierter Loading Indicator mit verschiedenen Stilen
class CustomLoadingIndicator extends StatefulWidget {
  final LoadingStyle style;
  final double size;
  final Color? color;
  final String? message;
  final bool showMessage;

  const CustomLoadingIndicator({
    Key? key,
    this.style = LoadingStyle.dots,
    this.size = 40.0,
    this.color,
    this.message,
    this.showMessage = false,
  }) : super(key: key);

  @override
  State<CustomLoadingIndicator> createState() => _CustomLoadingIndicatorState();
}

class _CustomLoadingIndicatorState extends State<CustomLoadingIndicator>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _pulseController;
  late Animation<double> _animation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimations();
  }

  void _initializeAnimations() {
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
  }

  void _startAnimations() {
    _controller.repeat();
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Widget _buildDotsIndicator() {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (index) {
            final delay = index * 0.3;
            final animationValue = (_animation.value - delay).clamp(0.0, 1.0);
            final opacity = (animationValue * 2).clamp(0.0, 1.0);
            final scale = 0.5 + (animationValue * 0.5);

            return Container(
              margin: EdgeInsets.symmetric(horizontal: widget.size * 0.1),
              child: Transform.scale(
                scale: scale,
                child: Opacity(
                  opacity: opacity,
                  child: Container(
                    width: widget.size * 0.3,
                    height: widget.size * 0.3,
                    decoration: BoxDecoration(
                      color: widget.color ?? AppColors.primaryBlue,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }

  Widget _buildSpinnerIndicator() {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.rotate(
          angle: _animation.value * 2 * 3.14159,
          child: CustomPaint(
            size: Size(widget.size, widget.size),
            painter: SpinnerPainter(
              color: widget.color ?? AppColors.primaryBlue,
              progress: _animation.value,
            ),
          ),
        );
      },
    );
  }

  Widget _buildPulseIndicator() {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              color: widget.color ?? AppColors.primaryBlue,
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }

  Widget _buildWaveIndicator() {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(4, (index) {
            final delay = index * 0.2;
            final animationValue = (_animation.value - delay).clamp(0.0, 1.0);
            final height = widget.size * (0.3 + 0.7 * animationValue);

            return Container(
              margin: EdgeInsets.symmetric(horizontal: widget.size * 0.05),
              width: widget.size * 0.15,
              height: height,
              decoration: BoxDecoration(
                color: widget.color ?? AppColors.primaryBlue,
                borderRadius: BorderRadius.circular(widget.size * 0.075),
              ),
            );
          }),
        );
      },
    );
  }

  Widget _buildRippleIndicator() {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: List.generate(3, (index) {
            final delay = index * 0.3;
            final animationValue = (_animation.value - delay).clamp(0.0, 1.0);
            final scale = 0.5 + (animationValue * 1.5);
            final opacity = (1.0 - animationValue).clamp(0.0, 1.0);

            return Transform.scale(
              scale: scale,
              child: Opacity(
                opacity: opacity,
                child: Container(
                  width: widget.size,
                  height: widget.size,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: widget.color ?? AppColors.primaryBlue,
                      width: 2,
                    ),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }

  Widget _buildLoadingWidget() {
    switch (widget.style) {
      case LoadingStyle.dots:
        return _buildDotsIndicator();
      case LoadingStyle.spinner:
        return _buildSpinnerIndicator();
      case LoadingStyle.pulse:
        return _buildPulseIndicator();
      case LoadingStyle.wave:
        return _buildWaveIndicator();
      case LoadingStyle.ripple:
        return _buildRippleIndicator();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildLoadingWidget(),
        if (widget.showMessage && widget.message != null) ...[
          const SizedBox(height: AppTheme.paddingMedium),
          Text(
            widget.message!,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.secondaryText,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }
}

/// Spinner Painter für Custom Loading Indicator
class SpinnerPainter extends CustomPainter {
  final Color color;
  final double progress;

  SpinnerPainter({required this.color, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = size.width * 0.1
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.4;

    // Hintergrund-Kreis
    final backgroundPaint = Paint()
      ..color = color.withOpacity(0.2)
      ..strokeWidth = size.width * 0.1
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(center, radius, backgroundPaint);

    // Progress-Arc
    const startAngle = -3.14159 / 2; // Start oben
    final sweepAngle = 2 * 3.14159 * 0.7; // 70% des Kreises

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(SpinnerPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}

/// Shimmer Loading Effect für Listen und Cards
class ShimmerLoading extends StatefulWidget {
  final Widget child;
  final bool isLoading;
  final Color? baseColor;
  final Color? highlightColor;

  const ShimmerLoading({
    Key? key,
    required this.child,
    required this.isLoading,
    this.baseColor,
    this.highlightColor,
  }) : super(key: key);

  @override
  State<ShimmerLoading> createState() => _ShimmerLoadingState();
}

class _ShimmerLoadingState extends State<ShimmerLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween<double>(begin: -1.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    
    if (widget.isLoading) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(ShimmerLoading oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isLoading != oldWidget.isLoading) {
      if (widget.isLoading) {
        _controller.repeat();
      } else {
        _controller.stop();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isLoading) {
      return widget.child;
    }

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              colors: [
                widget.baseColor ?? AppColors.lightGray,
                widget.highlightColor ?? AppColors.white,
                widget.baseColor ?? AppColors.lightGray,
              ],
              stops: const [0.0, 0.5, 1.0],
              begin: Alignment(-1.0 + _animation.value, 0.0),
              end: Alignment(1.0 + _animation.value, 0.0),
            ).createShader(bounds);
          },
          blendMode: BlendMode.srcATop,
          child: widget.child,
        );
      },
    );
  }
}

/// Skeleton Loading für verschiedene Layouts
class SkeletonLoader extends StatelessWidget {
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;

  const SkeletonLoader({
    Key? key,
    this.width,
    this.height,
    this.borderRadius,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ShimmerLoading(
      isLoading: true,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: AppColors.lightGray,
          borderRadius: borderRadius ?? BorderRadius.circular(AppTheme.borderRadiusSmall),
        ),
      ),
    );
  }
}

/// Loading Overlay für ganze Screens
class LoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  final String? message;
  final LoadingStyle style;
  final Color? backgroundColor;

  const LoadingOverlay({
    Key? key,
    required this.isLoading,
    required this.child,
    this.message,
    this.style = LoadingStyle.spinner,
    this.backgroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: backgroundColor ?? AppColors.shadowMedium,
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(AppTheme.paddingLarge),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
                  boxShadow: AppTheme.mediumShadow,
                ),
                child: CustomLoadingIndicator(
                  style: style,
                  message: message,
                  showMessage: message != null,
                  size: 50,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Progress Bar mit Animation
class AnimatedProgressBar extends StatefulWidget {
  final double progress;
  final double height;
  final Color? backgroundColor;
  final LinearGradient? gradient;
  final Color? progressColor;
  final BorderRadius? borderRadius;
  final String? label;
  final bool showPercentage;

  const AnimatedProgressBar({
    Key? key,
    required this.progress,
    this.height = 8.0,
    this.backgroundColor,
    this.gradient,
    this.progressColor,
    this.borderRadius,
    this.label,
    this.showPercentage = false,
  }) : super(key: key);

  @override
  State<AnimatedProgressBar> createState() => _AnimatedProgressBarState();
}

class _AnimatedProgressBarState extends State<AnimatedProgressBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AppTheme.animationMedium,
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.0, end: widget.progress).animate(
      CurvedAnimation(parent: _controller, curve: AppTheme.animationCurve),
    );
    _controller.forward();
  }

  @override
  void didUpdateWidget(AnimatedProgressBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.progress != widget.progress) {
      _animation = Tween<double>(
        begin: _animation.value,
        end: widget.progress,
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: AppTheme.animationCurve,
      ));
      _controller.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null || widget.showPercentage) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (widget.label != null)
                Text(
                  widget.label!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.primaryText,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              if (widget.showPercentage)
                AnimatedBuilder(
                  animation: _animation,
                  builder: (context, child) {
                    return Text(
                      '${(_animation.value * 100).round()}%',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.secondaryText,
                        fontWeight: FontWeight.w500,
                      ),
                    );
                  },
                ),
            ],
          ),
          const SizedBox(height: AppTheme.paddingSmall / 2),
        ],
        Container(
          height: widget.height,
          decoration: BoxDecoration(
            color: widget.backgroundColor ?? AppColors.lightGray,
            borderRadius: widget.borderRadius ?? 
                          BorderRadius.circular(widget.height / 2),
          ),
          child: AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: _animation.value.clamp(0.0, 1.0),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: widget.gradient ?? 
                              AppColors.createCustomGradient(
                                startColor: widget.progressColor ?? AppColors.primaryBlue,
                                endColor: widget.progressColor ?? AppColors.primaryMint,
                              ),
                    borderRadius: widget.borderRadius ?? 
                                  BorderRadius.circular(widget.height / 2),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

/// Error State Widget
class ErrorStateWidget extends StatelessWidget {
  final String title;
  final String? message;
  final IconData? icon;
  final VoidCallback? onRetry;
  final String? retryText;

  const ErrorStateWidget({
    Key? key,
    required this.title,
    this.message,
    this.icon,
    this.onRetry,
    this.retryText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.paddingLarge),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon ?? Icons.error_outline,
                size: 40,
                color: AppColors.error,
              ),
            ),
            const SizedBox(height: AppTheme.paddingLarge),
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.primaryText,
              ),
              textAlign: TextAlign.center,
            ),
            if (message != null) ...[
              const SizedBox(height: AppTheme.paddingMedium),
              Text(
                message!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.secondaryText,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (onRetry != null) ...[
              const SizedBox(height: AppTheme.paddingLarge),
              ElevatedButton(
                onPressed: onRetry,
                child: Text(retryText ?? 'Erneut versuchen'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Empty State Widget
class EmptyStateWidget extends StatelessWidget {
  final String title;
  final String? message;
  final IconData? icon;
  final VoidCallback? onAction;
  final String? actionText;

  const EmptyStateWidget({
    Key? key,
    required this.title,
    this.message,
    this.icon,
    this.onAction,
    this.actionText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.paddingLarge),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon ?? Icons.inbox_outlined,
                size: 40,
                color: AppColors.primaryBlue,
              ),
            ),
            const SizedBox(height: AppTheme.paddingLarge),
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.primaryText,
              ),
              textAlign: TextAlign.center,
            ),
            if (message != null) ...[
              const SizedBox(height: AppTheme.paddingMedium),
              Text(
                message!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.secondaryText,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (onAction != null) ...[
              const SizedBox(height: AppTheme.paddingLarge),
              ElevatedButton(
                onPressed: onAction,
                child: Text(actionText ?? 'Aktion'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ===== Enums =====

enum LoadingStyle {
  dots,
  spinner,
  pulse,
  wave,
  ripple,
}