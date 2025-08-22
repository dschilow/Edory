// lib/features/home/presentation/pages/home_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/modern_design_system.dart';
import '../../../../shared/presentation/widgets/app_scaffold.dart';
import '../../../../shared/presentation/widgets/gradient_card.dart';
import '../../../../shared/presentation/widgets/stats_row.dart';
import '../../../characters/presentation/providers/characters_provider.dart';
import '../../../characters/presentation/widgets/character_card.dart';
import '../../../characters/presentation/widgets/hero_card.dart' as character_hero;
import '../../../../shared/presentation/widgets/recent_stories_card.dart';
import '../../../../shared/presentation/widgets/daily_challenge_card.dart';
import '../../../stories/domain/entities/story.dart';

/// Hauptseite der Avatales App
/// Bietet Übersicht über Charaktere, Geschichten und tägliche Aktivitäten
class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage>
    with TickerProviderStateMixin {
  
  late AnimationController _animationController;
  late AnimationController _greetingController;
  late AnimationController _pulseController;
  
  final ScrollController _scrollController = ScrollController();
  
  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _greetingController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    
    _startAnimations();
    _loadInitialData();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _greetingController.dispose();
    _pulseController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _startAnimations() {
    _greetingController.forward();
    _animationController.forward();
    _pulseController.repeat();
  }

  void _loadInitialData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(charactersProvider.notifier).loadCharacters();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: _getGreeting(),
      subtitle: 'Wollen wir weiterträumen?',
      showBackButton: false,
      actions: [
        _buildNotificationButton(),
        _buildProfileButton(),
      ],
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: CustomScrollView(
          controller: _scrollController,
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Greeting and Hero Section
            SliverToBoxAdapter(
              child: _buildHeroSection()
                  .animate(controller: _greetingController)
                  .slideY(begin: -0.3, duration: 600.ms)
                  .fadeIn(),
            ),
            
            // Stats Overview
            SliverToBoxAdapter(
              child: _buildStatsSection()
                  .animate(controller: _animationController)
                  .slideY(begin: 0.3, duration: 600.ms, delay: 200.ms)
                  .fadeIn(),
            ),
            
            // Characters Preview
            SliverToBoxAdapter(
              child: _buildCharactersSection()
                  .animate(controller: _animationController)
                  .slideX(begin: -0.3, duration: 600.ms, delay: 400.ms)
                  .fadeIn(),
            ),
            
            // Recent Stories
            SliverToBoxAdapter(
              child: _buildRecentStoriesSection()
                  .animate(controller: _animationController)
                  .slideX(begin: 0.3, duration: 600.ms, delay: 600.ms)
                  .fadeIn(),
            ),
            
            // Daily Challenge
            SliverToBoxAdapter(
              child: _buildDailyChallengeSection()
                  .animate(controller: _animationController)
                  .slideY(begin: 0.3, duration: 600.ms, delay: 800.ms)
                  .fadeIn(),
            ),
            
            // Bottom spacing
            const SliverToBoxAdapter(
              child: SizedBox(height: 100),
            ),
          ],
        ),
      ),
      floatingActionButton: _buildQuickActionFAB(),
    );
  }

  Widget _buildNotificationButton() {
    return Stack(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.black.withOpacity(0.08)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () {
                // TODO: Show notifications
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Benachrichtigungen werden implementiert...'),
                  ),
                );
              },
              child: Icon(
                Icons.notifications_outlined,
                size: 20,
                color: ModernDesignSystem.primaryTextColor,
              ),
            ),
          ),
        ),
        
        // Notification badge
        Positioned(
          top: 8,
          right: 8,
          child: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: ModernDesignSystem.pastelRed,
              shape: BoxShape.circle,
            ),
          )
              .animate(controller: _pulseController)
              .scale(begin: Offset(0.8, 0.8), end: Offset(1.2, 1.2), duration: 1000.ms)
              .then()
              .scale(begin: Offset(1.2, 1.2), end: Offset(0.8, 0.8), duration: 1000.ms),
        ),
      ],
    );
  }

  Widget _buildProfileButton() {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        gradient: ModernDesignSystem.primaryGradient,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: ModernDesignSystem.primaryColor.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => context.go('/profile'),
          child: const Icon(
            Icons.person_outline,
            size: 20,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildHeroSection() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        children: [
          // Main CTA Card
          character_hero.HeroCard(
            title: 'Hallo, Mila!',
            subtitle: 'Bereit für ein neues Abenteuer?',
            buttonText: 'Neue Geschichte erstellen',
            onPressed: () => context.go('/stories/create'),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroIllustration() {
    return Stack(
      children: [
        // Background shapes
        Positioned(
          top: 20,
          right: 20,
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
          )
              .animate(controller: _pulseController)
              .scale(begin: Offset(0.8, 0.8), end: Offset(1.2, 1.2), duration: 2000.ms)
              .then()
              .scale(begin: Offset(1.2, 1.2), end: Offset(0.8, 0.8), duration: 2000.ms),
        ),
        
        Positioned(
          bottom: 30,
          left: 30,
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
          )
              .animate(controller: _pulseController)
              .scale(begin: Offset(1.0, 1.0), end: Offset(1.3, 1.3), duration: 2000.ms, delay: 500.ms)
              .then()
              .scale(begin: Offset(1.3, 1.3), end: Offset(1.0, 1.0), duration: 2000.ms),
        ),
        
        // Main illustration
        Center(
          child: Icon(
            Icons.auto_stories,
            size: 80,
            color: Colors.white.withOpacity(0.9),
          )
              .animate(controller: _animationController)
              .scale(duration: 800.ms, curve: Curves.elasticOut),
        ),
      ],
    );
  }

  Widget _buildStatsSection() {
    final charactersState = ref.watch(charactersProvider);
    
    return Container(
      margin: const EdgeInsets.all(20),
      child: charactersState.when(
        data: (characters) => StatsRow(
          stats: [
            StatData(
              icon: '📚',
              value: _getStoriesCount().toString(),
              label: 'Geschichten',
              gradient: ModernDesignSystem.redGradient,
            ),
            StatData(
              icon: '👥',
              value: characters.length.toString(),
              label: 'Avatare',
              gradient: ModernDesignSystem.primaryGradient,
            ),
            StatData(
              icon: '🏆',
              value: _getTotalLevel(characters).toString(),
              label: 'Level',
              gradient: ModernDesignSystem.greenGradient,
            ),
          ],
        ),
        loading: () => _buildStatsLoading(),
        error: (_, __) => _buildStatsLoading(),
      ),
    );
  }

  Widget _buildStatsLoading() {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildCharactersSection() {
    final charactersState = ref.watch(charactersProvider);
    
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 0, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Meine Avatare',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                TextButton(
                  onPressed: () => context.go('/characters'),
                  child: Text(
                    'Alle ansehen',
                    style: TextStyle(
                      color: ModernDesignSystem.primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          
          SizedBox(
            height: 200,
            child: charactersState.when(
              data: (characters) => _buildCharactersList(characters),
              loading: () => _buildCharactersLoading(),
              error: (_, __) => _buildCharactersError(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCharactersList(List characters) {
    if (characters.isEmpty) {
      return _buildCreateFirstCharacter();
    }
    
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: characters.length + 1,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemBuilder: (context, index) {
        if (index == characters.length) {
          return _buildAddCharacterCard();
        }
        
        final character = characters[index];
        return Container(
          width: 160,
          margin: const EdgeInsets.only(right: 16),
          child: CharacterCard(
            character: character,
            onTap: () => context.go('/characters/${character.id}'),
            isSelectable: false,
          )
              .animate(delay: (index * 100).ms)
              .slideX(begin: 0.3, duration: 600.ms)
              .fadeIn(),
        );
      },
    );
  }

  Widget _buildCharactersLoading() {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: 3,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemBuilder: (context, index) => Container(
        width: 160,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }

  Widget _buildCharactersError() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              color: Colors.red.shade400,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              'Fehler beim Laden',
              style: TextStyle(
                color: Colors.red.shade700,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCreateFirstCharacter() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: GradientCard(
        gradient: LinearGradient(
          colors: [
            ModernDesignSystem.primaryColor.withOpacity(0.1),
            ModernDesignSystem.primaryColor.withOpacity(0.05),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person_add_rounded,
              size: 48,
              color: ModernDesignSystem.primaryColor,
            ),
            const SizedBox(height: 12),
            Text(
              'Erstelle deinen ersten Avatar',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: ModernDesignSystem.primaryColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Beginne dein Abenteuer mit einem digitalen Helden',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: ModernDesignSystem.secondaryTextColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go('/characters/create'),
              style: ElevatedButton.styleFrom(
                backgroundColor: ModernDesignSystem.primaryColor,
                foregroundColor: Colors.white,
              ),
              child: const Text('Avatar erstellen'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddCharacterCard() {
    return Container(
      width: 120,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: ModernDesignSystem.primaryColor.withOpacity(0.3),
          width: 2,
          style: BorderStyle.solid,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => context.go('/characters/create'),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: ModernDesignSystem.primaryGradient,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.add,
                  size: 24,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Neuer\nAvatar',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: ModernDesignSystem.primaryColor,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentStoriesSection() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Letzte Geschichten',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              TextButton(
                onPressed: () => context.go('/stories'),
                child: Text(
                  'Alle ansehen',
                  style: TextStyle(
                    color: ModernDesignSystem.primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
  RecentStoriesCard(
    stories: _getRecentStories(),
    onStoryTap: (story) => context.go('/stories/${story.id}/read'),
    onCreateStoryTap: () => context.go('/stories/create'),
  ),
],
      ),
    );
  }

  Widget _buildDailyChallengeSection() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tägliche Herausforderung',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          
          DailyChallengeCard(
            title: 'Kreative Geschichtsidee',
            description: 'Erstelle eine Geschichte über Freundschaft zwischen zwei ungewöhnlichen Charakteren.',
            progress: 0.3,
            reward: '50 XP + Spezial-Avatar',
            onStartTap: () => context.go('/stories/create'),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionFAB() {
    return FloatingActionButton.extended(
      onPressed: () => context.go('/stories/create'),
      backgroundColor: ModernDesignSystem.primaryColor,
      icon: const Icon(Icons.auto_awesome, color: Colors.white),
      label: const Text(
        'Geschichte erstellen',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // Helper Methods
  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Guten Morgen';
    if (hour < 17) return 'Guten Tag';
    if (hour < 22) return 'Guten Abend';
    return 'Gute Nacht';
  }

  int _getStoriesCount() {
    // TODO: Get from stories provider
    return 3;
  }

  int _getTotalLevel(List characters) {
    if (characters.isEmpty) return 0;
    return characters.fold<int>(0, (sum, character) => sum + (character.level as int));
  }

  List<Story> _getRecentStories() {
    // TODO: Get from stories provider
    return [
      Story.mock(
        id: '1',
        title: 'Die Wolkenbahn',
        characterName: 'Luna',
      ),
      Story.mock(
        id: '2',
        title: 'Der magische Wald',
        characterName: 'Kiko',
      ),
    ];
  }

  Future<void> _onRefresh() async {
    await ref.read(charactersProvider.notifier).loadCharacters();
    // TODO: Refresh other data
  }
}