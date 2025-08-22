// lib/shared/presentation/pages/main_wrapper.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'dart:math';
import '../../../core/theme/modern_design_system.dart';
import '../widgets/modern_bottom_navigation.dart';

/// Main Wrapper für die Avatales App
/// Verwaltet das Bottom Navigation Layout und globale UI-Elemente
class MainWrapper extends StatefulWidget {
  const MainWrapper({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  State<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper>
    with TickerProviderStateMixin {
  
  late AnimationController _navigationController;
  late AnimationController _backgroundController;
  
  String _currentPath = '';
  bool _navigationVisible = true;

  @override
  void initState() {
    super.initState();
    
    _navigationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _backgroundController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _navigationController.forward();
    _backgroundController.forward();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateCurrentPath();
  }

  @override
  void dispose() {
    _navigationController.dispose();
    _backgroundController.dispose();
    super.dispose();
  }

  void _updateCurrentPath() {
    final router = GoRouter.of(context);
    final newPath = router.routeInformationProvider.value.uri.path;
    
    if (newPath != _currentPath) {
      setState(() {
        _currentPath = newPath;
        _navigationVisible = _shouldShowNavigation(newPath);
      });
      
      if (_navigationVisible) {
        _navigationController.forward();
      } else {
        _navigationController.reverse();
      }
    }
  }

  bool _shouldShowNavigation(String path) {
    // Hide navigation on certain pages
    final hiddenPaths = [
      '/stories/',  // Story reading pages
      '/create',    // Creation flows
      '/onboarding',
      '/auth',
    ];
    
    return !hiddenPaths.any((hiddenPath) => path.contains(hiddenPath));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: ModernDesignSystem.textLight,
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: _getSystemUiOverlayStyle(),
        child: Stack(
          children: [
            // Background
            _buildBackground(),
            
            // Main Content
            SafeArea(
              bottom: false, // Let navigation handle bottom safe area
              child: widget.child,
            ),
            
            // Bottom Navigation
            if (_navigationVisible)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: AnimatedBuilder(
                  animation: _navigationController,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(
                        0,
                        100 * (1 - _navigationController.value),
                      ),
                      child: Opacity(
                        opacity: _navigationController.value,
                        child: ModernBottomNavigation(
                          currentPath: _currentPath,
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackground() {
    return AnimatedBuilder(
      animation: _backgroundController,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                ModernDesignSystem.textLight,
                ModernDesignSystem.textLight.withOpacity(0.95),
              ],
            ),
          ),
          child: CustomPaint(
            painter: _BackgroundPatternPainter(
              animationValue: _backgroundController.value,
            ),
            size: Size.infinite,
          ),
        );
      },
    );
  }

  SystemUiOverlayStyle _getSystemUiOverlayStyle() {
    // Adapt system UI based on current page
    final isDarkPage = _currentPath.contains('/stories/') && 
                      _currentPath.contains('/read');
    
    return SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: isDarkPage 
          ? Brightness.light 
          : Brightness.dark,
      statusBarBrightness: isDarkPage 
          ? Brightness.dark 
          : Brightness.light,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
    );
  }
}

/// Background Pattern Painter für subtile Textur
class _BackgroundPatternPainter extends CustomPainter {
  final double animationValue;

  const _BackgroundPatternPainter({required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.02 * animationValue)
      ..style = PaintingStyle.fill;

    // Create subtle dot pattern
    const spacing = 60.0;
    const dotSize = 1.0;

    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        final opacity = (animationValue * 0.5) + 
                       (0.5 * ((x + y) / (size.width + size.height)));
        
        canvas.drawCircle(
          Offset(x + (spacing * 0.5), y + (spacing * 0.5)),
          dotSize * animationValue,
          paint..color = Colors.white.withOpacity(opacity.clamp(0.0, 0.1)),
        );
      }
    }

    // Add flowing geometric shapes
    final shapePaint = Paint()
      ..color = Colors.white.withOpacity(0.01 * animationValue)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    // Draw flowing lines
    final path = Path();
    for (int i = 0; i < 5; i++) {
      final yOffset = (size.height / 6) * (i + 1);
      path.moveTo(0, yOffset);
      
      for (double x = 0; x <= size.width; x += 40) {
        final y = yOffset + 
                  (15 * animationValue * 
                   (i.isEven ? 1 : -1) * 
                   sin(x / 200));
        path.lineTo(x, y);
      }
    }
    
    canvas.drawPath(path, shapePaint);
  }

  @override
  bool shouldRepaint(covariant _BackgroundPatternPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}

/// Navigation State Provider für globale Navigation
class NavigationState extends ChangeNotifier {
  String _currentPath = '/home';
  bool _navigationVisible = true;

  String get currentPath => _currentPath;
  bool get navigationVisible => _navigationVisible;

  void updatePath(String path) {
    if (_currentPath != path) {
      _currentPath = path;
      notifyListeners();
    }
  }

  void setNavigationVisible(bool visible) {
    if (_navigationVisible != visible) {
      _navigationVisible = visible;
      notifyListeners();
    }
  }

  void hideNavigation() => setNavigationVisible(false);
  void showNavigation() => setNavigationVisible(true);
}

/// Global App State für die gesamte App
class AppState extends ChangeNotifier {
  bool _isOnline = true;
  bool _isDarkMode = false;
  String _selectedLanguage = 'de';

  bool get isOnline => _isOnline;
  bool get isDarkMode => _isDarkMode;
  String get selectedLanguage => _selectedLanguage;

  void updateConnectionStatus(bool isOnline) {
    if (_isOnline != isOnline) {
      _isOnline = isOnline;
      notifyListeners();
    }
  }

  void toggleDarkMode() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  void updateLanguage(String languageCode) {
    if (_selectedLanguage != languageCode) {
      _selectedLanguage = languageCode;
      notifyListeners();
    }
  }
}

/// Safe Area Handler für verschiedene Bildschirmgrößen
class SafeAreaHandler {
  static EdgeInsets getSafeAreaPadding(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    return EdgeInsets.only(
      top: mediaQuery.padding.top,
      bottom: mediaQuery.padding.bottom,
    );
  }

  static double getBottomSafeArea(BuildContext context) {
    return MediaQuery.of(context).padding.bottom;
  }

  static double getTopSafeArea(BuildContext context) {
    return MediaQuery.of(context).padding.top;
  }

  static bool hasNotch(BuildContext context) {
    return MediaQuery.of(context).padding.top > 24;
  }
}

/// Responsive Layout Helper
class ResponsiveLayout {
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < 600;
  }

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= 600 && width < 1200;
  }

  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= 1200;
  }

  static int getGridCrossAxisCount(BuildContext context) {
    if (isDesktop(context)) return 4;
    if (isTablet(context)) return 3;
    return 2;
  }

  static double getCardWidth(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (isDesktop(context)) return screenWidth / 4 - 32;
    if (isTablet(context)) return screenWidth / 3 - 24;
    return screenWidth / 2 - 20;
  }
}

/// Performance Monitor für die App
class PerformanceMonitor {
  static void trackPageLoad(String pageName) {
    debugPrint('📱 Page Loaded: $pageName');
    // Hier würde normalerweise Analytics Integration stehen
  }

  static void trackUserAction(String action, {Map<String, dynamic>? parameters}) {
    debugPrint('👆 User Action: $action ${parameters ?? ''}');
    // Hier würde normalerweise Analytics Integration stehen
  }

  static void trackError(String error, {String? stackTrace}) {
    debugPrint('❌ Error: $error');
    if (stackTrace != null) {
      debugPrint('Stack: $stackTrace');
    }
    // Hier würde normalerweise Crash Analytics stehen
  }
}

/// App Lifecycle Manager
class AppLifecycleManager extends WidgetsBindingObserver {
  static final AppLifecycleManager _instance = AppLifecycleManager._internal();
  factory AppLifecycleManager() => _instance;
  AppLifecycleManager._internal();

  VoidCallback? onResume;
  VoidCallback? onPause;
  VoidCallback? onDetach;

  void initialize() {
    WidgetsBinding.instance.addObserver(this);
  }

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    switch (state) {
      case AppLifecycleState.resumed:
        onResume?.call();
        break;
      case AppLifecycleState.paused:
        onPause?.call();
        break;
      case AppLifecycleState.detached:
        onDetach?.call();
        break;
      case AppLifecycleState.inactive:
        // Handle inactive state if needed
        break;
      case AppLifecycleState.hidden:
        // Handle hidden state if needed
        break;
    }
  }
}