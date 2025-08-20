// lib/shared/presentation/pages/splash_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/modern_design_system.dart';


class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _navigateToHome();
  }

  void _navigateToHome() {
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) {
        context.go('/home');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: ModernDesignSystem.primaryGradient,
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo Container
              Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(35),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.2),
                    width: 3,
                  ),
                ),
                child: const Center(
                  child: Text(
                    '📚',
                    style: TextStyle(fontSize: 70),
                  ),
                ),
              )
                  .animate()
                  .fadeIn(duration: 800.ms)
                  .scale(begin: const Offset(0.8, 0.8), duration: 800.ms)
                  .then()
                  .animate(onPlay: (controller) => controller.repeat())
                  .moveY(
                    begin: 0,
                    end: -12,
                    duration: 2000.ms,
                    curve: Curves.easeInOut,
                  )
                  .then()
                  .moveY(
                    begin: -12,
                    end: 0,
                    duration: 2000.ms,
                    curve: Curves.easeInOut,
                  ),

              const SizedBox(height: 32),

              // App Title
              Text(
                'Edory',
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  color: ModernDesignSystem.whiteTextColor,
                  fontSize: 36,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -1,
                ),
              )
                  .animate()
                  .fadeIn(duration: 800.ms, delay: 400.ms)
                  .slideY(begin: 0.3, duration: 800.ms, delay: 400.ms),

              const SizedBox(height: 12),

              // App Subtitle
              Text(
                'KI-gestützte Premium Geschichten',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: ModernDesignSystem.whiteTextColor.withOpacity(0.8),
                  fontSize: 17,
                  fontWeight: FontWeight.w400,
                ),
              )
                  .animate()
                  .fadeIn(duration: 800.ms, delay: 600.ms)
                  .slideY(begin: 0.3, duration: 800.ms, delay: 600.ms),

              const SizedBox(height: 80),

              // Loading Indicator
              SizedBox(
                width: 30,
                height: 30,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation(
                    ModernDesignSystem.whiteTextColor.withOpacity(0.8),
                  ),
                ),
              )
                  .animate()
                  .fadeIn(duration: 800.ms, delay: 800.ms),
            ],
          ),
        ),
      ),
    );
  }
}
