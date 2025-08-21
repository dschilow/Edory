// Avatales.Main.App
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:edory_app/core/theme/app_theme.dart';
import 'navigation/main_navigation.dart';
import 'screens/home_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/search_screen.dart';
import 'screens/favorites_screen.dart';
import 'screens/create_avatar_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  // System UI-Konfiguration
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  // Präferierte Orientierungen
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const AvatalesApp());
}

class AvatalesApp extends StatelessWidget {
  const AvatalesApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Avatales',
      debugShowCheckedModeBanner: false,
      
      // Theme-Konfiguration
      theme: AppTheme.lightTheme,
      
      // Haupt-Navigation
      home: const MainNavigation(),
      
      // Route-Konfiguration
      routes: {
        '/home': (context) => const HomeScreen(),
        '/search': (context) => const SearchScreen(),
        '/create-avatar': (context) => const CreateAvatarScreen(),
        '/favorites': (context) => const FavoritesScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/categories': (context) => const CategoriesScreen(),
        '/category': (context) => const CategoryDetailScreen(),
        '/avatar-detail': (context) => const AvatarDetailScreen(),
        '/settings': (context) => const SettingsScreen(),
        '/edit-avatar': (context) => const EditAvatarScreen(),
        '/chat': (context) => const ChatScreen(),
        '/stat-detail': (context) => const StatDetailScreen(),
        '/collection': (context) => const CollectionScreen(),
        '/onboarding': (context) => const OnboardingScreen(),
      },
      
      // Unbekannte Routen behandeln
      onUnknownRoute: (settings) {
        return MaterialPageRoute(
          builder: (context) => const NotFoundScreen(),
        );
      },
      
      // Globale Navigator-Beobachter
      navigatorObservers: [
        AppNavigatorObserver(),
      ],
      
      // Locale-Konfiguration
      locale: const Locale('de', 'DE'),
      supportedLocales: const [
        Locale('de', 'DE'),
        Locale('en', 'US'),
      ],
      
      // Builder für globale Konfigurationen
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaleFactor: MediaQuery.of(context).textScaleFactor.clamp(0.8, 1.2),
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}

// Navigator Observer für Analytics und Debugging
class AppNavigatorObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    _logRouteChange('PUSH', route.settings.name);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    _logRouteChange('POP', route.settings.name);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    _logRouteChange('REPLACE', newRoute?.settings.name);
  }

  void _logRouteChange(String action, String? routeName) {
    debugPrint('🧭 Route $action: ${routeName ?? 'Unknown'}');
  }
}

// Placeholder Screens für Routen
class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kategorien'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: const Center(
        child: Text(
          'Kategorien Screen\n(Wird implementiert)',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}

class CategoryDetailScreen extends StatelessWidget {
  const CategoryDetailScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final category = ModalRoute.of(context)?.settings.arguments as String?;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(category ?? 'Kategorie'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: Text(
          'Kategorie: ${category ?? 'Unbekannt'}\n(Wird implementiert)',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}

class AvatarDetailScreen extends StatelessWidget {
  const AvatarDetailScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final avatarId = ModalRoute.of(context)?.settings.arguments;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Avatar Details'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: Text(
          'Avatar ID: $avatarId\n(Wird implementiert)',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Einstellungen'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: const Center(
        child: Text(
          'Einstellungen Screen\n(Wird implementiert)',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}

class EditAvatarScreen extends StatelessWidget {
  const EditAvatarScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Avatar Bearbeiten'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: const Center(
        child: Text(
          'Avatar Bearbeiten Screen\n(Wird implementiert)',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}

class ChatScreen extends StatelessWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: const Center(
        child: Text(
          'Chat Screen\n(Wird implementiert)',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}

class StatDetailScreen extends StatelessWidget {
  const StatDetailScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final stat = ModalRoute.of(context)?.settings.arguments as String?;
    
    return Scaffold(
      appBar: AppBar(
        title: Text('${stat ?? 'Statistik'} Details'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: Text(
          'Statistik: ${stat ?? 'Unbekannt'}\n(Wird implementiert)',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}

class CollectionScreen extends StatelessWidget {
  const CollectionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final collection = ModalRoute.of(context)?.settings.arguments as String?;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(collection ?? 'Kollektion'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: Text(
          'Kollektion: ${collection ?? 'Unbekannt'}\n(Wird implementiert)',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF87CEEB),
              Color(0xFFE0F6FF),
              Color(0xFFF0F8FF),
            ],
          ),
        ),
        child: const Center(
          child: Text(
            'Willkommen bei Avatales!\n(Onboarding wird implementiert)',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
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
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Die gesuchte Seite existiert nicht.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => Navigator.pushReplacementNamed(context, '/home'),
              child: const Text('Zur Startseite'),
            ),
          ],
        ),
      ),
    );
  }
}

// App-weite Utility-Klassen und Erweiterungen
extension ContextExtensions on BuildContext {
  // Theme-Zugriff
  ThemeData get theme => Theme.of(this);
  TextTheme get textTheme => Theme.of(this).textTheme;
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
  
  // MediaQuery-Zugriff
  MediaQueryData get mediaQuery => MediaQuery.of(this);
  Size get screenSize => MediaQuery.of(this).size;
  double get screenWidth => MediaQuery.of(this).size.width;
  double get screenHeight => MediaQuery.of(this).size.height;
  
  // Navigator-Shortcuts
  void pop<T>([T? result]) => Navigator.of(this).pop(result);
  Future<T?> push<T>(Widget page) => Navigator.of(this).push<T>(
    MaterialPageRoute(builder: (_) => page),
  );
  Future<T?> pushNamed<T>(String routeName, {Object? arguments}) =>
      Navigator.of(this).pushNamed<T>(routeName, arguments: arguments);
  
  // SnackBar-Shortcuts
  void showSnackBar(String message, {Color? backgroundColor}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}

// Globale App-Konstanten
class AppConstants {
  static const String appName = 'Avatales';
  static const String appVersion = '1.0.0';
  static const String supportEmail = 'support@avatales.com';
  
  // API-Konfiguration
  static const String baseUrl = 'https://api.avatales.com';
  static const int requestTimeout = 30000;
  
  // Feature Flags
  static const bool enableAnalytics = false;
  static const bool enableCrashReporting = false;
  static const bool enableDebugMode = true;
  
  // Cache-Konfiguration
  static const int maxCacheSize = 50; // MB
  static const Duration cacheExpiry = Duration(hours: 24);
}