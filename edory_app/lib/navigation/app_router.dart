// Avatales.Navigation.AppRouter
import 'package:flutter/material.dart';
import '../screens/splash_screen.dart';
import '../screens/onboarding_screen.dart';
import '../screens/home_screen.dart';
import '../screens/search_screen.dart';
import '../screens/create_avatar_screen.dart';
import '../screens/favorites_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/avatar_detail_screen.dart';
import '../screens/settings_screen.dart';
import '../navigation/main_navigation.dart';
import 'package:edory_app/core/theme/app_theme.dart';
import 'package:edory_app/core/utils/app_utils.dart';

/// Router für die gesamte App-Navigation
class AppRouter {
  static AppRouter? _instance;
  static AppRouter get instance => _instance ??= AppRouter._();
  AppRouter._();

  static const String initialRoute = '/splash';
  
  // Route Namen
  static const String splash = '/splash';
  static const String onboarding = '/onboarding';
  static const String main = '/main';
  static const String home = '/home';
  static const String search = '/search';
  static const String createAvatar = '/create-avatar';
  static const String favorites = '/favorites';
  static const String profile = '/profile';
  static const String avatarDetail = '/avatar-detail';
  static const String settings = '/settings';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String categories = '/categories';
  static const String categoryDetail = '/category-detail';
  static const String editProfile = '/edit-profile';
  static const String notifications = '/notifications';
  static const String help = '/help';
  static const String about = '/about';

  /// Router für MaterialApp.router
  static final router = AppRouter.instance;

  /// Generiert die Route-Map für MaterialApp.router
  Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    AppUtils.debugLog('Navigating to: ${settings.name}');

    switch (settings.name) {
      case splash:
        return MaterialPageRoute(
          builder: (context) => const SplashScreen(),
          settings: settings,
        );
      
      case onboarding:
        return MaterialPageRoute(
          builder: (context) => const OnboardingScreen(),
          settings: settings,
        );
      
      case main:
        return MaterialPageRoute(
          builder: (context) => const MainNavigation(),
          settings: settings,
        );
      
      case home:
        return MaterialPageRoute(
          builder: (context) => const HomeScreen(),
          settings: settings,
        );
      
      case search:
        return MaterialPageRoute(
          builder: (context) => const SearchScreen(),
          settings: settings,
        );
      
      case createAvatar:
        return MaterialPageRoute(
          builder: (context) => const CreateAvatarScreen(),
          settings: settings,
        );
      
      case favorites:
        return MaterialPageRoute(
          builder: (context) => const FavoritesScreen(),
          settings: settings,
        );
      
      case profile:
        return MaterialPageRoute(
          builder: (context) => const ProfileScreen(),
          settings: settings,
        );
      
      case '/settings':
        return MaterialPageRoute(
          builder: (context) => const SettingsScreen(),
          settings: settings,
        );

      case avatarDetail:
        final avatarId = settings.arguments as String?;
        return MaterialPageRoute(
          builder: (context) => AvatarDetailScreen(avatarId: avatarId),
          settings: settings,
        );

      case categoryDetail:
        final category = settings.arguments as String?;
        return MaterialPageRoute(
          builder: (context) => CategoryDetailScreen(category: category ?? 'Unknown'),
          settings: settings,
        );

      case editProfile:
        final userId = settings.arguments as String?;
        return MaterialPageRoute(
          builder: (context) => EditProfileScreen(userId: userId),
          settings: settings,
        );

      case notifications:
        return MaterialPageRoute(
          builder: (context) => const NotificationsScreen(),
          settings: settings,
        );

      case help:
        return MaterialPageRoute(
          builder: (context) => const HelpScreen(),
          settings: settings,
        );

      case about:
        return MaterialPageRoute(
          builder: (context) => const AboutScreen(),
          settings: settings,
        );

      default:
        // Unbekannte Route
        return MaterialPageRoute(
          builder: (context) => const NotFoundScreen(),
          settings: settings,
        );
    }
  }

  /// Generiert die Route-Map (Legacy Support)
  Map<String, WidgetBuilder> get routes => {
    splash: (context) => const SplashScreen(),
    onboarding: (context) => const OnboardingScreen(),
    main: (context) => const MainNavigation(),
    home: (context) => const HomeScreen(),
    search: (context) => const SearchScreen(),
    createAvatar: (context) => const CreateAvatarScreen(),
    favorites: (context) => const FavoritesScreen(),
    profile: (context) => const ProfileScreen(),
    settings: (context) => const SettingsScreen(),
    // Weitere Routen würden hier hinzugefügt
  };

  /// Erstellt eine Route mit Übergängen
  PageRoute<T> _createRoute<T>(
    Widget page, {
    required RouteSettings settings,
    RouteTransition transition = RouteTransition.platform,
  }) {
    switch (transition) {
      case RouteTransition.fade:
        return FadeRoute<T>(page: page, settings: settings);
      
      case RouteTransition.slideFromRight:
        return SlideRoute<T>(
          page: page,
          settings: settings,
          direction: SlideDirection.fromRight,
        );
      
      case RouteTransition.slideFromLeft:
        return SlideRoute<T>(
          page: page,
          settings: settings,
          direction: SlideDirection.fromLeft,
        );
      
      case RouteTransition.slideFromTop:
        return SlideRoute<T>(
          page: page,
          settings: settings,
          direction: SlideDirection.fromTop,
        );
      
      case RouteTransition.slideFromBottom:
        return SlideRoute<T>(
          page: page,
          settings: settings,
          direction: SlideDirection.fromBottom,
        );
      
      case RouteTransition.scale:
        return ScaleRoute<T>(page: page, settings: settings);
      
      case RouteTransition.rotation:
        return RotationRoute<T>(page: page, settings: settings);
      
      case RouteTransition.platform:
      default:
        return MaterialPageRoute<T>(
          builder: (_) => page,
          settings: settings,
        );
    }
  }

  /// Navigation Helper Methods
  static void pushNamed(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) {
    Navigator.pushNamed(context, routeName, arguments: arguments);
  }

  static void pushReplacementNamed(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) {
    Navigator.pushReplacementNamed(context, routeName, arguments: arguments);
  }

  static void pushNamedAndClearStack(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) {
    Navigator.pushNamedAndRemoveUntil(
      context,
      routeName,
      (route) => false,
      arguments: arguments,
    );
  }

  static void pop(BuildContext context, [dynamic result]) {
    Navigator.pop(context, result);
  }

  static void popUntil(BuildContext context, String routeName) {
    Navigator.popUntil(context, ModalRoute.withName(routeName));
  }

  /// Spezifische Navigation Methods
  static void goToHome(BuildContext context) {
    pushNamedAndClearStack(context, main);
  }

  static void goToLogin(BuildContext context) {
    pushReplacementNamed(context, login);
  }

  static void goToAvatarDetail(BuildContext context, String avatarId) {
    pushNamed(context, avatarDetail, arguments: avatarId);
  }

  static void goToProfile(BuildContext context, [String? userId]) {
    if (userId != null) {
      pushNamed(context, profile, arguments: userId);
    } else {
      pushNamed(context, profile);
    }
  }

  static void goToSettings(BuildContext context) {
    pushNamed(context, settings);
  }
}

// ===== Custom Route Transitions =====

/// Fade Transition Route
class FadeRoute<T> extends PageRouteBuilder<T> {
  final Widget page;

  FadeRoute({required this.page, RouteSettings? settings})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          settings: settings,
          transitionDuration: AppTheme.animationMedium,
          reverseTransitionDuration: AppTheme.animationMedium,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        );
}

/// Slide Transition Route
class SlideRoute<T> extends PageRouteBuilder<T> {
  final Widget page;
  final SlideDirection direction;

  SlideRoute({
    required this.page,
    required this.direction,
    RouteSettings? settings,
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          settings: settings,
          transitionDuration: AppTheme.animationMedium,
          reverseTransitionDuration: AppTheme.animationMedium,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return AppUtils.slideTransition(
              child: child,
              animation: animation,
              direction: direction,
            );
          },
        );
}

/// Scale Transition Route
class ScaleRoute<T> extends PageRouteBuilder<T> {
  final Widget page;

  ScaleRoute({required this.page, RouteSettings? settings})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          settings: settings,
          transitionDuration: AppTheme.animationMedium,
          reverseTransitionDuration: AppTheme.animationMedium,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return AppUtils.fadeScaleTransition(
              child: child,
              animation: animation,
            );
          },
        );
}

/// Rotation Transition Route
class RotationRoute<T> extends PageRouteBuilder<T> {
  final Widget page;

  RotationRoute({required this.page, RouteSettings? settings})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          settings: settings,
          transitionDuration: const Duration(milliseconds: 800),
          reverseTransitionDuration: const Duration(milliseconds: 800),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return RotationTransition(
              turns: Tween<double>(begin: 0.0, end: 1.0).animate(
                CurvedAnimation(parent: animation, curve: Curves.elasticOut),
              ),
              child: FadeTransition(opacity: animation, child: child),
            );
          },
        );
}

// ===== Placeholder Screens =====

class CategoryDetailScreen extends StatelessWidget {
  final String category;

  const CategoryDetailScreen({Key? key, required this.category}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(category),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Kategorie: $category',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            const Text('Diese Seite wird noch implementiert.'),
          ],
        ),
      ),
    );
  }
}

class EditProfileScreen extends StatelessWidget {
  final String? userId;

  const EditProfileScreen({Key? key, this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil bearbeiten'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Profil bearbeiten',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            if (userId != null) ...[
              const SizedBox(height: 8),
              Text('User ID: $userId'),
            ],
            const SizedBox(height: 16),
            const Text('Diese Seite wird noch implementiert.'),
          ],
        ),
      ),
    );
  }
}

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Benachrichtigungen'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: const Center(
        child: Text('Benachrichtigungen werden hier angezeigt.'),
      ),
    );
  }
}

class HelpScreen extends StatelessWidget {
  const HelpScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hilfe'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: const Center(
        child: Text('Hilfe-Informationen werden hier angezeigt.'),
      ),
    );
  }
}

class AboutScreen extends StatelessWidget {
  const AboutScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Über die App'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Avatales',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('Version 1.0.0'),
            SizedBox(height: 16),
            Text('Erstelle einzigartige Avatare für deine digitale Identität.'),
          ],
        ),
      ),
    );
  }
}

class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Seite nicht gefunden'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 80,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            const Text(
              'Seite nicht gefunden',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('Die angeforderte Seite existiert nicht.'),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => AppRouter.goToHome(context),
              child: const Text('Zur Startseite'),
            ),
          ],
        ),
      ),
    );
  }
}

// ===== Enums =====

enum RouteTransition {
  platform,
  fade,
  slideFromRight,
  slideFromLeft,
  slideFromTop,
  slideFromBottom,
  scale,
  rotation,
}