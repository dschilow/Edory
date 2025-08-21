// Avatales.Screens.SplashScreen
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import 'package:edory_app/core/theme/app_theme.dart';
import 'package:edory_app/core/theme/app_colors.dart';
import 'package:edory_app/navigation/main_navigation.dart';
import 'onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _backgroundController;
  late AnimationController _particleController;
  
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _logoRotationAnimation;
  late Animation<double> _textFadeAnimation;
  late Animation<double> _backgroundAnimation;
  late Animation<double> _particleAnimation;

  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startSplashSequence();
  }

  void _initializeAnimations() {
    // Logo Animation
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // Text Animation
    _textController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // Background Animation
    _backgroundController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    // Particle Animation
    _particleController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );

    // Logo Animations
    _logoScaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
    ));

    _logoRotationAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: const Interval(0.3, 1.0, curve: Curves.easeOutBack),
    ));

    // Text Animation
    _textFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: Curves.easeInOut,
    ));

    // Background Animation
    _backgroundAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _backgroundController,
      curve: Curves.linear,
    ));

    // Particle Animation
    _particleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _particleController,
      curve: Curves.easeInOut,
    ));
  }

  void _startSplashSequence() async {
    // Status Bar konfigurieren
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    // Animationen starten
    _backgroundController.repeat();
    _particleController.repeat(reverse: true);

    // Logo Animation starten
    await Future.delayed(const Duration(milliseconds: 300));
    _logoController.forward();

    // Text Animation starten
    await Future.delayed(const Duration(milliseconds: 800));
    _textController.forward();

    // Initialisierung simulieren
    await _initializeApp();

    // Navigation zur nächsten Seite
    await Future.delayed(const Duration(milliseconds: 1000));
    _navigateToNextScreen();
  }

  Future<void> _initializeApp() async {
    // Simuliere App-Initialisierung
    await Future.delayed(const Duration(milliseconds: 1500));
    
    // Hier würden normalerweise folgende Initialisierungen stattfinden:
    // - Prüfung der Netzwerkverbindung
    // - Laden der Benutzereinstellungen
    // - Initialisierung der Services
    // - Prüfung der App-Version
    // - Laden der Cache-Daten
    
    setState(() {
      _isInitialized = true;
    });
  }

  void _navigateToNextScreen() {
    // Prüfe ob Onboarding bereits gesehen wurde
    final shouldShowOnboarding = _shouldShowOnboarding();
    
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) {
          return shouldShowOnboarding 
              ? const OnboardingScreen()
              : const MainNavigation();
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: ScaleTransition(
              scale: Tween<double>(
                begin: 0.95,
                end: 1.0,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeInOut,
              )),
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 800),
      ),
    );
  }

  bool _shouldShowOnboarding() {
    // Hier würde normalerweise geprüft werden, ob der Benutzer
    // das Onboarding bereits gesehen hat (über SharedPreferences)
    // Für Demo-Zwecke geben wir true zurück
    return true;
  }

  Widget _buildLogo() {
    return AnimatedBuilder(
      animation: Listenable.merge([_logoScaleAnimation, _logoRotationAnimation]),
      builder: (context, child) {
        return Transform.scale(
          scale: _logoScaleAnimation.value,
          child: Transform.rotate(
            angle: _logoRotationAnimation.value * 0.1,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                gradient: AppColors.createCustomGradient(
                  startColor: AppColors.primaryBlue,
                  endColor: AppColors.primaryMint,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryBlue.withOpacity(0.4),
                    blurRadius: 30,
                    offset: const Offset(0, 15),
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: const Icon(
                Icons.account_circle,
                size: 60,
                color: AppColors.white,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAppName() {
    return AnimatedBuilder(
      animation: _textFadeAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _textFadeAnimation.value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - _textFadeAnimation.value)),
            child: Column(
              children: [
                Text(
                  'Avatales',
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    fontSize: 42,
                    fontWeight: FontWeight.w800,
                    color: AppColors.white,
                    letterSpacing: 1.5,
                    shadows: [
                      Shadow(
                        color: AppColors.primaryBlue.withOpacity(0.5),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppTheme.paddingMedium),
                Text(
                  'Erstelle einzigartige Avatare',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.white.withOpacity(0.9),
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFloatingParticles() {
    return AnimatedBuilder(
      animation: _particleAnimation,
      builder: (context, child) {
        return Stack(
          children: List.generate(12, (index) {
            final angle = (index * 30.0) + (_particleAnimation.value * 360);
            final radius = 150.0 + (50 * (index % 3));
            final radians = angle * math.pi / 180;
            final x = radius * math.cos(radians);
            final y = radius * math.sin(radians);
            
            return Transform.translate(
              offset: Offset(x, y),
              child: Opacity(
                opacity: 0.3 + (0.4 * _particleAnimation.value),
                child: Container(
                  width: 8 + (index % 3) * 4,
                  height: 8 + (index % 3) * 4,
                  decoration: BoxDecoration(
                    color: [
                      AppColors.primaryBlue,
                      AppColors.primaryPink,
                      AppColors.primaryMint,
                      AppColors.primaryPurple,
                    ][index % 4].withOpacity(0.6),
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

  Widget _buildLoadingIndicator() {
    return AnimatedBuilder(
      animation: _textFadeAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _textFadeAnimation.value,
          child: Column(
            children: [
              Container(
                width: 60,
                height: 4,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2),
                  color: AppColors.white.withOpacity(0.3),
                ),
                child: AnimatedBuilder(
                  animation: _backgroundAnimation,
                  builder: (context, child) {
                    return FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: _isInitialized ? 1.0 : _backgroundAnimation.value * 0.8,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(2),
                          gradient: AppColors.createCustomGradient(
                            startColor: AppColors.primaryPink,
                            endColor: AppColors.primaryPeach,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: AppTheme.paddingMedium),
              Text(
                _isInitialized ? 'Bereit!' : 'Wird geladen...',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.white.withOpacity(0.8),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPulsingCircles() {
    return AnimatedBuilder(
      animation: _backgroundAnimation,
      builder: (context, child) {
        return Stack(
          children: List.generate(3, (index) {
            final scale = 1.0 + (_backgroundAnimation.value * (index + 1) * 0.3);
            final opacity = 0.1 * (1 - _backgroundAnimation.value) * (3 - index);
            
            return Transform.scale(
              scale: scale,
              child: Container(
                width: 300 + (index * 100),
                height: 300 + (index * 100),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.white.withOpacity(opacity),
                    width: 2,
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    _backgroundController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF6BB6FF),
              Color(0xFF68D8F0),
              Color(0xFFB794F6),
              Color(0xFFFF8FB1),
            ],
            stops: [0.0, 0.3, 0.7, 1.0],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Pulsing Background Circles
              Center(child: _buildPulsingCircles()),
              
              // Floating Particles
              Center(child: _buildFloatingParticles()),
              
              // Main Content
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(flex: 2),
                    
                    // Logo
                    _buildLogo(),
                    
                    const SizedBox(height: AppTheme.paddingXLarge),
                    
                    // App Name and Tagline
                    _buildAppName(),
                    
                    const Spacer(flex: 3),
                    
                    // Loading Indicator
                    _buildLoadingIndicator(),
                    
                    const SizedBox(height: AppTheme.paddingXLarge),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}