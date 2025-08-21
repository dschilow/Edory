// Avatales.Widgets.GradientBackground
import 'package:flutter/material.dart';
import 'package:edory_app/core/theme/app_colors.dart';
import 'package:edory_app/core/theme/app_theme.dart';

class GradientBackground extends StatefulWidget {
  final Widget child;
  final LinearGradient? gradient;
  final bool enableParallax;
  final bool enableFloatingElements;
  final double? height;
  final EdgeInsets? padding;

  const GradientBackground({
    Key? key,
    required this.child,
    this.gradient,
    this.enableParallax = false,
    this.enableFloatingElements = true,
    this.height,
    this.padding,
  }) : super(key: key);

  @override
  State<GradientBackground> createState() => _GradientBackgroundState();
}

class _GradientBackgroundState extends State<GradientBackground>
    with TickerProviderStateMixin {
  late AnimationController _floatingController;
  late AnimationController _parallaxController;
  late List<Animation<Offset>> _floatingAnimations;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _floatingController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    );

    _parallaxController = AnimationController(
      duration: const Duration(seconds: 30),
      vsync: this,
    );

    // Verschiedene floating Elemente mit unterschiedlichen Bewegungsmustern
    _floatingAnimations = List.generate(6, (index) {
      final delay = index * 0.2;
      return Tween<Offset>(
        begin: Offset(
          (index % 2 == 0) ? -0.5 : 1.5,
          0.5 + (index * 0.3),
        ),
        end: Offset(
          (index % 2 == 0) ? 1.5 : -0.5,
          0.2 + (index * 0.4),
        ),
      ).animate(CurvedAnimation(
        parent: _floatingController,
        curve: Interval(delay, 1.0, curve: Curves.easeInOut),
      ));
    });

    if (widget.enableFloatingElements) {
      _floatingController.repeat(reverse: true);
    }

    if (widget.enableParallax) {
      _parallaxController.repeat();
    }
  }

  @override
  void dispose() {
    _floatingController.dispose();
    _parallaxController.dispose();
    super.dispose();
  }

  Widget _buildFloatingElement({
    required double size,
    required Color color,
    required Animation<Offset> animation,
    IconData? icon,
    double opacity = 0.6,
  }) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Positioned(
          left: MediaQuery.of(context).size.width * animation.value.dx,
          top: MediaQuery.of(context).size.height * animation.value.dy,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: color.withOpacity(opacity),
              borderRadius: BorderRadius.circular(size / 2),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: icon != null
                ? Icon(
                    icon,
                    color: Colors.white.withOpacity(0.8),
                    size: size * 0.6,
                  )
                : null,
          ),
        );
      },
    );
  }

  List<Widget> _buildFloatingElements() {
    if (!widget.enableFloatingElements) return [];

    return [
      // Große blaue Kreise
      _buildFloatingElement(
        size: 120,
        color: AppColors.primaryBlue,
        animation: _floatingAnimations[0],
        opacity: 0.4,
      ),
      // Mittelgroße rosa Kreise
      _buildFloatingElement(
        size: 80,
        color: AppColors.primaryPink,
        animation: _floatingAnimations[1],
        opacity: 0.5,
      ),
      // Kleine violette Kreise
      _buildFloatingElement(
        size: 60,
        color: AppColors.primaryPurple,
        animation: _floatingAnimations[2],
        opacity: 0.6,
      ),
      // Mint-farbene Elemente
      _buildFloatingElement(
        size: 90,
        color: AppColors.primaryMint,
        animation: _floatingAnimations[3],
        opacity: 0.3,
      ),
      // Pfirsich-farbene Elemente
      _buildFloatingElement(
        size: 70,
        color: AppColors.primaryPeach,
        animation: _floatingAnimations[4],
        opacity: 0.4,
      ),
      // Lavendel Elemente
      _buildFloatingElement(
        size: 110,
        color: AppColors.primaryLavender,
        animation: _floatingAnimations[5],
        opacity: 0.3,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final defaultGradient = widget.gradient ?? AppColors.skyGradient;

    return Container(
      height: widget.height,
      decoration: BoxDecoration(
        gradient: defaultGradient,
      ),
      child: Stack(
        children: [
          // Parallax Hintergrund Layer
          if (widget.enableParallax)
            AnimatedBuilder(
              animation: _parallaxController,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(
                    50 * _parallaxController.value,
                    20 * _parallaxController.value,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.white.withOpacity(0.1),
                          Colors.transparent,
                          AppColors.primaryBlue.withOpacity(0.05),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),

          // Floating Elements
          ...(_buildFloatingElements()),

          // Gradient Overlay für bessere Lesbarkeit
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  AppColors.white.withOpacity(0.1),
                  AppColors.white.withOpacity(0.3),
                ],
                stops: const [0.0, 0.7, 1.0],
              ),
            ),
          ),

          // Hauptinhalt
          Positioned.fill(
            child: Padding(
              padding: widget.padding ?? const EdgeInsets.all(AppTheme.paddingMedium),
              child: widget.child,
            ),
          ),
        ],
      ),
    );
  }
}

// Cloud Background für sanftere Effekte
class CloudBackground extends StatefulWidget {
  final Widget child;
  final EdgeInsets? padding;
  final bool enableAnimation;

  const CloudBackground({
    Key? key,
    required this.child,
    this.padding,
    this.enableAnimation = true,
  }) : super(key: key);

  @override
  State<CloudBackground> createState() => _CloudBackgroundState();
}

class _CloudBackgroundState extends State<CloudBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 25),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);

    if (widget.enableAnimation) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppColors.cloudGradient,
      ),
      child: Stack(
        children: [
          // Animierte Cloud Shapes
          if (widget.enableAnimation)
            AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return CustomPaint(
                  painter: CloudPainter(_animation.value),
                  size: Size.infinite,
                );
              },
            ),

          // Statische Cloud Shapes als Fallback
          if (!widget.enableAnimation)
            CustomPaint(
              painter: CloudPainter(0.0),
              size: Size.infinite,
            ),

          // Content
          Positioned.fill(
            child: Padding(
              padding: widget.padding ?? const EdgeInsets.all(AppTheme.paddingMedium),
              child: widget.child,
            ),
          ),
        ],
      ),
    );
  }
}

// Custom Painter für Cloud Effekte
class CloudPainter extends CustomPainter {
  final double animationValue;

  CloudPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = AppColors.white.withOpacity(0.3);

    // Verschiedene Cloud Shapes
    _drawCloud(canvas, size, paint, 0.2, 0.1, 80 + (animationValue * 20));
    _drawCloud(canvas, size, paint, 0.7, 0.2, 60 + (animationValue * 15));
    _drawCloud(canvas, size, paint, 0.1, 0.6, 100 + (animationValue * 25));
    _drawCloud(canvas, size, paint, 0.8, 0.7, 70 + (animationValue * 18));
    _drawCloud(canvas, size, paint, 0.4, 0.3, 90 + (animationValue * 22));
  }

  void _drawCloud(Canvas canvas, Size size, Paint paint, double x, double y, double radius) {
    final center = Offset(size.width * x, size.height * y);
    
    // Hauptkreis
    canvas.drawCircle(center, radius, paint);
    
    // Zusätzliche Kreise für Cloud-Form
    canvas.drawCircle(
      center.translate(-radius * 0.6, -radius * 0.3),
      radius * 0.7,
      paint,
    );
    canvas.drawCircle(
      center.translate(radius * 0.6, -radius * 0.2),
      radius * 0.8,
      paint,
    );
    canvas.drawCircle(
      center.translate(0, radius * 0.4),
      radius * 0.9,
      paint,
    );
  }

  @override
  bool shouldRepaint(CloudPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}

// Spezielle Hintergrund-Varianten
class DreamBackground extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;

  const DreamBackground({
    Key? key,
    required this.child,
    this.padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      gradient: AppColors.dreamGradient,
      enableFloatingElements: true,
      enableParallax: true,
      padding: padding,
      child: child,
    );
  }
}

class SunsetBackground extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;

  const SunsetBackground({
    Key? key,
    required this.child,
    this.padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      gradient: AppColors.sunsetGradient,
      enableFloatingElements: true,
      enableParallax: false,
      padding: padding,
      child: child,
    );
  }
}