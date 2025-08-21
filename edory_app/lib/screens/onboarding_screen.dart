// Avatales.Screens.OnboardingScreen
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:edory_app/core/theme/app_theme.dart';
import 'package:edory_app/core/theme/app_colors.dart';
import 'package:edory_app/shared/presentation/widgets/gradient_background.dart';
import 'package:edory_app/shared/presentation/widgets/custom_button.dart';
import '../navigation/main_navigation.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _progressController;
  late AnimationController _contentController;
  late AnimationController _backgroundController;
  
  late Animation<double> _progressAnimation;
  late Animation<double> _contentAnimation;
  late Animation<double> _backgroundAnimation;

  int _currentPage = 0;
  bool _isLastPage = false;

  final List<OnboardingPage> _pages = [
    OnboardingPage(
      title: 'Willkommen bei Avatales',
      subtitle: 'Erstelle und entdecke einzigartige Avatare',
      description: 'Tauche ein in eine Welt voller kreativer Möglichkeiten und gestalte deinen perfekten digitalen Avatar.',
      icon: Icons.account_circle,
      gradient: AppColors.skyGradient,
      floatingElements: [
        FloatingElement(Icons.star, AppColors.primaryBlue, 0.2, 0.3),
        FloatingElement(Icons.favorite, AppColors.primaryPink, 0.8, 0.2),
        FloatingElement(Icons.palette, AppColors.primaryMint, 0.1, 0.7),
        FloatingElement(Icons.auto_awesome, AppColors.primaryPurple, 0.9, 0.8),
      ],
    ),
    OnboardingPage(
      title: 'Endlose Kreativität',
      subtitle: 'Gestalte Avatare nach deinen Wünschen',
      description: 'Nutze unsere fortschrittlichen Tools und eine große Auswahl an Stilen, Farben und Accessoires.',
      icon: Icons.brush,
      gradient: AppColors.sunsetGradient,
      floatingElements: [
        FloatingElement(Icons.color_lens, AppColors.primaryPeach, 0.3, 0.2),
        FloatingElement(Icons.edit, AppColors.primaryBlue, 0.7, 0.3),
        FloatingElement(Icons.style, AppColors.primaryPink, 0.2, 0.8),
        FloatingElement(Icons.tune, AppColors.primaryMint, 0.8, 0.7),
      ],
    ),
    OnboardingPage(
      title: 'Teile & Entdecke',
      subtitle: 'Verbinde dich mit der Community',
      description: 'Teile deine Kreationen, entdecke inspirierende Avatare anderer und sammle deine Favoriten.',
      icon: Icons.share,
      gradient: AppColors.dreamGradient,
      floatingElements: [
        FloatingElement(Icons.people, AppColors.primaryPurple, 0.25, 0.25),
        FloatingElement(Icons.favorite, AppColors.primaryPink, 0.75, 0.2),
        FloatingElement(Icons.download, AppColors.primaryBlue, 0.2, 0.75),
        FloatingElement(Icons.public, AppColors.primaryMint, 0.8, 0.8),
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _startAnimations();
  }

  void _initializeControllers() {
    _pageController = PageController();
    
    _progressController = AnimationController(
      duration: AppTheme.animationMedium,
      vsync: this,
    );

    _contentController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _backgroundController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    );

    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: AppTheme.elasticOutCurve,
    ));

    _contentAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _contentController,
      curve: Curves.easeOutBack,
    ));

    _backgroundAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _backgroundController,
      curve: Curves.linear,
    ));
  }

  void _startAnimations() {
    _backgroundController.repeat();
    
    Future.delayed(const Duration(milliseconds: 300), () {
      _contentController.forward();
    });

    Future.delayed(const Duration(milliseconds: 500), () {
      _progressController.forward();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _progressController.dispose();
    _contentController.dispose();
    _backgroundController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: AppTheme.animationMedium,
        curve: AppTheme.animationCurve,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: AppTheme.animationMedium,
        curve: AppTheme.animationCurve,
      );
    }
  }

  void _skipOnboarding() {
    _completeOnboarding();
  }

  void _completeOnboarding() {
    // Haptic Feedback
    HapticFeedback.mediumImpact();
    
    // Navigation zur Haupt-App
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const MainNavigation(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;

          var tween = Tween(begin: begin, end: end).chain(
            CurveTween(curve: curve),
          );

          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
        transitionDuration: AppTheme.animationSlow,
      ),
    );
  }

  Widget _buildPageIndicator() {
    return AnimatedBuilder(
      animation: _progressAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _progressAnimation.value,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_pages.length, (index) {
              return AnimatedContainer(
                duration: AppTheme.animationMedium,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: index == _currentPage ? 24 : 8,
                height: 8,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  gradient: index == _currentPage
                      ? AppColors.createCustomGradient(
                          startColor: AppColors.primaryBlue,
                          endColor: AppColors.primaryMint,
                        )
                      : null,
                  color: index == _currentPage ? null : AppColors.lightGray,
                ),
              );
            }),
          ),
        );
      },
    );
  }

  Widget _buildSkipButton() {
    return AnimatedBuilder(
      animation: _contentAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, -20 * (1 - _contentAnimation.value)),
          child: Opacity(
            opacity: _contentAnimation.value,
            child: TextButton(
              onPressed: _skipOnboarding,
              child: Text(
                'Überspringen',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.white.withOpacity(0.8),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNavigationButtons() {
    return AnimatedBuilder(
      animation: _contentAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - _contentAnimation.value)),
          child: Opacity(
            opacity: _contentAnimation.value,
            child: Container(
              padding: const EdgeInsets.all(AppTheme.paddingLarge),
              child: Row(
                children: [
                  if (_currentPage > 0)
                    CustomButton(
                      text: 'Zurück',
                      type: ButtonType.ghost,
                      foregroundColor: AppColors.white,
                      onPressed: _previousPage,
                    ),
                  const Spacer(),
                  GradientButton(
                    text: _isLastPage ? 'Los geht\'s!' : 'Weiter',
                    gradient: AppColors.createCustomGradient(
                      startColor: AppColors.white.withOpacity(0.9),
                      endColor: AppColors.white.withOpacity(0.7),
                    ),
                    onPressed: _nextPage,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPageContent(OnboardingPage page) {
    return AnimatedBuilder(
      animation: _contentAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: 0.8 + (0.2 * _contentAnimation.value),
          child: Opacity(
            opacity: _contentAnimation.value,
            child: child,
          ),
        );
      },
      child: Column(
        children: [
          const Spacer(flex: 2),
          
          // Icon Section
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.white.withOpacity(0.2),
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.white.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: Icon(
              page.icon,
              size: 60,
              color: AppColors.white,
            ),
          ),
          
          const SizedBox(height: AppTheme.paddingXLarge),
          
          // Text Content
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.paddingLarge),
            child: Column(
              children: [
                Text(
                  page.title,
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.w700,
                    height: 1.2,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppTheme.paddingMedium),
                Text(
                  page.subtitle,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.white.withOpacity(0.9),
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppTheme.paddingLarge),
                Text(
                  page.description,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.white.withOpacity(0.8),
                    height: 1.6,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          
          const Spacer(flex: 3),
        ],
      ),
    );
  }

  Widget _buildFloatingElements(List<FloatingElement> elements) {
    return AnimatedBuilder(
      animation: _backgroundAnimation,
      builder: (context, child) {
        return Stack(
          children: elements.asMap().entries.map((entry) {
            final index = entry.key;
            final element = entry.value;
            final offset = _backgroundAnimation.value + (index * 0.2);
            
            return Positioned(
              left: MediaQuery.of(context).size.width * element.x +
                     (30 * (offset % 1.0 - 0.5)),
              top: MediaQuery.of(context).size.height * element.y +
                    (20 * (offset % 1.0 - 0.5)),
              child: Transform.rotate(
                angle: offset * 2 * 3.14159,
                child: Opacity(
                  opacity: 0.3 + (0.2 * (offset % 1.0)),
                  child: Container(
                    width: 40 + (10 * (offset % 1.0)),
                    height: 40 + (10 * (offset % 1.0)),
                    decoration: BoxDecoration(
                      color: element.color.withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      element.icon,
                      color: AppColors.white.withOpacity(0.6),
                      size: 20 + (5 * (offset % 1.0)),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background with floating elements
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
                _isLastPage = index == _pages.length - 1;
              });
              
              // Reset and restart content animation
              _contentController.reset();
              _contentController.forward();
              
              HapticFeedback.selectionClick();
            },
            itemCount: _pages.length,
            itemBuilder: (context, index) {
              final page = _pages[index];
              return Stack(
                children: [
                  // Gradient Background
                  Container(
                    decoration: BoxDecoration(gradient: page.gradient),
                  ),
                  
                  // Floating Elements
                  _buildFloatingElements(page.floatingElements),
                  
                  // Content
                  _buildPageContent(page),
                ],
              );
            },
          ),
          
          // Skip Button
          SafeArea(
            child: Positioned(
              top: AppTheme.paddingMedium,
              right: AppTheme.paddingMedium,
              child: _buildSkipButton(),
            ),
          ),
          
          // Page Indicator
          Positioned(
            bottom: 120,
            left: 0,
            right: 0,
            child: _buildPageIndicator(),
          ),
          
          // Navigation Buttons
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: _buildNavigationButtons(),
            ),
          ),
        ],
      ),
    );
  }
}

// Data Models
class OnboardingPage {
  final String title;
  final String subtitle;
  final String description;
  final IconData icon;
  final LinearGradient gradient;
  final List<FloatingElement> floatingElements;

  const OnboardingPage({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.icon,
    required this.gradient,
    required this.floatingElements,
  });
}

class FloatingElement {
  final IconData icon;
  final Color color;
  final double x;
  final double y;

  const FloatingElement(this.icon, this.color, this.x, this.y);
}