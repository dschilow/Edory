// lib/core/router/app_router.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/characters/presentation/pages/characters_page.dart';
import '../../features/characters/presentation/pages/character_detail_page.dart';
import '../../features/characters/presentation/pages/create_character_page.dart';
import '../../features/stories/presentation/pages/stories_page.dart';
import '../../features/stories/presentation/pages/story_detail_page.dart';
import '../../features/stories/presentation/pages/create_story_page.dart';
import '../../features/learning/presentation/pages/learning_page.dart';
import '../../features/learning/presentation/pages/learning_objective_detail_page.dart';
import '../../features/community/presentation/pages/community_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../shared/presentation/pages/main_wrapper.dart';
import '../../shared/presentation/pages/splash_page.dart';

class AppRouter {
  static const String splash = '/';
  static const String home = '/home';
  static const String characters = '/characters';
  static const String characterDetail = '/characters/:id';
  static const String createCharacter = '/characters/create';
  static const String stories = '/stories';
  static const String storyDetail = '/stories/:id';
  static const String createStory = '/stories/create';
  static const String learning = '/learning';
  static const String learningObjectiveDetail = '/learning/:id';
  static const String community = '/community';
  static const String profile = '/profile';

  static final GoRouter router = GoRouter(
    initialLocation: splash,
    routes: [
      GoRoute(
        path: splash,
        name: 'splash',
        builder: (context, state) => const SplashPage(),
      ),
      ShellRoute(
        builder: (context, state, child) {
          return MainWrapper(currentPath: state.uri.toString(), child: child);
        },
        routes: [
          GoRoute(
            path: home,
            name: 'home',
            builder: (context, state) => const HomePage(),
          ),
          GoRoute(
            path: characters,
            name: 'characters',
            builder: (context, state) => const CharactersPage(),
            routes: [
              GoRoute(
                path: 'create',
                name: 'createCharacter',
                builder: (context, state) => const CreateCharacterPage(),
              ),
              GoRoute(
                path: ':id',
                name: 'characterDetail',
                builder: (context, state) => CharacterDetailPage(
                  characterId: state.pathParameters['id']!,
                ),
              ),
            ],
          ),
          GoRoute(
            path: stories,
            name: 'stories',
            builder: (context, state) => const StoriesPage(),
            routes: [
              GoRoute(
                path: 'create',
                name: 'createStory',
                builder: (context, state) => const CreateStoryPage(),
              ),
              GoRoute(
                path: ':id',
                name: 'storyDetail',
                builder: (context, state) => StoryDetailPage(
                  storyId: state.pathParameters['id']!,
                ),
              ),
            ],
          ),
          GoRoute(
            path: learning,
            name: 'learning',
            builder: (context, state) => const LearningPage(),
            routes: [
              GoRoute(
                path: ':id',
                name: 'learningObjectiveDetail',
                builder: (context, state) => LearningObjectiveDetailPage(
                  objectiveId: state.pathParameters['id']!,
                ),
              ),
            ],
          ),
          GoRoute(
            path: community,
            name: 'community',
            builder: (context, state) => const CommunityPage(),
          ),
          GoRoute(
            path: profile,
            name: 'profile',
            builder: (context, state) => const ProfilePage(),
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'Seite nicht gefunden',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              state.error?.toString() ?? 'Unbekannter Fehler',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go(home),
              child: const Text('Zur Startseite'),
            ),
          ],
        ),
      ),
    ),
  );
}
