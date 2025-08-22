// lib/features/home/presentation/widgets/hero_card.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:math';
import '../../../../core/theme/modern_design_system.dart';

/// Hero Card Widget für die Avatales Homepage
/// Prominente Call-to-Action Karte mit Gradient und Animation
class HeroCard extends StatefulWidget {
  const HeroCard({
    super.key,
    required this.title,
    required this.subtitle,
    this.description,
    required this.buttonText,
    required this.onPressed,
    this.backgroundGradient,
    this.illustration,
    this.height = 200,
  });

  final String title;
  final String subtitle;
  final String? description;
  final String buttonText;
  final VoidCallback onPressed;
  final LinearGradient? backgroundGradient;
  final Widget? illustration;
  final double height;

  @override
  State<HeroCard> createState() => _HeroCardState();
}

class _HeroCardState extends State<HeroCard>
    with TickerProviderStateMixin {
  
  late AnimationController _animationController;
  late AnimationController _pulseController;
  late AnimationController _pressController;
  
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _pulseController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    
    _pressController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    
    _startAnimations();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pulseController.dispose();
    _pressController.dispose();
    super.dispose();
  }

  void _startAnimations() {
    _animationController.forward();
    _pulseController.repeat();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _onPressedChanged(true),
      onTapUp: (_) => _onPressedChanged(false),
      onTapCancel: () => _onPressedChanged(false),
      onTap: widget.onPressed,
      child: AnimatedBuilder(
        animation: Listenable.merge([_animationController, _pressController]),
        builder: (context, child) {
          final scale = 1.0 - (_pressController.value * 0.02);
          
          return Transform.scale(
            scale: scale,
            child: Container(
              height: widget.height,
              decoration: BoxDecoration(
                gradient: widget.backgroundGradient ?? ModernDesignSystem.primaryGradient,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: (widget.backgroundGradient?.colors.first ?? 
                           ModernDesignSystem.primaryColor).withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                  BoxShadow(
                    color: Colors.white.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Stack(
                  children: [
                    // Background Pattern
                    _buildBackgroundPattern(),
                    
                    // Illustration
                    if (widget.illustration != null)
                      Positioned(
                        right: -20,
                        top: -20,
                        bottom: -20,
                        width: 120,
                        child: widget.illustration!,
                      ),
                    
                    // Content
                    _buildContent(),
                    
                    // Floating Action Elements
                    _buildFloatingElements(),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBackgroundPattern() {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return CustomPaint(
          painter: _HeroPatternPainter(
            animationValue: _animationController.value,
          ),
          size: Size.infinite,
        );
      },
    );
  }

  Widget _buildContent() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            widget.title,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              height: 1.2,
            ),
          )
              .animate(controller: _animationController)
              .slideY(begin: 0.5, duration: 600.ms)
              .fadeIn(),
          
          const SizedBox(height: 8),
          
          // Subtitle
          Text(
            widget.subtitle,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.white.withOpacity(0.9),
              fontWeight: FontWeight.w500,
            ),
          )
              .animate(controller: _animationController)
              .slideY(begin: 0.5, duration: 600.ms, delay: 100.ms)
              .fadeIn(),
          
          if (widget.description != null) ...[
            const SizedBox(height: 8),
            Text(
              widget.description!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white.withOpacity(0.8),
                height: 1.4,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            )
                .animate(controller: _animationController)
                .slideY(begin: 0.5, duration: 600.ms, delay: 200.ms)
                .fadeIn(),
          ],
          
          const Spacer(),
          
          // Action Button
          _buildActionButton()
              .animate(controller: _animationController)
              .slideY(begin: 0.5, duration: 600.ms, delay: 400.ms)
              .fadeIn(),
        ],
      ),
    );
  }

  Widget _buildActionButton() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: widget.onPressed,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.auto_awesome,
                  color: widget.backgroundGradient?.colors.first ?? 
                         ModernDesignSystem.primaryColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  widget.buttonText,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: widget.backgroundGradient?.colors.first ?? 
                           ModernDesignSystem.primaryColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.arrow_forward_ios,
                  color: widget.backgroundGradient?.colors.first ?? 
                         ModernDesignSystem.primaryColor,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    )
        .animate(controller: _pulseController)
        .shimmer(
          duration: 2000.ms,
          color: Colors.white.withOpacity(0.2),
        );
  }

  Widget _buildFloatingElements() {
    return Stack(
      children: [
        // Floating circles
        Positioned(
          top: 30,
          right: 100,
          child: AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              return Transform.scale(
                scale: 0.8 + (_pulseController.value * 0.3),
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                ),
              );
            },
          ),
        ),
        
        Positioned(
          bottom: 60,
          right: 40,
          child: AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              return Transform.scale(
                scale: 1.0 + (_pulseController.value * 0.2),
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.4),
                    shape: BoxShape.circle,
                  ),
                ),
              );
            },
          ),
        ),
        
        // Sparkle effect
        Positioned(
          top: 50,
          right: 60,
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Opacity(
                opacity: (_animationController.value * 0.8).clamp(0.0, 1.0),
                child: Transform.rotate(
                  angle: _animationController.value * 6.28, // 2π
                  child: Icon(
                    Icons.auto_awesome,
                    color: Colors.white.withOpacity(0.6),
                    size: 16,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _onPressedChanged(bool isPressed) {
    setState(() => _isPressed = isPressed);
    if (isPressed) {
      _pressController.forward();
    } else {
      _pressController.reverse();
    }
  }
}

/// Custom painter for hero card background pattern
class _HeroPatternPainter extends CustomPainter {
  final double animationValue;

  const _HeroPatternPainter({required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.05 * animationValue)
      ..style = PaintingStyle.fill;

    // Create flowing wave pattern
    final path = Path();
    const waveHeight = 30.0;
    const waveLength = 100.0;
    
    path.moveTo(0, size.height * 0.7);
    
    for (double x = 0; x <= size.width; x += 20) {
      final y = (size.height * 0.7) + 
                (waveHeight * animationValue * 
                 sin(x / waveLength));
      path.lineTo(x, y);
    }
    
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    
    canvas.drawPath(path, paint);

    // Add subtle dots
    final dotPaint = Paint()
      ..color = Colors.white.withOpacity(0.1 * animationValue)
      ..style = PaintingStyle.fill;

    const spacing = 40.0;
    const dotSize = 1.0;

    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(
          Offset(x + (spacing * 0.5), y + (spacing * 0.5)),
          dotSize * animationValue,
          dotPaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _HeroPatternPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}

/// Hero Card Variants für verschiedene Use Cases
class HeroCardVariants {
  /// Story creation CTA
  static Widget storyCreation({
    required VoidCallback onPressed,
  }) {
    return HeroCard(
      title: 'Neue Geschichte',
      subtitle: 'Erschaffe magische Welten',
      description: 'Verwende deine Avatare für personalisierte Abenteuer voller Fantasie und Lernspaß.',
      buttonText: 'Geschichte erstellen',
      onPressed: onPressed,
      backgroundGradient: ModernDesignSystem.primaryGradient,
      illustration: const Icon(
        Icons.auto_stories,
        size: 80,
        color: Colors.white,
      ),
    );
  }

  /// Character creation CTA
  static Widget characterCreation({
    required VoidCallback onPressed,
  }) {
    return HeroCard(
      title: 'Erster Avatar',
      subtitle: 'Beginne dein Abenteuer',
      description: 'Erstelle deinen ersten digitalen Helden und entdecke unendliche Geschichtenwelten.',
      buttonText: 'Avatar erstellen',
      onPressed: onPressed,
      backgroundGradient: ModernDesignSystem.orangeGradient,
      illustration: const Icon(
        Icons.person_add,
        size: 80,
        color: Colors.white,
      ),
    );
  }

  /// Daily challenge CTA
  static Widget dailyChallenge({
    required VoidCallback onPressed,
    required String challengeTitle,
  }) {
    return HeroCard(
      title: 'Tägliche Challenge',
      subtitle: challengeTitle,
      description: 'Meistere die heutige Herausforderung und verdiene exklusive Belohnungen.',
      buttonText: 'Challenge starten',
      onPressed: onPressed,
      backgroundGradient: ModernDesignSystem.greenGradient,
      illustration: const Icon(
        Icons.emoji_events,
        size: 80,
        color: Colors.white,
      ),
    );
  }

  /// Learning journey CTA
  static Widget learningJourney({
    required VoidCallback onPressed,
  }) {
    return HeroCard(
      title: 'Lernreise',
      subtitle: 'Wachse mit deinen Geschichten',
      description: 'Entdecke neue Fähigkeiten und entwickle dich durch interaktive Erlebnisse weiter.',
      buttonText: 'Lernen beginnen',
      onPressed: onPressed,
      backgroundGradient: const LinearGradient(
        colors: [ModernDesignSystem.pastelPurple, Color(0xFF9C88FF)],
      ),
      illustration: const Icon(
        Icons.school,
        size: 80,
        color: Colors.white,
      ),
    );
  }
}