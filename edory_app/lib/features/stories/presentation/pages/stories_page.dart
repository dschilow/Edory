// lib/features/stories/presentation/pages/stories_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/modern_design_system.dart';
import '../../../../shared/presentation/widgets/app_scaffold.dart';
import '../../../../shared/presentation/widgets/gradient_card.dart';

class StoriesPage extends StatefulWidget {
  const StoriesPage({super.key});

  @override
  State<StoriesPage> createState() => _StoriesPageState();
}

class _StoriesPageState extends State<StoriesPage> with TickerProviderStateMixin {
  late AnimationController _animationController;
  String _selectedFilter = 'Alle';
  final List<String> _filters = ['Alle', 'Favoriten', 'Kürzlich', 'Abgeschlossen'];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: ModernDesignSystem.durationMedium,
      vsync: this,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Geschichten',
      subtitle: 'Deine Abenteuer-Bibliothek',
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              children: [
                const SizedBox(height: 150), // Account for app bar
                
                // Quick Actions
                _buildQuickActions(),
                
                const SizedBox(height: 24),
                
                // Filter Tabs
                _buildFilterTabs(),
                
                const SizedBox(height: 24),
                
                // Stories Statistics
                _buildStoriesStats(),
                
                const SizedBox(height: 24),
              ],
            ),
          ),
          
          // Stories List
          _buildStoriesList(),
          
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: _buildQuickActionCard(
              '✍️',
              'Neue Geschichte',
              'Erstelle ein magisches Abenteuer',
              () => context.go('/stories/create'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildQuickActionCard(
              '🎲',
              'Zufällige Idee',
              'Lasse dich inspirieren',
              () => _showRandomStoryIdea(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard(String emoji, String title, String subtitle, VoidCallback onTap) {
    return GradientCard(
      animationDelay: 100.ms,
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: onTap,
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 32)),
            const SizedBox(height: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: ModernDesignSystem.primaryTextColor,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: ModernDesignSystem.secondaryTextColor,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterTabs() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: ModernDesignSystem.systemGray6.withOpacity(0.5),
          borderRadius: BorderRadius.circular(ModernDesignSystem.radiusMedium),
        ),
        child: Row(
          children: _filters.map((filter) {
            final isSelected = _selectedFilter == filter;
            return Expanded(
              child: CupertinoButton(
                padding: const EdgeInsets.symmetric(vertical: 8),
                onPressed: () => setState(() => _selectedFilter = filter),
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.white : Colors.transparent,
                    borderRadius: BorderRadius.circular(ModernDesignSystem.radiusSmall),
                    boxShadow: isSelected ? [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ] : null,
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: Text(
                    filter,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: isSelected ? ModernDesignSystem.primaryTextColor : ModernDesignSystem.secondaryTextColor,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildStoriesStats() {
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
                child: Text(
                  'Deine Geschichten-Statistiken',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: ModernDesignSystem.primaryTextColor,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(child: _buildStatItem('12', 'Geschichten\nerstellt')),
              Expanded(child: _buildStatItem('48h', 'Gesamte\nLesezeit')),
              Expanded(child: _buildStatItem('9', 'Charaktere\nverwendet')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ModernDesignSystem.systemGray6.withOpacity(0.3),
        borderRadius: BorderRadius.circular(ModernDesignSystem.radiusSmall),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: ModernDesignSystem.primaryTextColor,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: ModernDesignSystem.secondaryTextColor,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildStoriesList() {
    // Demo Stories
    final stories = [
      _StoryItem('Die Zauberkatze Luna', 'Abenteuer • 8 Min', '🐱', '4.8'),
      _StoryItem('Das fliegende Baumhaus', 'Fantasy • 12 Min', '🏠', '4.9'),
      _StoryItem('Der kleine Drachenfreund', 'Freundschaft • 6 Min', '🐲', '4.7'),
      _StoryItem('Reise zu den Sternen', 'Weltraum • 15 Min', '🚀', '4.6'),
      _StoryItem('Das magische Kochbuch', 'Magie • 10 Min', '📚', '4.8'),
    ];

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final story = stories[index];
          return Container(
            margin: const EdgeInsets.only(left: 20, right: 20, bottom: 12),
            child: GradientCard(
              animationDelay: (300 + index * 100).ms,
              child: CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () => context.go('/stories/${index + 1}'),
                child: Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        gradient: ModernDesignSystem.primaryGradient,
                        borderRadius: BorderRadius.circular(ModernDesignSystem.radiusMedium),
                      ),
                      child: Center(
                        child: Text(story.emoji, style: const TextStyle(fontSize: 24)),
                      ),
                    ),
                    
                    const SizedBox(width: 16),
                    
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            story.title,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: ModernDesignSystem.primaryTextColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            story.subtitle,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: ModernDesignSystem.secondaryTextColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    Column(
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.star_rounded,
                              color: ModernDesignSystem.systemYellow,
                              size: 16,
                            ),
                            Text(
                              story.rating,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: ModernDesignSystem.primaryTextColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Icon(
                          CupertinoIcons.chevron_right,
                          color: ModernDesignSystem.systemGray,
                          size: 16,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
        childCount: stories.length,
      ),
    );
  }

  void _showRandomStoryIdea() {
    final ideas = [
      'Ein Roboter lernt Gefühle kennen',
      'Tiere können plötzlich sprechen',
      'Ein Haus aus Wolken bauen',
      'Freundschaft mit einem Zeitreisenden',
      'Das verschwundene Farbenreich',
    ];
    
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('🎲 Zufällige Idee'),
        content: Text(ideas[DateTime.now().millisecond % ideas.length]),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context),
            child: const Text('Andere Idee'),
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () {
              Navigator.pop(context);
              context.go('/stories/create');
            },
            child: const Text('Geschichte erstellen'),
          ),
        ],
      ),
    );
  }
}

class _StoryItem {
  final String title;
  final String subtitle;
  final String emoji;
  final String rating;

  _StoryItem(this.title, this.subtitle, this.emoji, this.rating);
}
