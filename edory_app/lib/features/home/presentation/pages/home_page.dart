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

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  @override
  void initState() {
    super.initState();
    // Load initial data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(charactersProvider.notifier).loadCharacters();
    });
  }

  @override
  Widget build(BuildContext context) {
    final charactersState = ref.watch(charactersProvider);
    final timeOfDay = _getTimeOfDay();

    return AppScaffold(
      title: timeOfDay.greeting,
      subtitle: 'Zeit für ein neues Abenteuer',
      actions: [
        Container(
          width: 60,
          height: 60,
          margin: const EdgeInsets.only(right: 20),
          decoration: BoxDecoration(
            gradient: ModernDesignSystem.primaryGradient,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: Colors.white.withOpacity(0.8),
              width: 3,
            ),
            boxShadow: [
              BoxShadow(
                color: ModernDesignSystem.systemBlue.withOpacity(0.25),
                blurRadius: 32,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Center(
            child: Text(
              '👨‍👩‍👧',
              style: TextStyle(fontSize: 24),
            ),
          ),
        ),
      ],
      body: RefreshIndicator(
        onRefresh: () => ref.read(charactersProvider.notifier).loadCharacters(),
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Column(
                children: [
                  const SizedBox(height: 150), // Account for app bar
                  
                  // Hero Card
                  HeroCard(
                    title: 'Erschaffe magische Welten',
                    subtitle: 'Personalisierte KI-Geschichten mit persistenten Charakteren und intelligentem Lernmodus',
                    buttonText: 'Neue Geschichte erstellen',
                    onPressed: () => context.go('/stories/create'),
                  ),

                  // Weekly Progress Stats
                  _buildWeeklyProgress(),

                  const SizedBox(height: 24),
                  
                  // Section Header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            'Deine Charaktersammlung',
                            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                              color: ModernDesignSystem.textPrimary,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () => context.go('/characters'),
                          child: Text(
                            'Alle anzeigen',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: ModernDesignSystem.systemBlue,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Characters Grid
            charactersState.when(
              data: (characters) => _buildCharactersList(characters),
              loading: () => _buildLoadingCharacters(),
              error: (error, _) => _buildErrorCharacters(),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyProgress() {
    return GradientCard(
      animationDelay: 200.ms,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('📈', style: TextStyle(fontSize: 24)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Wöchentliche Erfolge',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: ModernDesignSystem.textPrimary,
                      ),
                    ),
                    Text(
                      'Deine Lernreise im Überblick',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: ModernDesignSystem.secondaryLabel,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildProgressBar('Neue Wörter gelernt', 47, 60, ModernDesignSystem.primaryGradient),
          const SizedBox(height: 16),
          _buildProgressBar('Geschichten abgeschlossen', 23, 30, ModernDesignSystem.redGradient),
          const SizedBox(height: 16),
          _buildProgressBar('Charakterentwicklung', 28, 40, ModernDesignSystem.greenGradient),
        ],
      ),
    );
  }

  Widget _buildProgressBar(String label, int current, int target, LinearGradient gradient) {
    final progress = (current / target).clamp(0.0, 1.0);
    
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: ModernDesignSystem.secondaryLabel,
              ),
            ),
            Text(
              '$current/$target',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: gradient.colors.first,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 8,
          decoration: BoxDecoration(
            color: gradient.colors.first.withOpacity(0.1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.transparent,
              valueColor: AlwaysStoppedAnimation(gradient.colors.first),
              minHeight: 8,
            ),
          ),
        )
            .animate()
            .scaleX(begin: 0, duration: 1000.ms, delay: 500.ms),
      ],
    );
  }

  Widget _buildCharactersList(List<dynamic> characters) {
    final displayCharacters = characters.take(4).toList();
    
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
            if (index < displayCharacters.length) {
              return CharacterCard(
                character: displayCharacters[index],
                onTap: () => context.go('/characters/${displayCharacters[index].id}'),
              );
            } else {
              return _buildViewAllCard();
            }
          },
          childCount: displayCharacters.length + (displayCharacters.length < 4 ? 1 : 0),
        ),
      ),
    );
  }

  Widget _buildViewAllCard() {
    return GestureDetector(
      onTap: () => context.go('/characters'),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              ModernDesignSystem.secondaryLabel.withOpacity(0.1),
              ModernDesignSystem.secondaryLabel.withOpacity(0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: ModernDesignSystem.secondaryLabel.withOpacity(0.2),
            width: 2,
            strokeAlign: BorderSide.strokeAlignInside,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.grid_view,
              size: 40,
              color: ModernDesignSystem.secondaryLabel,
            ),
            const SizedBox(height: 16),
            Text(
              'Alle Charaktere anzeigen',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: ModernDesignSystem.secondaryLabel,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingCharacters() {
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
            child: const Center(child: CircularProgressIndicator()),
          ),
          childCount: 4,
        ),
      ),
    );
  }

  Widget _buildErrorCharacters() {
    return SliverToBoxAdapter(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Text(
            'Fehler beim Laden der Charaktere',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: ModernDesignSystem.secondaryLabel,
            ),
          ),
        ),
      ),
    );
  }

  TimeOfDayInfo _getTimeOfDay() {
    final hour = DateTime.now().hour;
    
    if (hour < 12) {
      return TimeOfDayInfo('Guten Morgen', '🌅');
    } else if (hour < 17) {
      return TimeOfDayInfo('Guten Tag', '☀️');
    } else {
      return TimeOfDayInfo('Guten Abend', '🌙');
    }
  }
}

class TimeOfDayInfo {
  const TimeOfDayInfo(this.greeting, this.emoji);
  
  final String greeting;
  final String emoji;
}
