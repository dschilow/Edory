// lib/features/characters/presentation/pages/characters_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/modern_design_system.dart';
import '../../../../shared/presentation/widgets/app_scaffold.dart';
import '../providers/characters_provider.dart';
import '../widgets/character_card.dart';

class CharactersPage extends ConsumerStatefulWidget {
  const CharactersPage({super.key});

  @override
  ConsumerState<CharactersPage> createState() => _CharactersPageState();
}

class _CharactersPageState extends ConsumerState<CharactersPage>
    with TickerProviderStateMixin {
  
  late AnimationController _staggerController;
  String _selectedFilter = 'eigene';
  
  final List<String> _filters = ['eigene', 'geteilte'];

  @override
  void initState() {
    super.initState();
    
    _staggerController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    // Load characters when page initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(charactersProvider.notifier).loadCharacters();
      _staggerController.forward();
    });
  }

  @override
  void dispose() {
    _staggerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final charactersState = ref.watch(charactersProvider);

    return AppScaffold(
      title: 'Avatare',
      subtitle: 'Deine digitalen Helden verwalten',
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 20),
          child: IconButton(
            onPressed: () => context.go('/characters/create'),
            icon: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6E77FF), Color(0xFF4B55E6)],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6E77FF).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.add_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ),
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
              // Filter Tabs
              SliverToBoxAdapter(
                child: _buildFilterTabs()
                  .animate(controller: _staggerController)
                  .fadeIn(duration: 400.ms)
                  .slideX(begin: -0.2, curve: Curves.easeOutCubic),
              ),
              
              // Characters Grid
              charactersState.when(
                data: (characters) => _buildCharactersGrid(characters),
                loading: () => _buildLoadingGrid(),
                error: (_, __) => _buildErrorState(),
              ),
              
              // Bottom padding
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterTabs() {
    return Container(
      margin: const EdgeInsets.all(24),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(40), // radius.xl
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: _filters.map((filter) {
          final isSelected = _selectedFilter == filter;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedFilter = filter),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutCubic,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected 
                    ? const Color(0xFF6E77FF)
                    : Colors.transparent,
                  borderRadius: BorderRadius.circular(36),
                  boxShadow: isSelected ? [
                    BoxShadow(
                      color: const Color(0xFF6E77FF).withOpacity(0.18), // cardGlow
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ] : null,
                ),
                child: Text(
                  filter == 'eigene' ? 'Meine Avatare' : 'Geteilte Avatare',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isSelected 
                      ? Colors.white
                      : const Color(0xFF6E77FF),
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCharactersGrid(List<dynamic> characters) {
    final filteredCharacters = characters; // TODO: Apply filter logic
    
    if (filteredCharacters.isEmpty) {
      return SliverFillRemaining(
        child: _buildEmptyState(),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, // grid2 layout from JSON
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.85,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final character = filteredCharacters[index];
            return _buildCharacterCard(character, index)
              .animate(controller: _staggerController)
              .fadeIn(
                delay: Duration(milliseconds: 100 * index),
                duration: 500.ms,
              )
              .slideY(
                begin: 0.3,
                curve: Curves.easeOutBack,
              );
          },
          childCount: filteredCharacters.length,
        ),
      ),
    );
  }

  Widget _buildCharacterCard(dynamic character, int index) {
    return GestureDetector(
      onTap: () => context.go('/characters/${character.id}'),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20), // radius.md
          border: Border.all(
            color: const Color(0xFF6E77FF).withOpacity(0.1),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08), // elevation.low
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16), // Card padding from JSON
          child: Column(
            children: [
              // Avatar Image (88px wie AvatarTile)
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(44),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFF6E77FF).withOpacity(0.2),
                      const Color(0xFF8EE2D2).withOpacity(0.2),
                      const Color(0xFFFF89B3).withOpacity(0.1),
                    ],
                  ),
                  border: Border.all(
                    color: const Color(0xFF6E77FF).withOpacity(0.2),
                    width: 2,
                  ),
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
              const SizedBox(height: 12),
              
              // Name & Level (footer from AvatarTile)
              Text(
                character.displayName ?? 'Unbekannt',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF0F172A),
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                'Level ${character.traits?.courage ?? 1}',
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF475569),
                ),
              ),
              const SizedBox(height: 12),
              
              // Stat Badges (mut, staerke, angst from JSON)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildStatBadge(
                    '🦁', 
                    character.traits?.courage ?? 50, 
                    const Color(0xFF6E77FF), // mut color
                  ),
                  _buildStatBadge(
                    '💪', 
                    character.traits?.strength ?? 50, 
                    const Color(0xFF8EE2D2), // staerke color
                  ),
                  _buildStatBadge(
                    '❤️', 
                    (100 - (character.traits?.fear ?? 50)).toInt(), 
                    const Color(0xFFFF89B3), // angst color (inverted)
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatBadge(String emoji, int value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(40), // roundedPill shape
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 12)),
          const SizedBox(width: 4),
          Text(
            value.toString(),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingGrid() {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.85,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) => _buildSkeletonCard(),
          childCount: 6, // Show 6 skeleton cards
        ),
      ),
    );
  }

  Widget _buildSkeletonCard() {
    return Container(
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
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Avatar skeleton
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: const Color(0xFF6E77FF).withOpacity(0.1),
                borderRadius: BorderRadius.circular(44),
              ),
            ),
            const SizedBox(height: 12),
            
            // Name skeleton
            Container(
              width: 80,
              height: 16,
              decoration: BoxDecoration(
                color: const Color(0xFF475569).withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(height: 8),
            
            // Level skeleton
            Container(
              width: 50,
              height: 12,
              decoration: BoxDecoration(
                color: const Color(0xFF475569).withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            const SizedBox(height: 12),
            
            // Badges skeleton
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(3, (index) => Container(
                width: 32,
                height: 20,
                decoration: BoxDecoration(
                  color: const Color(0xFF6E77FF).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
              )),
            ),
          ],
        ),
      ),
    ).animate(onPlay: (controller) => controller.repeat())
      .shimmer(duration: 1500.ms, color: Colors.white.withOpacity(0.8));
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Cloud friend illustration
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF6E77FF).withOpacity(0.1),
                  const Color(0xFF8EE2D2).withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(60),
            ),
            child: const Center(
              child: Text('☁️', style: TextStyle(fontSize: 60)),
            ),
          ),
          const SizedBox(height: 24),
          
          const Text(
            'Noch keine Avatare',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _selectedFilter == 'eigene' 
              ? 'Erstelle deinen ersten Avatar und starte dein Abenteuer!'
              : 'Noch keine geteilten Avatare entdeckt.',
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF475569),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          
          // CTA Button
          GestureDetector(
            onTap: () => context.go('/characters/create'),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6E77FF), Color(0xFF4B55E6)],
                ),
                borderRadius: BorderRadius.circular(28), // lg corner
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6E77FF).withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.add_rounded, color: Colors.white, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Neuen Avatar erstellen',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return SliverFillRemaining(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Rain cloud illustration
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF475569).withOpacity(0.1),
                    const Color(0xFF475569).withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(60),
              ),
              child: const Center(
                child: Text('🌧️', style: TextStyle(fontSize: 60)),
              ),
            ),
            const SizedBox(height: 24),
            
            const Text(
              'Fehler beim Laden',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Die Avatare konnten nicht geladen werden.',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF475569),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            
            // Retry Button
            GestureDetector(
              onTap: () => ref.read(charactersProvider.notifier).loadCharacters(),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF6F8FF),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: const Color(0xFF6E77FF).withOpacity(0.3),
                  ),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.refresh_rounded, color: Color(0xFF6E77FF), size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Erneut versuchen',
                      style: TextStyle(
                        color: Color(0xFF6E77FF),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}