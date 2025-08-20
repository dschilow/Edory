// lib/features/characters/presentation/pages/characters_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/modern_design_system.dart';
import '../../../../shared/presentation/widgets/app_scaffold.dart';

import '../../../../shared/presentation/widgets/stats_row.dart';
import '../providers/characters_provider.dart';
import '../widgets/character_card.dart';

class CharactersPage extends ConsumerStatefulWidget {
  const CharactersPage({super.key});

  @override
  ConsumerState<CharactersPage> createState() => _CharactersPageState();
}

class _CharactersPageState extends ConsumerState<CharactersPage> {
  @override
  void initState() {
    super.initState();
    // Load characters when page initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(charactersProvider.notifier).loadCharacters();
    });
  }

  @override
  Widget build(BuildContext context) {
    final charactersState = ref.watch(charactersProvider);

    return AppScaffold(
      title: 'Charaktere',
      subtitle: 'Deine digitalen Helden verwalten',
      body: RefreshIndicator(
        onRefresh: () => ref.read(charactersProvider.notifier).loadCharacters(),
        child: CustomScrollView(
          slivers: [
            // Stats Overview
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: _buildStatsOverview()
                    .animate()
                    .fadeIn(duration: 600.ms)
                    .slideY(begin: 0.2, duration: 600.ms),
              ),
            ),

            // Characters Grid
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Aktive Charaktere',
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        color: ModernDesignSystem.primaryTextColor,
                      ),
                    ),
                    IconButton(
                      onPressed: () => context.go('/characters/create'),
                      icon: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          gradient: ModernDesignSystem.primaryGradient,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: ModernDesignSystem.primaryGradient.colors.first.withOpacity(0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.add,
                          color: ModernDesignSystem.whiteTextColor,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 16)),

            // Characters List
            charactersState.when(
              data: (characters) => _buildCharactersList(characters),
              loading: () => _buildLoadingState(),
              error: (error, stack) => _buildErrorState(error.toString()),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsOverview() {
    final charactersState = ref.watch(charactersProvider);
    
    return charactersState.when(
      data: (characters) {
        final totalStories = characters.fold<int>(0, (sum, char) => sum + char.experienceCount);
        final totalLevels = characters.fold<int>(0, (sum, char) => sum + char.level);
        final totalTraitPoints = characters.fold<int>(0, (sum, char) => sum + char.traits.averageValue.round());

        return StatsRow(
          stats: [
            StatData(
              icon: '🔥',
              value: totalStories.toString(),
              label: 'Geschichten gesamt',
              gradient: ModernDesignSystem.redGradient,
            ),
            StatData(
              icon: '⚡',
              value: totalTraitPoints.toString(),
              label: 'Eigenschaftspunkte',
              gradient: ModernDesignSystem.primaryGradient,
            ),
            StatData(
              icon: '🎯',
              value: totalLevels.toString(),
              label: 'Level gesamt',
              gradient: ModernDesignSystem.greenGradient,
            ),
          ],
        );
      },
      loading: () => const StatsRow(stats: []),
      error: (_, __) => const StatsRow(stats: []),
    );
  }

  Widget _buildCharactersList(List<dynamic> characters) {
    if (characters.isEmpty) {
      return SliverToBoxAdapter(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(40),
            child: Column(
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const Icon(
                    Icons.person_add,
                    size: 60,
                    color: ModernDesignSystem.secondaryTextColor,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Noch keine Charaktere',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: ModernDesignSystem.primaryTextColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Erstelle deinen ersten Charakter und beginne dein Abenteuer!',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: ModernDesignSystem.secondaryTextColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => context.go('/characters/create'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ModernDesignSystem.primaryGradient.colors.first,
                    foregroundColor: ModernDesignSystem.whiteTextColor,
                  ),
                  child: const Text('Ersten Charakter erstellen'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.8,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            if (index < characters.length) {
              final character = characters[index];
              return CharacterCard(
                character: character,
                onTap: () => context.go('/characters/${character.id}'),
              );
            } else {
              // Add Character Card
              return _buildAddCharacterCard();
            }
          },
          childCount: characters.length + 1,
        ),
      ),
    );
  }

  Widget _buildAddCharacterCard() {
    return GestureDetector(
      onTap: () => context.go('/characters/create'),
      child: Container(
        decoration: BoxDecoration(
          gradient: ModernDesignSystem.orangeGradient,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: ModernDesignSystem.orangeGradient.colors.first.withOpacity(0.6),
            width: 3,
            strokeAlign: BorderSide.strokeAlignInside,
          ),
          boxShadow: [
            BoxShadow(
              color: ModernDesignSystem.orangeGradient.colors.first.withOpacity(0.3),
              blurRadius: 32,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.6),
                    width: 3,
                    strokeAlign: BorderSide.strokeAlignInside,
                  ),
                ),
                child: const Icon(
                  Icons.add,
                  size: 40,
                  color: ModernDesignSystem.whiteTextColor,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Neuen Charakter erschaffen',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: ModernDesignSystem.whiteTextColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Text(
                'Unbegrenzte Möglichkeiten',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: ModernDesignSystem.whiteTextColor.withOpacity(0.9),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 600.ms, delay: 200.ms)
        .slideY(begin: 0.2, duration: 600.ms, delay: 200.ms)
        .then()
        .shimmer(delay: 2000.ms, duration: 2000.ms);
  }

  Widget _buildLoadingState() {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.8,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) => Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.05),
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
          childCount: 4,
        ),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return SliverToBoxAdapter(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            children: [
              const Icon(
                Icons.error_outline,
                size: 80,
                color: ModernDesignSystem.pastelRed,
              ),
              const SizedBox(height: 24),
              Text(
                'Fehler beim Laden',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: ModernDesignSystem.primaryTextColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                error,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: ModernDesignSystem.secondaryTextColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => ref.read(charactersProvider.notifier).loadCharacters(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: ModernDesignSystem.primaryGradient.colors.first,
                  foregroundColor: ModernDesignSystem.whiteTextColor,
                ),
                child: const Text('Erneut versuchen'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
