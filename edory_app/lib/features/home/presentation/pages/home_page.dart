// lib/features/home/presentation/pages/home_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/modern_design_system.dart';
import '../../../../shared/presentation/widgets/app_scaffold.dart';
import '../../../characters/presentation/providers/characters_provider.dart';
import '../../../characters/presentation/widgets/character_card.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> 
    with TickerProviderStateMixin {
  
  late AnimationController _greetingController;
  late AnimationController _cardController;
  late AnimationController _floatingController;

  @override
  void initState() {
    super.initState();
    
    _greetingController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _cardController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _floatingController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    
    _greetingController.forward();
    _cardController.forward();
    _floatingController.repeat(reverse: true);
    
    // Load initial data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(charactersProvider.notifier).loadCharacters();
    });
  }

  @override
  void dispose() {
    _greetingController.dispose();
    _cardController.dispose();
    _floatingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final charactersState = ref.watch(charactersProvider);
    final timeOfDay = _getTimeOfDay();

    return AppScaffold(
      title: timeOfDay.greeting,
      subtitle: 'Wollen wir weiterträumen?',
      actions: [
        Container(
          width: 60,
          height: 60,
          margin: const EdgeInsets.only(right: 20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF6E77FF), Color(0xFF8EE2D2)],
            ),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: Colors.white.withOpacity(0.8),
              width: 3,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF6E77FF).withOpacity(0.25),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Center(
            child: Text('👦', style: TextStyle(fontSize: 24)),
          ),
        ).animate(controller: _floatingController)
          .moveY(begin: -2, end: 2, curve: Curves.easeInOut),
      ],
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFF6F8FF), // bg from JSON
              Color(0xFFFFFFFF),
            ],
          ),
        ),
        child: RefreshIndicator(
          onRefresh: () => ref.read(charactersProvider.notifier).loadCharacters(),
          child: CustomScrollView(
            slivers: [
              // Hero Section mit Greeting
              SliverToBoxAdapter(
                child: _buildHeroSection(timeOfDay)
                  .animate(controller: _greetingController)
                  .fadeIn(duration: 600.ms)
                  .slideY(begin: 0.3, curve: Curves.easeOutBack),
              ),
              
              // Recent Stories Section
              SliverToBoxAdapter(
                child: _buildRecentStoriesSection()
                  .animate(controller: _cardController)
                  .fadeIn(delay: 200.ms, duration: 500.ms)
                  .slideX(begin: -0.2, curve: Curves.easeOutCubic),
              ),
              
              // My Avatars Section
              SliverToBoxAdapter(
                child: _buildAvatarsSection(charactersState)
                  .animate(controller: _cardController)
                  .fadeIn(delay: 400.ms, duration: 500.ms)
                  .slideX(begin: 0.2, curve: Curves.easeOutCubic),
              ),
              
              // Quick Start Section
              SliverToBoxAdapter(
                child: _buildQuickStartSection()
                  .animate(controller: _cardController)
                  .fadeIn(delay: 600.ms, duration: 500.ms)
                  .slideY(begin: 0.2, curve: Curves.easeOutBack),
              ),
              
              // Bottom padding
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroSection(TimeOfDay timeOfDay) {
    return Container(
      margin: const EdgeInsets.all(24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF6E77FF).withOpacity(0.1),
            const Color(0xFF8EE2D2).withOpacity(0.1),
            const Color(0xFFFF89B3).withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(28), // radius.lg
        border: Border.all(
          color: const Color(0xFF6E77FF).withOpacity(0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6E77FF).withOpacity(0.08),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                timeOfDay.emoji,
                style: const TextStyle(fontSize: 32),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hallo, Mila', // aus sampleData
                      style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    Text(
                      timeOfDay.subtitle,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: const Color(0xFF475569),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Stats Overview
          Row(
            children: [
              _buildStatCard('📚', '3', 'Geschichten'),
              const SizedBox(width: 12),
              _buildStatCard('👥', '2', 'Avatare'),
              const SizedBox(width: 12),
              _buildStatCard('🏆', '5', 'Level'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String emoji, String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.8),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFF6E77FF).withOpacity(0.1),
          ),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF475569),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentStoriesSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Letzte Geschichten',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
              TextButton(
                onPressed: () => context.go('/stories'),
                child: const Text(
                  'Alle ansehen',
                  style: TextStyle(
                    color: Color(0xFF6E77FF),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Story Cards (horizontal scroll)
          SizedBox(
            height: 180,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 3, // Mock data
              itemBuilder: (context, index) => _buildStoryCard(index),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStoryCard(int index) {
    final stories = [
      {
        'title': 'Die Wolkenbahn',
        'avatar': 'Luna',
        'progress': 0.6,
        'cover': '🌙',
      },
      {
        'title': 'Der magische Wald',
        'avatar': 'Kiko', 
        'progress': 0.3,
        'cover': '🌲',
      },
      {
        'title': 'Unterwasser-Abenteuer',
        'avatar': 'Luna',
        'progress': 1.0,
        'cover': '🐠',
      },
    ];
    
    final story = stories[index];
    
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cover Image
          Container(
            height: 90,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF6E77FF).withOpacity(0.2),
                  const Color(0xFF8EE2D2).withOpacity(0.2),
                ],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Center(
              child: Text(
                story['cover'] as String,
                style: const TextStyle(fontSize: 40),
              ),
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  story['title'] as String,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0F172A),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  'mit ${story['avatar']}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF475569),
                  ),
                ),
                const SizedBox(height: 8),
                
                // Progress Bar
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    LinearProgressIndicator(
                      value: story['progress'] as double,
                      backgroundColor: const Color(0xFF6E77FF).withOpacity(0.2),
                      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF6E77FF)),
                      minHeight: 4,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${((story['progress'] as double) * 100).toInt()}%',
                      style: const TextStyle(
                        fontSize: 10,
                        color: Color(0xFF475569),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarsSection(AsyncValue<List<dynamic>> charactersState) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Meine Avatare',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
              TextButton(
                onPressed: () => context.go('/characters'),
                child: const Text(
                  'Alle ansehen',
                  style: TextStyle(
                    color: Color(0xFF6E77FF),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          charactersState.when(
            data: (characters) => SizedBox(
              height: 100,
              child: Row(
                children: [
                  // Existing Characters
                  ...characters.take(3).map((character) => 
                    _buildAvatarTile(character)
                  ),
                  
                  // Add New Avatar Button
                  _buildAddAvatarButton(),
                ],
              ),
            ),
            loading: () => const SizedBox(
              height: 120,
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (_, __) => _buildEmptyAvatarsState(),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarTile(dynamic character) {
    return Container(
      width: 88, // AvatarTile size from JSON
      margin: const EdgeInsets.only(right: 16),
      child: Column(
        children: [
          GestureDetector(
            onTap: () => context.go('/characters/${character.id}'),
            child: Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(44),
                border: Border.all(
                  color: const Color(0xFF6E77FF).withOpacity(0.2),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6E77FF).withOpacity(0.18),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  character.displayName?.substring(0, 1).toUpperCase() ?? '?',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF6E77FF),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            character.displayName ?? 'Unbekannt',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF0F172A),
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            'Level ${character.traits?.courage ?? 1}',
            style: const TextStyle(
              fontSize: 10,
              color: Color(0xFF475569),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddAvatarButton() {
    return GestureDetector(
      onTap: () => context.go('/characters/create'),
      child: Container(
        width: 88,
        height: 88,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF6E77FF).withOpacity(0.1),
              const Color(0xFF8EE2D2).withOpacity(0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(44),
          border: Border.all(
            color: const Color(0xFF6E77FF).withOpacity(0.3),
            width: 2,
            strokeAlign: BorderSide.strokeAlignInside,
          ),
        ),
        child: const Center(
          child: Icon(
            Icons.add_rounded,
            size: 32,
            color: Color(0xFF6E77FF),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyAvatarsState() {
    return Container(
      height: 120,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF6E77FF).withOpacity(0.2),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('☁️', style: TextStyle(fontSize: 32)),
          const SizedBox(height: 8),
          const Text(
            'Noch keine Avatare',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF0F172A),
            ),
          ),
          TextButton(
            onPressed: () => context.go('/characters/create'),
            child: const Text(
              'Ersten Avatar erstellen',
              style: TextStyle(
                color: Color(0xFF6E77FF),
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStartSection() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Schnellstart',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: _buildQuickActionButton(
                  icon: '✨',
                  label: 'Neue Geschichte',
                  color: const Color(0xFF6E77FF),
                  onTap: () => context.go('/stories/create'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildQuickActionButton(
                  icon: '🎓',
                  label: 'Lernmodus',
                  color: const Color(0xFF8EE2D2),
                  onTap: () => context.go('/learning'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton({
    required String icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: color.withOpacity(0.2),
          ),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Center(
                child: Text(
                  icon,
                  style: const TextStyle(fontSize: 24),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  TimeOfDay _getTimeOfDay() {
    final hour = DateTime.now().hour;
    
    if (hour < 12) {
      return TimeOfDay(
        greeting: 'Guten Morgen',
        subtitle: 'Bereit für ein neues Abenteuer?',
        emoji: '🌅',
      );
    } else if (hour < 18) {
      return TimeOfDay(
        greeting: 'Guten Tag', 
        subtitle: 'Lass uns weiterträumen!',
        emoji: '☀️',
      );
    } else {
      return TimeOfDay(
        greeting: 'Guten Abend',
        subtitle: 'Zeit für eine Gute-Nacht-Geschichte?',
        emoji: '🌙',
      );
    }
  }
}

class TimeOfDay {
  final String greeting;
  final String subtitle;
  final String emoji;

  TimeOfDay({
    required this.greeting,
    required this.subtitle,
    required this.emoji,
  });
}