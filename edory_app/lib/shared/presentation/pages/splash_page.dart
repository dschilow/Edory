// lib/shared/presentation/pages/splash_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/modern_design_system.dart';

class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage>
    with TickerProviderStateMixin {
  
  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _backgroundController;
  late AnimationController _cloudController;
  
  @override
  void initState() {
    super.initState();
    
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _textController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _backgroundController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _cloudController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );
    
    _initializeApp();
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    _backgroundController.dispose();
    _cloudController.dispose();
    super.dispose();
  }

  Future<void> _initializeApp() async {
    // Start animations
    _backgroundController.forward();
    _cloudController.repeat();
    
    await Future.delayed(const Duration(milliseconds: 300));
    _logoController.forward();
    
    await Future.delayed(const Duration(milliseconds: 600));
    _textController.forward();
    
    // Simulate app initialization
    await Future.delayed(const Duration(milliseconds: 2000));
    
    // Navigate to main app
    if (mounted) {
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0E1324), // dark bg for dramatic effect
      body: Stack(
        children: [
          // Animated Background
          _buildAnimatedBackground(),
          
          // Floating Clouds
          _buildFloatingClouds(),
          
          // Main Content
          SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // App Logo/Mascot
                  _buildLogo(),
                  
                  const SizedBox(height: 40),
                  
                  // App Name
                  _buildAppName(),
                  
                  const SizedBox(height: 16),
                  
                  // Tagline
                  _buildTagline(),
                  
                  const SizedBox(height: 80),
                  
                  // Loading Indicator
                  _buildLoadingIndicator(),
                ],
              ),
            ),
          ),
          
          // Powered by indicator
          _buildPoweredBy(),
        ],
      ),
    );
  }

  Widget _buildAnimatedBackground() {
    return AnimatedBuilder(
      animation: _backgroundController,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF0E1324),
                const Color(0xFF171C30),
                Color.lerp(
                  const Color(0xFF171C30),
                  const Color(0xFF8D95FF).withOpacity(0.1),
                  _backgroundController.value,
                ) ?? const Color(0xFF171C30),
              ],
            ),
          ),
          child: CustomPaint(
            painter: StarFieldPainter(_backgroundController.value),
            size: Size.infinite,
          ),
        );
      },
    );
  }

  Widget _buildFloatingClouds() {
    return AnimatedBuilder(
      animation: _cloudController,
      builder: (context, child) {
        return Stack(
          children: [
            // Cloud 1
            Positioned(
              top: 100 + (20 * (_cloudController.value % 1)),
              left: -50 + (MediaQuery.of(context).size.width * 1.2 * _cloudController.value) % (MediaQuery.of(context).size.width + 100),
              child: Opacity(
                opacity: 0.3,
                child: Transform.scale(
                  scale: 0.8,
                  child: const Text('☁️', style: TextStyle(fontSize: 40)),
                ),
              ),
            ),
            
            // Cloud 2
            Positioned(
              top: 200 + (15 * ((_cloudController.value + 0.3) % 1)),
              left: -50 + (MediaQuery.of(context).size.width * 1.2 * (_cloudController.value + 0.3)) % (MediaQuery.of(context).size.width + 100),
              child: Opacity(
                opacity: 0.2,
                child: Transform.scale(
                  scale: 1.2,
                  child: const Text('☁️', style: TextStyle(fontSize: 40)),
                ),
              ),
            ),
            
            // Cloud 3
            Positioned(
              top: 300 + (25 * ((_cloudController.value + 0.7) % 1)),
              left: -50 + (MediaQuery.of(context).size.width * 1.2 * (_cloudController.value + 0.7)) % (MediaQuery.of(context).size.width + 100),
              child: Opacity(
                opacity: 0.25,
                child: const Text('☁️', style: TextStyle(fontSize: 40)),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLogo() {
    return Container(
      width: 160,
      height: 160,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(80),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF8D95FF),
            const Color(0xFF9EF0DE),
            const Color(0xFFFF9BC4),
          ],
        ),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 3,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8D95FF).withOpacity(0.4),
            blurRadius: 40,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('📖', style: TextStyle(fontSize: 48)),
            SizedBox(height: 4),
            Text('✨', style: TextStyle(fontSize: 24)),
          ],
        ),
      ),
    ).animate(controller: _logoController)
      .scale(
        begin: const Offset(0.3, 0.3),
        end: const Offset(1.0, 1.0),
        curve: Curves.elasticOut,
      )
      .fadeIn(duration: 800.ms)
      .then()
      .shimmer(
        duration: 2000.ms,
        color: Colors.white.withOpacity(0.3),
      );
  }

  Widget _buildAppName() {
    return const Text(
      'Avatales',
      style: TextStyle(
        fontSize: 48,
        fontWeight: FontWeight.bold,
        color: Color(0xFFF8FAFC),
        letterSpacing: -1.0,
      ),
    ).animate(controller: _textController)
      .fadeIn(duration: 600.ms)
      .slideY(
        begin: 0.5,
        end: 0,
        curve: Curves.easeOutCubic,
      )
      .then()
      .shimmer(
        delay: 1000.ms,
        duration: 1500.ms,
        color: const Color(0xFF8D95FF).withOpacity(0.5),
      );
  }

  Widget _buildTagline() {
    return Column(
      children: [
        Text(
          'Magische Geschichten',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w400,
            color: const Color(0xFFCBD5E1).withOpacity(0.9),
          ),
        ).animate(controller: _textController)
          .fadeIn(delay: 200.ms, duration: 600.ms)
          .slideY(begin: 0.3, curve: Curves.easeOutCubic),
        
        const SizedBox(height: 8),
        
        Text(
          'mit KI erschaffen',
          style: TextStyle(
            fontSize: 16,
            color: const Color(0xFF8D95FF).withOpacity(0.8),
          ),
        ).animate(controller: _textController)
          .fadeIn(delay: 400.ms, duration: 600.ms)
          .slideY(begin: 0.3, curve: Curves.easeOutCubic),
      ],
    );
  }

  Widget _buildLoadingIndicator() {
    return Column(
      children: [
        // Progress Dots
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (index) {
            return Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF8D95FF),
                borderRadius: BorderRadius.circular(4),
              ),
            ).animate(onPlay: (controller) => controller.repeat())
              .fadeIn(
                delay: Duration(milliseconds: index * 200),
                duration: 600.ms,
              )
              .then()
              .fadeOut(duration: 600.ms);
          }),
        ),
        
        const SizedBox(height: 20),
        
        // Loading Text
        Text(
          'Geschichtenwelt wird geladen...',
          style: TextStyle(
            fontSize: 14,
            color: const Color(0xFFCBD5E1).withOpacity(0.7),
          ),
        ).animate(onPlay: (controller) => controller.repeat(reverse: true))
          .fadeIn(duration: 1500.ms)
          .fadeOut(duration: 1500.ms),
      ],
    ).animate(controller: _textController)
      .fadeIn(delay: 800.ms, duration: 600.ms);
  }

  Widget _buildPoweredBy() {
    return Positioned(
      bottom: 40,
      left: 0,
      right: 0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Powered by',
            style: TextStyle(
              fontSize: 12,
              color: const Color(0xFFCBD5E1).withOpacity(0.6),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF8D95FF), Color(0xFF9EF0DE)],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'OpenAI + Runware',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ).animate(controller: _textController)
        .fadeIn(delay: 1200.ms, duration: 800.ms)
        .slideY(begin: 0.5, curve: Curves.easeOutCubic),
    );
  }
}

// Custom Painter für animierte Sterne im Hintergrund
class StarFieldPainter extends CustomPainter {
  final double animationValue;
  
  StarFieldPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF8D95FF).withOpacity(0.3)
      ..style = PaintingStyle.fill;

    // Generate stars based on animation value
    for (int i = 0; i < 50; i++) {
      final x = (i * 37.5) % size.width;
      final y = (i * 23.7) % size.height;
      final opacity = (0.3 + (animationValue * 0.7)) * 
                     ((i % 3 + 1) / 4); // Varying opacity
      
      paint.color = const Color(0xFF8D95FF).withOpacity(opacity);
      
      // Twinkling effect
      final twinkle = (animationValue + (i * 0.1)) % 1.0;
      final radius = 1.0 + (twinkle * 2.0);
      
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(StarFieldPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}