// lib/core/router/app_router.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/characters/presentation/pages/characters_page.dart';
import '../../features/characters/presentation/pages/character_detail_page.dart';
import '../../features/characters/presentation/pages/create_character_page.dart';
import '../../features/characters/presentation/pages/avatar_creation_page.dart';
import '../../features/stories/presentation/pages/stories_page.dart';
import '../../features/stories/presentation/pages/story_detail_page.dart';
import '../../features/stories/presentation/pages/create_story_page.dart';
import '../../features/stories/presentation/pages/story_display_page.dart';
import '../../features/learning/presentation/pages/learning_page.dart';
import '../../features/community/presentation/pages/community_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../shared/presentation/pages/main_wrapper.dart';
import '../../shared/presentation/pages/error_page.dart';
import '../../features/stories/domain/entities/story.dart';

/// Vollständige Router-Konfiguration für Avatales
/// Manages all navigation routes with proper error handling and transitions
class AppRouter {
  static const String home = '/home';
  
  // Character routes
  static const String characters = '/characters';
  static const String characterDetail = '/characters/:id';
  static const String createCharacter = '/characters/create';
  static const String createAvatar = '/characters/create-avatar';
  
  // Story routes
  static const String stories = '/stories';
  static const String storyDetail = '/stories/:id';
  static const String createStory = '/stories/create';
  static const String readStory = '/stories/:id/read';
  
  // Other main routes
  static const String learning = '/learning';
  static const String community = '/community';
  static const String profile = '/profile';
  
  // Error routes
  static const String notFound = '/404';

  static final GoRouter router = GoRouter(
    initialLocation: home,
    debugLogDiagnostics: true,
    routes: [
      // Main Shell Route with Bottom Navigation
      ShellRoute(
        builder: (context, state, child) => MainWrapper(child: child),
        routes: [
          // Home Route
          GoRoute(
            path: home,
            name: 'home',
            pageBuilder: (context, state) => _buildPageWithTransition(
              child: const HomePage(),
              settings: state,
            ),
          ),

          // Characters Routes
          GoRoute(
            path: characters,
            name: 'characters',
            pageBuilder: (context, state) => _buildPageWithTransition(
              child: const CharactersPage(),
              settings: state,
            ),
            routes: [
              // Character Detail
              GoRoute(
                path: ':id',
                name: 'character-detail',
                pageBuilder: (context, state) {
                  final characterId = state.pathParameters['id']!;
                  return _buildPageWithTransition(
                    child: CharacterDetailPage(characterId: characterId),
                    settings: state,
                  );
                },
              ),
              // Create Character
              GoRoute(
                path: 'create',
                name: 'create-character',
                pageBuilder: (context, state) => _buildPageWithTransition(
                  child: const CreateCharacterPage(),
                  settings: state,
                  transitionType: TransitionType.slideUp,
                ),
              ),
              // Create Avatar
              GoRoute(
                path: 'create-avatar',
                name: 'create-avatar',
                pageBuilder: (context, state) => _buildPageWithTransition(
                  child: const AvatarCreationPage(),
                  settings: state,
                  transitionType: TransitionType.slideUp,
                ),
              ),
            ],
          ),

          // Stories Routes
          GoRoute(
            path: stories,
            name: 'stories',
            pageBuilder: (context, state) => _buildPageWithTransition(
              child: const StoriesPage(),
              settings: state,
            ),
            routes: [
              // Story Detail
              GoRoute(
                path: ':id',
                name: 'story-detail',
                pageBuilder: (context, state) {
                  final storyId = state.pathParameters['id']!;
                  return _buildPageWithTransition(
                    child: StoryDetailPage(storyId: storyId),
                    settings: state,
                  );
                },
                routes: [
                  // Read Story
                  GoRoute(
                    path: 'read',
                    name: 'read-story',
                    pageBuilder: (context, state) {
                      final storyId = state.pathParameters['id']!;
                      // Note: In real app, fetch story by ID
                      return _buildPageWithTransition(
                        child: StoryDisplayPage(
                          story: _getMockStory(storyId),
                          showBackButton: true,
                        ),
                        settings: state,
                        transitionType: TransitionType.fade,
                      );
                    },
                  ),
                ],
              ),
              // Create Story
              GoRoute(
                path: 'create',
                name: 'create-story',
                pageBuilder: (context, state) => _buildPageWithTransition(
                  child: const CreateStoryPage(),
                  settings: state,
                  transitionType: TransitionType.slideUp,
                ),
              ),
            ],
          ),

          // Learning Route
          GoRoute(
            path: learning,
            name: 'learning',
            pageBuilder: (context, state) => _buildPageWithTransition(
              child: const LearningPage(),
              settings: state,
            ),
          ),

          // Community Route
          GoRoute(
            path: community,
            name: 'community',
            pageBuilder: (context, state) => _buildPageWithTransition(
              child: const CommunityPage(),
              settings: state,
            ),
          ),

          // Profile Route
          GoRoute(
            path: profile,
            name: 'profile',
            pageBuilder: (context, state) => _buildPageWithTransition(
              child: const ProfilePage(),
              settings: state,
            ),
          ),
        ],
      ),

      // Error/404 Route
      GoRoute(
        path: notFound,
        name: 'not-found',
        builder: (context, state) => ErrorPage(
          error: 'Seite nicht gefunden',
          message: 'Die angeforderte Seite konnte nicht gefunden werden.',
        ),
      ),
    ],
    
    // Global Error Handler
    errorBuilder: (context, state) => ErrorPage(
      error: 'Navigation Error',
      message: state.error.toString(),
    ),
    
    // Redirect Logic
    redirect: (context, state) {
      // Add any authentication or initialization checks here
      return null; // No redirect needed
    },
  );

  /// Builds page with custom transitions
  static Page<dynamic> _buildPageWithTransition({
    required Widget child,
    required GoRouterState settings,
    TransitionType transitionType = TransitionType.slide,
    Duration duration = const Duration(milliseconds: 300),
  }) {
    return CustomTransitionPage<void>(
      key: settings.pageKey,
      child: child,
      transitionType: transitionType,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
    );
  }

  /// Mock story getter for demo purposes
  static Story _getMockStory(String id) {
    // Import the Story entity
    // This would normally fetch from a repository
    return Story.mock(id: id);
  }
}

/// Custom transition types
enum TransitionType {
  slide,
  slideUp,
  fade,
  scale,
  rotation,
}

/// Custom transition page implementation
class CustomTransitionPage<T> extends Page<T> {
  const CustomTransitionPage({
    required this.child,
    this.transitionType = TransitionType.slide,
    this.transitionDuration = const Duration(milliseconds: 300),
    this.reverseTransitionDuration = const Duration(milliseconds: 300),
    super.key,
    super.name,
    super.arguments,
    super.restorationId,
  });

  final Widget child;
  final TransitionType transitionType;
  final Duration transitionDuration;
  final Duration reverseTransitionDuration;

  @override
  Route<T> createRoute(BuildContext context) {
    return PageRouteBuilder<T>(
      settings: this,
      pageBuilder: (context, animation, _) => child,
      transitionDuration: transitionDuration,
      reverseTransitionDuration: reverseTransitionDuration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return _buildTransition(
          context: context,
          animation: animation,
          secondaryAnimation: secondaryAnimation,
          child: child,
        );
      },
    );
  }

  Widget _buildTransition({
    required BuildContext context,
    required Animation<double> animation,
    required Animation<double> secondaryAnimation,
    required Widget child,
  }) {
    switch (transitionType) {
      case TransitionType.slide:
        return SlideTransition(
          position: animation.drive(
            Tween(begin: const Offset(1.0, 0.0), end: Offset.zero)
                .chain(CurveTween(curve: Curves.easeInOut)),
          ),
          child: child,
        );

      case TransitionType.slideUp:
        return SlideTransition(
          position: animation.drive(
            Tween(begin: const Offset(0.0, 1.0), end: Offset.zero)
                .chain(CurveTween(curve: Curves.easeInOut)),
          ),
          child: child,
        );

      case TransitionType.fade:
        return FadeTransition(
          opacity: animation.drive(
            Tween(begin: 0.0, end: 1.0)
                .chain(CurveTween(curve: Curves.easeInOut)),
          ),
          child: child,
        );

      case TransitionType.scale:
        return ScaleTransition(
          scale: animation.drive(
            Tween(begin: 0.8, end: 1.0)
                .chain(CurveTween(curve: Curves.elasticOut)),
          ),
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );

      case TransitionType.rotation:
        return RotationTransition(
          turns: animation.drive(
            Tween(begin: 0.8, end: 1.0)
                .chain(CurveTween(curve: Curves.elasticOut)),
          ),
          child: ScaleTransition(
            scale: animation,
            child: child,
          ),
        );
    }
  }
}

/// Router Extensions for easier navigation
extension AppRouterExtensions on BuildContext {
  /// Navigate to home
  void goHome() => go(AppRouter.home);
  
  /// Navigate to characters
  void goCharacters() => go(AppRouter.characters);
  
  /// Navigate to character detail
  void goCharacterDetail(String characterId) => 
      go('/characters/$characterId');
  
  /// Navigate to create character
  void goCreateCharacter() => go(AppRouter.createCharacter);
  
  /// Navigate to create avatar
  void goCreateAvatar() => go(AppRouter.createAvatar);
  
  /// Navigate to stories
  void goStories() => go(AppRouter.stories);
  
  /// Navigate to story detail
  void goStoryDetail(String storyId) => go('/stories/$storyId');
  
  /// Navigate to create story
  void goCreateStory() => go(AppRouter.createStory);
  
  /// Navigate to read story
  void goReadStory(String storyId) => go('/stories/$storyId/read');
  
  /// Navigate to learning
  void goLearning() => go(AppRouter.learning);
  
  /// Navigate to community
  void goCommunity() => go(AppRouter.community);
  
  /// Navigate to profile
  void goProfile() => go(AppRouter.profile);
  
  /// Safe back navigation
  void safeBack() {
    if (canPop()) {
      pop();
    } else {
      goHome();
    }
  }
}

/// Route Information Provider for current route tracking
class RouteInformation {
  static String getCurrentRouteName(BuildContext context) {
    final router = GoRouter.of(context);
    final routeInformation = router.routeInformationProvider.value;
    return routeInformation.uri.path;
  }
  
  static bool isCurrentRoute(BuildContext context, String routePath) {
    return getCurrentRouteName(context) == routePath;
  }
  
  static bool isInSection(BuildContext context, String sectionPath) {
    return getCurrentRouteName(context).startsWith(sectionPath);
  }
}

/// Route Guards for authentication and permissions
class RouteGuards {
  static String? authGuard(BuildContext context, GoRouterState state) {
    // Add authentication logic here
    // Return redirect path or null to continue
    return null;
  }
  
  static String? permissionGuard(BuildContext context, GoRouterState state) {
    // Add permission checks here
    // Return redirect path or null to continue
    return null;
  }
}

/// Deep Link Handler
class DeepLinkHandler {
  static void handleDeepLink(String link) {
    // Parse and handle deep links
    // Example: avatales://story/123
    if (link.startsWith('avatales://')) {
      final uri = Uri.parse(link);
      final path = uri.path;
      
      // Navigate based on deep link
      // This would be called from main.dart or platform channels
    }
  }
}

/// Analytics Helper for route tracking
class RouteAnalytics {
  static void trackPageView(String routeName) {
    // Track page views for analytics
    // Example: Firebase Analytics, Amplitude, etc.
    debugPrint('Page View: $routeName');
  }
  
  static void trackNavigation(String from, String to) {
    // Track navigation patterns
    debugPrint('Navigation: $from -> $to');
  }
}

// Import für Story Entity (würde normalerweise am Anfang stehen)
